// Side-by-side model eval on your own data.
//
// Runs the app's real Today's Pick and receipt-scan code once per model, with the
// fallback switched off, on a throwaway copy of a backup, and writes a report.
//
//   GEMINI_API_KEY=... \
//   EVAL_BACKUP=~/Downloads/trackcalfin-backup.json \
//   EVAL_RECEIPTS=~/Desktop/receipts \
//   flutter test tool/model_eval_test.dart
//
// EVAL_BACKUP    Required. Settings → Export backup (pantry, profile and history).
// EVAL_RECEIPTS  Optional folder of receipt photos: one image per receipt, or one
//                subfolder per receipt photographed in several parts.
// EVAL_DAYS      Consecutive days of Today's Pick per model (default 3).
// EVAL_MODELS    Comma-separated (default gemini-3.5-flash-lite,gemini-3.8-flash).
//
// The report lands in build/model_eval/<timestamp>/report.md, raw responses next to it.
// Free tier: gemini-3.8-flash allows 20 requests a day and 5 a minute. The eval waits
// out a per-minute limit once and skips a model's remaining cases after its daily limit.

// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';
import 'package:trackcalfin/application/ai_gateway.dart';
import 'package:trackcalfin/application/backup_service.dart';
import 'package:trackcalfin/application/daily_pick_service.dart';
import 'package:trackcalfin/application/profile_service.dart';
import 'package:trackcalfin/application/scan_service.dart';
import 'package:trackcalfin/core/currency.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/core/money.dart';
import 'package:trackcalfin/data/ai/context_builders.dart';
import 'package:trackcalfin/data/ai/gemini_client.dart';
import 'package:trackcalfin/data/ai/prompt_repository.dart';
import 'package:trackcalfin/data/isar/collections/schemas.dart';
import 'package:trackcalfin/platform/image_store.dart';
import 'package:trackcalfin/platform/secret_store.dart';

import '../test/support/test_db.dart';

final _env = Platform.environment;

String? _path(String name) {
  final v = _env[name]?.trim();
  if (v == null || v.isEmpty) return null;
  return v.replaceFirst(RegExp('^~'), _env['HOME'] ?? '~');
}

void main() {
  final key = _env['GEMINI_API_KEY']?.trim() ?? '';
  final backup = _path('EVAL_BACKUP');
  test(
    'model eval',
    () async {
      final models = (_env['EVAL_MODELS'] ?? 'gemini-3.5-flash-lite,gemini-3.8-flash')
          .split(',')
          .map((m) => m.trim())
          .where((m) => m.isNotEmpty)
          .toList();
      final eval = _Eval(
        apiKey: key,
        backupJson: await File(backup!).readAsString(),
        models: models,
        days: int.tryParse(_env['EVAL_DAYS'] ?? '') ?? 3,
        receipts: _receiptCases(_path('EVAL_RECEIPTS')),
        out: Directory('build/model_eval/${DateFormat('yyyyMMdd-HHmm').format(DateTime.now())}'),
      );
      await eval.run();
      print('Report: ${File('${eval.out.path}/report.md').absolute.path}');
    },
    skip: key.isEmpty || backup == null ? 'Set GEMINI_API_KEY and EVAL_BACKUP to run the model eval' : false,
    timeout: Timeout.none,
  );
}

const _imageExt = ['.jpg', '.jpeg', '.png', '.heic', '.webp'];

bool _isImage(FileSystemEntity e) => e is File && _imageExt.any((x) => e.path.toLowerCase().endsWith(x));

String _base(String path) => path.split(Platform.pathSeparator).last;

/// One image per receipt, or one subfolder per multi-part receipt.
List<_ReceiptCase> _receiptCases(String? dir) {
  if (dir == null) return const [];
  final entries = Directory(dir).listSync()..sort((a, b) => a.path.compareTo(b.path));
  return [
    for (final e in entries)
      if (_isImage(e))
        _ReceiptCase(_base(e.path), [e.path])
      else if (e is Directory)
        _ReceiptCase(_base(e.path), [
          for (final f in e.listSync()..sort((a, b) => a.path.compareTo(b.path)))
            if (_isImage(f)) f.path,
        ]),
  ].where((c) => c.images.isNotEmpty).toList();
}

