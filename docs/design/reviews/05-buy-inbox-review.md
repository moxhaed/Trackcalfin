# Review 05: Buy (Pantry, Ledger, item sheet) + Inbox, Review (Phase 5)

Shots: `build/rounds/p5/{light,dark}/04, 05` (Pantry), `06` (Ledger), `11` (Inbox), `12, 13`
(Review) and `24` (item sheet). Measured on the 2× PNGs (px ÷ 2 = dp). Behavior was verified
separately, so this review covers visuals and usability only.

## What works
- **Buy header**: the large title, the Inbox badge and `+` sit on one line, and the full-width
  segmented control works. Removing the four action buttons makes a real difference: the
  pantry starts at 167 dp.
- **Pantry**: group headers sit at x = 32 with 24 above. Category icons move into the header
  (icon 16, text at x = 54). Rows are 66 tall with hairlines from x = 32 and quantities with a
  smaller secondary unit. The Use soon strip peeks off the right edge, so it reads as
  scrollable. Each tile has one status color ("1 day" in `criticalInk`, "2 days" in
  `warningInk`). The Running low tile carries its status in the ↘ glyph and the header, not in
  color alone.
- **Ledger**: 36 glyph circles, day totals at x = 358 in `nums` w600 secondary, and a calm
  rhythm of one group per day. The selected "All" chip is the only accent on the screen.
- **Review**: the warning notice, the "Check 1" group, the "look good" summary and the bottom
  bar (Discard · nums total · Looks good) have the right hierarchy. In 13 the FX notice gives
  "CHF 23.10 → €24.74" real weight, and the bottom total stacks home over original as specified.
- **Item sheet**: the 650 hero and its smaller "g" are centered on the ± pair (center 390 px
  for both). The chips row and the caption share that center. The nutrition panel uses an even
  4-column grid (x = 36 / 116 / 195 / 275), and the sheet keeps its 20 margin throughout.

## Scores

| Category | Pantry | Ledger | Inbox | Review L / D | Item sheet L / D |
|---|---|---|---|---|---|
| Hierarchy | 9.0 | 8.5 | 8.5 | 9.0 | 9.0 |
| Typography | 8.5 | 8.5 | 8.0 | **7.5** | 9.0 |
| Spacing | 8.5 | 8.0 | 8.5 | 8.0 | 8.5 |
| Alignment | 8.0 | 8.5 | 8.5 | 8.0 | 9.0 |
| Color | 9.0 | 9.0 | 9.0 | 9.0 | 8.5 |
| Contrast | 9.0 | 9.0 | 9.0 | 9.0 / **7.5** | 9.0 / **7.0** |
| Consistency | 8.5 | 8.5 | 8.5 | 8.0 / **7.5** | 8.5 / **7.5** |
| Density | 8.5 | 8.0 | **7.5** | 8.5 | 8.5 |
| Usability | 9.0 | 9.0 | 8.5 | 9.0 | 9.0 |
| Polish | **7.5** | 8.0 | 8.0 | 8.0 | 8.5 / 8.0 |
| **Overall** | **8.4** | **8.5** | **8.2** | **8.4 / 8.1** | **8.8 / 8.3** |

Pantry and Ledger are the same in light and dark.

Notes (measured):
- **Scroll edge (Buy header, 05)**: the scrolled-under hairline is at y = 213 px (106.5 dp),
  between the title and the segmented control. The pinned block actually ends at y = 334 px
  (167 dp), where content is hard-clipped mid-glyph ("200 g" is sliced) with no edge at all.
  The line is in the wrong place, so the scrolled state looks broken.
