# Design audit: current state (round 00-before)

Source: `build/rounds/00-before/{light,dark}/*.png` (390 × 844 @2×, demo data, Roboto
fallback) and the code in `lib/app/theme.dart`, `lib/app/floating_nav.dart`,
`lib/features/**`. Scores run from 1 to 10 and are strict: **8.5 means flagship quality**,
5 means it works but looks like a default Material app, and 3 is broken.

## Scores

| Screen (shots) | Hierarchy | Typography | Spacing | Alignment | Color | Contrast | Consistency | Density | Usability | Polish | **Overall** |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Dashboard (01–03, 26) | 5 | 4 | 6 | 5 | 4 | 6 | 5 | 5 | 6 | 4 | **5.0** |
| Buy · Pantry (04, 05) | 4 | 4 | 5 | 6 | 5 | 6 | 4 | 4 | 6 | 4 | **4.5** |
| Buy · Ledger (06) | 5 | 4 | 5 | 6 | 5 | 6 | 5 | 4 | 6 | 4 | **5.0** |
| Cook (07, 08, 27) | 6 | 5 | 5 | 5 | 4 | 6 | 5 | 5 | 6 | 4 | **5.0** |
| Recipe detail (09, 10) | 6 | 5 | 6 | 5 | 5 | 6 | 5 | 6 | 7 | 5 | **5.5** |
| Inbox + Review (11–13) | 5 | 4 | 6 | 6 | 4 | 6 | 4 | 6 | 6 | 3 | **4.5** |
| Settings (14, 15) + Stats (16) | 4 | 5 | 5 | 6 | 6 | 6 | 5 | 5 | 6 | 4 | **5.0** |
| Capture sheet ⊕ (20) | 6 | 6 | 6 | 7 | 6 | 6 | 6 | 6 | 7 | 5 | **6.0** |
| Log sheets: ate / expense / cooked / item (21–24) | 6 | 5 | 6 | 6 | 6 | 6 | 5 | 6 | 7 | 5 | **5.5** |
| Onboarding (18, 19) | 6 | 5 | 4 | 4 | 6 | 7 | 6 | 4 | 7 | 4 | **5.0** |
| Dark mode, whole app | 5 | 4 | 6 | 5 | 3 | 5 | 5 | 5 | 6 | 4 | **4.5** |
| **Average** | 5.3 | 4.6 | 5.5 | 5.5 | 4.9 | 6.0 | 5.0 | 5.1 | 6.4 | 4.2 | **5.0** |

**Weakest categories, app-wide**: Polish (4.2), Typography (4.6), Color (4.9). Usability is
the strongest (6.4): the flows are good (one-tap commits, undo, sticky cook bar). The look
lets them down.

## Per-screen notes

**Dashboard.** Five rounded cards of equal weight, each headed by the same 12 sp uppercase
grey label. Only the mint fill marks the Vibe card as the hero. The page title "Sun 4 Oct"
renders at the size of row text. The key numbers (982, €54, €3.97) are 16 sp w600, barely
bigger than their labels, and use proportional figures. Three rings sit near each other
(Vibe, kcal, protein) and compete. The rainbow palette (Material green `#0CA30C`, blue,
orange, red, yellow) is unrelated to the brand green, and protein orange `#EB6834` reads the
same as "serious" orange `#EC835A`. In Other spend, fixed columns (116 / 78 / 20 px) squeeze
the bars to about 150 dp and leave amounts floating. The pace marker is a dark 2 px tick that
sticks out above the bar. "on pace" pills repeat a check icon in a tinted pill. The vibe
icon (bolt) doubles the label.

**Buy · Pantry.** The top ~280 dp (a third of the screen) is chrome: the title, a filled
"Scan receipt" and three tonal circle buttons (all duplicating ⊕), a segmented control with
icons and a check, and the search field. Three and a half pantry items are visible. Every row
repeats the same mint avatar circle (leaf, leaf, leaf), which is pure noise under a "Produce"
header. Use-soon items are 116-tall outlined pills with orange clock icons. Running-low uses a
different chip style. Rows are 72 dp for two short lines.

**Buy · Ledger.** Filter chips with check marks and borders. Single-transaction days print
the same total twice (header and row). Grey avatar circles. Bold day totals compete with the
row amounts. A plain list on a mint background, with no grouping surface.

