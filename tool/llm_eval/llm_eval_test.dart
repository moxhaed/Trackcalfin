// LLM-in-the-loop eval of Prompt A (receipts and pantry photos) and Prompt G (Say it).
//
// Each case in tool/llm_eval/cases.json is a pantry, a receipt or photo (described in
// text) or a sentence, and what the pantry must hold once the app has filed the answer.
//
//   1. LLM_EVAL=dump flutter test tool/llm_eval/llm_eval_test.dart
//      Writes build/llm_eval/requests/<case>.md: the system prompt and the user turn the app
//      sends for the case, with the photo's description where the image would be.
//   2. A model answers each request into build/llm_eval/answers/<model>/<case>.json, exactly as
//      Gemini would (the bare JSON object). Any model can stand in; see README.md.
//   3. LLM_EVAL=check flutter test tool/llm_eval/llm_eval_test.dart
//      Runs every answer through the real ScanService or QuickLogService on a fresh test
//      database (Gemini faked to return the answer), files it, checks the pantry and writes
//      build/llm_eval/report.md. An answer the app would reject counts as a failure: in the app
//      it costs a second request (the repair round).
//
// LLM_EVAL_OUT changes the build/llm_eval folder. LLM_EVAL_ONLY=<regex> runs matching cases.

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:trackcalfin/application/ai_gateway.dart';
import 'package:trackcalfin/application/profile_service.dart';
import 'package:trackcalfin/application/quick_log_service.dart';
import 'package:trackcalfin/application/scan_service.dart';
import 'package:trackcalfin/core/enums.dart';
import 'package:trackcalfin/data/ai/dto/enum_codec.dart';
import 'package:trackcalfin/data/ai/dto/quick_log_dto.dart';
import 'package:trackcalfin/data/ai/dto/receipt_dto.dart';
import 'package:trackcalfin/data/ai/gemini_client.dart';
import 'package:trackcalfin/data/ai/prompt_repository.dart';
import 'package:trackcalfin/data/isar/collections/schemas.dart';
import 'package:trackcalfin/domain/units.dart';
import 'package:trackcalfin/platform/image_store.dart';
import 'package:trackcalfin/platform/secret_store.dart';

import '../../test/support/fake_gemini.dart';
import '../../test/support/test_db.dart';

final _env = Platform.environment;
String get _out => _env['LLM_EVAL_OUT'] ?? 'build/llm_eval';

void main() {
  final mode = _env['LLM_EVAL'];
  test(
    'LLM eval: $mode',
    () async {
      final spec = jsonDecode(File('tool/llm_eval/cases.json').readAsStringSync()) as Map<String, dynamic>;
      final only = _env['LLM_EVAL_ONLY'];
      final cases = [
        for (final c in (spec['cases'] as List).cast<Map<String, dynamic>>())
          if (only == null || RegExp(only).hasMatch(c['id'] as String)) c,
      ];
      final eval = _Eval(spec, DateTime.parse(spec['now'] as String));
      if (mode == 'dump') {
        for (final c in cases) {
          await eval.dump(c);
        }
        print('Wrote ${cases.length} requests to $_out/requests');
      } else {
        await eval.check(cases);
      }
    },
    skip: mode == 'dump' || mode == 'check' ? false : 'Set LLM_EVAL=dump or LLM_EVAL=check',
    timeout: Timeout.none,
  );
}

class _Eval {
  _Eval(this.spec, this.now);
  final Map<String, dynamic> spec;
  final DateTime now;

  /// A stand-in for the image: the eval sends the photo's description as text.
  static const _photoBytes = [0xFF, 0xD8, 0xFF, 0xD9];

  List<Map<String, dynamic>> _pantry(Map<String, dynamic> c) {
    if (c['kind'] == 'scan') return (c['pantry'] as List? ?? const []).cast<Map<String, dynamic>>();
    final remove = {...(c['pantry_remove'] as List? ?? const [])};
    final override = {for (final o in (c['pantry_override'] as List? ?? const [])) (o as Map)['key']: o};
    return [
      for (final i in (spec['kitchen'] as List).cast<Map<String, dynamic>>())
        if (!remove.contains(i['key'])) (override[i['key']] as Map<String, dynamic>?) ?? i,
      ...(c['pantry_add'] as List? ?? const []).cast<Map<String, dynamic>>(),
    ];
  }

  Future<({Isar isar, FakeGemini fake, AiGateway ai, Directory tmp})> _world(Map<String, dynamic> c) async {
    GeminiClient.compatLevel = 0;
    final isar = await openTestDb();
    await ProfileService(isar).load();
    final p = (await isar.userProfiles.get(1))!
      ..country = (c['country'] as String?) ?? 'DE'
      ..currency = (c['currency'] as String?) ?? 'EUR'
      ..currencyMinorDigits = 2
      ..outputLanguage = 'en'
      ..lookUpPrices = false
      ..autoCommitCleanScans = false;
    await isar.writeTxn(() async {
      await isar.userProfiles.put(p);
      for (final m in _pantry(c)) {
        await isar.ingredients.put(_ingredient(m));
      }
    });
    final fake = FakeGemini();
    final ai = AiGateway(
      isar: isar,
      secrets: MemorySecretStore('eval-key'),
      prompts: PromptRepository(loadPromptAsset),
      httpClient: fake.client,
    );
    return (isar: isar, fake: fake, ai: ai, tmp: await Directory.systemTemp.createTemp('llm_eval_'));
  }

