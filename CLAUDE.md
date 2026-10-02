# Trackcalfin: notes for coding sessions

Flutter app (Android/iOS; Linux desktop for local UI checks) with a local Isar database and Gemini for seven tasks: receipts, Today's Pick, Ask, ingredient macros (estimates and label reading), shop prices for pantry photos (Google Search grounding), and Say it (logging what the user says they did, or asking where food is cheaper). The architecture docs live in `docs/`, and the system prompts in `assets/prompts/`.

## Commands
- `flutter pub get`
- `flutter analyze` (must be clean)
- `flutter test` (all green; widget smoke tests use the live binding and take ~20 s)
- `dart run build_runner build` after editing `lib/data/isar/collections/*.dart`
- `flutter run -d linux --dart-define=DEMO=true` seeds demo data into an empty DB. Add `--dart-define=THEME=dark` for dark mode.
- `--dart-define=GEMINI_BASE_URL=http://127.0.0.1:8765/v1beta` sends AI calls to a local stand-in instead of Google, to check AI screens on the desktop. The desktop build reads its key from `.gemini_key` in the app support directory when there is no keyring.
- `GEMINI_API_KEY=... EVAL_BACKUP=backup.json flutter test tool/model_eval_test.dart` compares Gemini models on real data (Today's Pick and receipts) and writes `build/model_eval/*/report.md`. It spends real quota; options are in the file header.

## Gotchas
- `build_runner` is pinned to 2.15.1 because `isar_community_generator` 3.3.2 needs `analyzer < 11`. Don't bump it on its own.
- Never run `dart format` on `*.g.dart`. CI checks that generated code matches a fresh `build_runner` run. Format with `dart format -l 120 $(git ls-files 'lib/*.dart' 'test/*.dart' | grep -v '\.g\.dart$')`.
- Tests load `libisar.so` from `isar_community_flutter_libs` in the pub cache (`test/support/test_db.dart`). No download is needed.
- Isar query extension methods (`findAll`, `findFirst`, ...) need `import 'package:isar_community/isar.dart';` in the calling file.
- Prompts are versioned assets. Change one by adding `*.v2.md`, update `PromptRepository`, and keep the prompt's example JSON parseable. `test/data/ai_layer_test.dart` parses it with the app DTOs.

## Architecture rules
- LLM proposes, Dart disposes: every number shown in the UI (cost, macros, feasibility) is recomputed in Dart (`lib/domain`).
- One use case = one Isar write transaction (`lib/application`).
- `lib/domain` has no I/O and never touches an `Isar` instance.
- Cooking deducts stock and creates a `CookSession` (the fridge). Intake is logged when a portion is eaten (`DailyLog`).
- Nothing is assumed to be in the kitchen: there are no staples. Every recipe ingredient is a pantry item (counted, deducted and costed, salt and oil included) or `missing`.
- A receipt is filed on its printed date. Checks that need what the app knows (an old date, an item counted since, a duplicate receipt) are pure Dart in `ReceiptValidator`/`ScanService` and hold the scan for review (docs/03 §3.16).
- Undo instead of confirm: hot paths commit on the last tap and show `showUndo`.
