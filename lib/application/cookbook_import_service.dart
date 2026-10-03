import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:isar_community/isar.dart';

import '../core/enums.dart';
import '../data/ai/ai_runner.dart';
import '../data/ai/context_builders.dart';
import '../data/ai/dto/cookbook_dto.dart';
import '../data/ai/gemini_client.dart';
import '../data/ai/gemini_files.dart';
import '../data/ai/prompt_repository.dart';
import '../data/ai/schemas.dart';
import '../data/isar/collections/schemas.dart';
import '../domain/cookbook.dart';
import '../domain/stock_index.dart';
import '../domain/validation/cookbook_validator.dart';
import 'ai_gateway.dart';
import 'clock.dart';
import 'profile_service.dart';
import 'recipe_service.dart';

class CookbookException implements Exception {
  CookbookException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// What one pass did.
class CookbookProgress {
  const CookbookProgress({required this.more, this.error, this.transient = false});

  /// Something is left to read.
  final bool more;

  /// Why the pass failed. Its recipes stay pending (or go to "failed" after a few tries).
  final String? error;

  /// A daily limit, no connection or no key: stop for now and go on later.
  final bool transient;
}

/// Prompt H: reads a PDF cookbook into recipes, a pass at a time, keeping every pass's result.
///
/// 1. [create] keeps a copy of the PDF and counts its pages when the file says how many.
/// 2. [step] runs one call: first the index (titles and pages, in passes of [indexBatch]),
///    then [batchSize] recipes at a time. Each pass saves what it read, so a daily limit or a
///    closed app loses nothing; the next [step] goes on where the last one stopped.
/// 3. The user reviews the drafts; [save] turns the chosen ones into recipes in one write,
///    with every ingredient matched to the pantry and every number computed in Dart.
///
/// A PDF up to [inlineMaxBytes] is sent with every call. A larger one is uploaded once with the
/// Files API, and the calls point at it until it expires (48 h).
class CookbookImportService {
  CookbookImportService({
    required this.isar,
    required this.ai,
    required this.dir,
    Now? now,
    this.batchSize = 8,
    this.delay,
  }) : now = now ?? DateTime.now;

  final Isar isar;
  final AiGateway ai;

  /// Where the PDF copies go.
  final Future<String> Function() dir;
  final Now now;
  final int batchSize;

  /// Waits between checks on an upload still being processed (tests skip it).
  final Future<void> Function(Duration)? delay;

  /// Gemini reads a PDF of up to 50 MB and 1000 pages, inline or uploaded.
  static const maxBytes = 50 * 1024 * 1024;
  static const maxPages = 1000;

  /// Small enough to send with each call; larger files are uploaded once.
  static const inlineMaxBytes = 2 * 1024 * 1024;

  /// When the Files API isn't there (a local stand-in), files up to this size still go inline:
  /// base64 keeps the request under 20 MB.
  static const inlineFallbackMaxBytes = 14 * 1024 * 1024;

  static const indexBatch = 150;
  static const maxIndexCalls = 12;

  /// A recipe that failed this often (in ever smaller batches) is set aside as failed.
  static const maxAttempts = 3;

  static const pdfMime = 'application/pdf';

  Future<CookbookImport?> get(int id) => isar.cookbookImports.get(id);

  String nextLabel(CookbookImport job) =>
      _needsUpload(job) ? 'Sending the PDF to Gemini' : CookbookPlanner.nextLabel(job, batchSize: batchSize);

  bool _needsUpload(CookbookImport job) =>
      job.sizeBytes > inlineMaxBytes &&
      job.hasWork &&
      (job.remoteUri == null || !(job.remoteExpiresAt?.isAfter(now().add(const Duration(minutes: 30))) ?? false));

  static String _titleFromFile(String fileName) {
    final base = fileName.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '').replaceAll(RegExp(r'[_\-]+'), ' ');
    final t = base.trim();
    return t.isEmpty ? 'Cookbook' : t;
  }