  Ingredient _ingredient(Map<String, dynamic> m) {
    final unit = BaseUnit.values.byName(m['unit'] as String);
    return Ingredient()
      ..key = m['key'] as String
      ..name = m['name'] as String
      ..baseUnit = unit
      ..category = EnumCodec.ingredientCategory[m['category']] ?? IngredientCategory.other
      ..qtyOnHand = (m['on_hand'] as num).toDouble()
      ..gramsPerPiece = (m['gpp'] as num?)?.toDouble()
      ..pieceName = m['piece'] as String?
      ..densityGPerMl = (m['density'] as num?)?.toDouble()
      ..avgCostPerUnitMinor = (m['cost'] as num?)?.toDouble() ?? 0
      ..per100 = Nutrition(kcal: 100, proteinG: 3, carbsG: 15, fatG: 3)
      ..nutritionSource = DataSource.aiEstimate
      ..shelfLifeDays = 60
      ..lastPurchasedAt = now.subtract(const Duration(days: 2))
      ..lastPurchaseQty = (m['on_hand'] as num).toDouble()
      ..updatedAt = now;
  }

  Future<void> _close(({Isar isar, FakeGemini fake, AiGateway ai, Directory tmp}) w) async {
    await closeTestDb(w.isar);
    await w.tmp.delete(recursive: true);
  }

  ScanService _scans(({Isar isar, FakeGemini fake, AiGateway ai, Directory tmp}) w) =>
      ScanService(isar: w.isar, images: ImageStore('${w.tmp.path}/store'), ai: w.ai, now: () => now);

  Future<int> _enqueue(({Isar isar, FakeGemini fake, AiGateway ai, Directory tmp}) w, Map<String, dynamic> c) async {
    final f = File('${w.tmp.path}/photo.jpg')..writeAsBytesSync(_photoBytes);
    return _scans(w).enqueue([f.path], hint: c['hint'] as String?);
  }

  /// The request the app sends for [c], captured from the faked Gemini.
  Future<void> dump(Map<String, dynamic> c) async {
    final w = await _world(c);
    try {
      if (c['kind'] == 'scan') {
        w.fake.replyJson({
          'schema_version': 1,
          'image_type': 'unreadable',
          'stock_mode': 'none',
          'merchant': null,
          'purchased_at': null,
          'purchased_time': null,
          'currency': 'EUR',
          'receipt_total_minor': null,
          'items': [],
          'warnings': ['dump'],
        });
        await _scans(w).process(await _enqueue(w, c));
      } else {
        w.fake.replyJson({'schema_version': 1, 'actions': [], 'total_paid_minor': null, 'question': 'dump'});
        await QuickLogService(isar: w.isar, ai: w.ai, now: () => now).interpret(c['said'] as String);
      }
      final body = w.fake.requests.first;
      final system = ((body['systemInstruction'] as Map)['parts'] as List).first['text'] as String;
      final parts = ((body['contents'] as List).last as Map)['parts'] as List;
      final text = parts.where((p) => (p as Map).containsKey('text')).map((p) => (p as Map)['text']).join('\n');
      final images = parts.where((p) => (p as Map).containsKey('inlineData')).length;
      final b = StringBuffer()
        ..writeln('# SYSTEM PROMPT')
        ..writeln()
        ..writeln(system.trim())
        ..writeln()
        ..writeln('# USER TURN')
        ..writeln();
      if (images > 0) {
        b
          ..writeln('## Image 1 (described in words; treat it as the photo you are looking at)')
          ..writeln()
          ..writeln(c['photo'])
          ..writeln();
      }
      b
        ..writeln('## Text')
        ..writeln()
        ..writeln(text.trim());
      File('$_out/requests/${c['id']}.md')
        ..createSync(recursive: true)
        ..writeAsStringSync(b.toString());
    } finally {
      await _close(w);
    }
  }

  Future<void> check(List<Map<String, dynamic>> cases) async {
    final dir = Directory('$_out/answers');
    final models = dir.existsSync()
        ? (dir.listSync().whereType<Directory>().toList()..sort((a, b) => a.path.compareTo(b.path)))
        : <Directory>[];
    if (models.isEmpty) fail('No answers in ${dir.path}: one folder per model, one <case>.json per case.');
    final report = StringBuffer('# LLM eval\n\n');
    final summary = <String>[];
    for (final m in models) {
      final model = m.uri.pathSegments.where((s) => s.isNotEmpty).last;
      var passed = 0, answered = 0;
      final rows = StringBuffer();
      for (final c in cases) {
        final f = File('${m.path}/${c['id']}.json');
        if (!f.existsSync()) continue;
        answered++;
        final r = await _run(c, f.readAsStringSync());
        if (r.ok) passed++;
        rows.writeln('### ${r.ok ? 'PASS' : 'FAIL'} · ${c['id']}\n');
        for (final n in r.notes) {
          rows.writeln('- $n');
        }
        rows.writeln();
      }
      summary.add('$model: $passed / $answered passed');
      report
        ..writeln('## $model: $passed / $answered passed\n')
        ..write(rows);
    }
    final out = File('$_out/report.md')
      ..createSync(recursive: true)
      ..writeAsStringSync(report.toString());
    print(summary.join('\n'));
    print('Report: ${out.path}');
  }