class _ReceiptCase {
  _ReceiptCase(this.name, this.images);
  final String name;
  final List<String> images;
}

class _PickRun {
  _PickRun(this.day);
  final DateTime day;
  bool skipped = false;
  Recipe? recipe;
  String? error;
  bool insufficientStock = false;
  AiCallLog? log;
  int compatLevel = 0;

  /// Inventory items with days_left ≤ 3 that day, and which of them the recipe used.
  Map<String, int> spoiling = {};
  List<String> rescued = [];
}

class _ScanRun {
  bool skipped = false;
  ScanJob? job;
  String? error;
  bool autoFiled = false;
  AiCallLog? log;
  int compatLevel = 0;
}

class _Eval {
  _Eval({
    required this.apiKey,
    required this.backupJson,
    required this.models,
    required this.days,
    required this.receipts,
    required this.out,
  });

  final String apiKey;
  final String backupJson;
  final List<String> models;
  final int days;
  final List<_ReceiptCase> receipts;
  final Directory out;

  final prompts = PromptRepository((p) => File(p).readAsString());
  final _dailyQuotaHit = <String>{};
  final picks = <String, List<_PickRun>>{};
  final scans = <String, Map<String, _ScanRun>>{};
  late UserProfile profile;
  late int pantrySize;
  late final DateTime start = () {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day, 11);
  }();

  Future<void> run() async {
    Directory('${out.path}/raw').createSync(recursive: true);
    final probe = await _freshDb();
    profile = (await probe.userProfiles.get(1))!;
    pantrySize = await probe.ingredients.count();
    await closeTestDb(probe);

    for (final m in models) {
      print('$m: $days days of Today\'s Pick');
      picks[m] = await _dailyPicks(m);
      scans[m] = {};
      for (final c in receipts) {
        print('$m: receipt ${c.name}');
        scans[m]![c.name] = await _scan(m, c);
      }
    }
    File('${out.path}/report.md').writeAsStringSync(_report());
  }

  Future<Isar> _freshDb() async {
    final isar = await openTestDb();
    await BackupService(isar).importJson(backupJson);
    return isar;
  }

  AiGateway _gateway(Isar isar, String model) =>
      AiGateway(isar: isar, secrets: MemorySecretStore(apiKey), prompts: prompts, model: model, fallbackModel: null);

  static bool _isRateLimit(String e) {
    final m = e.toLowerCase();
    return m.contains('quota') || m.contains('rate limit') || m.contains('exhausted');
  }

  /// Runs one case, waiting out a per-minute limit once. After a daily limit the
  /// model's remaining cases are skipped.
  Future<T> _attempt<T>(String model, T skipped, Future<(T, String?)> Function() once) async {
    if (_dailyQuotaHit.contains(model)) return skipped;
    for (var tries = 0; ; tries++) {
      // A 400 from one model must not simplify the request for the next one.
      GeminiClient.compatLevel = 0;
      final (result, error) = await once();
      final e = error ?? '';
      if (e.contains('Daily free-tier limit')) {
        print('  $model: daily limit reached, skipping its remaining cases');
        _dailyQuotaHit.add(model);
        return skipped;
      }
      if (tries == 0 && _isRateLimit(e)) {
        print('  $model: rate limited, waiting 65 s');
        await Future<void>.delayed(const Duration(seconds: 65));
        continue;
      }
      return result;
    }
  }

  Future<List<_PickRun>> _dailyPicks(String model) async {
    final isar = await _freshDb();
    try {
      final ai = _gateway(isar, model);
      final clock = ProfileService.clockFor(profile);
      final runs = <_PickRun>[];
      for (var d = 0; d < days; d++) {
        final t = start.add(Duration(days: d));
        runs.add(
          await _attempt(model, _PickRun(t)..skipped = true, () async {
            final run = _PickRun(t);
            final ingredients = await isar.ingredients.where().findAll();
            final ctx = ContextBuilders.daily(
              profile: profile,
              ingredients: ingredients,
              now: t,
              forDate: t,
              recentTitles: const [],
            );
            for (final i in (ctx['inventory'] as List).cast<Map>()) {
              final left = i['days_left'];
              if (left is int && left <= 3) run.spoiling['${i['key']}'] = left;
            }
            final logsBefore = await isar.aiCallLogs.count();
            // Earlier days' picks stay in the DB, so recent_recipes fills up like in the app.
            final res = await DailyPickService(isar: isar, ai: ai, now: () => t).generate(clock.dateKey(t));
            final logs = await isar.aiCallLogs.where().findAll();
            run
              ..recipe = res.recipe
              ..error = res.recipe == null ? res.error : null
              ..insufficientStock = res.shopping.isNotEmpty
              ..log = logs.length > logsBefore ? logs.last : null
              ..compatLevel = GeminiClient.compatLevel
              ..rescued = [
                for (final i in res.recipe?.ingredients ?? const <RecipeIngredient>[])
                  if (run.spoiling.containsKey(i.key)) i.key,
              ];
            _saveRaw('day${d + 1}', model, run.log);
            return (run, run.log?.error);
          }),
        );
      }
      return runs;
    } finally {
      await closeTestDb(isar);
    }
  }

  Future<_ScanRun> _scan(String model, _ReceiptCase c) => _attempt(model, _ScanRun()..skipped = true, () async {
    final isar = await _freshDb();
    final tmp = await Directory.systemTemp.createTemp('trackcalfin_eval_');
    try {
      // Auto-filing on means ScanResult.autoCommitted reports whether the scan was clean enough.
      final p = (await isar.userProfiles.get(1))!..autoCommitCleanScans = true;
      await isar.writeTxn(() => isar.userProfiles.put(p));
      final svc = ScanService(
        isar: isar,
        images: ImageStore(tmp.path, compressor: _shrinkLikeThePhone),
        ai: _gateway(isar, model),
      );
      final id = await svc.enqueue(c.images, hint: 'receipt');
      final res = await svc.process(id);
      final job = (await isar.scanJobs.get(id))!;
      final run = _ScanRun()
        ..job = job
        ..autoFiled = res?.autoCommitted ?? false
        ..log = job.aiCallLogId == null ? null : await isar.aiCallLogs.get(job.aiCallLogId!)
        ..compatLevel = GeminiClient.compatLevel;
      run.error = job.status == ScanStatus.needsReview || run.autoFiled ? null : (job.lastError ?? run.log?.error);
      _saveRaw(c.name, model, run.log);
      return (run, run.log?.error ?? job.lastError);
    } finally {
      await closeTestDb(isar);
      tmp.deleteSync(recursive: true);
    }
  });

  void _saveRaw(String caseName, String model, AiCallLog? log) {
    if (log == null || log.rawResponse.isEmpty) return;
    final safe = caseName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    File('${out.path}/raw/$safe--$model.json').writeAsStringSync(log.rawResponse);
  }

  // ---------------------------------------------------------------------------
  // Report

  MoneyFormat get _home => ProfileService.moneyFor(profile);
  Map<String, dynamic> get _targets => ContextBuilders.targets(profile);

  static String _pct(num v, num target) => target <= 0 ? '–' : '${(v / target * 100).round()}%';
  static String _secs(AiCallLog? l) => l == null ? '–' : '${(l.latencyMs / 1000).toStringAsFixed(1)} s';
  static String _cell(String s) => s.replaceAll('|', '/').replaceAll('\n', ' ');
  static String _yes(bool b) => b ? 'yes' : 'no';

  String _row(String label, String Function(String model) cell) =>
      '| $label | ${models.map((m) => _cell(cell(m))).join(' | ')} |';

  String _header([String first = '']) =>
      '| $first | ${models.join(' | ')} |\n|---|${models.map((_) => '---').join('|')}|';

  String _count(Iterable<bool> xs) {
    final l = xs.toList();
    return '${l.where((x) => x).length}/${l.length}';
  }

  String _avgLatency(Iterable<AiCallLog?> logs) {
    final ms = logs.whereType<AiCallLog>().map((l) => l.latencyMs).toList();
    if (ms.isEmpty) return '–';
    return '${(ms.reduce((a, b) => a + b) / ms.length / 1000).toStringAsFixed(1)} s';
  }

  String _report() {
    final t = _targets;
    final kcalT = (t['kcal'] as num).toDouble();
    final proteinT = (t['protein_g'] as num).toDouble();
    final costT = t['max_cost_minor'] as int;
    final b = StringBuffer()
      ..writeln('# Model eval · ${DateFormat('d MMM yyyy, HH:mm').format(DateTime.now())}')
      ..writeln()
      ..writeln(
        'Pantry: $pantrySize ingredients. Target per portion: ${kcalT.round()} kcal, '
        '${proteinT.round()} g protein, at most ${_home.format(costT)}. '
        'Every number below is computed by the app, not taken from the model.',
      )
      ..writeln()
      ..writeln('## Summary')
      ..writeln()
      ..writeln(_header());

    List<_PickRun> ran(String m) => picks[m]!.where((r) => !r.skipped).toList();
    List<Recipe> ok(String m) => ran(m).map((r) => r.recipe).whereType<Recipe>().toList();
    b
      ..writeln(_row('**Today\'s Pick**', (_) => ''))
      ..writeln(_row('Valid recipe', (m) => _count(ran(m).map((r) => r.recipe != null))))
      ..writeln(
        _row('… on the first try', (m) => _count(ran(m).map((r) => r.recipe != null && !(r.log?.repaired ?? false)))),
      )
      ..writeln(
        _row('Protein ≥ 85% of target', (m) => _count(ok(m).map((r) => r.perPortion.proteinG >= proteinT * 0.85))),
      )
      ..writeln(
        _row(
          'Calories within ±15%',
          (m) => _count(ok(m).map((r) => (r.perPortion.kcal - kcalT).abs() <= kcalT * 0.15)),
        ),
      )
      ..writeln(_row('Cost within target', (m) => _count(ok(m).map((r) => r.costPerPortionMinor <= costT))))
      ..writeln(
        _row(
          'Used food about to spoil',
          (m) =>
              _count(ran(m).where((r) => r.recipe != null && r.spoiling.isNotEmpty).map((r) => r.rescued.isNotEmpty)),
        ),
      )
      ..writeln(_row('Average time', (m) => _avgLatency(ran(m).map((r) => r.log))));

    if (receipts.isNotEmpty) {
      List<_ScanRun> sran(String m) => scans[m]!.values.where((r) => !r.skipped).toList();
      List<ScanJob> read(String m) =>
          sran(m).where((r) => r.error == null).map((r) => r.job).whereType<ScanJob>().toList();
      b
        ..writeln(_row('**Receipts**', (_) => ''))
        ..writeln(_row('Read', (m) => _count(sran(m).map((r) => r.error == null))))
        ..writeln(
          _row('… on the first try', (m) => _count(sran(m).map((r) => r.error == null && !(r.log?.repaired ?? false)))),
        )
        ..writeln(
          _row(
            'Lines add up to the total',
            (m) =>
                _count(read(m).map((j) => !j.flags.contains('total_mismatch') && !j.flags.contains('total_missing'))),
          ),
        )
        ..writeln(_row('Clean enough to file automatically', (m) => _count(sran(m).map((r) => r.autoFiled))))
        ..writeln(
          _row(
            'Low-confidence lines',
            (m) =>
                '${read(m).expand((j) => j.lines).where((l) => l.confidence == Confidence.low).length}'
                ' of ${read(m).expand((j) => j.lines).length}',
          ),
        )
        ..writeln(
          _row(
            'Receipts with suspect nutrition',
            (m) => '${read(m).where((j) => j.flags.contains('nutrition_suspect')).length}',
          ),
        )
        ..writeln(_row('Average time', (m) => _avgLatency(sran(m).map((r) => r.log))));
    }
    b.writeln(
      _row('Skipped (daily limit)', (m) {
        final n = picks[m]!.where((r) => r.skipped).length + (scans[m]?.values.where((r) => r.skipped).length ?? 0);
        return '$n';
      }),
    );

    b
      ..writeln()
      ..writeln('## Today\'s Pick')
      ..writeln()
      ..writeln('Consecutive days on the same pantry. Earlier picks count as recent recipes, as in the app.');
    for (var d = 0; d < days; d++) {
      _PickRun r(String m) => picks[m]![d];
      b
        ..writeln()
        ..writeln('### Day ${d + 1} · ${DateFormat('EEE d MMM').format(start.add(Duration(days: d)))}')
        ..writeln()
        ..writeln(_header())
        ..writeln(_row('Recipe', (m) => _pickTitle(r(m))))
        ..writeln(
          _row('Per portion', (m) {
            final x = r(m).recipe;
            if (x == null) return '–';
            final n = x.perPortion;
            return '${n.kcal.round()} kcal · ${n.proteinG.round()} g protein · ${_home.format(x.costPerPortionMinor)}';
          }),
        )
        ..writeln(
          _row('vs target', (m) {
            final x = r(m).recipe;
            if (x == null) return '–';
            return 'kcal ${_pct(x.perPortion.kcal, kcalT)} · protein ${_pct(x.perPortion.proteinG, proteinT)} · '
                'cost ${_pct(x.costPerPortionMinor, costT)}';
          }),
        )
        ..writeln(
          _row('About to spoil', (m) {
            final run = r(m);
            if (run.spoiling.isEmpty) return 'nothing';
            return run.spoiling.entries
                .map((e) => '${e.key} (${e.value} d)${run.rescued.contains(e.key) ? ' ✓' : ''}')
                .join(', ');
          }),
        )
        ..writeln(
          _row('Ingredients', (m) {
            final x = r(m).recipe;
            if (x == null) return '–';
            return x.ingredients.map((i) => '${i.key} ${_qty(i.qtyPerPortion)} ${i.unit.label}').join(', ');
          }),
        )
        ..writeln(_row('Why', (m) => r(m).recipe?.why ?? '–'))
        ..writeln(_row('Repair round', (m) => r(m).log == null ? '–' : _yes(r(m).log!.repaired)))
        ..writeln(_row('Flags', (m) => _flags(r(m).recipe?.validationFlags ?? const [], r(m).compatLevel)))
        ..writeln(_row('Time', (m) => _secs(r(m).log)));
    }

    if (receipts.isNotEmpty) {
      b
        ..writeln()
        ..writeln('## Receipts')
        ..writeln()
        ..writeln('Check the lines against the photo: that is where the models differ most.');
      for (final c in receipts) {
        _ScanRun r(String m) => scans[m]![c.name]!;
        b
          ..writeln()
          ..writeln('### ${c.name}')
          ..writeln()
          ..writeln(_header())
          ..writeln(
            _row('Store · date', (m) {
              final j = r(m).job;
              if (r(m).skipped) return 'skipped';
              if (j == null || r(m).error != null) return 'failed: ${r(m).error ?? 'unknown'}';
              final date = j.purchasedAt == null ? 'no date' : DateFormat('yyyy-MM-dd').format(j.purchasedAt!);
              return '${j.merchant ?? 'no store'} · $date · ${j.currency ?? '?'}';
            }),
          )
          ..writeln(
            _row('Lines · sum / total', (m) {
              final j = r(m).job;
              if (j == null || r(m).error != null) return '–';
              final fmt = MoneyFormat(
                currency: j.currency ?? profile.currency,
                digits: Currency.digitsOf(j.currency ?? profile.currency),
              );
              final sum = j.lines.fold(0, (a, l) => a + l.totalMinor);
              final total = j.receiptTotalMinor == null ? 'no total' : fmt.format(j.receiptTotalMinor!);
              return '${j.lines.length} · ${fmt.format(sum)} / $total';
            }),
          )
          ..writeln(_row('Files automatically', (m) => r(m).job == null ? '–' : _yes(r(m).autoFiled)))
          ..writeln(_row('Repair round', (m) => r(m).log == null ? '–' : _yes(r(m).log!.repaired)))
          ..writeln(_row('Flags', (m) => _flags(r(m).job?.flags ?? const [], r(m).compatLevel)))
          ..writeln(_row('Time', (m) => _secs(r(m).log)));
        for (final m in models) {
          final j = r(m).job;
          if (j == null || r(m).error != null || j.lines.isEmpty) continue;
          final fmt = MoneyFormat(
            currency: j.currency ?? profile.currency,
            digits: Currency.digitsOf(j.currency ?? profile.currency),
          );
          b
            ..writeln()
            ..writeln('**$m**')
            ..writeln()
            ..writeln('| Printed | Name | Ingredient | Qty | Price | Confidence |')
            ..writeln('|---|---|---|---|---|---|');
          for (final l in j.lines) {
            final ing = l.ingredientKey == null ? '–' : '${l.ingredientKey}${l.isNewIngredient ? ' (new)' : ''}';
            final qty = l.qty == null ? '–' : '${_qty(l.qty!)} ${l.unit.label} (${l.qtySource.name})';
            b.writeln(
              '| ${_cell(l.rawText)} | ${_cell(l.name)} | $ing | $qty | ${fmt.format(l.totalMinor)} | ${l.confidence.name} |',
            );
          }
        }
      }
    }
    b
      ..writeln()
      ..writeln('Raw model responses are in `raw/`.');
    return b.toString();
  }

  String _pickTitle(_PickRun r) {
    if (r.skipped) return 'skipped';
    final x = r.recipe;
    if (x != null) return '${x.title} (×${x.defaultPortions})';
    if (r.insufficientStock) return 'said the pantry is too empty';
    return 'failed: ${r.error ?? 'unknown'}';
  }

  static String _flags(List<String> flags, int compatLevel) {
    final all = [...flags, if (compatLevel > 0) 'simplified_request_$compatLevel'];
    return all.isEmpty ? '–' : all.join(', ');
  }

  static String _qty(double q) => q == q.roundToDouble() ? '${q.round()}' : q.toStringAsFixed(1);
}