  /// Keeps a copy of [bytes] and starts an import. Throws [CookbookException] for a file
  /// Gemini can't read. Imports discarded earlier are cleared out in the same write.
  Future<int> create({required String fileName, required Uint8List bytes}) async {
    if (!CookbookPdf.looksLikePdf(bytes)) throw CookbookException('That file is not a PDF.');
    if (bytes.length > maxBytes) {
      throw CookbookException(
        'This PDF is ${(bytes.length / 1048576).toStringAsFixed(0)} MB. Gemini reads PDFs up to 50 MB: '
        'split it into parts and import them one by one.',
      );
    }
    final pages = CookbookPdf.pageCount(bytes);
    if (pages != null && pages > maxPages) {
      throw CookbookException('This PDF has $pages pages. Gemini reads up to $maxPages: split it into parts.');
    }
    final folder = Directory(await dir());
    await folder.create(recursive: true);
    final t = now();
    final file = File('${folder.path}/cookbook_${t.microsecondsSinceEpoch}.pdf');
    await file.writeAsBytes(bytes, flush: true);
    final old = await isar.cookbookImports.filter().statusEqualTo(CookbookStatus.discarded).findAll();
    final job = CookbookImport()
      ..fileName = fileName
      ..bookTitle = _titleFromFile(fileName)
      ..filePath = file.path
      ..sizeBytes = bytes.length
      ..pageCount = pages
      ..createdAt = t
      ..updatedAt = t;
    final id = await isar.writeTxn(() async {
      await isar.cookbookImports.deleteAll([for (final j in old) j.id]);
      return isar.cookbookImports.put(job);
    });
    for (final j in old) {
      _deleteFile(j.filePath);
    }
    return id;
  }

  static void _deleteFile(String path) {
    try {
      final f = File(path);
      if (f.existsSync()) f.deleteSync();
    } catch (_) {}
  }

  /// Applies [change] to the stored import, read inside the write: a save from the review
  /// screen while a pass runs is never overwritten.
  Future<CookbookImport?> _update(int id, void Function(CookbookImport job) change) => isar.writeTxn(() async {
    final job = await isar.cookbookImports.get(id);
    if (job == null) return null;
    change(job);
    job.updatedAt = now();
    await isar.cookbookImports.put(job);
    return job;
  });

  void Function(CookbookImport) _remote(CookbookImport from) =>
      (j) => j
        ..remoteName = from.remoteName
        ..remoteUri = from.remoteUri
        ..remoteExpiresAt = from.remoteExpiresAt;

  Future<CookbookProgress> _stop(CookbookImport job, String error, {required bool transient}) async {
    await _update(job.id, (j) {
      _remote(job)(j);
      j.lastError = error;
    });
    return CookbookProgress(more: true, error: error, transient: transient);
  }

  /// One call: the next index pass, or the next batch of recipes.
  Future<CookbookProgress> step(int id) async {
    final job = await isar.cookbookImports.get(id);
    if (job == null || job.status != CookbookStatus.open || !job.hasWork) return const CookbookProgress(more: false);
    final runner = await ai.runner();
    if (runner == null) {
      return _stop(job, 'Add a Gemini API key in Settings to read the cookbook.', transient: true);
    }
    final Attachment pdf;
    try {
      pdf = await _document(job, runner.client);
    } on GeminiException catch (e) {
      return _stop(job, 'Could not send the PDF: ${e.message}', transient: e.retryable);
    } on FileSystemException {
      return _stop(job, "The app's copy of the PDF is gone. Import the book again.", transient: false);
    }
    return job.indexDone ? _recipePass(job, runner, pdf) : _indexPass(job, runner, pdf);
  }

  /// The PDF for a call: its upload while that is fresh, else inline or a new upload.
  Future<Attachment> _document(CookbookImport job, GeminiClient client) async {
    final t = now();
    if (job.remoteUri != null && (job.remoteExpiresAt?.isAfter(t.add(const Duration(minutes: 30))) ?? false)) {
      return Attachment.uploaded(pdfMime, job.remoteUri!);
    }
    final bytes = await File(job.filePath).readAsBytes();
    if (bytes.length <= inlineMaxBytes) return Attachment.inline(pdfMime, bytes);
    try {
      final f = await GeminiFiles.of(client, delay: delay).upload(bytes, mimeType: pdfMime, displayName: job.fileName);
      job
        ..remoteName = f.name
        ..remoteUri = f.uri
        ..remoteExpiresAt = f.expiresAt ?? t.add(const Duration(hours: 47));
      return Attachment.uploaded(pdfMime, f.uri);
    } on GeminiException catch (e) {
      if (e.retryable || bytes.length > inlineFallbackMaxBytes) rethrow;
      return Attachment.inline(pdfMime, bytes);
    }
  }

