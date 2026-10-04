# Trackcalfin design system

The single source of truth for the redesign. The Implementer codes from this file; the
Director scores screenshots against it. Every value is exact. When something here
conflicts with older code, this file wins. When something is missing, ask the Director
rather than invent.

Contents: 0 Direction · 1 Principles · 2 Typography · 3 Spacing & layout · 4 Color ·
5 Shape · 6 Elevation & separation · 7 Components · 8 Iconography · 9 Motion ·
10 Imagery · 11 Accessibility · 12 Flutter token map · 13 Research notes

---

## 0. Direction: "the quiet kitchen ledger"

Warm paper canvas, white surfaces, near-black ink and one forest-green accent. The
numbers carry the design: they're set large, in tabular figures, with small grey units
beside them. Section titles are written in sentence case and are never letter-spaced caps.
Color appears only where it carries meaning: the accent marks what you can do, the status
colors mark how you're doing, and two cool data hues mark nutrition (blue for kcal, plum
for protein). Containers come in one kind (the white rounded surface). Shadows appear only
on things that float (the tab bar, ⊕, snackbars and menus). The whole app has a single ring,
the Vibe score, and everything else uses one shared linear progress bar.

## 1. Principles

1. **The number is the hero.** Every screen has one figure or title that the eye hits first.
   Figures are large and tabular, with units small and grey. Labels never outweigh values.
2. **One accent, used for action.** Forest green means you can tap it, or that something is
   selected or on track. Nothing decorative is green, and no surface gets tinted green just
   because the seed was green.
3. **Color means something or it isn't there.** Status colors appear only on status. The data
   hues appear only on kcal and protein. Status always shows an icon or text as well as color.
4. **One container type.** There's a single white rounded surface. A module or a list group
   earns one, and a lone label, number or button never does. Nothing is nested inside a
   second container.
5. **Fast paths stay one tap.** The commit control is the most prominent thing in its region
   (I cooked this, Eat 1, Looks good, category tile). Undo follows the tap, never a
   confirmation dialog.
6. **Calm by default, loud by exception.** Neutral when all is well. Amber or red only when
   something's actually off, and only on the Dashboard or a review screen, never right after
   a log (R10).
7. **Same thing, same look, everywhere.** A row, a section header, a stepper and a status label
   look the same on every screen. A new look needs a new meaning.

---

## 2. Typography

### 2.1 Family

**Inter 4.001** (SIL OFL 1.1), static TTFs, **4 weights**:

| File to ship | Source (npm tarball, verified) | Weight |
|---|---|---|
| `assets/fonts/Inter/Inter-Regular.ttf` | `@expo-google-fonts/inter@0.4.2` → `package/400Regular/Inter_400Regular.ttf` | 400 |
| `assets/fonts/Inter/Inter-Medium.ttf` | `… /500Medium/Inter_500Medium.ttf` | 500 |
| `assets/fonts/Inter/Inter-SemiBold.ttf` | `… /600SemiBold/Inter_600SemiBold.ttf` | 600 |
| `assets/fonts/Inter/Inter-Bold.ttf` | `… /700Bold/Inter_700Bold.ttf` | 700 |
| `assets/fonts/Inter/OFL.txt` | `raw.githubusercontent.com/google/fonts/main/ofl/inter/OFL.txt` (HTTP 200 checked) or the tarball's `LICENSE_FONT` | – |

`npm pack @expo-google-fonts/inter@0.4.2` and extract. Each file is about 335 KB, 1.3 MB in
total. No italics.

pubspec:
```yaml
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter/Inter-Regular.ttf
          weight: 400
        - asset: assets/fonts/Inter/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter/Inter-Bold.ttf
          weight: 700
```

**Why Inter.** I checked eleven OFL families with fontTools and rendered each one: Inter, Geist,
Schibsted Grotesk, Onest, Manrope, Plus Jakarta Sans, Figtree, Instrument Sans, DM Sans,
Albert Sans and Hanken Grotesk. Inter is the only one that covers every glyph we use
(`€ £ $ · × – — … ≈ ↑ ↓ → ← ÷ ~ ° ½ ± −` and Latin-1, which includes ü and è) **and**
ships a `tnum` that keeps `.` and `,` narrow. Schibsted Grotesk's `tnum` makes punctuation
tabular too, which renders "€7 . 80". Figtree is missing `≈`, and DM Sans and Albert Sans
have no `tnum`. Inter also has the largest x-height in the set (0.546 em), which helps the
13 and 11 sp captions. The current FX card shows a missing-glyph box for "→". Inter fixes that.

**Font features.**
- `FontFeature.tabularFigures()` on **every** numeric style (§2.3) and on any text whose main
  job is a number: amounts, quantities, kcal, times, counts and the stepper value.
