# Implementation plan

The work goes global primitives first, then screens. Each phase ends with a screenshot round
(`shots.sh <round> "<filters>" "light dark"`), a Director critique, and Guardian verification
before the orchestrator commits. **Target per screen: overall ≥ 8.5, with no critical category
(hierarchy, typography, color, consistency, usability) below 8.** Phases 0–2 aren't scored per
screen. They're judged on whether the primitives match `DESIGN_SYSTEM.md` exactly.

Rules for every phase:
- `flutter analyze` is clean, `flutter test` is green (the Guardian updates the flagged finders
  listed in `SCREENS.md` → "Summary of flags"), and `dart format -l 120` passes.
- No changes outside the Implementer's paths. Behavior, providers and use cases stay untouched.
- Each phase keeps the app fully working. No half-migrated screen ships in a commit.

---

## Phase 0: Foundations (tokens, type, color)
**Files**: `assets/fonts/Inter/*`, `pubspec.yaml` (`fonts:`), `lib/app/theme.dart`.
1. Add the Inter 400/500/600/700 TTFs + `OFL.txt` (DESIGN_SYSTEM §2.1) and the pubspec `fonts:` block.
2. `AppSpace`, `AppRadius`, `AppMotion` constants. Add an `AppNumbers` ThemeExtension and
   `context.nums`.
3. Build an explicit `ColorScheme` for light and dark (§4.1, 4.2, 4.4). Drop `fromSeed`.
4. `AppColors`: new values plus the new fields (`fill`, `fillStrong`, `separator`,
   `textTertiary`, `goodInk`, `warningInk`, `criticalInk`), `inkForPace`, and real
   `copyWith`/`lerp`.
5. The full `TextTheme` (§2.2) with `leadingDistribution.even`.
6. Component themes (§12): app bar, card, list tile, buttons, icon buttons, inputs, chips,
   switch, checkbox, bottom sheet, dialog, popup menu, snackbar, badge, divider, progress,
   tooltip, page transitions, `splashFactory: NoSplash`, `materialTapTargetSize: padded`.

**Definition of done**: all 27 shots render in both themes with no overflow stripes and no
missing glyphs (shot 13 shows "→"), and nothing mint remains on canvas, cards, chips or nav.
Director check on contact sheets: typography ≥ 7 and color ≥ 7 app-wide, even before the
layout work.

## Phase 1: Navigation and page headers
**Files**: `lib/app/floating_nav.dart`, `lib/app/shell.dart`, the app bars of every screen.
1. Floating pill and ⊕ per §7.17 (height 60, neutral indicator, accent selected, blur, shadows,
   ⊕ press scale, haptics, badge theme).
2. Tab-root headers: large title 30/36 (Dashboard date, Buy, Cook, Settings) and the
   Quick-check capsule button.
3. Pushed-screen compact bars (17 w600, adaptive back with tooltip "Back").

**DoD**: shots 01, 04, 07, 14, 11, 09, 20, 27 (light + dark). The nav and headers score ≥ 8.5
on hierarchy, consistency and polish. The snackbar still sits above the pill (27). The iOS 26
code path still compiles (no change to `_GlassNav` beyond reading the new `scheme.primary`).

## Phase 2: Shared components (`lib/features/common/widgets.dart`)
1. `SectionCard` (sentence case, 17 w600 title, trailing slot alignment).
2. New: `AppGroup`, `AppRow`, `SectionTitle`, `GroupHeader`, `AppNotice`, `AppSegmented`,
   `AppSkeleton`, `Tag`, `PantryTile`, `CaptureTile`.
3. Restyle: `PaceBar` (marker), `RingGauge` (Vibe-only spec), `WeekBars`, `StatusPill`
   (label, no container, `ink`), `PortionStepper`, `Metric`, `EmptyState` (glyph circle),
   `showUndo/showUndoOn/showInfo` (message + detail layout).
4. Keep the public names and tooltips (SCREENS "Global changes" 4).

**DoD**: the app compiles, every screen still renders (some still on old layouts), and the
Guardian has updated the 🔵 casing finders (TODAY, FOOD SPEND, OTHER SPEND · MONTH, CALORIES
THIS WEEK, USE SOON, IN THE FRIDGE, COOK AGAIN, NUTRITION PER 100 G), since `SectionCard` and
the header helpers stop uppercasing here. Shots 01, 05, 07, 26 rendered for a sanity check.

## Phase 3: Dashboard
`dashboard_screen.dart` per SCREENS §1: Vibe hero on the canvas, the Today card with two
linear bars, Food spend, Other spend two-line rows, Calories this week, the vibe sheet, the
skeleton loading state, the error notice. ⚫ grouping for the kcal target.

