import 'dart:convert';

import 'package:isar_community/isar.dart';

import '../core/enums.dart';
import '../data/ai/context_builders.dart';
import '../data/ai/dto/receipt_dto.dart';
import '../data/ai/gemini_client.dart';
import '../data/ai/prompt_repository.dart';
import '../data/ai/schemas.dart';
import '../data/isar/collections/schemas.dart';
import '../domain/costing.dart';
import '../domain/fx.dart';
import '../domain/ingredient_matcher.dart';
import '../domain/receipt_math.dart';
import '../domain/validation/receipt_validator.dart';
import '../platform/image_store.dart';
import 'ai_gateway.dart';
import 'clock.dart';
import 'fx_service.dart';

/// A foreign-currency receipt can't be filed until it has an exchange rate.
class MissingExchangeRate implements Exception {
  MissingExchangeRate(this.from, this.to);
  final String from;
  final String to;

  @override
  String toString() => 'Set an exchange rate from $from to $to first';
}

class ScanResult {
  ScanResult(this.job, {this.autoCommitted = false, this.transactionId});
  final ScanJob job;
  final bool autoCommitted;
  final int? transactionId;
}

/// Capture → queue → Prompt A → validate → review/auto-commit → ledger + pantry.
class ScanService {
  ScanService({required this.isar, required this.images, required this.ai, this.fx, Now? now})
    : now = now ?? DateTime.now;

  final Isar isar;
  final ImageStore images;
  final AiGateway ai;

  /// Converts foreign-currency receipts; null disables automatic rates.
  final FxService? fx;
  final Now now;

  static const maxAttempts = 3;
  bool _busy = false;

  Future<int> enqueue(List<String> sourcePaths, {String? hint}) async {
    final t = now();
    final stamp = t.microsecondsSinceEpoch;
    final stored = <String>[];
    for (var i = 0; i < sourcePaths.length; i++) {
      stored.add(await images.importImage(sourcePaths[i], 'scan_${stamp}_$i'));
    }
    final job = ScanJob()
      ..imagePaths = stored
      ..capturedAt = t
      ..userHint = hint
      ..status = ScanStatus.queued;
    return isar.writeTxn(() => isar.scanJobs.put(job));
  }

  /// Processes queued jobs one at a time. Safe to call repeatedly.
  Future<List<ScanResult>> processQueue() async {
    if (_busy) return const [];
    _busy = true;
    final results = <ScanResult>[];
    try {
      // Jobs left in "processing" by a killed app go back to the queue.
      final stuck = await isar.scanJobs.where().statusEqualTo(ScanStatus.processing).findAll();
      if (stuck.isNotEmpty) {
        await isar.writeTxn(() => isar.scanJobs.putAll([for (final j in stuck) j..status = ScanStatus.queued]));
      }
      final queued = await isar.scanJobs.where().statusEqualTo(ScanStatus.queued).sortByCapturedAt().findAll();
      for (final j in queued) {
        final r = await process(j.id);
        if (r == null) break; // no key / offline: stop for now
        results.add(r);
      }
    } finally {
      _busy = false;
    }
    return results;
  }

