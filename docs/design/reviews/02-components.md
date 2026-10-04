# Review 02: Phase 2 shared components (fidelity check)

Reviewed: `build/rounds/p2/{light,dark}/90-components.png`, `91-components.png`, `gallery.png`,
the 27-shot contact sheets, and `lib/features/common/widgets.dart` + `lib/app/theme.dart` in
the worktree. Judged on fidelity to `DESIGN_SYSTEM.md`, not scored per screen.

## Verdict: **PASS, with 2 must-fixes**

The component set is faithful and handsome in both themes. It covers `AppSegmented` (thumb,
shadow, labels), `SectionTitle` with an aligned trailing text button, `AppGroup` with hairlines
inset to the text and full-bleed to the right, `AppRow` (title 16 w500, meta 13, values
`nums.body`, settings values muted, chevron, glyph circle), `GroupHeader`, `AppNotice` (info and
warning tints), the four chip variants plus `Tag`, `PantryTile` (ink colors for days),
`CaptureTile`, the `SectionCard` title row with the status label, `PaceBar` with a centered
2 × (h + 8) marker, `RingGauge` 72/7 with a 24 w700 score, `PortionStepper`, skeletons, the
snackbar message/detail split, `tonalButton` (fill + accent label), the `fillStrong` highlight,
and the lighter menu shadow. The sentence-case titles now render across all 27 shots.

## Rulings on the interpretations

| # | Interpretation | Ruling |
|---|---|---|
| 1 | Chip variants as wrapper widgets; the theme default stays until adoption | **Accept.** Every chip a screen phase touches must use a wrapper. No raw `ChoiceChip`/`FilterChip`/`ActionChip`/`InputChip` left after P8 (`grep` in P9) |
| 2 | `tonalButton(context, {small})` | **Accept** |
| 3 | `GroupHeader.inset` (16 default) | **Accept.** The rule is: *the header text sits on the same x as the row text below it*. Full-width rows today → 16; inside `AppGroup` → 32 |
| 4 | Title → subtitle gap 2 | **Accept.** Two-line rows measure 66 (22 + 2 + 18 + 24), which is fine. I'm amending §7.3's "64" to "≥ 64" |
| 5 | `StatusPill` call sites without `ink` | **Accept**, but every status label migrated in P3+ passes `ink: colors.inkForPace(...)` (or `goodInk` / `warningInk` / `criticalInk`) |
| 6 | PaceBar is bar-height without a marker | **Accept.** Correct |
| 7 | Today caption wraps | **Accept.** Phase 3 replaces that layout |

## MUST-FIX-NOW (these would propagate into every screen phase)

1. **Rows with an interactive trailing control are too tall.** The gallery measures the
   Notifications switch row at **72.5 dp** (a single line!) and the fridge row with "Eat 1" at
   **72 dp**, because the control's 48 tap target is added to 2 × 12 padding. In `AppRow`, when
   `trailing` is a control (Switch, button, icon button), use **vertical padding 8** and min
   height **56 (one line) / 64 (two lines)**. The text column stays vertically centered and the
   control keeps its 48 hit target. *Verify in 90*: the Notifications row is 56, the fridge row
   64–66, and the plain rows are unchanged (52 / 66).
2. **`valueSpan` must join number and unit with a no-break space** (`' ${unit}'`, not
   `' $unit'`). Otherwise "51 g" or "30 min" can break across lines in narrow metric columns. It's
   spec §2.3, and the Guardian's `value()` finder accepts NBSP.

Cheap and recommended now (prevents misaligned hairlines later): add constants
`AppGroup.indentPlain = 16`, `AppGroup.indentIcon = 52` (16 + 24 + 12) and
`AppGroup.indentGlyph = 64` (16 + 36 + 12), and use them at every call site instead of literals.

## Fold into the screen phases
- **P3**: the streak flame currently uses the *protein* plum. It must be `textSecondary` (icon
  and label), see SCREENS §1.
- **P5**: horizontal tile strips (Use soon / Running low) must **bleed to the screen edge**: a
  full-width `ListView` with 16 *internal* padding. The gallery clips them at the 16 margin.
- **P7**: switch thumb **white when on** in both themes (`#FFFFFF` light, `#F1F1EE` dark). The
  dark-on-mint thumb reads like a hole. I'm amending §12.

## Additions to the Phase 3 (Dashboard) spec
1. **Vibe hero on the canvas, not in a card**: ring 72 at x = 16, 16 gap, "Vibe · Locked in"
   (`titleMedium`), insight (`bodyMedium` secondary, max 3 lines), trailing chevron 20
   `textTertiary`. `InkWell` radius 16 inset 8 from the edges with 8 padding (content stays at
   x = 16). Semantics "Vibe 97 of 100, Locked in". No bolt icon. Spacing: header → hero 8,
   hero → Today card 20.
2. **Today**: two equal columns, each holding the value (`nums.large` + unit via `valueSpan`),
   a 4 gap, the caption `● of 2,200 kcal · 45%` / `● of 140 g · 34%` (`bodySmall`, dot 8 in
   kcal/protein, `NumberFormat.decimalPattern()`), an 8 gap, then `PaceBar` h6 in kcal/protein with
   no marker. 24 between the columns. The Today card has **no** `RingGauge`.
3. **Food spend**: a "Week" `labelMedium` secondary line, then one `Text.rich` with `€54`
   (`nums.medium`) + ` / €69` (`bodyMedium` secondary), and `StatusPill(ink: inkForPace)`
   right-aligned on that line. `PaceBar` h6 + marker 8 below, 16 before Month. The projection is
   `bodySmall`, then a hairline 12 / 12 and the three `Metric`s with `style: nums.title`.
4. **Other spend**: title "Other spend" + trailing meta "This month" (🔵 finder change). Each row
   is line 1 = icon 16 secondary, 8, label `bodyLarge` w500, spacer, amount `nums.body`
   (`warningInk` + leading `warning_amber_rounded` 16 `serious` when pace > 1.15), then a 6 gap
   and line 2 = `PaceBar` h4 full width with the month marker. 12 between rows. "Other" (no
   limit) has no bar. No fixed widths.
5. **Calories this week**: avg line `titleSmall` `onSurface` tnum, coverage `bodySmall`,
   `WeekBars` height 112 per §7.10, footnote `bodySmall`. Streak trailing neutral (see above).
6. **States**: a skeleton (hero circle + 2 lines, 2 card blocks) replaces the spinner. The error
   becomes `AppNotice(critical)`.
7. Keep the Dashboard scroller a `ListView` (smoke-test drag).