**Cook.** Today's pick has decent hierarchy (big title, a primary button), but the mic is a
filled green circle that competes with "I cooked this". The fridge row wraps its title to 4
lines because the trailing "Eat 1" + ⋮ takes about 160 dp. Cook again shows readiness twice
(subtitle "Ready" + green check), uses a yellow star and a restaurant icon, and has no
affordance that rows open a recipe. The eyebrow is UPPERCASE in accent. The undo snackbar
wraps with an orphan ("each"). Shot 08 doesn't scroll (tool issue).

**Recipe detail.** The title is strong. The metrics wrap raggedly (5 on line one, 2 on line
two). Step numbers sit in mint circles. Tags are big outlined chips that look like buttons.
Every section is a mint card with an uppercase label. The sticky cook bar is good, but it has
no separation from the content scrolling under it.

**Inbox + Review.** The API-key card is light blue (`tertiaryContainer`), a color that appears
nowhere else. In the FX card, "CHF 23.10 ▯ €24.74" shows a **missing glyph** (→ isn't in the
fallback font): a visible defect. The banners use three different tints (peach, mint, blue).
In the review line editor, the M3 floating labels sit *on* the fill's edge ("Amount",
"Quantity"), so they look detached. The checkbox is raw M3. The review screen's bottom-bar
total floats between Discard and the button without alignment.

**Settings + Stats.** A long undifferentiated list on the canvas, with section labels in green
uppercase (accent used decoratively). Values are bold and compete with titles. The chip blocks
mix outlined, check-marked and closable chips. The theme segmented control has three icons and a
check. Stats are two lonely cards. The row tap opens a dialog, which works but looks dated.

**Capture sheet ⊕.** It's the cleanest screen: a simple 3 × 2 grid with clear labels. It has
no title, the tiles are mint-grey, and the icons sit in a slightly lighter green. Fine, but
generic.

**Log sheets.** Expense is functionally excellent (tap a chip to commit), but the chips are
outlined pills with icons in two colors. The amount field has a keyboard glyph button inside.
Ate is sparse: one row plus an outlined "Something else" button that floats. Cooked has a
good structure, but its stepper is a grey capsule with a tiny "portions". The item sheet
didn't render in shot 24 (the tap hit an off-screen chip), so it's scored from code. It holds
the nutrition card inside a sheet (card-in-sheet) with a tinted status pill.

**Onboarding.** The icon is centered while the title, body and list are left-aligned: mixed
alignment. The content is top-stacked with half the screen empty. The primary button sits
small in the bottom-right, and "Back" is a lonely green word. The progress segments are fine.
The goals fields show the floating-label-on-edge bug. There's no brand moment.

**Dark mode.** Everything has a green cast (seeded tonal palette). The saturated `#0CA30C`
ring and bars glare. The Vibe card is a dark-green slab. Primary buttons are pale mint with
dark text, which is acceptable but heavy. The Buy badge is pink with dark text (weak). Card vs.
background separation is ~1.1:1, which is fine, but the secondary text is greenish grey.

## Highest-impact problems, in priority order

Each item names the global primitive that causes it (fix it there, once).

### Layout
1. **Every block is the same rounded card.** `SectionCard` + `CardThemeData` (radius 20,
   `surfaceContainerLow`), used for every module, list and stat. There's no layout hierarchy,
   no hero and no rhythm, and lists sit in cards next to stats in cards. *Fix*: hero on the
   canvas, cards only for modules, grouped sections for lists, section titles outside.
2. **Buy chrome consumes ~280 dp before content** and duplicates ⊕. *Cause*: the
   `buy_screen.dart` action row (FilledButton + 3 `IconButton.filledTonal`) + `SegmentedButton`
   + search. *Fix*: header Add menu, `AppSegmented`, search directly above the content.
3. **Fixed pixel columns and crowded trailing slots.** The Other-spend row widths (116 / 78 /
   20) and the fridge row trailing (`FilledButton.tonal` + `PopupMenuButton` ≈ 160 dp) force
   4-line titles. *Fix*: two-line rows with full-width bars; S buttons; `more_horiz`.
4. **Onboarding composition**: `_page0` stacks a centered icon over left text, the content
   hugs the top and a small button sits bottom-right. *Fix*: left-aligned, full-width primary,
   brand mark.

### Hierarchy
5. **Page titles carry no hierarchy.** `AppBarTheme.titleTextStyle` renders at row-text size,
   so no screen has a title moment. *Fix*: large titles 30/36 w700 on tab roots, 17 w600 on
   pushed screens.