/// What the phone sends: FlutterImageCompress with the short side at 1400 px, JPEG 85.
/// Uses macOS `sips`; elsewhere the original photo is sent.
Future<Uint8List?> _shrinkLikeThePhone(String src) async {
  if (!Platform.isMacOS) return null;
  final info = await Process.run('sips', ['-g', 'pixelWidth', '-g', 'pixelHeight', src]);
  int? dim(String name) => int.tryParse(RegExp('$name: (\\d+)').firstMatch('${info.stdout}')?.group(1) ?? '');
  final w = dim('pixelWidth'), h = dim('pixelHeight');
  if (w == null || h == null) return null;
  final out = '${Directory.systemTemp.path}/trackcalfin_eval_${DateTime.now().microsecondsSinceEpoch}.jpg';
  final resize = math.min(w, h) <= 1400 ? const <String>[] : [w <= h ? '--resampleWidth' : '--resampleHeight', '1400'];
  final r = await Process.run('sips', [
    '-s',
    'format',
    'jpeg',
    '-s',
    'formatOptions',
    '85',
    ...resize,
    src,
    '--out',
    out,
  ]);
  if (r.exitCode != 0) return null;
  final f = File(out);
  final bytes = await f.readAsBytes();
  await f.delete();
  return bytes;
}
