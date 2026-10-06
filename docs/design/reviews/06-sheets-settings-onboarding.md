# Review 06: Settings, Stats, Quick check, Onboarding, capture and log sheets, Recipe editor (Phases 6–8)

Shots: `build/rounds/p678/{light,dark}/14, 15` (Settings), `16` (Stats), `17` (Quick check, opened
cold), `18, 19` (Onboarding), `20` (capture sheet), `21` (Ate), `22` (Expense), `23` (Cooked) and
`25` (Recipe editor). Measured on the 2× PNGs (px ÷ 2 = dp). Behavior was verified separately, so
this review covers visuals and usability only. The Stats monospace panel isn't in these shots
(no AI calls are seeded), so the font-box artifact doesn't come up.

## What works
- **Settings**: this is the calmest screen in the app so far. Group headers are at x = 32 in
  `titleSmall` secondary, 24 above and 8 below. Groups run 16–374, row text sits at x = 32 and
  values end at 357.5, in `textSecondary` w400 with a smaller unit ("2,200 kcal", "30 min").
  One-line rows are 52 and two-line rows 66.5, and the switch row is 64. Chip cells use the
  translucent fill (light #F1F2F1, dark #2E2F2D on the group), toggle chips use
  `primaryContainer` with a check, and chip labels measure 13 sp. In 15 the scroll edge sits at
  106.5 dp, exactly where the content clips.
- **Quick check**: the opened-cold shot shows the deck ("1 / 2", matching "Quick check · 2" on
  the Dashboard), so the approved fix holds. The card's rhythm is circle 64 → 24 → 26/32 question
  → 8 → `bodyLarge` estimate → 12 → neutral status → 24 → hint, all centered on x = 195. The three
  M buttons are each 113.5 wide with 8 gaps, and Yes is the only accent.
- **Onboarding**: the progress bar is 6 × 4 tall with 4 gaps at x = 16–374. The app mark is 72,
  40 below the bar, with the §10 colors (#2E7D5B field). The title is 30/36, the body 16/22
  secondary, and the habit rows are 15/21 with icons at x = 16 and text at x = 48. The goals page
  uses 62-tall filled fields 12 apart with labels inside. The bottom bar (Back aligned at
  x = 16, Next L 52 expanded) and the 16 + safe-area foot are right.
- **Capture sheet**: tiles are exactly 104 × 110 with 10 gaps, the content is vertically centered
  (17 / 16.5), the title sits at x = 20, and nothing truncates ("Stocktake photo" fits).
- **Ate**: one row with "Eat 1" (S 36, ending at x = 370) and the full-width tonal M "Something
  else". Plain and fast.
- **Expense**: the 44 amount is unmistakably the hero. The category buttons are 52 tall in two
  columns with 8 gaps, and "Add a note" sits on x = 20.
- **Cooked rows**: 64.5 tall, hairlines from the text x (56) to 370. Today's pick sun is in
  `primary` and the other leading icons are secondary. There's one status icon per row
  (`good` check / `warning` info).
- **Dark**: every fill composites correctly. Sheet controls are #353634, card chips #2E2F2D,
  canvas fields and tonal buttons #212221, the focused field #434442, and the toggle chip
  #1A3A2B. Dark scores match light.

## Scores

| Category | Settings | Stats | Quick check | Onboarding | Capture | Ate | Expense | Cooked | Editor |
|---|---|---|---|---|---|---|---|---|---|
| Hierarchy | 9.0 | 8.5 | 9.0 | 9.0 | 8.5 | 9.0 | 9.0 | 8.0 | 8.5 |
| Typography | 9.0 | 8.5 | 9.0 | 9.0 | 8.5 | 9.0 | 8.5 | **7.5** | 8.5 |
| Spacing | 8.5 | 8.5 | 8.5 | 9.0 | 9.0 | 8.5 | 8.5 | 8.5 | 8.0 |
| Alignment | 9.0 | 9.0 | 9.0 | 8.5 | 9.0 | 9.0 | 8.0 | 9.0 | 8.0 |
| Color | 9.0 | 9.0 | 9.0 | 9.0 | 9.0 | 9.0 | 9.0 | 9.0 | 9.0 |
| Contrast | 9.0 | 9.0 | 9.0 | 9.0 | 9.0 | 9.0 | 9.0 | 9.0 | 9.0 |
| Consistency | 9.0 | 8.5 | 8.5 | 9.0 | 8.5 | 9.0 | 8.5 | 8.0 | 8.5 |
| Density | 8.5 | 8.0 | 8.0 | 8.5 | 9.0 | 8.5 | 9.0 | 8.5 | 8.5 |
| Usability | 9.0 | 8.5 | **7.5** | 9.0 | 9.0 | 9.0 | 9.0 | 9.0 | 8.5 |
| Polish | 8.5 | 8.5 | 8.5 | 9.0 | 8.5 | 8.5 | 8.5 | 8.0 | 8.0 |
| **Overall** | **8.9** | **8.6** | **8.5** | **8.9** | **8.8** | **8.8** | **8.7** | **8.4** | **8.5** |

Notes (measured):
- **Cooked 23, title**: "What did you cook?" wraps to "What did" / "you cook?" at 1.0×. Set on one
  line, it's about 200 wide (90.5 + space + 104). The stepper is 140 × 48 at x = 230–370, and its
  center column is 52 for a 42.5-wide "portions" hint. That leaves the title about 198, so it
  misses by 2 dp. The header becomes a 56-tall two-line block, while the Ate sheet next to it has a
  28-tall title. This is the only typographic defect in the round.
- **Quick check 17, exit**: the shot is the real cold path. A notification launch passes its
  payload as `initialLocation`, so `/quick-check` (and `/inbox`) is the only page in the stack.
  The bar has no back button, iOS has no system back, and Done calls `pop()` on the root page,
  so the user has no way out. This also corrects review 05 SHOULD 8. "Opened at `/inbox` with no
  back stack" isn't only a harness artifact, because it's the same notification path.
- **Fields, all screens**: the text inside filled fields starts 20.5 in from the field edge,
  although the theme says 16. Onboarding labels are at x = 37, editor hints at 36.5, and the
  expense "€" at 40.5 in a field that starts at x = 20. In the expense sheet the "€" (40.5), the
  category icons (34.5) and the note icon (22) make three left lines in one column.
- **Editor 25**: the ingredient-row fields render 45.5 tall with edges at x = 17 / 172.5,
  183 / 252.5 and 263 / 324.5. That gives 10.5 gaps and a unit field 61.5 wide, so every box
  looks inset about 1.25 on each side. With the inset removed, the boxes would be 48 tall at
  x = 16, with 8 gaps and a 64-wide unit field, matching the Title field. The form rows are 8
  apart (Title → portions 8.5, portions → times 8), while §7.14 uses 12 between fields. The
  "Save" label ends at 369.5, not 374.
- **Onboarding 19**: the 28 page icon box is at x = 16, but the flag glyph starts at 21.5 while
  "Your goals" starts at 16.5. The 5 dp optical step shows on a fully left-aligned page.
- **Quick check density**: the card fills 107–730 (623 tall) around a 220-tall content block.
  That's acceptable for a swipe card, and it's the biggest target on the screen. Not a fix.
- **Settings chips**: there are 8.5 dp between chips and 12.5 dp between rows, because 36 chips
  have 48 hit boxes. Accepted. Overlapping the hit targets to get an 8 run would cost more than
  it gains.
- **Capture / Expense glyphs**: `restaurant` (I ate, Eating out) has a solid knife blade and
  reads heavier than the five outlined tile icons. It's minor, so I've listed it under Later.

## Verdict
- **Settings: PASS** (8.9).
- **Stats: PASS** for the empty state (8.6). The populated layout (median rows with status icons,
  AI-call rows, recent-call panels) wasn't in the shot and remains unreviewed (SHOULD 5).
- **Quick check: narrow FAIL** (8.5, usability 7.5). It needs MUST 2. The visuals pass, and it
  reaches ≈ 8.8 once fixed.
- **Onboarding: PASS** (8.9).
- **Capture sheet: PASS** (8.8).
- **Ate sheet: PASS** (8.8).
- **Expense sheet: PASS** (8.7). SHOULD 1 lifts alignment.
- **Cooked sheet: FAIL** (8.4, typography 7.5). It needs MUST 1.
- **Recipe editor: PASS, narrowly** (8.5). Do SHOULD 2–3 in this phase.

## Rulings on the interpretations
1. **Expense amount 44 in number mode, 28 in text mode; check on the parsed category**: **accept**,
   on two conditions. The field keeps the same height (64) in both modes, with the 28 text
   centered, so the grid doesn't jump when toggling. The check is a trailing `check_rounded` 18
   in `onPrimaryContainer`, 16 from the button's right edge. The category icon stays leading.
   The check means the selection no longer relies on color alone, which is an improvement.
2. **"Not checked in a while" in neutral secondary**: **accept**. Staleness is the premise of
   the screen, not an exception (principle 6), and the `history_rounded` icon plus the text
   carry the meaning. Measured #62645F, w600 13.
3. **Quick-check buttons stack above 1.15×**: **accept**. Make them full width, 8 apart, M 44,
   in the order Yes (primary) on top, then Adjust, then Gone (HIG: the likeliest action leads a
   stack). Labels never truncate.
4. **Capture grid as two `IntrinsicHeight` rows**: **accept**. The tiles measure exactly 104 at
   1.0× and stay equal within a row when text grows. This matches §5's intent.
5. **Onboarding mark as a `CustomPainter` port**: **accept**. It's 72 × 72, the colors match
   §10 and it's identical in dark.
6. **`NoWidowText` on every `AppRow` subtitle without " · "**: **accept**, with two
   constraints. It may only narrow within the same line count (never add a line), and
   subtitles stay at 2 lines max.

## Fix list

### MUST
1. **Cooked title on one line at 1.0×** (23). Make the title → stepper gap 8 (`AppSpace.inline`).
   Make `PortionStepper`'s center column hug: width = max(40, hint width), with no side
   padding. Expected: the stepper is about 131 wide (now 140), the title gets about 211, and
   "What did you cook?" (200) sets on one line, 28 tall, with the stepper centered on it. Above
   1.15× it may wrap, through `NoWidowText`. Check that the Cook hero stepper still looks right
   at the new width.
2. **Notification cold launch keeps a way out** (17, and `/inbox`). Build the router at `/` and
   push the launch payload after the first frame, the same path the warm `onResponse` uses. The
   pushed screen then has the back chevron and Done pops to the Dashboard. As a guard, Done
   uses `canPop() ? pop() : go('/')`. Re-shoot 17 cold. Expected: a back button left of
   "Quick check · 1 / 2" (title at `titleSpacing` 0). **Flag to the Guardian (functional).**

### SHOULD (this phase)
1. **Field inner padding renders 20.5, not 16**: find where the extra 4 comes from. Expected
   field text at x = 32 for full-width page fields (36 in sheets). In the expense sheet, give
   the category buttons 16 padding so their icons and the "€" share x = 36.
2. **Editor ingredient row**: remove the about 1.25 inset. Expected: fields 48 tall, edges at
   x = 16, gaps 8, unit field 64.
3. **Editor rhythm**: 12 between form rows (Title → Default portions → Prep/Cook/Fridge).
   Align the "Save" text button's label to x = 374 (end margin −12, as for card trailing text
   buttons in review 05).
4. **Onboarding page icons**: align optically, so the glyph's left edge sits on x = 16 (the
   flag needs −5).
5. **Shots**: seed a few log timings and AI calls so 16 shows the populated Stats. Open 16 from
   Settings and 25 from Cook (push), so their back buttons are captured.

### Later (not blocking)
- Use a lighter glyph than the solid `restaurant` for "I ate" / "Eating out" to match the
  outlined tile set (for example `dinner_dining_outlined`). Decide with the icon pass.
- Expense placeholder: while the field is empty, the `textSecondary` "€" outweighs the
  `textTertiary` "0.00". Consider `textTertiary` for the prefix until there's a value.

Re-shoot 17 (cold), 23 and 25 in light and dark after the MUST items (and 16/22/19 if the SHOULDs
land). I'll re-check by measurement.