  Future<({bool ok, List<String> notes})> _run(Map<String, dynamic> c, String answer) async {
    final notes = <String>[];
    Map<String, dynamic> json;
    try {
      json = jsonDecode(GeminiClient.stripFences(answer)) as Map<String, dynamic>;
    } catch (e) {
      return (ok: false, notes: ['not JSON: $e']);
    }
    final w = await _world(c);
    try {
      if (c['kind'] == 'scan') {
        final parsed = ReceiptExtraction.parse(json);
        if (!parsed.ok) {
          return (ok: false, notes: ['rejected by the app (a repair request): ${parsed.errors.join('; ')}']);
        }
        w.fake.replyJson(json);
        final s = _scans(w);
        final id = await _enqueue(w, c);
        await s.process(id);
        final job = (await w.isar.scanJobs.get(id))!;
        if (job.status == ScanStatus.failed) return (ok: false, notes: ['scan failed: ${job.lastError}']);
        for (final l in job.lines.where((l) => l.ingredientKey != null)) {
          notes.add(
            'line `${l.ingredientKey}`: ${l.qty == null ? '?' : UnitConverter.format(l.qty!, l.unit, piece: l.pieceName)}'
            '${l.switchFrom == null ? '' : ' (switches the item from ${l.switchFrom!.label} to pieces)'}'
            '${l.include ? '' : ' (left out)'}',
          );
        }
        if (job.flags.isNotEmpty) notes.add('flags: ${job.flags.join(', ')}');
        if (job.status == ScanStatus.needsReview) await s.commit(id);
      } else {
        final ctx = QuickLogContext(
          now: now,
          pantry: {for (final i in await w.isar.ingredients.where().findAll()) i.key: i.baseUnit},
          fridge: const {},
          recipes: const {},
        );
        final parsed = QuickLog.parse(json, ctx: ctx);
        if (!parsed.ok) {
          return (ok: false, notes: ['rejected by the app (a repair request): ${parsed.errors.join('; ')}']);
        }
        w.fake.replyJson(json);
        final s = QuickLogService(isar: w.isar, ai: w.ai, now: () => now);
        final draft = await s.interpret(c['said'] as String);
        if (draft.error != null) return (ok: false, notes: ['Say it failed: ${draft.error}']);
        for (final st in draft.steps) {
          notes.add('step: ${st.title}${st.detail == null ? '' : ' · ${st.detail}'}');
        }
        if (draft.question != null) notes.add('question: ${draft.question}');
        await s.apply(draft.log!);
      }
      if (w.fake.requests.length > 1) notes.add('${w.fake.requests.length} requests');
      final all = await w.isar.ingredients.where().findAll();
      var ok = w.fake.requests.length == 1;
      for (final e in (c['expect'] as List).cast<Map<String, dynamic>>()) {
        final re = RegExp(e['key'] as String);
        final hits = all.where((i) => re.hasMatch(i.key)).toList();
        if (hits.isEmpty) {
          ok = false;
          notes.add('MISSING an item matching /${e['key']}/ (pantry: ${all.map((i) => i.key).join(', ')})');
          continue;
        }
        final i = hits.first;
        final got = '${i.key} = ${_fmt(i)}';
        final options = e['any'] == null ? [e] : (e['any'] as List).cast<Map<String, dynamic>>();
        final miss = <String>[];
        final good = options.any((o) {
          final why = _mismatch(i, o);
          if (why != null) miss.add(why);
          return why == null;
        });
        if (!good) ok = false;
        notes.add('${good ? 'ok' : 'WRONG'}: $got${good ? '' : ' (${miss.join(' / ')})'}');
      }
      return (ok: ok, notes: notes);
    } finally {
      await _close(w);
    }
  }

  static String _fmt(Ingredient i) => UnitConverter.format(i.qtyOnHand, i.baseUnit, piece: i.pieceName);

  static String? _mismatch(Ingredient i, Map<String, dynamic> e) {
    final unit = e['unit'] as String?;
    if (unit != null && i.baseUnit.name != unit) return 'want $unit';
    final piece = e['piece'] as String?;
    if (piece != null && i.baseUnit == BaseUnit.pc && !RegExp(piece).hasMatch(i.pieceName ?? '')) {
      return 'want pieces called /$piece/';
    }
    final range = (e['on_hand'] as List?)?.cast<num>();
    if (range != null && (i.qtyOnHand < range[0] - 1e-6 || i.qtyOnHand > range[1] + 1e-6)) {
      return 'want ${range[0] == range[1] ? range[0] : '${range[0]}–${range[1]}'}';
    }
    return null;
  }
}