- Proportional figures (Inter's default) everywhere else. This includes numbers inside running
  prose such as the Vibe insight or a recipe hook.
- No all-caps text in the app. You'll never need `case`.
- Set `leadingDistribution: TextLeadingDistribution.even` on every style. Text then centers
  optically in buttons, chips and rows.

### 2.2 Text styles → `TextTheme`

Sizes are in logical px and line heights are absolute (Flutter `height = LH / size`). Tracking
follows Inter's dynamic-metrics formula (`-0.0223 + 0.185·e^(-0.1745·size)` em), rounded.

| Role | `TextTheme` slot | Size / LH | Weight | Tracking (px) | Used for |
|---|---|---|---|---|---|
| Display | `displayLarge` | 56 / 60 | 600 | -1.25 | reserved (not used in v1) |
| Display M | `displayMedium` | 44 / 48 | 600 | -0.98 | expense amount input (tnum) |
| Display S | `displaySmall` | 34 / 40 | 700 | -0.74 | quick-check done state, empty hero numbers |
| **Large title** | `headlineLarge` | 30 / 36 | 700 | -0.64 | tab-root titles ("Sun 4 Oct", "Buy", "Cook", "Settings"), onboarding page titles |
| Title 1 | `headlineMedium` | 26 / 32 | 700 | -0.53 | recipe-detail title, quick-check question |
| Title 2 | `headlineSmall` | 22 / 28 | 600 | -0.40 | Today's-pick title, bottom-sheet titles |
| Title 3 | `titleLarge` | 20 / 26 | 600 | -0.33 | **section titles** on the canvas ("In the fridge", "Ingredients · 3 portions"), dialog titles |
| Headline | `titleMedium` | 17 / 22 | 600 | -0.22 | **card titles** ("Today", "Food spend"), compact app-bar title, "Vibe · Locked in" |
| Subhead | `titleSmall` | 15 / 20 | 600 | -0.13 | **group headers** (always `textSecondary`), tile titles |
| Body L | `bodyLarge` | 16 / 22 | 400 | -0.18 | default body; row titles use it at **w500** (see ListTile) |
| Body | `bodyMedium` | 15 / 21 | 400 | -0.13 | descriptions, hooks, insight line, notice text, step text uses 16/24 (below) |
| Footnote | `bodySmall` | 13 / 18 | 400 | -0.04 | row subtitles/meta, captions, helper text, footnotes |
| Button | `labelLarge` | 15 / 20 | 600 | -0.13 | all buttons, segmented labels |
| Label | `labelMedium` | 13 / 16 | 500 | -0.04 | chips, metric captions, status labels (w600) |
| Caption 2 | `labelSmall` | 11 / 13 | 500 | +0.05 | tab-bar labels, chart axis, badge, stepper hint ("max 3") |

**Reading text** (recipe steps): 16/24, w400, tracking −0.18. Write it as
`bodyLarge.copyWith(height: 24/16)`.

**Colors by default.** Text uses `onSurface` unless the table says secondary. Subtitles, meta,
captions and group headers use `textSecondary` (`scheme.onSurfaceVariant`). Placeholders and
chevrons use `textTertiary` (`scheme.outline`).

### 2.3 Numeric styles: `AppNumbers` ThemeExtension (`context.nums`)

All of these use tabular figures and `leadingDistribution.even`.

| Token | Size / LH | Weight | Tracking | Used for |
|---|---|---|---|---|
| `nums.hero` | 44 / 48 | 600 | -0.98 | expense amount, ingredient on-hand qty in the item sheet |
| `nums.large` | 28 / 32 | 600 | -0.59 | Today kcal and protein values, Vibe score (in the ring, w700, 24/28) |
| `nums.medium` | 20 / 24 | 600 | -0.33 | Food spend week/month values, metric values (pick card, recipe per portion), review total |
| `nums.title` | 17 / 22 | 600 | -0.22 | secondary figures in a card footer (Food spend metrics), stepper value |
| `nums.body` | 16 / 22 | 500 | -0.18 | trailing row values (qty, amount, day total), settings values (in `textSecondary`, w400) |
| `nums.small` | 13 / 18 | 500 | -0.04 | numbers inside meta lines that must align (ledger time, chart selection label) |

**Number + unit pattern.** Use **one** `Text.rich`, never two `Text` widgets: the value span in
the numeric style, then a no-break space (U+00A0, written `'\u00A0'` in Dart) and the unit span in the next smaller body
style in `textSecondary`. Example: `982` (nums.large) + ` kcal` (bodyMedium, secondary). Tests
and screen readers read the pair as one string.

**Number formatting.** Integers ≥ 1,000 get grouping (`NumberFormat.decimalPattern()`), so
"2,200 kcal", never "2200". This is a format change on the Dashboard and in Settings, flagged
in SCREENS.md. Money keeps `MoneyFormat` as it is.

### 2.4 Rules

- Weights: 400 for body, 500 for row titles and labels, 600 for headings, buttons and numbers,
  700 for large titles only (and the Vibe score). Never 300, never 800.
- Only three type sizes per card: its title (17), its values (28, 20 or 16) and its meta (13).
- No text below 11. Nothing essential below 13.
- Line length for prose is at most about 60 characters (recipe steps and onboarding body run
  near full width at 16 margin on phones, which is fine).
- Truncation: row titles get 2 lines and then an ellipsis. Subtitles get 2 lines. Values never
  truncate (their slot sizes to fit).

---

## 3. Spacing & layout

### 3.1 Scale (`AppSpace`)

Base unit **4**. Scale: `2, 4, 8, 12, 16, 20, 24, 32, 40, 48`.

| Token | Value | Use |
|---|---|---|
| `AppSpace.screen` | 16 | left/right page margin (phones). Sheets use 20 |
| `AppSpace.sheet` | 20 | bottom-sheet horizontal padding |
| `AppSpace.card` | 16 | card / group inner padding (all sides) |
| `AppSpace.hero` | 20 | hero card inner padding (Today's pick) |
| `AppSpace.cardGap` | 12 | between sibling cards |
| `AppSpace.section` | 28 | above a section title or group header (from the previous block) |
| `AppSpace.headerGap` | 8 | section title / group header → its content |
| `AppSpace.block` | 16 | between blocks inside a card (rows of metrics, a bar and its caption block) |
| `AppSpace.inline` | 8 | icon→text, chip→chip, button→button |
| `AppSpace.tight` | 4 | value→caption, title→subtitle |

### 3.2 Page anatomy (390 × 844 reference)

```
status bar (47)                                       ← system inset
┌ page header 60 ────────────────────────────────┐    tab roots: large title 30/36 at x=16,
│ Title                               [a] [b]    │    actions 44×44 hit, last one 8 from edge
└────────────────────────────────────────────────┘
  8                                                   header → first content
  content … margins 16, cards 12 apart, sections 28 apart
  bottom padding = MediaQuery.paddingOf(context).bottom + 24 (clears the floating nav)
```

- **Content width**: wider than 600 (tablet/desktop) centers the content column at max **600**.
  The floating nav centers at max 600 too.
- **Alignment lines** (keep them exact):
  - x = 16: screen edge of cards, large titles, section titles (20 sp), the Vibe ring.
  - x = 32: text inside cards and groups, and **group headers** (15 sp), so a small header
    sits on the same line as the rows it labels.
  - Right edge: trailing values align at screen width − 32 (inside cards) and never at
    different insets in the same list.
- **Rows**: horizontal padding 16 and vertical 12. A single-line row is at least 52 tall and a
  two-line row at least 64. The leading slot is 24 (icon) or 36 (glyph circle), with 12 gap
  to the text. The trailing slot has 12 gap. The separator starts at the text's x.
- **Vertical rhythm**: spacing is always from the 4-scale. Text leading follows §2.2. Never
  add stray 6 or 10 gaps.

### 3.3 Density targets (above the fold, 390 × 844 with nav)

| Screen | Must be fully visible without scrolling |
|---|---|
| Dashboard | Header, Vibe, Today card, Food spend week row |
| Pantry | Header, segmented, search, Use soon, first 3 category rows |
| Ledger | Header, segmented, filter chips, 5 transactions |
| Cook | Header, ask field, whole Today's-pick card incl. the cook button |
| Recipe | Title, hook, per-portion card, first 2 ingredients, bottom cook bar |

---

## 4. Color

### 4.1 Light theme

| Token | Hex | Flutter |
|---|---|---|
| Canvas (page background) | `#F4F3EF` | `scheme.surface`, `scaffoldBackgroundColor`, `surfaceDim` → `#E9E8E3` |
| Surface (cards, groups) | `#FFFFFF` | `scheme.surfaceContainerLow`, also `surfaceContainerLowest`, `surfaceBright` |
| Surface elevated (sheets, dialogs, menus, nav pill) | `#FFFFFF` | `scheme.surfaceContainer`, `surfaceContainerHigh` |
| Surface pressed / skeleton base | `#E9E8E3` | `scheme.surfaceContainerHighest` |
| Fill (inputs, stepper, segmented track, chips, tonal buttons) | `#191A18` @ 6% → `0x0F191A18` | `AppColors.fill` |
| Fill strong (pressed fill, skeleton) | `#191A18` @ 10% → `0x1A191A18` | `AppColors.fillStrong` |
| Text primary | `#191A18` | `scheme.onSurface` |
| Text secondary | `#62645F` | `scheme.onSurfaceVariant` (= `textSecondary`) |
| Text tertiary (placeholders, chevrons, disabled-ish) | `#787A74` | `scheme.outline`, `AppColors.textTertiary` |
| Disabled content | `#191A18` @ 38% | M3 default |
| Separator / hairline | `#E4E3DD` | `scheme.outlineVariant`, `AppColors.separator` |
| **Accent** | `#1D6A4A` | `scheme.primary` (also `secondary`, `tertiary`; see 4.4) |
| On accent | `#FFFFFF` | `scheme.onPrimary` |
| Accent container (selected toggle chip, highlight) | `#E1EEE6` | `scheme.primaryContainer` |
| On accent container | `#0F4A32` | `scheme.onPrimaryContainer` |
| Inverse surface (snackbar) | `#2A2B29` | `scheme.inverseSurface` |
| On inverse | `#F1F1EE` | `scheme.onInverseSurface` |
| Inverse accent (snackbar action) | `#86D6AC` | `scheme.inversePrimary` |
| Error | `#C2362E` / on `#FFFFFF` | `scheme.error`, `onError`; container `#FBE9E7` / on `#7A1A14` |
| Modal barrier | `#000000` @ 32% | `BottomSheetThemeData.modalBarrierColor`, dialogs |

### 4.2 Dark theme

| Token | Hex | Flutter |
|---|---|---|
| Canvas | `#0E0F0E` | `scheme.surface`, scaffold, `surfaceDim` |
| Surface (cards, groups) | `#1C1D1B` | `scheme.surfaceContainerLow` (`surfaceContainerLowest` = `#0A0B0A`) |
| Surface elevated (sheets, dialogs, menus, nav pill) | `#242523` | `scheme.surfaceContainer`, `surfaceContainerHigh` |
| Surface pressed / skeleton base | `#2E2F2C` | `scheme.surfaceContainerHighest`, `surfaceBright` |
| Fill | `#FFFFFF` @ 8% → `0x14FFFFFF` | `AppColors.fill` |
| Fill strong | `#FFFFFF` @ 14% → `0x24FFFFFF` | `AppColors.fillStrong` |
| Text primary | `#F1F1EE` | `scheme.onSurface` |
| Text secondary | `#A9ABA5` | `scheme.onSurfaceVariant` |
| Text tertiary | `#7C7F78` | `scheme.outline`, `AppColors.textTertiary` |
| Separator | `#30322E` | `scheme.outlineVariant`, `AppColors.separator` |
| **Accent** | `#74C99E` | `scheme.primary` |
| On accent | `#04281A` | `scheme.onPrimary` |
| Accent container | `#1A3A2B` | `scheme.primaryContainer` |
| On accent container | `#B9E7CE` | `scheme.onPrimaryContainer` |
| Inverse surface / on / accent | `#EDEDEA` / `#1A1B19` / `#1D6A4A` | snackbar |
| Error | `#F08A80` / on `#3D0905`; container `#3A1714` / on `#FFD9D4` | |
| Modal barrier | `#000000` @ 56% | |

### 4.3 Status & data colors: `AppColors` (ThemeExtension)

Existing fields keep their names. **New fields**: `fill`, `fillStrong`, `separator`,
`textTertiary`, `goodInk`, `warningInk`, `criticalInk`.

| Field | Light | Dark | Meaning / where |
|---|---|---|---|
| `kcal` | `#3A6BD6` (blue) | `#7DA0F0` | energy: Today kcal bar + dot, week bars, kcal dots in metrics |
| `protein` | `#A04AB4` (plum) | `#CC86DA` | protein: Today protein bar + dot, protein dots in metrics |
| `good` | `#24845A` | `#74C99E` | on pace, ready, confirmed: bar fills, ring, check icons |
| `warning` | `#BD7F00` (amber) | `#EBB33A` | pace ≤ +15 %, needs a look, missing item: fills and icons |
| `serious` | `#D2691A` (orange) | `#F0924C` | pace ≤ +30 %, use-soon ≤ 1 day: fills and icons |
| `critical` | `#CC3A31` (red) | `#EE7468` | pace > +30 %, failed scan, badge background, destructive |
| `track` | `#EAE9E3` | `#2D2F2B` | progress-bar and ring tracks |
| `gridLine` | `#D6D5CF` | `#3B3D38` | chart target line, dashed |
| `fill` | `0x0F191A18` | `0x14FFFFFF` | see 4.1 |
| `fillStrong` | `0x1A191A18` | `0x24FFFFFF` | see 4.1 |
| `separator` | `#E4E3DD` | `#30322E` | hairlines |
| `textTertiary` | `#787A74` | `#7C7F78` | placeholders, chevrons |
| `goodInk` | `#24845A` | `#74C99E` | status **text** (On pace, Ready) |
| `warningInk` | `#8F6200` | `#EBB33A` | status text (12% ahead, 1 to check) |
| `criticalInk` | `#B42E26` | `#F28B80` | status text, destructive text buttons |

Add `Color inkForPace(double? pace)` next to `forPace`, with the same thresholds but returning
`goodInk/warningInk/warningInk/criticalInk`. Serious text uses `warningInk`, because orange
text on white is only 3.6:1. `copyWith` and `lerp` must include the new fields (lerp with
`Color.lerp`, so theme switches animate).

**Why these hues.** The brand is a forest green (app icon `#2E7D5B`). Status needs the
familiar green → amber → orange → red ladder. So the two nutrition series take the **cool
side**, blue and plum, which collide with no status meaning. The old protein orange `#EB6834`
was indistinguishable from the old "serious" `#EC835A`. Blue and plum are also always labelled
("kcal", "protein") and always sit in fixed positions, so color is never the only cue.

**Where the accent appears (exhaustive):** filled buttons, text buttons, the ⊕, the selected
tab icon and label, the selected single-select chip, the switch "on" track, the focus ring,
links, the Today's-pick eyebrow, the action-chip icon, capture-tile icons, the ask-field
icons, the progress segments in onboarding, selection in date/time pickers, the text cursor.
(The selected segment of a segmented control stays neutral: white thumb with ink label, see
7.6.) **Nowhere else.** In particular: no green section labels,
no green-tinted cards, no green icons in rows, no green avatar circles.

### 4.4 ColorScheme construction

Don't use `ColorScheme.fromSeed`. Build the scheme explicitly (`ColorScheme(brightness: …)`)
with the values above. Set `secondary/onSecondary/secondaryContainer/onSecondaryContainer`
**equal to the neutral fill set** (`secondaryContainer` = `#EFEEE9` light / `#2E2F2C` dark,
`onSecondaryContainer` = `onSurface`). Set `tertiary*` equal to `primary*`. Then no stray mint
or light blue reaches any default component. `surfaceTint` = `Colors.transparent`, and
`shadow`/`scrim` = `#000000`.

### 4.5 Interactive states

| State | Spec |
|---|---|
| Pressed (rows, cards, tiles) | overlay `AppColors.fillStrong` over the surface, instant on press, fades out 150 ms. **No ripple** (`splashFactory: NoSplash.splashFactory`, `highlightColor: AppColors.fillStrong`; ruled in review 01) |
| Pressed (filled button) | overlay `onPrimary` @ 12% |
| Pressed (text button / icon button) | overlay `onSurface` @ 8% (accent @ 10% for accent text buttons) |
| Pressed (⊕) | scale 0.94 over 120 ms + overlay `onPrimary` @ 12% |
| Hover (desktop only) | overlay 4% (light) / 6% (dark) |
| Focus (keyboard) | 2 px `primary` ring, offset 2, following the control's shape |
| Disabled | content `onSurface` @ 38%; filled containers `onSurface` @ 10%; no shadow |
| Selected: single-select chip | `primary` background, `onPrimary` label, w600 |
| Selected: multi-select chip | `primaryContainer` background, `onPrimaryContainer` label w600, leading `check_rounded` 16 |
| Selected: segmented | thumb = surface (light `#FFFFFF` with shadow §6, dark `#3A3C38`), label `onSurface` w600; unselected label `textSecondary` w500 |
| Selected: tab | icon (filled) + label in `primary`, indicator capsule `AppColors.fill` |
| Error field | fill `critical` @ 8%, helper text in `criticalInk` |

### 4.6 Contrast (WCAG 2.2, measured)

| Pair | Light | Dark | Requirement |
|---|---|---|---|
| Text primary on surface / canvas | 17.5 / 15.7 | 15.0 / 17.0 | ≥ 4.5 ✓ |
| Text secondary on surface / canvas / fill | 6.0 / 5.4 / 4.8 | 7.3 / 8.3 / 6.1 | ≥ 4.5 ✓ |
| Text tertiary on surface / canvas | 4.3 / 3.9 | 4.2 / 4.7 | placeholders and chevrons only (≥ 3 ✓). **Never essential text** |
| Accent text on surface / canvas | 6.5 / 5.9 | 8.5 / 9.7 | ≥ 4.5 ✓ |
| On-accent label on accent button | 6.5 | 8.0 | ≥ 4.5 ✓ |
| Accent text on fill (tonal button) | 5.8 | 6.1 | ≥ 4.5 ✓ |
| On accent container | 8.6 | 9.1 | ✓ |
| goodInk / warningInk / criticalInk on surface | 4.6 / 5.4 / 6.3 | 8.2 / 8.9 / 7.2 | ≥ 4.5 ✓ |
| kcal / protein fill on surface | 4.9 / 5.1 | 6.6 / 6.4 | graphics ≥ 3 ✓ |
| good / warning / serious / critical fill on surface | 4.6 / 3.4 / 3.6 / 5.0 | 8.2 / 8.9 / 7.2 / 5.9 | graphics ≥ 3 ✓ |
| kcal fill on track | 4.1 | 5.3 | ✓ |
| Snackbar text on inverse | 12.6 | 14.7 | ✓; action 8.3 / 5.6 ✓ |
| Badge white on critical | 5.0 | dark uses `#2A0B07` on `#EE7468` = 6.4 | ✓ |
| Surface vs canvas (separation) | 1.11 | 1.14 (sheet 1.25) | by design, iOS-grouped style |

The ratios come from the WCAG relative-luminance formula
(`/tmp/claude-0/-home-user-Trackcalfin/959da1af-9ea6-51de-b8b3-a820cf5d3c3b/scratchpad/contrast.py`).
Re-check them if any hex changes.

---

## 5. Shape (`AppRadius`)

| Token | Radius | Applies to |
|---|---|---|
| `AppRadius.card` | 20 | cards, grouped-list sections, notices on the canvas, the Vibe hero highlight (16, see 7.4) |
| `AppRadius.sheet` | 28 | bottom-sheet top corners |
| `AppRadius.dialog` | 24 | dialogs, date/time pickers |
| `AppRadius.tile` | 16 | capture tiles, use-soon tiles, quick-check card (24) |
| `AppRadius.input` | 14 | text fields, search, the expense category buttons |
| `AppRadius.menu` | 14 | popup menus, snackbars |
| `AppRadius.segment` | 12 track / 9 thumb | segmented controls |
| `AppRadius.chip` | 10 | chips (all variants) |
| `AppRadius.tag` | 6 | non-interactive tags (recipe tags) |
| Capsule (`StadiumBorder`) | – | buttons, stepper, nav pill, tab indicator, Quick-check header button |
| Circle | – | ⊕, icon buttons with fill, step numbers, glyph circles, badges |
| Bars | height / 2 | progress bars and tracks; week bars 6 top / 2 bottom |

**When a container is warranted:**
- **Card** (white, radius 20): a self-contained module with mixed content, such as a Dashboard
  module, Today's pick, Per portion or Nutrition per 100 g.
- **Grouped section** (white, radius 20, rows split by hairlines): a homogeneous list such as
  a pantry category, a ledger day, settings, fridge, cook again, ingredients or inbox jobs.
- **Directly on the canvas**: page and section titles, the Vibe hero, group headers,
  explanatory footnotes, horizontal tile strips (the tiles are the containers), chips that
  stand alone (staples), and empty states.
- **Never**: a container around a single label or number, a container inside a card (except
  fields and tiles, which are controls), a tinted card for "importance", or a border around a
  card.

---

## 6. Elevation & separation

Surfaces separate by **value** (white on warm canvas, or `#1C1D1B` on `#0E0F0E`), never by
shadow or border. Shadows exist only for things that float above scrolling content.

| Element | Shadow(s) | Border |
|---|---|---|
| Cards, groups, notices | none | none |
| Floating nav pill | `BoxShadow(color: black @ 8% (dark 40%), blur 24, offset (0, 8))` + `BoxShadow(black @ 4% (dark 0%), blur 2, offset (0, 1))` | 0.5 px `separator` (light); 0.5 px white @ 6% (dark) |
| ⊕ capture button | `BoxShadow(color: primary @ 28% (dark: black @ 40%), blur 16, offset (0, 6))` | none |
| Snackbar | `BoxShadow(black @ 18%, blur 24, offset (0, 8))` | none |
| Popup menu | `BoxShadow(black @ 12%, blur 24, offset (0, 8))` | 0.5 px `separator` (dark only) |
| Segmented thumb (light only) | `BoxShadow(black @ 10%, blur 3, offset (0, 1))` + `BoxShadow(black @ 4%, blur 0, spread 0.5)` | none |
| Bottom sheet, dialog | none (the barrier separates) | none |
| Bottom action bar (recipe, review) | none | top hairline 0.5 px `separator` |
| Page header on scroll | none (or 0.5 elevation, see 7.5) | bottom hairline 0.5 px `separator` once content scrolls under (**required**, see 7.5) |

**Hairlines** are 0.5 logical px in `AppColors.separator`, inset to the text start (x = 32 in a
group). There's none above the first row or below the last one.

**Blur**: only the floating nav pill (`ImageFilter.blur(sigmaX: 20, sigmaY: 20)` over the
surface color at 88% opacity) and the bottom action bars (canvas at 94% + blur 20). That's the
whole "glass" budget, and nothing else is translucent.

---

## 7. Components

Every component lives in `lib/features/common/widgets.dart` (or `lib/app/floating_nav.dart`),
and screens compose them. **Keep these public class names**: `PortionStepper`, `SectionCard`,
`PaceBar`, `RingGauge`, `WeekBars`, `StatusPill`, `Metric`, `EmptyState`, and the functions
`showUndo`, `showUndoOn`, `showInfo`. The Guardian's tests find some of them by type. You can
change their internals and add parameters.

### 7.1 Buttons

| Variant | Background | Label / icon | Height | H-padding | Use |
|---|---|---|---|---|---|
| **Primary** (`FilledButton`) | `primary` | `onPrimary`, labelLarge, icon 20, gap 8 | L 52 · M 44 | 24 · 20 | the one commit per region: I cooked this, Looks good, Get started/Next, Log meal, Convert all lines, Save (sheets), Add to pantry |
| **Secondary / tonal** (`FilledButton.tonal`) | `AppColors.fill` | `primary`, w600 | M 44 · S 36 | 20 · 16 | Eat 1, Add an item, Try again, Something else, Gone/Adjust (quick check), Add key |
| **Tertiary / text** (`TextButton`) | none | `primary`, w600 | 44 (S 36) | 12 | + Meal, Swap, Fill with AI, Change rate, Wrong currency?, Mark as correct, Back, Skip, Cancel, Add a note |
| **Destructive** | none (text) | `criticalInk`, w600 | 44 | 12 | Discard, Delete, Remove. The import confirm uses a **filled** button with `critical` bg and white label |
| **Icon button** | none | `onSurface` icon 24 (rows: `textSecondary` 20) | 44 visual, 48 hit | – | app-bar actions, row overflow (`more_horiz_rounded`) |
| **Icon button, tonal** | `AppColors.fill`, circle 44 | `onSurface` 20 | 44 | – | the big ± in the ingredient sheet |
| **Capture ⊕** | `primary` circle 60 | `add_rounded` 28 `onPrimary` | 60 | – | global capture only |

- Shape: capsule for all. `minimumSize` height as above. `tapTargetSize: padded` so S still has 48 hit.
- One primary per visible region. A primary never sits next to another primary.
- `OutlinedButton` is **not used**. Restyle current uses to tonal.
- Disabled primary: bg `onSurface` @ 10%, label @ 38%.
- A loading button keeps its width and swaps the icon for a 16 px, 2 px-stroke spinner in the label color.

### 7.2 Cards: `SectionCard`

- Background `surfaceContainerLow`, radius 20, padding 16 (hero: 20), no border, no shadow,
  `clipBehavior: antiAlias`.
- **Title row** (optional): title in `titleMedium` (17/22 w600, `onSurface`) and **sentence
  case**. Drop the `.toUpperCase()`. The optional trailing widget (a text button, a status
  label, or a meta text in `bodySmall` `textSecondary`) sits right-aligned and vertically centered
  on the title line. Text buttons in the trailing slot use negative margin so their text aligns
  to the card's right padding (x = 358). Title → content gap 12.
- Tappable cards get the pressed overlay (4.5). Add a trailing `chevron_right_rounded` 20 in
  `textTertiary` **only** when tapping navigates and the card shows no other affordance.

### 7.3 Grouped sections & rows

`AppGroup` (new): white surface, radius 20, children separated by hairlines (x from 32 to
the right edge, i.e. inset 16 inside the group). It clips its children, so swipe backgrounds
and pressed overlays follow the rounded corners.

`AppRow` (new, or themed `ListTile`) anatomy:
```
| 16 | [leading 24/36] 12 | Title (bodyLarge w500, 2 lines max)        | 12 [trailing] | 16 |
|    |                    | Subtitle (bodySmall, textSecondary, 2 max) |               |    |
```
- Min height 52 (one line) / ≥ 64 (two lines; 66 in practice: 22 + 2 + 18 + 2 × 12); vertical
  padding 12; title → subtitle gap **2** (review 02).
- **Rows with an interactive trailing control** (switch, button, icon button): vertical padding
  **8**, min height **56** (one line) / **64** (two lines), so the control's 48 hit target doesn't
  inflate the row to 72 (review 02).
- `AppGroup` hairline indents: `indentPlain` 16, `indentIcon` 52, `indentGlyph` 64 (inside the group).
- Trailing options: value (`nums.body`, `onSurface`; settings values in `textSecondary` w400),
  chevron (`chevron_right_rounded` 20 `textTertiary`), switch, small tonal button (S 36), or
  icon button. A value and a chevron can combine (value 8 gap chevron).
- Leading: only when it carries information (category in a mixed list, status). Use a
  24 icon in `textSecondary` (or a status color), or a **glyph circle** (36 circle, fill
  `AppColors.fill`, icon 20 `textSecondary`) for mixed-category lists (ledger, capture).
- `ListTileThemeData`: `contentPadding: EdgeInsets.symmetric(horizontal: 16)`,
  `minVerticalPadding: 12`, `titleTextStyle: bodyLarge.copyWith(fontWeight: w500)`,
  `subtitleTextStyle: bodySmall` (`textSecondary`), `leadingAndTrailingTextStyle: nums.body`,
  `iconColor: textSecondary`, `minLeadingWidth: 24`, `horizontalTitleGap: 12`.
- Swipe actions (`Dismissible`): the background is `critical` @ 100% with a white label and icon
  (`Out` + `remove_shopping_cart_outlined`, or `delete_outline_rounded`), right-aligned with
  24 padding, clipped by the group.

### 7.4 Section titles, group headers, the hero

| Kind | Style | Position | Example |
|---|---|---|---|
| **Section title** (on canvas) | `titleLarge` 20/26 w600 `onSurface` | x = 16; 28 above, 8 below; optional trailing text button or meta on the same baseline at x = 374 | "In the fridge", "Cook again", "Ingredients · 3 portions", "Steps" |
| **Group header** (on canvas, above a group) | `titleSmall` 15/20 w600 `textSecondary` | x = 32; 24 above, 8 below; optional leading icon 16 `textSecondary` with 6 gap; optional trailing value `nums.body` w600 `textSecondary` at x = 358 | "Produce", "Yesterday  €7.80", "Goals", "Check 1" |
| **Card title** | `titleMedium` 17/22 | inside a card, see 7.2 | "Today", "Food spend" |
| **Eyebrow** | `labelMedium` 13/16 **w600** in `primary`, leading icon 16 `primary`, gap 6, sentence case | top of the Today's-pick card only | "☀ Today's pick" |

**Vibe hero** (Dashboard only): it sits on the canvas, not in a card. Layout is ring 72 at x = 16,
16 gap, then a text column (title `titleMedium`, insight `bodyMedium` `textSecondary`, max 3
lines), then a trailing `chevron_right_rounded` 20 `textTertiary` aligned to the title line.
The tap target is the whole hero: `InkWell` with radius 16, inset 8 from the screen edges and
inner padding 8, so the content still aligns at x = 16.

### 7.5 Page headers (app bars)

- **Tab roots** (Dashboard, Buy, Cook, Settings): `AppBar(toolbarHeight: 60, titleSpacing: 16,
  centerTitle: false)`, title in `headlineLarge` (30/36 w700). Background is the canvas,
  `scrolledUnderElevation: 0`, `surfaceTintColor: transparent`. Actions are 44 icon buttons with
  the last one 8 from the edge. The header doesn't scroll away. Content scrolls beneath it.
- **Pushed screens** (inbox, review, recipe, editor, stats, quick check): `toolbarHeight: 52`,
  adaptive back button (tooltip "Back"), title `titleMedium` 17/22 w600, left-aligned next to
  the back button (`titleSpacing: 0`). Same colors.
- **Header actions**: icon buttons, or one compact capsule button (36 tall, fill bg, icon 18 +
  `labelLarge` 14/18 w600). Example: `[☑ Quick check · 2]`, where the icon is in `primary` and
  the label in `onSurface`.
- **Header edges** (ruled in review 01): an action with a *visible* shape (the capsule button)
  ends at x = screen − 16, flush with the cards. Icon-only actions keep the 8 px edge inset, so
  their glyph lands near x = screen − 16.
- **Header → content**: the first content block starts exactly **8** below the header (tab
  roots: status inset + 60 + 8) on every tab. A group header that comes first still uses 8, not 24.
- **Scrolled under** (required, not optional): once content scrolls beneath the header, a 0.5 px
  `separator` line appears at its bottom edge (or an equivalent 0.5 elevation shadow,
  `shadowColor` black @ 30% light / 60% dark). At rest, there's no line. A card must never
  look sliced by an invisible edge.

### 7.6 Segmented control: `AppSegmented<T>` (new)

Replaces `SegmentedButton` everywhere (Pantry/Ledger, theme mode, unit g/ml/pc, Amount
charged/Exchange rate).
- Track: `AppColors.fill`, radius 12, height 40, padding 3. Thumb: radius 9, light `#FFFFFF`
  with the §6 shadow, dark `#3A3C38`. It slides 220 ms `easeOutCubic`.
- Labels: `labelLarge` 15/20, selected w600 `onSurface`, unselected w500 `textSecondary`. **No
  icons, no checkmark.** Each label is a `Text` widget, because tests find "Ledger", "System",
  "Light" and "Dark".
- Full width when it's the page's main switch (Buy). Hug content (min segment width 64) inside
  forms.
- Semantics: each segment is a button with `selected` state.

### 7.7 Inputs

- Filled, no visible border: `filled: true`, `fillColor: WidgetStateColor` → `AppColors.fill`
  (focused: `fillStrong`; error: `critical` @ 8%; disabled: `fill` @ 50%).
- Border: `UnderlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)`
  for **all** states. The floating label then sits *inside* the filled field instead of on its
  edge, which is the current bug in onboarding and the review editor.
- `contentPadding: EdgeInsets.fromLTRB(16, 12, 16, 12)`. Single-line height is about 56 with a
  label, 48 without.
- Label `bodySmall` 13 `textSecondary` (focused: `primary`). Value `bodyLarge` 16 `onSurface`
  (numeric fields use tnum). Hint `bodyLarge` `textTertiary`. Prefix/suffix `bodyLarge`
  `textSecondary`. Helper and error `bodySmall`, with error in `criticalInk`.
- Search field: `search_rounded` 20 `textSecondary` prefix, hint "Search pantry", height 44,
  radius 14, no label.
- The ask field (Cook) is a search-style field: prefix `auto_awesome_outlined` 20 `primary`
  (busy: 16 spinner), suffix icon button (mic / send / listening) 40 in `primary`. Height 48.
- Keep `labelText` **inside** `InputDecoration`. Tests find fields by their label ("kcal", "search").

### 7.8 Chips

Height 36 (hit 48 via padded tap target), radius 10, horizontal padding 14 (12 when it has
an icon), icon 16 with gap 6, label `labelMedium` 13/16. Spacing 8 both ways. **No borders.**

| Variant | Unselected | Selected | Use |
|---|---|---|---|
| **Choice** (single-select) | `fill` bg, `onSurface` w500, optional category icon `textSecondary` | `primary` bg, `onPrimary` w600, icon `onPrimary` | Ledger filters, review line category, transaction category, currency picker |
| **Toggle** (multi-select) | `fill` bg, `onSurface` w500 | `primaryContainer` bg, `onPrimaryContainer` w600, leading `check_rounded` 16 | Diet, Equipment, onboarding staples |
| **Input** (removable) | `fill` bg, `onSurface` w500, trailing `close_rounded` 16 `textSecondary` (32 hit) | – | Allergies, Dislikes, Cuisines, Meal reminder times |
| **Action** | `fill` bg, leading icon 16 in `primary`, label `onSurface` w500 | – | "Add" (settings tags), "Confirm / Ask AI / Scan label / Edit" (nutrition), "I'm out / Looks right", "Use last rate", staples in pantry |
| **Tag** (not interactive) | `fill` bg, radius 6, height 26, `labelMedium` w500 `textSecondary`, padding 10 | – | recipe tags ("high protein") |

The staple chip for an item without macros shows a leading `help_outline_rounded` 16 in `warning`.

### 7.9 Steppers: `PortionStepper`

- Capsule, `fill` bg, height 48. Two 44 × 44 icon buttons (`remove_rounded` / `add_rounded` 20,
  `onSurface`, disabled @ 38%) with tooltips **"Fewer portions" / "More portions"** (keep them).
- Center column, min width 40: value in `nums.title` (17, w600, tnum; line height 20 here) and optional hint below in
  `labelSmall` `textSecondary` ("max 3", "portions"). The hint only renders when given.
- Haptic `tick()` on each change.
- Inline stepper in forms (recipe editor, onboarding rhythm): reuse `PortionStepper` without a
  hint. Don't build ad-hoc `IconButton` rows.
- Ingredient quantity stepper (item sheet): two 44 tonal circle buttons and the value between
  them in `nums.hero` (44/48) with an "on hand" caption (`bodySmall`), centered, 24 between
  the buttons and the value.

### 7.10 Progress: `PaceBar`, `RingGauge`, `WeekBars`

**PaceBar** (the only linear progress in the app):
- Height 6 in cards and 4 in dense rows. Radius h/2. Track `AppColors.track`. Fill color comes
  from the caller (`good`/`warning`/`serious`/`critical` via `forPace`, or `kcal`/`protein`).
  A non-zero fill is at least as wide as it is tall.
- **Marker** ("expected by now"): 2 × (h + 8), radius 1, `onSurface` @ 50%, centered
  vertically on the bar. It replaces the current 0.7-alpha tick, which was taller than the bar
  only on top.
- Animates width 450 ms `easeOutCubic` from the previous value. With reduced motion (11.4) the
  change is instant.
- Semantics: `"<label> <value> of <target>"`, plus the status text when there is one.

**RingGauge**: used **only** for the Vibe score. Size 72, stroke 7, round cap, start at 12
o'clock, track `AppColors.track`, fill = status (`good` ≥ 70, `warning` ≥ 50, `critical` < 50,
null → track only). The center shows the score in `nums.large` at 24/28 **w700** (or "–" when
it's null). It animates 600 ms `easeOutCubic` from 0 on first build only. Semantics:
"Vibe 97 of 100, Locked in".

**WeekBars** (calories this week):
- Chart height 112. Seven slots; bar width = slot width − 12 (clamped to 12…28) and centered.
  Bar radius 6 top / 2 bottom. A day with a value > 0 is at least 4 tall.
- Colors: completed days `kcal` @ 85%; the selected day `kcal` @ 100%; today (in progress)
  `kcal` @ 35%.
- Target line: dashed 1 px `gridLine`, dash 4 / gap 4, full width, behind the bars.
- Selection label above the chart (height 18): `nums.small` w600 `onSurface`, centered over the
  selected bar (or centered on the chart), "Su · 982 kcal". Tapping a column toggles selection.
- Day labels: `labelSmall` `textSecondary` with today `onSurface` w600, 6 below the bars.
- Each column has semantics: "Sunday, 982 kcal, in progress".

### 7.11 Status label: `StatusPill` (keeps its name, loses the pill)

There's no container. Icon 14 + gap 4 + text `labelMedium` **w600**, both in the **ink** color
(`goodInk`, `warningInk`, `criticalInk`, or `textSecondary` for neutral). Icons: `check_rounded`
(on pace, ready), `north_east_rounded` (ahead), `info_outline_rounded` (stock short),
`help_outline_rounded` (unknown), `verified_outlined` (confirmed), `auto_awesome_outlined`
(AI estimate), `history_rounded` (not checked). Labels are sentence case ("On pace",
"12% ahead", "AI estimate"). The constructor gains an optional `ink` color. When it's
omitted, the label renders in `onSurface` and the icon in `color`.

### 7.12 Metric: `Metric`

A vertical pair: the value (default `nums.medium` 20/24; pass a style to override) and 4 below
it the caption in `bodySmall` `textSecondary`. When `dotColor` is set, an 8 px dot sits before
the caption with 6 gap, vertically centered on the caption's x-height. Metric rows use
`Row` + `Expanded` (equal columns) when there are ≤ 4. They wrap (`Wrap`, spacing 24,
runSpacing 12) when text scale > 1.3.

### 7.13 Notices (banners): `AppNotice` (new)

For exceptional, actionable information on a page (totals mismatch, receipt in another
currency, missing API key, items without macros, the recipe verdict, an error).
- Radius 16, padding 14, no border. Background: `info` = `AppColors.fill`; `warning` =
  `warning` @ 12% (dark 16%); `critical` = `critical` @ 10% (dark 16%); `success` = `good` @ 10%
  (dark 14%).
- Leading icon 20 in the variant color (info: `primary`), top-aligned with the first text line,
  with 12 gap.
- Optional title in `titleSmall` 15/20 w600 `onSurface`, then the body in `bodyMedium` 15/21
  `onSurface`, then optional meta in `bodySmall` `textSecondary`.
- Actions are text buttons (S 36) on a row under the text, with the first one's label aligned
  to the text start (negative 12 margin). Or the whole notice is tappable with a trailing
  chevron.
- At most one notice per kind per screen. Never stack more than two.

### 7.14 Bottom sheets & dialogs

- `BottomSheetThemeData`: `backgroundColor: surfaceContainer`, `surfaceTintColor: transparent`,
  `shape: RoundedRectangleBorder(borderRadius: vertical top 28)`, `showDragHandle: true`,
  `dragHandleColor: onSurface @ 18%`, `dragHandleSize: Size(36, 4)`, `modalBarrierColor` per 4.1
  and 4.2, `elevation: 0`, `clipBehavior: antiAlias`, `constraints: maxWidth 640`.
- Sheet content: padding `20, 0, 20, 24` + bottom safe area. Title in `headlineSmall` 22/28 w600,
  then an optional subtitle in `bodyMedium` `textSecondary` 4 below, then 16 to content. Field
  spacing 12. The primary action sits at the bottom, full width (L 52), 20 above the bottom
  padding. A trailing title control (stepper, Skip, edit toggle) aligns to the title's center.
- Lists inside sheets use `AppRow` directly on the sheet surface with hairlines. Don't nest a
  group card inside a sheet.
- Dialogs: `surfaceContainerHigh`, radius 24, padding 24, title `titleLarge`, content
  `bodyMedium` `textSecondary`, actions right-aligned (`TextButton` Cancel, `FilledButton` M
  Save), 8 apart. They're used only for settings value prompts and the import warning.
- Popup menus: `surfaceContainer`, radius 14, item height 48, padding 16, text `bodyLarge`,
  optional leading icon 20 `textSecondary` with 12 gap. Destructive items in `criticalInk`. Min
  width 200. Shadow per §6.

### 7.15 Snackbar / undo: `showUndo`, `showUndoOn`, `showInfo`

- `SnackBarThemeData`: `behavior: floating`, `backgroundColor: inverseSurface`, shape radius 14,
  `insetPadding: EdgeInsets.fromLTRB(16, 0, 16, 12)` (it must sit **above** the floating nav, as
  it does today), `elevation: 0` + the §6 shadow (wrap the content or accept M3 elevation 6 with
  `shadowColor` black @ 18%), `actionTextColor: inversePrimary`.
- Content: the message in `bodyMedium` **w500** 15/21 `onInverseSurface`, max 2 lines. The detail
  goes on a second line in `bodySmall` `onInverseSurface` @ 70%. The action "Undo" is
  `labelLarge` w600 `inversePrimary` with a 44 hit target.
- Duration: undo 5 s, info 3 s. One at a time (`hideCurrentSnackBar` first, already done).
- Copy rules: lead with what happened ("Logged Red lentil & chickpea dal"). Put the number in
  the detail line, not across a wrap. The cook message "1 logged, 2 in the fridge · 51 g protein
  each" should break as `message: "1 logged, 2 in the fridge"`, `detail: "51 g protein each"`.
  That is a layout change, not a copy change. The smoke test looks for 'in the fridge' with
  `textContaining`, so it still passes.

### 7.16 Badges

`BadgeThemeData`: `backgroundColor: critical` (dark: `#EE7468` with label `#2A0B07`),
`textColor: #FFFFFF`, `smallSize: 8`, `largeSize: 16`, `textStyle: labelSmall w600 tnum`,
`padding: EdgeInsets.symmetric(horizontal: 4)`, `offset: Offset(6, -4)` from the icon's
top-right. Badges are for counts that need action only (Inbox). Never more than one per bar.

### 7.17 Floating tab bar + ⊕ (Flutter-drawn; iOS 26+ uses the native bar)

```
| 16 |  ( pill: 4 tabs, height 60, radius 30 )  | 12 | (⊕ 60) | 16 |
```
- `FloatingNav.height = 60`. Bottom offset `max(12, bottomInset − 8)`, unchanged.
- Pill: surface color @ 88% (light `#FFFFFF`, dark `#242523`) over `BackdropFilter` blur 20,
  with the §6 shadow and border. Inner padding 4.
- Indicator: capsule, `AppColors.fill`, as wide as the tab slot and as tall as the pill's
  inner height (pill 60 − 2 × 4 padding = 52). It slides 280 ms `easeOutCubic` (as now).
- Tab: icon 24 above the label `labelSmall` 11/13, 2 apart, the pair vertically centered.
  Selected: `primary`, filled icon (`*_rounded`), label w600. Unselected: `textSecondary`,
  outlined icon, label w500. Pressed: no ripple; the indicator is the feedback, plus
  `tick()` haptic.
- Icons (keep the SF-symbol metaphors so the native bar matches): Dashboard
  `insights_outlined`/`insights_rounded`, Buy `shopping_basket_outlined`/`shopping_basket_rounded`,
  Cook `soup_kitchen_outlined`/`soup_kitchen_rounded`, Settings `tune_rounded` (both states;
  the selected one is colored).
- ⊕: circle 60, `primary` with `add_rounded` 28 `onPrimary`. Tooltip **"Log something"** (keep
  it). Pressed: scale 0.94 over 120 ms. Haptic `tick()` on tap.
- Badge on Buy per 7.16.

### 7.18 Empty, loading and error states

**Empty state (`EmptyState`)**: centered in its region, vertical padding 32, max text width
300. A glyph circle 56 (`AppColors.fill`) with the icon 28 `textSecondary`, then 16, the title
in `titleMedium` 17/22, 6, the message in `bodyMedium` `textSecondary` (centered), 16, and the
optional action as a tonal M button. No illustrations.

**Loading**: use a **skeleton** whenever the shape of the content is known (Dashboard first
load, Today's pick "Planning from your pantry…", Quick check deck before the pantry loads,
Settings before the profile loads). Skeleton blocks are `AppColors.fillStrong`, with text lines
at height = font size × 0.7 and radius 4, block radius 12. They pulse in opacity 1.0 → 0.55 →
1.0 over 1200 ms `easeInOut`, repeating (static under reduced motion). Show the real labels
that are already known; the skeleton only stands in for data. **Spinners** only appear inline:
16 px, 2 px stroke, `primary`, inside a button, field prefix or status row ("Reading 1 scan…").
No full-screen `CircularProgressIndicator` anywhere. Replace the current ones with skeletons.

**Error**: an inline `AppNotice` (critical) in place of the failed module, saying
"Couldn't load this." with the technical detail in the meta line (`$e`, max 2 lines) and a
"Try again" text button when a retry exists. Never a bare `Text('Could not load: $e')`
centered on the screen.

### 7.19 Tiles (capture sheet, use-soon strip)

- **Capture tile**: `AppColors.fill` bg, radius 16, height 104, padding 12, centered column:
  icon 26 in `primary`, 10, title `titleSmall` 15/20 w600 `onSurface` (1 line), 2, subtitle
  `labelMedium` w400 `textSecondary` (1 line). A grid of 3 columns, 10 gap.
- **Pantry tile** (Use soon / Running low strip): surface bg (white), radius 16, min width 132,
  max 180, height 72, padding 12/14. Name in `bodyLarge` w500 (1 line, ellipsis), 2, then the
  meta in `bodySmall`: the qty in `textSecondary`, " · ", and the days in `warningInk`
  (`criticalInk` when ≤ 1 day / "use today"). Running-low meta is `trending_down_rounded` 14
  `warning` + qty. Horizontal `ListView`, 16 side padding, 8 gap.

---

## 8. Iconography

- **Library**: bundled Material Icons only. Default and unselected use `*_outlined`. Selected,
  filled and status use `*_rounded`. **Never `*_sharp`**, and never mix outlined and rounded
  in one row. Chevrons, add, close, check, more and arrows are always `*_rounded`.
- **Sizes**: 24 in app bars, the nav and empty-state circles (28 there); 20 in rows, buttons,
  fields and notices; 16 in chips, inline meta and group headers; 14 in status labels.
- **Colors**: `onSurface` for app-bar actions; `textSecondary` for row leading and inline meta;
  `primary` only on interactive icons (⊕, tab selected, ask prefix, action-chip icon, capture
  tiles, Today's-pick eyebrow); status colors only for status icons.
- **When an icon earns its place**: (a) it's the only label of a control, and then it **must**
  have a tooltip; (b) it distinguishes items in a *mixed* list (ledger categories, capture
  options, staple without macros); (c) it encodes status together with text. **Not** as a
  repeated decoration on every row of a homogeneous group (pantry rows, fridge rows), and not
  next to a section title.
- **Swaps**: `more_vert` → `more_horiz_rounded`; `add` → `add_rounded`; `check` →
  `check_rounded`; `check_circle` → `check_circle_rounded`; `close` → `close_rounded`; `edit_note`
  stays (Write a recipe); `warning_amber_rounded` stays; `star`/`star_border` →
  `star_rounded`/`star_outline_rounded` (favorite star color: `onSurface`, never yellow).

---

## 9. Motion

**Philosophy**: motion confirms cause and effect and is over quickly. Nothing loops except
skeleton pulses, nothing bounces, and nothing counts up for show.

| Token (`AppMotion`) | Duration | Curve | Used for |
|---|---|---|---|
| `quick` | 120 ms | `Curves.easeOut` | press scale (⊕), highlight fade-in |
| `short` | 200 ms | `Curves.easeOutCubic` | chip select, switch, value crossfade (`AnimatedSwitcher`), icon swaps |
| `medium` | 280 ms | `Curves.easeOutCubic` | nav indicator, segmented thumb (220 ms), expand/collapse (`AnimatedSize`, `easeInOutCubic`) |
| `sheet` | 300 ms in / 220 ms out | `Cubic(0.2, 0, 0, 1)` | bottom sheets (`sheetAnimationStyle: AnimationStyle(duration:…, reverseDuration:…)`) |
| `long` | 450 ms | `Curves.easeOutCubic` | progress-bar fills, week-bar heights |
| `ring` | 600 ms | `Curves.easeOutCubic` | Vibe ring, first build only |

- **Page transitions**: `PageTransitionsTheme` with iOS/macOS → `CupertinoPageTransitionsBuilder`,
  Android/Linux/Windows → `FadeForwardsPageTransitionsBuilder` (present in this SDK).
- **Tap feedback**: the pressed overlay is instant on press and fades out 150 ms. No ink ripples.
- **Haptics**: keep `celebrate()` (medium) after every commit (cook, eat, expense, scan
  queued, review filed). `tick()` (selection) on stepper changes, chip toggles, tab changes, ⊕,
  swipe commits and quick-check answers.
- **Commit moment** (Fogg "shine"): after "I cooked this" or "Eat 1", the button label
  crossfades to a `check_rounded` + "Cooked · again?" state (existing logic) over `short`. The
  affected numbers (fridge count, Today values) crossfade to their new values. The snackbar
  carries the undo.
- **Numbers**: when a value changes in place, `AnimatedSwitcher` fades it over `short` with no
  vertical slide. Bars and ring tween as specified. No count-up animations.
- **Reduced motion**: if `MediaQuery.disableAnimationsOf(context)` is true, the ring, bars,
  skeleton pulse and number crossfades are instant. Sheets and page transitions stay (the OS
  shortens them).

---

## 10. Imagery

**Decision: no photography and no illustrations.**
- Recipes are generated or typed. A stock photo would show a dish that isn't the user's and
  invents the look of an AI recipe. That conflicts with "LLM proposes, Dart disposes" honesty.
  Recipe cards get their character from the title, hook and numbers.
- Empty states use the glyph circle (7.18), which reads as part of the app rather than
  decoration.
- **One brand moment**: the onboarding welcome page shows the app mark at 72 × 72 (radius 18
  squircle). Draw it with a `CustomPainter` that ports the paths in
  `assets/branding/app_icon.svg` (`#2E7D5B` field, leaf `#A8E6C1` / `#7FD3A4`, bowl `#F6F3EA`,
  rim `#E4DDCB`). It's our own asset, so there's no license question and no new dependency. In
  dark mode it stays the same, because it's the icon.
- Anything else (food photos, 3D emoji, gradients, mesh blobs) is clutter and stays out.

---

## 11. Accessibility

1. **Contrast**: per 4.6. Essential text ≥ 4.5:1 and graphics/UI boundaries ≥ 3:1 in both
   themes. Tertiary text is for placeholders and chevrons only.
2. **Never color alone**: every status pairs with an icon and words (On pace, 12% ahead, Ready,
   Missing X, 1 day left). Every macro color pairs with its label (kcal, protein). Selected
   chips change weight (and multi-select ones show a check). Tabs change icon fill and weight.
3. **Touch targets**: ≥ 48 × 48 dp hit area for everything interactive
   (`materialTapTargetSize: padded`). The visual size can be smaller (chips 36, S buttons 36),
   but the hit area can't. Row-level actions (Eat 1, ⋯) keep 8 between targets.
4. **Text scaling**: the app follows the system `TextScaler`. Layouts must hold at **1.3×**
   without clipping. Rows wrap to 2 lines, metric rows switch to `Wrap`, and fixed-width text
   columns are forbidden (the current 116 / 78 px columns in Other spend must go). Clamp only
   the Display/`nums.hero` and `nums.large` styles to a max scale of 1.4
   (`MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.4)` locally). Everything else
   scales freely.
5. **Semantics**: icon-only controls have tooltips (they become labels). Rings and bars carry
   `Semantics(label: …)` with the numbers. Each week bar is a button with day and value. Group
   and section headers are `Semantics(header: true)`. Tabs keep `selected` and `button`. A
   dismissible row also offers its action through a long-press or overflow alternative
   (pantry: the item sheet has "I'm out"; ledger: the transaction sheet). Keep these.
6. **Reduced motion** per §9. **Dark mode** is complete (every token has a dark value).
7. **Focus order** follows visual order. Desktop keyboard focus shows the 2 px ring.

---

## 12. Flutter token map (`lib/app/theme.dart`)

A skeleton the Implementer can type straight in (values from the tables above):

```dart
abstract final class AppSpace {
  static const x1 = 4.0, x2 = 8.0, x3 = 12.0, x4 = 16.0, x5 = 20.0, x6 = 24.0, x8 = 32.0, x10 = 40.0, x12 = 48.0;
  static const screen = 16.0, sheet = 20.0, card = 16.0, hero = 20.0, cardGap = 12.0,
      section = 28.0, headerGap = 8.0, block = 16.0, inline = 8.0, tight = 4.0;
  static const maxContentWidth = 600.0;
}

abstract final class AppRadius {
  static const card = 20.0, sheet = 28.0, dialog = 24.0, tile = 16.0, input = 14.0, menu = 14.0,
      segmentTrack = 12.0, segmentThumb = 9.0, chip = 10.0, tag = 6.0;
}

abstract final class AppMotion {
  static const quick = Duration(milliseconds: 120), short = Duration(milliseconds: 200),
      medium = Duration(milliseconds: 280), long = Duration(milliseconds: 450), ring = Duration(milliseconds: 600);
  static const sheetIn = Duration(milliseconds: 300), sheetOut = Duration(milliseconds: 220);
  static const standard = Curves.easeOutCubic, move = Curves.easeInOutCubic, emphasized = Cubic(0.2, 0, 0, 1);
}

// ThemeExtension with hero/large/medium/title/body/small (all tabular, Inter) → context.nums
class AppNumbers extends ThemeExtension<AppNumbers> { … }

// helper used by every style
TextStyle _inter(double size, double lh, FontWeight w, double tracking, Color color, {bool tnum = false}) => TextStyle(
  fontFamily: 'Inter', fontSize: size, height: lh / size, fontWeight: w, letterSpacing: tracking, color: color,
  leadingDistribution: TextLeadingDistribution.even,
  fontFeatures: tnum ? const [FontFeature.tabularFigures()] : null,
);
```

`ThemeData` must set: `fontFamily: 'Inter'`, the full `textTheme` (§2.2), explicit
`colorScheme` (§4.4), `scaffoldBackgroundColor`, `splashFactory: NoSplash.splashFactory`,
`highlightColor: AppColors.fillStrong`, `hoverColor`, `focusColor`, `materialTapTargetSize: padded`,
`visualDensity: VisualDensity.standard`, `pageTransitionsTheme` (§9), and themes for
`appBarTheme` (7.5), `cardTheme` (7.2), `listTileTheme` (7.3), `filledButtonTheme`,
`textButtonTheme`, `iconButtonTheme` (7.1), `inputDecorationTheme` (7.7), `chipTheme` (7.8),
`switchTheme`, `checkboxTheme`, `bottomSheetTheme`, `dialogTheme`, `popupMenuTheme` (7.14),
`snackBarTheme` (7.15), `badgeTheme` (7.16), `dividerTheme` (`thickness: 0.5`,
`color: separator`, `space: 0.5`), `progressIndicatorTheme` (`color: primary`,
`linearTrackColor: track`, `linearMinHeight: 4`), `tooltipTheme` (inverse surface, radius 8,
`bodySmall`).

**Switch** (`SwitchThemeData`): track on = `primary`, track off = light `#D9D8D2` / dark
`#3A3C38`, `trackOutlineColor: transparent`, thumb on = `#FFFFFF` (light) / `#F1F1EE` (dark),
per review 02 (a dark thumb on the mint track read as a hole), thumb off = `#FFFFFF`
(dark `#C9CBC5`). To get the full-size off thumb (no M3 shrinking), set
`thumbIcon: WidgetStatePropertyAll(Icon(Icons.circle, color: Colors.transparent))`.
**Checkbox**: radius 6, fill `primary` when checked, border 1.5 `textTertiary` unchecked,
check `onPrimary`.

---

## 13. Research notes (what I used, briefly)

- **Apple HIG, Typography** (JSON endpoint of developer.apple.com): iOS default sizes and
  leading (Large Title 34/41 … Caption 2 11/13), minimum 11 pt, avoid light weights. Our scale
  follows those ratios, scaled to Inter's larger x-height (30 large title, 17 headline, 16
  body, 13 footnote, 11 caption).
- **Apple HIG, Charting data**: keep charts simple, highlight the important value, use common
  bar charts, never rely on color alone, give accessibility labels. That's why there's one ring
  and one bar chart, the selected-day label and per-bar semantics.
- **Apple HIG, Tab bars**: tab bars are for navigation, not actions. That's why ⊕ sits
  *beside* the pill and isn't a tab. Use single-word labels, red badges only for critical
  counts, and filled icons when selected.
- **Apple HIG, Layout**: group with negative space, containers or separators, put important
  content top and leading, and keep alignment consistent. That's the x = 16 / x = 32 alignment
  lines.
- **WCAG 2.2** 1.4.3 (text 4.5:1) and 1.4.11 (non-text 3:1). Ratios computed with the WCAG
  relative-luminance formula (scratchpad script).
- **Inter dynamic metrics** (rsms.me/inter): the tracking formula in §2.2. Glyph and `tnum`
  coverage verified locally with fontTools on the npm TTFs.
- **Reference screenshots** (principles only, not copied): one hero number with a small grey
  qualifier ("of $2,000 spent"); sentence-case section titles with right-aligned meta ("Where it
  went · 6 categories"); right-aligned amounts with a secondary "of" line; one highlighted bar
  among neutral ones; units set smaller than their numbers ("1230 kcal"); a calm, sparse
  layout. Rejected from them: rainbow color-blocked category cards, a black hero card,
  superscript cents, pastel-tinted cards, greeting headers with avatars, decorative waveforms.
