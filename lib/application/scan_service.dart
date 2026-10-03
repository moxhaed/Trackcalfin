import 'dart:convert';
import 'dart:io';

import 'package:isar_community/isar.dart';

import '../core/day_clock.dart';
import '../core/enums.dart';
import '../data/ai/ai_runner.dart';
import '../data/ai/context_builders.dart';
import '../data/ai/dto/price_dto.dart';
import '../data/ai/dto/receipt_dto.dart';
import '../data/ai/gemini_client.dart';
import '../data/ai/prompt_repository.dart';
import '../data/ai/schemas.dart';
import '../data/isar/collections/schemas.dart';
import '../domain/costing.dart';
import '../domain/fx.dart';
import '../domain/ingredient_matcher.dart';
import '../domain/receipt_math.dart';
import '../domain/stock_index.dart';
import '../domain/used_up.dart';
import '../domain/validation/receipt_validator.dart';
import '../platform/image_store.dart';
import 'ai_gateway.dart';
import 'clock.dart';
import 'fx_service.dart';
import 'recipe_service.dart';
import 'shopping_service.dart';

/// A foreign-currency receipt can't be filed until it has an exchange rate.
class MissingExchangeRate implements Exception {
  MissingExchangeRate(this.from, this.to);
  final String from;
  final String to;

  @override
  String toString() => 'Set an exchange rate from $from to $to first';
}

class ScanResult {
  ScanResult(this.job, {this.autoCommitted = false, this.transactionId, this.clean = false, this.waiting = false});
  final ScanJob job;
  final bool autoCommitted;
  final int? transactionId;

  /// The AI read the receipt without a flag. It may still wait for review because of what the
  /// app knows: an old date, a possible duplicate, or items already counted in the pantry.
  final bool clean;

  /// Not read this time for a passing reason (offline, quota, a timeout): the job is back in
  /// the queue with [ScanJob.lastError] saying why, and is tried again later.
  final bool waiting;
}

/// What is being read right now in one database, shared by every [ScanService] on it.
class _Flight {
  bool running = false;

  /// A run was asked for while one was going: it looks for newly queued jobs before it ends.
  bool again = false;
  final jobs = <int>{};
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

  /// Items per price lookup call: each one may cost a Google search.
  static const priceBatch = 20;

  /// Keyed by the database, not this object: the queue is started from app start, resume,
  /// connectivity changes, the Inbox and new scans, and a job must never be read twice at once.
  static final _flights = Expando<_Flight>('scan queue');
  _Flight get _flight => _flights[isar] ??= _Flight();

  static const closedWhileReading = 'The app closed while reading this photo.';

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

  /// Processes queued jobs one at a time, oldest first. Safe to call any time, from anywhere:
  /// while a run is going, a second call returns nothing at once and the running one also
  /// reads what was queued since (it reports them), so a new scan never waits for a restart.
  Future<List<ScanResult>> processQueue() async {
    final f = _flight;
    if (f.running) {
      f.again = true;
      return const [];
    }
    f.running = true;
    final results = <ScanResult>[];
    try {
      await _recoverStuck();
      final tried = <int>{};
      var stop = false;
      do {
        f.again = false;
        final queued = await isar.scanJobs.where().statusEqualTo(ScanStatus.queued).sortByCapturedAt().findAll();
        for (final j in queued) {
          if (!tried.add(j.id)) continue;
          final r = await process(j.id);
          if (r == null) {
            if (!await ai.hasKey) stop = true; // nothing can be read until there is a key
            if (stop) break;
            continue;
          }
          results.add(r);
          // Offline or out of quota: the next ones would fail the same way.
          if (r.waiting) {
            stop = true;
            break;
          }
        }
      } while (f.again && !stop);
    } finally {
      f
        ..running = false
        ..again = false;
    }
    return results;
  }