  /// Returns null when the job stays queued (no key or transient failure).
  Future<ScanResult?> process(int jobId) async {
    final job = await isar.scanJobs.get(jobId);
    if (job == null) return null;
    final runner = await ai.runner();
    if (runner == null) {
      await _save(
        job
          ..status = ScanStatus.queued
          ..lastError = 'Add a Gemini API key in Settings to process scans.',
      );
      return null;
    }
    await _save(
      job
        ..status = ScanStatus.processing
        ..attempts += 1,
    );

    final profile = (await isar.userProfiles.get(1))!;
    final ingredients = await isar.ingredients.where().findAll();
    final ctx = ContextBuilders.receipt(profile: profile, ingredients: ingredients, now: now(), userHint: job.userHint);
    final imgs = [for (final p in job.imagePaths) await images.read(p)];
    final prompt = await ai.prompts.load(PromptRepository.receipt);
    final outcome = await runner.run<ReceiptExtraction>(
      task: AiTask.receipt,
      promptVersion: PromptRepository.receipt,
      request: GeminiRequest(
        systemPrompt: prompt,
        turns: [Turn.user(jsonEncode(ctx), imgs)],
        thinkingLevel: 'low',
        highMediaResolution: true,
        responseSchema: AiSchemas.receipt,
        maxOutputTokens: 16384,
        timeout: const Duration(seconds: 60),
      ),
      parse: ReceiptExtraction.parse,
    );
    job.aiCallLogId = outcome.logId;

    if (!outcome.ok) {
      final retry = outcome.transient && job.attempts < maxAttempts;
      await _save(
        job
          ..status = retry ? ScanStatus.queued : ScanStatus.failed
          ..lastError = outcome.errors.isEmpty ? 'Unknown error' : outcome.errors.first,
      );
      return retry ? null : ScanResult(job);
    }

    final x = outcome.value!;
    if (x.imageType == ScanKind.unreadable) {
      await _save(
        job
          ..kind = ScanKind.unreadable
          ..status = ScanStatus.failed
          ..lastError = x.warnings.isEmpty ? 'The photo was unreadable.' : 'Unreadable: ${x.warnings.join(', ')}',
      );
      return ScanResult(job);
    }

    final draft = ReceiptValidator.validate(
      x,
      matcher: IngredientMatcher(ingredients),
      homeCurrency: profile.currency,
      capturedAt: job.capturedAt,
    );
    job
      ..kind = draft.kind
      ..merchant = draft.merchant
      ..purchasedAt = draft.purchasedAt
      ..receiptTotalMinor = draft.receiptTotalMinor
      ..currency = draft.currency
      ..lines = draft.lines
      ..flags = draft.flags
      ..lastError = null
      ..status = ScanStatus.needsReview;
    if (isForeign(job, profile.currency) && fx != null) {
      final q = await fx!.quote(job.currency!, profile.currency, job.purchasedAt ?? job.capturedAt);
      if (q != null) _setRate(job, q);
    }
    await _save(job);

    if (draft.autoCommitEligible && profile.autoCommitCleanScans) {
      final txId = await commit(job.id);
      final fresh = (await isar.scanJobs.get(job.id))!;
      return ScanResult(fresh, autoCommitted: true, transactionId: txId);
    }
    return ScanResult(job);
  }

  Future<void> _save(ScanJob job) => isar.writeTxn(() => isar.scanJobs.put(job));

  Future<void> updateJob(ScanJob job) => _save(job);

  static bool isForeign(ScanJob job, String homeCurrency) =>
      job.kind == ScanKind.receipt && job.currency != null && job.currency!.toUpperCase() != homeCurrency.toUpperCase();

  static void _setRate(ScanJob job, FxQuote q) {
    job
      ..fxRate = q.rate
      ..fxSource = q.source.name
      ..fxDate = q.date;
  }

  /// Review screen: use this rate for the receipt. Manual rates are remembered
  /// for the next receipt in the same currency.
  Future<void> applyRate(int jobId, FxQuote q) async {
    final job = await isar.scanJobs.get(jobId);
    if (job == null || !FxMath.plausible(q.rate)) return;
    _setRate(job, q);
    await _save(job);
    if (q.source == FxSource.manual || q.source == FxSource.charged) await fx?.remember(q);
  }

  /// Re-tries the automatic rate (e.g. after coming back online).
  Future<FxQuote?> refreshRate(int jobId) async {
    final job = await isar.scanJobs.get(jobId);
    final profile = await isar.userProfiles.get(1);
    if (job == null || profile == null || fx == null || !isForeign(job, profile.currency)) return null;
    final q = await fx!.quote(job.currency!, profile.currency, job.purchasedAt ?? job.capturedAt);
    if (q != null) {
      _setRate(job, q);
      await _save(job);
    }
    return q;
  }

  Future<void> retry(int jobId) async {
    final job = await isar.scanJobs.get(jobId);
    if (job == null) return;
    await _save(
      job
        ..status = ScanStatus.queued
        ..attempts = 0
        ..lastError = null,
    );
  }

  Future<void> discard(int jobId) async {
    final job = await isar.scanJobs.get(jobId);
    if (job == null) return;
    await _save(job..status = ScanStatus.discarded);
  }