  /// An upload that is gone (deleted, or expired early) fails the call; the next pass uploads again.
  bool _uploadGone(Attachment pdf, AiOutcome<Object?> outcome) =>
      pdf.fileUri != null &&
      !outcome.transient &&
      outcome.errors.any((e) => e.toLowerCase().contains('file') && !e.startsWith(r'$'));

  Future<CookbookProgress> _indexPass(CookbookImport job, AiRunner runner, Attachment pdf) async {
    final prompt = await ai.prompts.load(PromptRepository.cookbookIndex);
    final outcome = await runner.run<CookbookIndexOutput>(
      task: AiTask.cookbookImport,
      promptVersion: PromptRepository.cookbookIndex,
      request: GeminiRequest(
        systemPrompt: prompt,
        turns: [
          Turn.user(jsonEncode(ContextBuilders.cookbookIndex(job, maxRecipes: indexBatch)), const [], [pdf]),
        ],
        thinkingLevel: 'low',
        responseSchema: AiSchemas.cookbookIndex,
        maxOutputTokens: 16384,
        timeout: const Duration(seconds: 180),
      ),
      parse: CookbookIndexOutput.parse,
    );
    if (!outcome.ok) {
      if (_uploadGone(pdf, outcome)) job.remoteUri = null;
      final why = outcome.errors.firstOrNull ?? 'no answer';
      return _stop(job, "Couldn't read the book's contents: $why", transient: outcome.transient);
    }
    final out = outcome.value!;
    final saved = await _update(job.id, (j) {
      _remote(job)(j);
      j.indexCalls++;
      if (out.bookTitle != null) j.bookTitle = CookbookPlanner.truncate(out.bookTitle!, 80);
      j.pageCount ??= out.pageCount;
      final entries = [...j.entries];
      final added = CookbookPlanner.addToIndex(entries, out.recipes);
      j.entries = entries;
      final next = out.nextPage;
      final stuck = next != null && (next <= j.nextIndexPage || added == 0);
      j.indexDone = next == null || stuck || j.indexCalls >= maxIndexCalls;
      if (next != null && !j.indexDone) j.nextIndexPage = next;
      j.lastError = j.indexDone && j.entries.isEmpty
          ? (out.isCookbook
                ? 'No recipes found in this PDF.'
                : "This PDF doesn't look like a cookbook: no recipes found.")
          : null;
    });
    final empty = saved != null && saved.indexDone && saved.entries.isEmpty;
    return CookbookProgress(more: saved?.hasWork ?? false, error: empty ? saved.lastError : null);
  }

  Future<CookbookProgress> _recipePass(CookbookImport job, AiRunner runner, Attachment pdf) async {
    final batch = CookbookPlanner.nextBatch(job.entries, size: batchSize);
    if (batch.isEmpty) return const CookbookProgress(more: false);
    final profile = await isar.userProfiles.get(1) ?? ProfileService.defaults();
    final ingredients = await isar.ingredients.where().findAll();
    final prompt = await ai.prompts.load(PromptRepository.cookbookImport);
    final ctx = ContextBuilders.cookbookRecipes(job: job, batch: batch, ingredients: ingredients, profile: profile);
    final outcome = await runner.run<CookbookRecipesOutput>(
      task: AiTask.cookbookImport,
      promptVersion: PromptRepository.cookbookImport,
      request: GeminiRequest(
        systemPrompt: prompt,
        turns: [
          Turn.user(jsonEncode(ctx), const [], [pdf]),
        ],
        thinkingLevel: 'low',
        responseSchema: AiSchemas.cookbookRecipes,
        maxOutputTokens: 16384,
        timeout: const Duration(seconds: 180),
      ),
      parse: (json) => CookbookRecipesOutput.parse(json, ids: batch.toSet()),
    );
    final pages = CookbookPlanner.pagesLabel(job.entries, batch);
    if (!outcome.ok) {
      final why = outcome.errors.firstOrNull ?? 'no answer';
      if (outcome.transient || _uploadGone(pdf, outcome)) {
        if (!outcome.transient) job.remoteUri = null;
        return _stop(job, 'Stopped at $pages: $why', transient: outcome.transient);
      }
      // The answer failed its checks twice: read these again in smaller batches, then give up on them.
      await _update(job.id, (j) {
        _remote(job)(j);
        final entries = [...j.entries];
        for (final i in batch) {
          final e = entries[i];
          if (e.state != CookbookEntryState.pending) continue;
          e.attempts++;
          if (e.attempts >= maxAttempts) e.state = CookbookEntryState.failed;
        }
        j
          ..entries = entries
          ..lastError = "Couldn't read $pages: $why";
      });
      return CookbookProgress(more: true, error: "Couldn't read $pages: $why");
    }
    final saved = await _update(job.id, (j) {
      _remote(job)(j);
      final entries = [...j.entries];
      final drafts = [...j.drafts];
      for (final dto in outcome.value!.recipes) {
        final e = entries[dto.id];
        if (!dto.found) {
          e.state = CookbookEntryState.notFound;
          continue;
        }
        e
          ..state = CookbookEntryState.done
          ..page = dto.page ?? e.page;
        drafts
          ..removeWhere((d) => d.entry == dto.id && d.recipeId == null)
          ..add(CookbookValidator.draft(dto, entry: dto.id, title: e.title, profile: profile));
      }
      j
        ..entries = entries
        ..drafts = drafts
        ..lastError = null;
    });
    return CookbookProgress(more: saved?.hasWork ?? false);
  }

