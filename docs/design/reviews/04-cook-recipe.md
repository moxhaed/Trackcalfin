# Review 04: Cook + Recipe detail (Phase 4)

Shots: `build/rounds/p4/{light,dark}/07, 08, 27` (Cook) and `09, 10` (Recipe). Shot 23 (cooked
sheet) is Phase 6 and isn't scored. Measured on the 2× PNGs.

## What works
- **Cook**: Today's pick is clearly the hero (padding 20, a 22/28 title measured at a 16 dp cap
  height, four 20 sp metrics with small units, the stepper + L 52 "I cooked this"). The mic now
  sits inside the ask field (48 tall, at the header + 8), so nothing competes with the primary
  action. "In the fridge" and "Cook again" use section titles at x = 16 and groups with 52-inset
  hairlines. Fridge rows are 64 with no redundant icon. Cook again shows status once (leading
  check or cart), the favorite ★ inline, and a chevron. The status label "Missing Chicken
  breast" in `warningInk` (27) and the split snackbar ("1 logged, 2 in the fridge" /
  "51 g protein each") sit above the pill.
- **Recipe**: the 26/32 title dominates, the hook fits on one line, and the Per portion card,
  ingredient group (status icon, 16 w500 name, "have …" meta, quantity with a small unit) and
  numbered steps (24 circles, 16/24 text) are all calm. The bottom bar has a hairline and keeps
  "I cooked this" in reach. Dark mode matches token for token.

## Scores

| Category | Cook light | Cook dark | Recipe light | Recipe dark |
|---|---|---|---|---|
| Hierarchy | 9.0 | 9.0 | 9.0 | 9.0 |
| Typography | **7.5** | **7.5** | 8.0 | 8.0 |
| Spacing | 8.5 | 8.5 | 8.5 | 8.5 |
| Alignment | 9.0 | 9.0 | **7.5** | **7.5** |
| Color | 9.0 | 9.0 | 9.0 | 9.0 |
| Contrast | 9.0 | 9.0 | 9.0 | 9.0 |
| Consistency | 9.0 | 9.0 | 8.5 | 8.5 |
| Density | 8.5 | 8.5 | 8.5 | 8.5 |
| Usability | 9.0 | 9.0 | 9.0 | 9.0 |
| Polish | 8.0 | 8.0 | 8.0 | 8.0 |
| **Overall** | **8.6** | **8.6** | **8.6** | **8.6** |

Notes:
- Cook typography 7.5: the hero card has two typographic defects. The hook breaks as
  "…before it wilts **·**" / "51 g protein", leaving the separator dangling at the end of line 1
  (the orchestrator's observation is correct; it's a side effect of `noOrphans` binding the last
  words). The title also widows as "…spinach rice" / "**bowls**".
- Recipe alignment 7.5: the Per portion card puts a 4-column row (kcal, protein, carbs, fat at
  x = 32 / 114 / 195 / 277) over a 3-column row (cost, time, fridge at x = 32 / 141 / 249). The
  second row's columns line up with nothing above them. Same title widow ("bowls").

## Verdict
- **Cook: narrow FAIL.** Overall 8.6, but typography (critical) is 7.5. MUST items 1 and 2.
- **Recipe detail: PASS** (8.6, no critical category < 8). MUST 2 (shared) and SHOULD 3 lift it
  to ≈ 8.9, so do them in this phase.

## Rulings on the interpretations
1. **Eyebrow row 48 tall, title 16 below the label**: keep the 48 tap target for Swap, but the
   visual gap is too loose (the eyebrow glyphs end 25 dp above the title's cap height, versus 4 dp
   between title and hook). See SHOULD 4.
2. **4 equal metric columns, the time column empty when there's no time**: **accept**. A fixed
   grid beats reflow.
3. **Expired-portion icon uses `warning` for a single hue**: **accept** (same rule as the Dashboard).
4. **The smaller unit applies to every `AppRow` value**: **accept**. It's the number + unit
   pattern everywhere.
- Copy changes (sentence-case eyebrows, the snackbar split, "Couldn't plan today's pick." + the
  error, shopping bullets → rows): **approved**.

## Fix list

### MUST
1. **No dangling separators (Cook hook, typography).** A hook made of " · "-joined parts either
   fits on one line *with* the separators, or wraps **at the separators without them**, one part
   per line. Add `separatedText(String text, TextStyle style, double maxWidth)` to
   `lib/features/common/format.dart`: split on `' · '`, measure the joined string with a
   `TextPainter` (same style and text scaler), return it joined with `' · '` if
   `width <= maxWidth`, otherwise joined with `'\n'` (apply `noOrphans` per part). Use it via a
   `LayoutBuilder` for the hook in the pick card and on Recipe detail. Expected in 07:
   "Uses your spinach before it wilts" / "51 g protein".
2. **No single-word last line in recipe titles (both screens).** Apply `noOrphans` to the
   recipe title wherever it can wrap (pick card `headlineSmall`, Recipe `headlineMedium`, and
   later the fridge and cook-again row titles): bind the last two words with U+00A0 when the
   title has ≥ 3 words. Expected: "Garlic chicken & spinach" / "rice bowls" on both screens.
   ⚠ **Guardian coordination required**: the smoke and reachability tests use
   `find.text('Garlic chicken & spinach rice bowls')`, which compares the plain text (rich spans
   included) exactly, so a U+00A0 makes it fail. Keep `semanticsLabel` equal to the unbound
   title so screen readers are unaffected. The Guardian switches those finders to a
   whitespace-tolerant match (e.g. a predicate that normalizes U+00A0 to a space, as the
   harness's `value()` already does) before this merges. `noOrphans` on the hook is already in
   place, so the hook finders have the same exposure.

### SHOULD (this phase)
3. **One grid for Per portion (Recipe alignment).** Both rows use the same 4 equal columns.
   Row 2 is `€2.62` / "cost", `30 min` / "total", `20 min` / "active", `4 d` / "in fridge".
   This splits "30 min · 20 min active" into total and active, and shortens "keeps in fridge"
   (91.5 dp at 13 sp, too wide for an 81.5 dp column) to "in fridge". Empty cells stay empty
   (same as ruling 2). ⚪ copy: "20 min active" → "20 min" + "active", "keeps in fridge" →
   "in fridge". Values are unchanged (`value('30 min')`, `value('4 d')` still match).
4. **Eyebrow → title = 8** between line boxes (pick card). Keep Swap's 48 target with the same
   "lift" technique as `SectionCard`: the row is 48 tall but offset −16 top and bottom so the
   13/16 label line sits 20 below the card top and the title 8 below it. With no Swap (no key,
   or cooked today) the row is simply the 16 label line.

### Later (not blocking)
5. **P9**: the hook/meta separator rule (MUST 1) should also cover `AppRow` subtitles if any
   wrap at 1.3× text scale. Check in the text-scale shot.

Re-shoot 07, 08, 09 and 27 in light and dark after MUST 1–2 (and SHOULD 3–4 if done). I'll
re-check by measurement.