  /// Jobs left in "processing" by an app that was closed or killed mid-read go back to the
  /// queue. One that keeps taking the app down with it stops after [maxAttempts] and waits for
  /// the user in the Inbox, instead of being tried on every start.
  Future<void> _recoverStuck() async {
    final busy = _flight.jobs;
    final stuck = [
      for (final j in await isar.scanJobs.where().statusEqualTo(ScanStatus.processing).findAll())
        if (!busy.contains(j.id)) j,
    ];
    if (stuck.isEmpty) return;
    for (final j in stuck) {
      final again = j.attempts < maxAttempts;
      j
        ..status = again ? ScanStatus.queued : ScanStatus.failed
        ..lastError = again ? closedWhileReading : '$closedWhileReading Try again, or retake it.';
    }
    await isar.writeTxn(() => isar.scanJobs.putAll(stuck));
  }

  /// Reads one queued job. Returns null when nothing was done: the job isn't queued, is already
  /// being read, or there is no API key. A passing failure returns a [ScanResult.waiting] result.
  Future<ScanResult?> process(int jobId) async {
    final busy = _flight.jobs;
    if (!busy.add(jobId)) return null;
    try {
      final job = await isar.scanJobs.get(jobId);
      if (job == null || job.status != ScanStatus.queued) return null;
      final runner = await ai.runner();
      if (runner == null) {
        await _save(job..lastError = 'Add a Gemini API key in Settings to process scans.');
        return null;
      }
      final marked = await _saveUnlessDiscarded(
        job
          ..status = ScanStatus.processing
          ..attempts += 1,
      );
      if (!marked) return null;
      try {
        return await _read(job, runner);
      } catch (e) {
        // Never leave a job "Reading…": a photo that is gone, a reply that isn't JSON (a Wi-Fi
        // login page), a bug. It waits in the Inbox with the reason and Try again.
        await _saveUnlessDiscarded(
          job
            ..status = ScanStatus.failed
            ..lastError = e is FileSystemException
                ? 'The photo is no longer on the phone. Retake it.'
                : 'Something went wrong reading it: $e',
        );
        return ScanResult(job);
      }
    } finally {
      busy.remove(jobId);
    }
  }

  Future<ScanResult> _read(ScanJob job, AiRunner runner) async {
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
      await _saveUnlessDiscarded(
        job
          ..status = retry ? ScanStatus.queued : ScanStatus.failed
          ..lastError = outcome.errors.isEmpty ? 'Unknown error' : outcome.errors.first,
      );
      return ScanResult(job, waiting: retry);
    }