  /// "Try again" for recipes that failed: read them once more, one or two at a time.
  Future<void> retryFailed(int id) => _update(id, (j) {
    j
      ..entries = [
        for (final e in j.entries)
          e.state == CookbookEntryState.failed
              ? (e
                  ..state = CookbookEntryState.pending
                  ..attempts = maxAttempts - 1)
              : e,
      ]
      ..status = CookbookStatus.open
      ..lastError = null;
  });

  /// Saves the drafts of [entries] as recipes, in one write. Ingredients are matched to the
  /// pantry as it is now, and cost and macros come from it. Returns the new recipe ids.
  Future<List<int>> save(int id, Set<int> entries) => isar.writeTxn(() async {
    final job = await isar.cookbookImports.get(id);
    if (job == null) return const <int>[];
    final pantry = await isar.ingredients.where().findAll();
    final stock = StockIndex(pantry);
    final matcher = CookbookMatcher(pantry);
    final picked = [
      for (final d in job.drafts)
        if (d.recipeId == null && entries.contains(d.entry)) d,
    ];
    final t = now();
    final recipes = [
      for (final d in picked)
        CookbookReview.toRecipe(d, book: job.bookTitle, matcher: matcher)
          ..promptVersion = PromptRepository.cookbookImport
          ..createdAt = t,
    ];
    for (final r in recipes) {
      RecipeService.refreshNumbers(r, stock);
    }
    final ids = await isar.recipes.putAll(recipes);
    for (final (i, d) in picked.indexed) {
      d.recipeId = ids[i];
    }
    job
      ..drafts = [...job.drafts]
      ..status = job.hasWork || job.unsaved.isNotEmpty ? CookbookStatus.open : CookbookStatus.done
      ..updatedAt = t;
    await isar.cookbookImports.put(job);
    return ids;
  });

  /// Undo for [save]: the recipes go, their drafts come back for review.
  Future<void> unsave(int id, List<int> recipeIds) => isar.writeTxn(() async {
    await isar.recipes.deleteAll(recipeIds);
    final job = await isar.cookbookImports.get(id);
    if (job == null) return;
    final ids = recipeIds.toSet();
    job
      ..drafts = [for (final d in job.drafts) ids.contains(d.recipeId) ? (d..recipeId = null) : d]
      ..status = CookbookStatus.open
      ..updatedAt = now();
    await isar.cookbookImports.put(job);
  });

  /// Sets an import aside (Undo: [restore]). Its file goes with the next import.
  Future<void> discard(int id) => _update(id, (j) => j.status = CookbookStatus.discarded);

  Future<void> restore(int id) => _update(id, (j) => j.status = CookbookStatus.open);

  /// Points cookbook ingredients that weren't in the pantry at items bought since, and
  /// refreshes those recipes' numbers. Returns how many recipes changed.
  Future<int> relink() => isar.writeTxn(() async {
    final recipes = await isar.recipes.filter().originEqualTo(RecipeOrigin.cookbook).findAll();
    if (recipes.isEmpty) return 0;
    final pantry = await isar.ingredients.where().findAll();
    final stock = StockIndex(pantry);
    final matcher = CookbookMatcher(pantry);
    final changed = [
      for (final r in recipes)
        if (CookbookReview.relink(r, stock, matcher)) r,
    ];
    for (final r in changed) {
      RecipeService.refreshNumbers(r, stock);
    }
    await isar.recipes.putAll(changed);
    return changed.length;
  });
}