**DoD**: shots 01, 02, 03, 26 (light + dark) score **≥ 8.5 overall**, every category ≥ 8. The
smoke test and display-fidelity test are green (the Guardian has adjusted `value('2200')`).

## Phase 4: Cook and Recipe detail
`cook_screen.dart` (ask field with internal mic, the pick card as hero, fridge and cook-again
groups with section titles, states), `recipe_detail_screen.dart` (verdict notice, title, Per
portion card with 2 metric rows, ingredients group, to buy, steps card, tags, bottom bar with
hairline and blur), the long-press sheet, `cook_actions.dart` snackbar layout (message/detail
split).

**DoD**: shots 07, 08 (with the tool scroll fix), 09, 10, 27 score ≥ 8.5. The reachability
tests for cook and recipe pass unchanged except the 🔵 casing finders.

## Phase 5: Buy (Pantry, Ledger, Item sheet) and Inbox/Review
`buy_screen.dart` (header Add menu 🟠, segmented, scan status row), `pantry_view.dart` (search,
notice, tiles, groups with category headers, out of stock, staples, review row),
`ledger_view.dart` (choice chips, day groups), `ingredient_sheet.dart` (big stepper, inset
nutrition panel, edit form), `inbox_screen.dart`, `review_screen.dart`, `fx_widgets.dart`
(`AppNotice`-based conversion, rate and currency sheets), `transaction_sheet.dart`.

**DoD**: shots 04, 05, 06, 11, 12, 13, 24 (with the tool tap fix) score ≥ 8.5. The Guardian has
updated the Buy reachability test for the Add menu (open "Add", then find the four item labels).

## Phase 6: Capture and log sheets
`capture_sheet.dart` (title + tiles), `ate_sheet.dart`, `expense_sheet.dart` (hero amount, a
2-column category grid 🟠), `cooked_sheet.dart`.

**DoD**: shots 20, 21, 22, 23 score ≥ 8.5. Every commit path still takes the same number of
taps (expense: amount → category = 1 tap).

## Phase 7: Settings, Stats, Quick check, Recipe editor
`settings_screen.dart` (groups, chip cells, switch rows, AI cell, segmented theme, data rows,
dialogs), `stats_screen.dart`, `quick_check_screen.dart` (card, buttons, done state, **cold-start
fix** once the Guardian agrees), `recipe_editor_screen.dart`.

**DoD**: shots 14, 15, 16, 17 (deck visible when opened cold), 25 score ≥ 8.5.

## Phase 8: Onboarding
`onboarding_screen.dart`: left-aligned pages, the brand-mark `CustomPainter` on the welcome
page, full-width bottom actions, group rows for the sweep, `PortionStepper` in rhythm.

**DoD**: shots 18, 19 score ≥ 8.5. The smoke test's onboarding steps pass ("Your kitchen, on
autopilot", "Get started", "Your goals").

## Phase 9: States, dark mode, motion and accessibility pass
1. Empty / loading / error states everywhere per §7.18 (no full-screen spinners left:
   `grep -rn CircularProgressIndicator lib/features` should only show inline 16 px uses).
2. Motion: `AnimatedSwitcher` for changed numbers, `AnimatedSize` for expanders, the sheet
   animation style, reduced-motion handling.
3. Accessibility: semantics labels on the ring, bars and week bars; `header: true` on titles;
   1.3× text-scale check.
4. Optional extra shots (Implementer, in `tool/screenshots_test.dart`): `28-dashboard-text13`
   (textScaler 1.3), `29-pantry-search-empty`, `30-inbox-empty`, `31-cook-loading` (if it can be
   staged without network).

**DoD**: a full 27-shot round (+ extras) in light and dark. Every screen is ≥ 8.5 with no
category < 8, the dark-mode row is ≥ 8.5, and no overflow at 1.3×. The final Director sign-off
updates the scores in `AUDIT.md` with an "after" column.

---

### Score targets at a glance

| Screen | Before | Target |
|---|---|---|
| Dashboard | 5.0 | ≥ 8.5 |
| Buy · Pantry | 4.5 | ≥ 8.5 |
| Buy · Ledger | 5.0 | ≥ 8.5 |
| Cook | 5.0 | ≥ 8.5 |
| Recipe detail | 5.5 | ≥ 8.5 |
| Inbox + Review | 4.5 | ≥ 8.5 |
| Settings (+ Stats) | 5.0 | ≥ 8.5 |
| Capture sheet | 6.0 | ≥ 8.5 |
| Log sheets | 5.5 | ≥ 8.5 |
| Onboarding | 5.0 | ≥ 8.5 |
| Dark mode | 4.5 | ≥ 8.5 |
