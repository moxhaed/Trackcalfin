# Review 03: Dashboard (Phase 3)

Shots: `build/rounds/p3/{light,dark}/01, 02, 03, 26` (02 and 03 are identical because the page
now ends after 600 px of scroll). Code: `lib/features/dashboard/dashboard_screen.dart`. Measured
on the 2× PNGs.

## What works
- **The hierarchy reads in the right order**: the date (30 bold), then the Vibe ring and score,
  then the two big Today numbers (28), then the week spend (20) with its status. "+ Meal" and
  "Quick check" are the only actions and both are obvious. Nothing competes with the ⊕.
- The Vibe hero on the canvas works. It's lighter than the old mint card and still clearly the
  summary. Ring 72, chevron on the title line, content at x = 16, 20 to the Today card.
- Today's two columns (value + unit, caption with dot and %, 6 px bar, 24 gutter) are clean,
  and the three-ring clutter is gone.
- Food spend's Week/Month blocks have the right internal order (label → value / target →
  status → bar with marker). The month markers in Other spend line up vertically, so "expected
  by now" reads at a glance.
- The alignment lines hold everywhere (x = 16 / 32, right edge at 358). Card gaps are 12,
  header → hero 8, hero → card 20. Type sizes measured: card titles 17, rows 16, meta 13,
  sheet title 22.

## Scores

| Category | Light | Dark | Notes |
|---|---|---|---|
| Hierarchy | 8.5 | 8.5 | Clear order. In Other spend, row labels (16 w500) sit close to the card title (17 w600). Acceptable |
| Typography | 8.0 | 8.0 | The scale and tabular figures are right, but **three widows/orphans**: "saved vs eating / out" (Food spend footer), "Today is still in / progress." (chart footnote), "…are left / out." (vibe sheet) |
| Spacing | 8.5 | 8.5 | Rhythm 8 / 12 / 16 / 20 holds. The Food spend card is tall (326 dp) but not loose |
| Alignment | 9.0 | 9.0 | |
| Color | **7.5** | **7.5** | **The Eating out row shows three status hues at once**: a red bar (critical, pace 2.8), an orange warning icon (serious) and amber-brown text (warningInk). The week chart is also a heavy saturated blue block that outweighs everything else on the scrolled screen |
| Contrast | 9.0 | 9.0 | |
| Consistency | 8.0 | 8.0 | The status colors in Other spend don't follow `forPace` / `inkForPace` the way Food spend does |
| Density | 8.5 | 8.5 | Above the fold: header, hero, Today, all of Food spend. Nothing is too empty |
| Usability | 9.0 | 9.0 | Tappable hero + chevron, + Meal, Quick check, bar tap-to-read |
| Polish | 8.0 | 8.0 | The orphans and the status-hue mismatch |
| **Overall** | **8.4** | **8.4** | |

Vibe sheet (26) on its own: 8.5. It's clean, with green bars, a 22 title and 16 rows. The only
defect is the subtitle orphan.

## Verdict: **not yet. A narrow FAIL.**
Overall is 8.4 (target ≥ 8.5), and Color (a critical category) is 7.5 (< 8). Two MUST fixes get
it over the line. Projected after them: color 8.5, typography 8.5, consistency 8.5, polish 8.5,
overall ≈ 8.7.

## Rulings on the interpretations
- **(a)** Chevron only when tappable: **accept**.
- **(b)** "/ €40" in secondary w400, like Food spend: **accept**.
- **(c)** Projection 8 below the month bar: **accept** (it reads as the month's footnote).
- **(d)** ListView without side padding, each card adds 16: **accept** (required by the hero's
  tap inset). The skeleton and the error state must use the same 16.
- Copy changes "On pace", "of 2,200 kcal · 45%" and "Couldn't load your dashboard.": **approved**.

## Fix list (by impact)

### MUST (required to pass)
1. **One status hue per row (color, consistency).** In `_OtherSpendCard`, the warning icon
   color = `c.forPace(s.pace)` and the amount ink = `c.inkForPace(s.pace)`, matching the bar's
   `forPace`. For Eating out (pace ≈ 2.8) that's a red icon, a `criticalInk` amount and a red
   bar. Keep the `> 1.15` threshold for showing the icon. (SCREENS §1 is corrected; my earlier
   "serious + warningInk" was wrong.)
2. **No wrapped captions in the Food spend footer (typography, layout).** Replace the 3-column
   `Metric` strip with three key–value lines under the hairline (12 above):
   label `bodyMedium` 15/21 `textSecondary` on the left (sentence case: "Eaten this week",
   "Per home meal", "Saved vs eating out"), value `nums.body` **w600** `onSurface` right-aligned
   at the card's right padding, min line height 24, 4 between lines. The values' formatting and
   '–' fallbacks are unchanged (the fidelity test only reads values). ⚪ copy: caption
   capitalization.

### SHOULD (polish; do now if cheap, otherwise Phase 9)
3. **Quieter week chart, highlight the selected day.** Completed days `kcal @ 0.45`, the
   selected bar `kcal @ 1.0`, and today when not selected `kcal @ 0.25`. The default selection
   stays today (the "Su · 982 kcal" label), so today renders at full strength and the eye lands
   on today's number. In dark, use the same alphas on `#7DA0F0`.
4. **Chart footnote orphan**: shorten to "Dashed line: daily target. Today is in progress."
   (one line at 13 sp). ⚪ copy.
5. **Vibe sheet subtitle orphan**: two sentences on two lines, "Each part is scored 0–100."
   then "Parts without a goal are left out." ⚪ copy.
6. **Semantics on the bars**: pass `semanticsLabel` to the Today bars ("Calories 982 of 2,200,
   45%") and the Food spend bars ("Week €54 of €69, on pace"). The neighboring text already
   carries this, so it's non-blocking.

Re-shoot 01, 02 and 26 in light and dark after the MUST items. I'll re-check measurements only.