    final x = outcome.value!;
    if (x.imageType == ScanKind.unreadable) {
      await _saveUnlessDiscarded(
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
    if (job.kind == ScanKind.pantry && profile.lookUpPrices) {
      await _lookUpPrices(job, runner, profile, StockIndex(ingredients));
    }
    await _findDuplicate(job);
    if (isForeign(job, profile.currency) && fx != null) {
      final q = await fx!.quote(job.currency!, profile.currency, job.purchasedAt ?? job.capturedAt);
      if (q != null) _setRate(job, q);
    }
    if (!await _saveUnlessDiscarded(job)) return ScanResult(job..status = ScanStatus.discarded);

    if (draft.autoCommitEligible && !job.maybeDuplicate && profile.autoCommitCleanScans) {
      final txId = await commit(job.id);
      final fresh = (await isar.scanJobs.get(job.id))!;
      return ScanResult(fresh, autoCommitted: true, transactionId: txId, clean: true);
    }
    return ScanResult(job, clean: draft.clean);
  }

  /// Pantry photos: asks Gemini, searching Google, what each item without a price paid costs in
  /// the shops. A found price replaces the photo's own estimate; review asks about every one.
  /// When the lookup fails the estimates stand, and [ScanJob.priceLookupError] says why.
  /// Prices already found or confirmed are left alone, so it can run again after a failure.
  Future<void> _lookUpPrices(ScanJob job, AiRunner runner, UserProfile profile, StockIndex pantry) async {
    job.priceLookupError = null;
    final todo = <String, DraftLine>{
      for (final (i, l) in job.lines.indexed)
        if (l.include &&
            l.ingredientKey != null &&
            !l.priceConfirmed &&
            l.priceSource != PriceSource.web &&
            ReceiptValidator.needsPrice(pantry.byId[l.matchedIngredientId]))
          '$i': l,
    };
    if (todo.isEmpty) return;
    final prompt = await ai.prompts.load(PromptRepository.priceLookup);
    final ids = todo.keys.toList();
    for (var start = 0; start < ids.length; start += priceBatch) {
      final batch = {for (final id in ids.skip(start).take(priceBatch)) id: todo[id]!};
      final outcome = await runner.run<PriceLookup>(
        task: AiTask.priceLookup,
        promptVersion: PromptRepository.priceLookup,
        request: GeminiRequest(
          systemPrompt: prompt,
          turns: [Turn.user(jsonEncode(ContextBuilders.priceLookup(profile: profile, now: now(), items: batch)))],
          thinkingLevel: 'low',
          googleSearch: true,
          maxOutputTokens: 4096,
          timeout: const Duration(seconds: 90),
        ),
        parse: (m) => PriceLookup.parse(m, units: {for (final e in batch.entries) e.key: e.value.unit}),
      );
      if (!outcome.ok) {
        job.priceLookupError = outcome.errors.firstOrNull ?? 'Unknown error';
        return;
      }
      final g = outcome.grounding;
      job
        ..priceSearchHtml = [...job.priceSearchHtml, ?g?.searchEntryHtml]
        ..priceQueries = [...job.priceQueries, ...?g?.queries];
      for (final f in outcome.value!.items) {
        final l = batch[f.id]!..priceNote = f.note;
        if (!f.found) continue;
        final page = g?.sources.where((s) => _sameSite(s.title, f.source)).firstOrNull;
        l
          ..packageQty = f.packageQty
          ..packagePriceMinor = f.priceMinor
          ..priceSource = PriceSource.web
          ..priceConfirmed = false
          ..priceStore = f.store
          ..priceLinks = [
            if (page != null)
              WebLink()
                ..title = page.title
                ..uri = page.uri,
          ];
      }
    }
  }

  /// "www.REWE.de", "rewe.de" and "shop.rewe.de" are the same site.
  static bool _sameSite(String title, String? domain) {
    String bare(String s) => s.trim().toLowerCase().replaceFirst(RegExp(r'^(https?://)?(www\.)?'), '').split('/').first;
    if (domain == null) return false;
    final a = bare(title);
    final b = bare(domain);
    return a.isNotEmpty && b.isNotEmpty && (a == b || a.endsWith('.$b') || b.endsWith('.$a'));
  }

  static int _lineSum(ScanJob job) => job.lines.where((l) => l.include).fold(0, (a, l) => a + l.totalMinor);

  /// Flags a receipt that looks like one already filed, or like another scan waiting in the
  /// Inbox: same day, same total (printed or added up) and the same store.
  Future<void> _findDuplicate(ScanJob job) async {
    job
      ..duplicateOfTxId = null
      ..duplicateOfJobId = null;
    final day = job.purchasedAt;
    if (job.kind != ScanKind.receipt || day == null) return;
    final currency = (job.currency ?? '').toUpperCase();
    final totals = {?job.receiptTotalMinor, _lineSum(job)};
    bool same(String? merchant, DateTime otherDay, Iterable<int?> otherTotals) => totals.any(
      (a) => otherTotals.nonNulls.any(
        (b) => ReceiptValidator.sameReceipt(
          merchant: job.merchant,
          day: day,
          totalMinor: a,
          otherMerchant: merchant,
          otherDay: otherDay,
          otherTotalMinor: b,
        ),
      ),
    );

    final from = DateTime(day.year, day.month, day.day);
    final filed = await isar.transactions.where().occurredAtBetween(from, DayClock.addDays(from, 1)).findAll();
    for (final tx in filed) {
      // Compare in the receipt's own currency: a foreign receipt keeps its printed total.
      final txCurrency = (tx.originalCurrency ?? tx.currency).toUpperCase();
      if (txCurrency != currency) continue;
      final source = tx.scanJobId == null ? null : await isar.scanJobs.get(tx.scanJobId!);
      if (same(tx.merchant, tx.occurredAt, [tx.originalTotalMinor ?? tx.totalMinor, source?.receiptTotalMinor])) {
        job.duplicateOfTxId = tx.id;
        return;
      }
    }
    final waiting = await isar.scanJobs.where().statusEqualTo(ScanStatus.needsReview).findAll();
    for (final other in waiting) {
      if (other.id == job.id || other.kind != ScanKind.receipt || other.purchasedAt == null) continue;
      if ((other.currency ?? '').toUpperCase() != currency) continue;
      if (same(other.merchant, other.purchasedAt!, [other.receiptTotalMinor, _lineSum(other)])) {
        job.duplicateOfJobId = other.id;
        return;
      }
    }
  }

  /// Review: the user set the receipt's date. Re-runs what depends on it: the pantry
  /// questions, the duplicate check and an automatic exchange rate.
  Future<void> setPurchaseDate(int jobId, DateTime date) async {
    final job = await isar.scanJobs.get(jobId);
    if (job == null || job.kind != ScanKind.receipt) return;
    job
      ..purchasedAt = date
      ..flags = job.flags.where((f) => !ReceiptValidator.dateFlags.contains(f)).toList();
    final pantry = StockIndex(await isar.ingredients.where().findAll());
    for (final l in job.lines) {
      if (l.ingredientKey == null) continue;
      ReceiptValidator.checkStock(
        l,
        kind: job.kind,
        existing: pantry.byId[l.matchedIngredientId] ?? (l.isNewIngredient ? null : pantry.byKey[l.ingredientKey]),
        purchasedAt: date,
        capturedAt: job.capturedAt,
      );
    }
    await _findDuplicate(job);
    final home = (await isar.userProfiles.get(1))?.currency ?? 'EUR';
    final automatic =
        job.fxSource == null || job.fxSource == FxSource.ecb.name || job.fxSource == FxSource.remembered.name;
    if (isForeign(job, home) && fx != null && automatic) {
      final q = await fx!.quote(job.currency!, home, date);
      if (q != null) _setRate(job, q);
    }
    await _save(job);
  }

  /// Review's "Try again" after the price lookup failed.
  Future<void> retryPrices(int jobId) async {
    final job = await isar.scanJobs.get(jobId);
    final profile = await isar.userProfiles.get(1);
    if (job == null || profile == null || job.kind != ScanKind.pantry || job.status != ScanStatus.needsReview) return;
    final runner = await ai.runner();
    if (runner == null) return;
    await _lookUpPrices(job, runner, profile, StockIndex(await isar.ingredients.where().findAll()));
    await _save(job);
  }

  Future<void> _save(ScanJob job) => isar.writeTxn(() => isar.scanJobs.put(job));

  /// Saves what a read found, unless the user discarded the scan while it was being read.
  Future<bool> _saveUnlessDiscarded(ScanJob job) => isar.writeTxn(() async {
    if ((await isar.scanJobs.get(job.id))?.status == ScanStatus.discarded) return false;
    await isar.scanJobs.put(job);
    return true;
  });

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
    if (_flight.jobs.contains(jobId)) return; // being read right now
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

      final touched = <int>{};
      if (job.kind == ScanKind.pantry) {
        // The photo shows the pantry as it was when it was taken.
        final seen = job.capturedAt;
        final counted = <String>{};
        for (final l in included) {
          if (l.ingredientKey == null || l.qty == null) continue;
          final effect = l.effectFor(job.kind);
          if (effect == StockEffect.none) continue;
          final ing = await _resolveOrCreate(l, t);
          final before = ing.qtyOnHand;
          // "Extra one" adds to what's there; so does a second line for the same item.
          final extra = effect == StockEffect.add || counted.contains(ing.key);
          // The photo shows less than the pantry had: the rest was used up since the last count.
          final use = extra ? null : UsedUp.fromCount(ing, before: before, after: l.qty!, at: seen);
          if (use != null) await isar.foodUses.put(use);
          ing.qtyOnHand = extra ? before + l.qty! : l.qty!;
          if (ing.qtyOnHand < before) {
            ExpiryEstimator.onDeplete(ing);
          } else if (before <= 0 && ing.qtyOnHand > 0) {
            ing
              ..lastPurchasedAt = seen
              ..lastPurchaseQty = ing.qtyOnHand
              ..expiresAt = DayClock.addDays(seen, ing.shelfLifeDays);
          } else if (extra && l.qty! > 0) {
            ExpiryEstimator.onPurchase(ing, qtyBefore: before, at: seen);
            ing
              ..lastPurchasedAt = seen
              ..lastPurchaseQty = l.qty!;
          }
          // A shop price the user confirmed counts as real; otherwise it's kept as an estimate.
          final shelfPrice = l.estUnitCostMinor;
          if (shelfPrice != null) {
            l.priceConfirmed
                ? CostingEngine.applyCheckedPrice(ing, shelfPrice)
                : CostingEngine.applyEstimate(ing, shelfPrice);
          }
          ing
            ..lastVerifiedAt = seen
            ..lastCountedAt = seen
            ..updatedAt = t;
          touched.add(await isar.ingredients.put(ing));
          counted.add(ing.key);
        }
        await RecipeService.refreshUsing(isar, touched);
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
      final uses = <FoodUse>[];
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
          // "What's left?" on an old receipt: only what is left goes into the pantry.
          final left = l.effectFor(job.kind) == StockEffect.none ? 0.0 : (l.qtyLeft ?? l.qty!).clamp(0.0, l.qty!);
          final stocked = left > 0;
          if (stocked) {
            final paid = left == l.qty! ? l.totalMinor : (l.totalMinor * left / l.qty!).round();
            CostingEngine.applyPurchase(ing, qtyAdded: left, lineTotalMinor: paid, at: at);
          } else {
            // Already counted, or used up: the money is filed, the pantry stays as it is.
            CostingEngine.learnPrice(ing, qty: l.qty!, lineTotalMinor: l.totalMinor);
          }
          if (l.rawText.isNotEmpty) IngredientMatcher.learnAlias(ing, l.rawText);
          final id = await isar.ingredients.put(ing);
          touched.add(id);
          // What it is and how much, stocked or not: the store's price for it (PriceBook).
          item
            ..ingredientKey = ing.key
            ..qtyBought = l.qty
            ..unit = l.unit
            ..product = l.product;
          if (stocked) {
            item
              ..ingredientId = id
              ..qtyBase = left;
          }
          // What is gone since an old purchase counts as eaten (or thrown away) in those days.
          final gone = l.qty! - left;
          if (gone > 1e-9 && (l.stockCheck == StockCheck.whatsLeft || l.stockCheck == StockCheck.usedUp)) {
            final use = UsedUp.fromReceipt(
              key: ing.key,
              name: ing.name,
              gone: gone,
              costMinor: (l.totalMinor * gone / l.qty!).round(),
              bought: at,
              found: t,
              keepsDays: ing.shelfLifeDays,
              kind: l.thrownAway ? UseKind.thrownAway : UseKind.eaten,
            );
            if (use != null) uses.add(use);
          }
        }
        txLines.add(item);
      }
      // Prices changed: recipes show what they cost now.
      await RecipeService.refreshUsing(isar, touched);
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
      await isar.foodUses.putAll([for (final u in uses) u..transactionId = txId]);
      // Bought: the shopping list's lines for these items are ticked off.
      await ShoppingService.tickOff(isar, [
        for (final l in txLines)
          if (l.category.isFood && l.ingredientKey != null) l.ingredientKey!,
      ], t);
      job
        ..status = ScanStatus.committed
        ..transactionId = txId;
      await isar.scanJobs.put(job);
      return txId;
    });
  }

  Future<Ingredient> _resolveOrCreate(DraftLine l, DateTime t) async {
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
      ..lastVerifiedAt = t
      ..updatedAt = t;
  }
}