  /// Commits a reviewed job: receipt → Transaction + stock, pantry → quantities.
  /// Returns the transaction id (null for pantry snapshots).
  Future<int?> commit(int jobId) async {
    final t = now();
    return isar.writeTxn(() async {
      final job = await isar.scanJobs.get(jobId);
      if (job == null || job.status == ScanStatus.committed) return job?.transactionId;
      final included = job.lines.where((l) => l.include).toList();

      if (job.kind == ScanKind.pantry) {
        for (final l in included) {
          if (l.ingredientKey == null || l.qty == null) continue;
          final ing = await _resolveOrCreate(l, t, qtyOnly: true);
          final before = ing.qtyOnHand;
          ing.qtyOnHand = l.qty!;
          if (ing.qtyOnHand < before) {
            ExpiryEstimator.onDeplete(ing);
          } else if (before <= 0 && ing.qtyOnHand > 0) {
            ing
              ..lastPurchasedAt = t
              ..lastPurchaseQty = ing.qtyOnHand
              ..expiresAt = t.add(Duration(days: ing.shelfLifeDays));
          }
          ing
            ..lastVerifiedAt = t
            ..updatedAt = t;
          await isar.ingredients.put(ing);
        }
        job.status = ScanStatus.committed;
        await isar.scanJobs.put(job);
        return null;
      }

      final lines = ReceiptMath.allocateAdjustments(included);
      final home = (await isar.userProfiles.get(1))?.currency ?? job.currency ?? 'EUR';
      final foreign = isForeign(job, home);
      if (foreign && (job.fxRate == null || !FxMath.plausible(job.fxRate!))) {
        throw MissingExchangeRate(job.currency!, home);
      }
      final originalTotal = lines.fold(0, (a, l) => a + l.totalMinor);
      final amounts = foreign
          ? FxMath.convertLines([for (final l in lines) l.totalMinor], from: job.currency!, to: home, rate: job.fxRate!)
          : [for (final l in lines) l.totalMinor];
      final at = job.purchasedAt ?? job.capturedAt;
      final txLines = <LineItem>[];
      for (final (i, l) in lines.indexed) {
        l.totalMinor = amounts[i];
        final item = LineItem()
          ..rawText = l.rawText
          ..name = l.name
          ..lineType = l.lineType
          ..category = l.category
          ..totalMinor = l.totalMinor;
        if (l.category == SpendCategory.groceries &&
            l.lineType == LineType.product &&
            l.ingredientKey != null &&
            (l.qty ?? 0) > 0) {
          final ing = await _resolveOrCreate(l, t);
          CostingEngine.applyPurchase(ing, qtyAdded: l.qty!, lineTotalMinor: l.totalMinor, at: at);
          if (l.rawText.isNotEmpty) IngredientMatcher.learnAlias(ing, l.rawText);
          final id = await isar.ingredients.put(ing);
          item
            ..ingredientId = id
            ..ingredientKey = ing.key
            ..qtyBase = l.qty;
        }
        txLines.add(item);
      }
      final tx = Transaction()
        ..occurredAt = at
        ..source = TxSource.receiptScan
        ..merchant = job.merchant
        ..currency = home
        ..originalCurrency = foreign ? job.currency!.toUpperCase() : null
        ..originalTotalMinor = foreign ? originalTotal : null
        ..fxRate = foreign ? job.fxRate : null
        ..lines = txLines
        ..totalMinor = txLines.fold(0, (a, l) => a + l.totalMinor)
        ..primaryCategory = ReceiptMath.primaryCategory(
          txLines.map((l) => (category: l.category, totalMinor: l.totalMinor)),
        )
        ..scanJobId = job.id
        ..createdAt = t;
      final txId = await isar.transactions.put(tx);
      job
        ..status = ScanStatus.committed
        ..transactionId = txId;
      await isar.scanJobs.put(job);
      return txId;
    });
  }

  Future<Ingredient> _resolveOrCreate(DraftLine l, DateTime t, {bool qtyOnly = false}) async {
    if (l.matchedIngredientId != null) {
      final hit = await isar.ingredients.get(l.matchedIngredientId!);
      if (hit != null) return hit;
    }
    final byKey = await isar.ingredients.getByKey(l.ingredientKey!);
    if (byKey != null) return byKey;
    final p =
        l.profile ??
        (NewIngredientProfile()
          ..name = l.name
          ..unit = l.unit);
    return Ingredient()
      ..key = l.ingredientKey!
      ..name = p.name.isEmpty ? l.name : p.name
      ..category = p.category
      ..baseUnit = l.unit
      ..gramsPerPiece = p.gramsPerPiece ?? (l.unit == BaseUnit.pc ? 50 : null)
      ..densityGPerMl = p.densityGPerMl
      ..per100 = p.per100
      ..nutritionSource = l.profile == null ? DataSource.none : DataSource.aiEstimate
      ..shelfLifeDays = p.shelfLifeDays
      ..trackingMode = p.suggestStaple ? TrackingMode.staple : TrackingMode.exact
      ..lastVerifiedAt = t
      ..updatedAt = t;
  }
}
