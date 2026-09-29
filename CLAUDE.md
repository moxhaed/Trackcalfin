# Trackcalfin: notes for coding sessions

Flutter app (Android/iOS; Linux desktop for local UI checks) with a local Isar database and Gemini for three tasks. The architecture docs live in `docs/`, and the three system prompts in `assets/prompts/`.

## Commands
- `flutter pub get`
- `flutter analyze` (must be clean)
- `flutter test` (all green; widget smoke tests use the live binding and take ~20 s)
- `dart run build_runner build` after editing `lib/data/isar/collections/*.dart`
- `flutter run -d linux --dart-define=DEMO=true` seeds demo data into an empty DB. Add `--dart-define=THEME=dark` for dark mode.

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
