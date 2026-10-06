# Trackcalfin: notes for coding sessions

Flutter app (Android/iOS; Linux desktop for local UI checks) with a local Isar database and Gemini for five tasks: receipts, Today's Pick, Ask, and ingredient macros (estimates and label reading). The architecture docs live in `docs/`, and the system prompts in `assets/prompts/`.

## Commands
- `flutter pub get`
- `flutter analyze` (must be clean)
- `flutter test` (all green; widget smoke tests use the live binding and take ~20 s)
- `dart run build_runner build` after editing `lib/data/isar/collections/*.dart`
- `flutter run -d linux --dart-define=DEMO=true` seeds demo data into an empty DB. Add `--dart-define=THEME=dark` for dark mode.
- `flutter test tool/screenshots_test.dart [--dart-define=THEME=dark]` renders every major screen on demo data at phone size into `build/screenshots/<theme>/` (`SHOTS_DIR`, `SHOTS_ONLY=01-,07-` to filter). Check visual changes with it.
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
- Undo instead of confirm: hot paths commit on the last tap and show `showUndo`.

## Design system
- `docs/design/DESIGN_SYSTEM.md` is the source of truth for type, color, spacing and components; `SCREENS.md` has per-screen specs. Tokens live in `lib/app/theme.dart` (`AppSpace`, `AppRadius`, `AppMotion`, `context.nums`, `context.colors`); shared widgets in `lib/features/common/widgets.dart`. Reuse them; don't hard-code colors or sizes.
- Multi-line titles use `NoWidowText`, " · " meta lines `SeparatedText`, numbers with units `valueSpan` (one `Text.rich`). Status is never shown by color alone.
- Widget tests find copy with `textExact`/`textCI` from `test/support/app_harness.dart` (they treat no-break spaces as spaces). `docs/redesign/BASELINE.md` lists the UI contract each screen must keep.