- **Chip fill (12, 24, dark)**: chips use an opaque fill that was composited over the
  *canvas*: light #E7E6E2, dark #212221. In dark, that's darker than the sheet (#242523), so
  "I'm out" and "Looks right" lose their container. On the Review card (#1C1D1B) the category
  chips almost disappear (≈1.05:1), while the fields next to them are #2E2F2D. In light the
  chips are darker than the fields in the same card (#E7E6E2 vs #F1F2F1).
- **Inbox 11**: "Yesterday 09:29" / "converted from CHF" / "ready to file" splits one part per
  line. The subtitle takes 3 lines (AppRow allows 2), and the Migros row takes 5 lines
  (190 dp) with the leading icon floating in its middle.
- **Review 13**: the FX meta breaks inside a part: "…· European Central Bank" / "rate, 4 Oct".
  The " · " wrap rule doesn't hold here. In 13 the summary "Pasta, Gruyère, Chicken" /
  "sandwich, Sunscreen" also splits an item name.
- **Review 12 spacing**: notice → "Check 1" is 24 dp, but line group → "3 look good" is 36 dp.
  The "Mark as correct" label ends at x = 345.5 dp (the amount and fields end at 357.5), and
  there's 31.5 dp from its glyph bottom to the card edge. The "Show" label also ends at 345.5.
  The category chips are hard-clipped at the card's inner padding ("Eatin|").
- **Ledger 06**: the chips' visible top is 18 dp below the segmented control. On Pantry the
  search field starts 12 below it, so the content jumps 6 dp when you switch segments. "All"
  starts at x = 18 (not 16). The first day header sits 19 dp under the chips, versus 29 dp
  glyph-to-card everywhere else.
- **Pantry tiles**: text sits at x = 30 (padding 14, per §7.19), while every row and header
  below it is at x = 32. You can see the 2 dp step between "Whole milk" (tile) and "Bananas"
  (row).

## Verdict
- **Pantry: FAIL (narrow)**. Overall 8.4, held down by the scroll edge. MUST 1.
- **Ledger: PASS** (8.5, no critical category < 8). MUST 1 also applies, since the header is
  shared.
- **Inbox: FAIL** (8.2). MUST 3.
- **Review: FAIL**. Typography is 7.5 in light and dark. Dark has consistency 7.5 and overall
  8.1. MUST 2 and 4.
- **Item sheet: light PASS (8.8), dark FAIL** (8.3, consistency 7.5). MUST 2.

## Rulings on the interpretations
1. **"Less"/"More" tooltips on the item-sheet ±**: **accept**. It adds a label where there was
   none and doesn't change the visuals. (Later, optionally: step-aware labels like "Remove 50 g".)
2. **"AI estimate" in neutral grey**: **accept**. Provenance isn't a kcal quantity, so it must
   not borrow a data-series color. The sparkle icon and the text carry the meaning, so status
   isn't conveyed by color alone.
3. **48-tall Ledger chip strip**: **accept** the 48 target, but not its visible offset. See
   SHOULD 2.
4. **" · " subtitles break at separators**: **accept, refined**. Breaking one part per line
   was right for two-part hooks (review 04), but with 3+ parts it wastes lines. See MUST 3.
5. **Running-low items as tiles (name / ↘ qty)**: **accept**.

## Fix list

### MUST
1. **Scroll edge at the bottom of the pinned block (Buy header, Pantry and Ledger).** Draw the
   scrolled-under hairline (`AppColors.hairline`, 0.5) at y = 167 dp, the bottom of the
   segmented control plus its 12 padding, where content clips. Remove the one at 106.5 dp.
   With no scroll offset there's no line (as now).
2. **Chips use the translucent `AppColors.fill`** (light `0x0F191A18`, dark `0x14FFFFFF`) as
   their background, composited over whatever surface they sit on. This covers unselected
   choice chips and action chips. Expected: dark sheet chips ≈ #353634 (same as the ± circles),
   dark Review card chips ≈ #2E2F2D (same as the fields), light card chips #F1F2F1, canvas chips
   unchanged (#E7E6E2 / #212221). In the nutrition panel they become ≈ #E4E5E4 / #454644.
   Selected chips stay accent.
3. **Greedy `SeparatedText`.** Pack parts first-fit per line and break only at " · ", dropping
   the separator at the break. A part never splits, a line never starts or ends with "·", and
   there are as many parts per line as fit. Apply it to every " · " subtitle and meta (AppRow
   subtitles are 2 lines max). Expected in 11: "Yesterday 09:29 · converted from CHF" /
   "ready to file". Hooks with two parts behave as before.
4. **FX meta through the same `SeparatedText`** (13): "1 CHF = 1.0712 EUR" /
   "European Central Bank rate, 4 Oct".

### SHOULD (this phase)
1. **Pantry tile padding 12 / 16** (was 12 / 14), so tile text sits on x = 32. Update §7.19.
2. **Ledger strip offset**: put the 48 strip box 6 dp below the segmented control, so the
   chips' visible top lands at 167 dp, the same y as the Pantry search field. Put the first
   day header's line box 24 below the chips' visible bottom. Start "All" at x = 16.
3. **Trailing text buttons align at x = 358** (−12 end margin, §7.2): "Mark as correct",
   "Show". Lift the "Mark as correct" row so its glyph bottom sits 20 above the card edge
   (it's 31.5 now).
4. **Review rhythm**: line group → next group header = 24 (now 36). Drop the extra 12 bottom
   margin.
5. **Review chip strip bleeds to the card edges**: the scroll view spans the full card width
   with 16 inner padding, and the card's rounded edge clips it, so the peek reads as scroll.
6. **Comma summaries wrap at ", "** (13): "Pasta, Gruyère," / "Chicken sandwich, Sunscreen".
   Same packer as MUST 3, with ", " as the separator (kept at line end).
7. **Inbox leading icon top-aligned** to the title's first line when a row runs to more than
   2 lines (same rule as `AppNotice`).
8. **Shot 11**: open Inbox from Buy (push), so the "←" is captured. The current shot starts at
   `/inbox` with no back stack.

### Later (not blocking)
- Ledger density: a day with one transaction repeats its amount in the header and the row.
  Hiding the day total for single-row days would save the noise, but §2c currently requires it.
  Revisit with the Guardian.

Re-shoot 04, 05, 06, 11, 12, 13 and 24 in light and dark after MUST 1–4 (and the SHOULDs if
done), plus a scrolled Ledger shot for MUST 1. I'll re-check by measurement.

## Re-check (orchestrator, by inspection of p5-fix light/dark)
- MUST 1 Buy scroll hairline at the clip edge: implemented (ScrollEdge at 167 dp on Pantry; on Ledger at the bottom of the pinned chip strip, where content actually clips). Accepted.
- MUST 2 chip fill: chips now composite the translucent fill; visible on dark sheets and cards (24, 12). Pass.
- MUST 3 greedy separator packing: 11 reads "Yesterday 19:33 · converted from CHF" / "ready to file". Pass.
- MUST 4 FX meta: 13 reads "1 CHF = 1.0712 EUR" / "European Central Bank rate, 5 Oct". Pass.
- SHOULD 1–8 implemented; 11 now opened from Buy (back arrow shown); 06b scrolled ledger added.
- Carried to the final pass: raw chips in settings/expense/onboarding still on an opaque canvas (their batch converts them).
Verdict: Phase 5 passes.