6. **Uppercase, tracked, grey 12 sp labels for every section** (`SectionCard`, `_Header`,
   `_Section`, `_Label`). They make all sections equal, they're weak at a glance, and in
   Settings they're green (accent used as decoration). *Fix*: sentence-case card titles (17),
   section titles (20) and group headers (15, secondary).
7. **Numbers have no numeric style.** Values use `titleMedium` (16 w600), labels 11–12 sp, and
   there are no tabular figures, so amounts in the ledger, settings and recipe columns don't
   align. *Fix*: the `AppNumbers` scale (44 / 28 / 20 / 16 / 13, tnum) and the number + unit pattern.

### Spacing
8. **Inconsistent rhythm and low density.** `ListTile` defaults (72 dp rows with 40 dp
   avatars), chip rows 76 tall, ad-hoc gaps of 4, 6, 10 and 14 (`SectionCard` padding 16/14/16/16,
   `_Header` 14/6, `_Section` 20/4). *Fix*: the 4-pt `AppSpace` scale, 52 / 64 rows, group
   headers 24 / 8, sections 28 / 8.

### Typography
9. **Default Roboto with a missing glyph and a weight soup.** There's no `fontFamily`, and
   the screenshot fallback lacks "→". Weights 400 / 500 / 600 / 700 are applied ad hoc (bold
   trailing values in settings outrank titles). *Fix*: Inter 4 weights, a defined `TextTheme`,
   and weight rules.

### Consistency
10. **Five chip styles plus pills.** `ActionChip` with avatar (outlined), `InputChip`,
    `ChoiceChip` with check, `FilterChip`, `Chip` tags, `StatusPill` in tinted pills, and a
    `SegmentedButton` with icons and a check. Tags look like buttons. *Fix*: four chip
    variants with no borders, a status *label* with no container, and `AppSegmented`.
11. **Status shown 1–3 ways per row** (leading icon, trailing icon, subtitle text). Cook again
    shows "Ready" twice, while quick check and stats use yet another pattern. *Fix*: status =
    one leading icon + subtitle text.
12. **Banners in three tints** (peach `serious` 12%, mint `primary` 10%, light-blue
    `tertiaryContainer`) built three ways (`_Banner`, `ConversionCard`, a `Card` with
    `ListTile`). *Fix*: one `AppNotice` with 4 variants.

### Color
13. **The seed palette tints everything mint.** `ColorScheme.fromSeed(seedColor: #2E7D5B)`
    puts green in the background, cards, tonal buttons, selected chips, the nav indicator and
    avatars, so the accent has no signal left. *Fix*: an explicit scheme with a warm neutral
    canvas, white surfaces, and the accent only for action and selection.
14. **The data palette is a rainbow and collides with status.** In `AppColors`, kcal blue,
    protein orange ≈ serious orange, `#0CA30C` good, a yellow star, a light-blue key card.
    *Fix*: blue / plum for nutrition, a harmonized green → amber → orange → red ladder, ink
    variants for status text.
15. **Dark mode glare and green cast** come from the same two primitives. *Fix*: the dark
    token set (§4.2) with desaturated status colors.

### Imagery
16. **No brand moment anywhere.** Empty states and onboarding use 40–44 sp Material icons in
    green. *Fix*: no stock imagery, the app mark on the welcome page, and glyph-circle empty states.

### Micro-details
17. **The pace marker** is a 2 × 14 tick at 70% ink that sticks out only above the bar. Make
    it a centered 2 × (h + 8) tick at 50%.
18. **Ink ripples** on rows and cards feel like stock Android. Use an instant highlight with no splash.
19. **Floating label on the fill's edge** (`OutlineInputBorder` + `filled`) in onboarding,
    review and the editor. Use `UnderlineInputBorder(radius 14, none)` so the label sits inside.
20. **Snackbar copy wraps with an orphan**, and the badge is pink-on-dark in dark mode.
21. **Full-screen spinners** (`CircularProgressIndicator`) on every load. Use skeletons.

## Issues outside pure visuals (for the Guardian / orchestrator)

- **Quick check opened cold shows an empty deck.** `QuickCheckScreen` snapshots
  `ref.read(quickCheckProvider)` on first build. Opened from a route or the weekly-recap
  notification (`/quick-check`) before `ingredientsProvider` has emitted, it shows "Nothing to
  check" while the Dashboard says "Quick check · 2" (shot 17). It's a UI-layer fix: wait for the
  pantry stream.
- **Screenshot tool**: 08 doesn't scroll (it drags the ask field's own `Scrollable`). 24 taps
  the off-screen use-soon chip, so the item sheet never opens.
