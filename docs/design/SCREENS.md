# Screen-by-screen redesign specs

Read with `DESIGN_SYSTEM.md`, which defines every token and component named here. The
wireframes assume 390 dp width with 16 margins, `│` marks a surface (card or group) edge, and
`──` is a hairline.

**Flag legend** (for the Integrity Guardian):
- 🟠 **MOVED**: an action that changes place or now needs one more tap.
- 🔵 **COPY**: a change to a string in the test-copy list, which includes casing. The finder needs updating.
- ⚪ **copy**: a string change outside the test-copy list, listed for completeness.
- ⚫ **FORMAT**: a number shown in a different format (e.g. thousands grouping).

**Global changes that affect several screens**
1. `SectionCard`, `_Header` (pantry), `_Section` (settings) and `_Label` (review) **stop
   uppercasing**. Titles render in the sentence case already written in code. 🔵 This changes
   `TODAY`, `FOOD SPEND`, `OTHER SPEND · MONTH`, `CALORIES THIS WEEK`, `USE SOON`,
   `IN THE FRIDGE`, `COOK AGAIN` and `NUTRITION PER 100 G` (see each screen).
2. Integers ≥ 1,000 use grouping ("2,200"). ⚫ This hits the kcal target on Dashboard ("2,200"),
   Settings "Daily calories" ("2,200 kcal") and the onboarding default display (the field keeps
   the raw "2200" because it's an input). The display-fidelity test's `value('2200')` needs
   `NumberFormat.decimalPattern()`.
3. Number + unit always render in **one** `Text.rich` (e.g. "48 g"), so `value('48 g')` still
   matches.
4. **Keep these widget types and finders stable**: `PortionStepper` (tooltips "Fewer
   portions"/"More portions", value and hint as text); the Dashboard and Pantry main scrollers
   stay a vertical `ListView` that is the first `ListView` in the tab's subtree (the smoke test
   drags `find.byType(ListView).first`); one `TextField` on Cook; one `PopupMenuButton<String>`
   on Cook (fridge) and on Recipe detail; tooltips "Log something", "Inbox", "Write a recipe",
   "Hold to talk, or tap to send", "Favorite"/"Remove favorite", "Edit details"; segment labels
   as `Text`.
5. No screen shows a full-screen `CircularProgressIndicator`. Skeletons are defined per screen.

---

## 1. Dashboard (`lib/features/dashboard/dashboard_screen.dart`)

```
 ┌──────────────────────────────────────────┐  status bar
  Sun 4 Oct                  [☑ Quick check · 2]   ← headlineLarge; capsule button (36)
  8
  (97)  Vibe · Locked in                    ›       ← hero on canvas, ring 72
        Everything's on track: 6 days
        logged, ~€122 saved.
  20
 │ Today                               + Meal │    ← card, titleMedium + text button
 │ 12                                         │
 │ 982 kcal               48 g                │    ← nums.large + unit (bodyMedium, secondary)
 │ ● of 2,200 kcal · 45%  ● of 140 g · 34%    │    ← bodySmall secondary, dot = kcal / protein
 │ ▬▬▬▬▬▬░░░░░░░░░        ▬▬▬▬░░░░░░░░░░      │    ← PaceBar h6, kcal / protein
 │ (Nothing logged yet today.)                │    ← only when 0 meals, bodySmall secondary
  12
 │ Food spend                                 │
 │ Week                                       │    ← labelMedium secondary
 │ €54 / €69                       ✓ On pace  │    ← nums.medium + " / €69" bodyMedium secondary; StatusPill
 │ ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬|▬▬░░░          │    ← PaceBar h6 + marker
 │ 16                                         │
 │ Month                                      │
 │ €42 / €300                      ✓ On pace  │
 │ ▬▬|▬░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░         │
 │ Projected month: €254 (trailing week × 4.33) │  ← bodySmall secondary
 │ ────────────────────────────────────────── │    ← hairline, 12 above / 12 below
 │ €52            €3.97          €122         │    ← Metric, value nums.title (see note)
 │ eaten this     per home       saved vs     │
 │ week           meal           eating out   │
  12
 │ Other spend                    This month  │    ← title + trailing meta (bodySmall secondary)
 │ ⌂ Household                     €1 / €40   │    ← icon 16 secondary, bodyLarge w500, nums.body
 │ ▬░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░      │    ← PaceBar h4 (+ marker), full width
 │ 12                                         │
 │ ⚘ Clothes                       €0 / €50   │
 │ ▬…                                         │
 │ 🍴 Eating out          ⚠ €22 / €60         │    ← over-pace: warning_amber 16 serious + amount in warningInk
 │ ▬▬▬▬▬▬▬░░░…                                │
 │ ★ Entertainment                 €0 / €40   │
 │ ⋯ Other                              €0    │    ← no limit: no bar
  12
 │ Calories this week      🔥 14-day streak   │    ← trailing: flame 16 + labelMedium w600, both secondary
 │ Avg 2,167 kcal · 119 g protein             │    ← titleSmall 15/20 w600 onSurface (tnum)
 │ 6 of 6 days logged                         │    ← bodySmall secondary
 │            Su · 982 kcal                   │    ← selection label
 │ ▇   ▇   ▆   ▇   ▇   ▆   ▂   - - - target   │    ← WeekBars h112
 │ Mo  Tu  We  Th  Fr  Sa  Su                 │
 │ Dashed line: your daily target. Today is still in progress. │ ← bodySmall secondary
  24 + nav
```
Metric values in the Food spend footer use `nums.title` (17/22 w600, one step below
`nums.medium`, so the week/month values stay dominant). Captions are `bodySmall`.

**Hierarchy**: (1) the date title and the Vibe score with its label, which say how I'm doing.
(2) Today's two big numbers, kcal and protein. (3) The food-spend week value with its status.
(4) Everything else is reference: month, metrics, other spend, the week chart.

**Components**: page header (7.5) + header capsule button; Vibe hero (7.4) with `RingGauge`;
`SectionCard` ×4; `PaceBar`; `StatusPill` (label variant); `Metric`; `WeekBars`; the
"How the vibe is scored" sheet (bottom sheet 7.14 with rows: name `bodyLarge`, value
`nums.body` w600 right, `PaceBar` h6 colored by score, 16 between rows).

**States**
- Loading: header (real date) + a skeleton hero (72 circle + 2 lines) + 2 card skeletons
  (title line + 2 value blocks + bar). No spinner.
- Error: `AppNotice` critical "Couldn't load your dashboard." with the detail as meta.
- Vibe with no score: ring track only, "–" in the center, label as computed.

**Preservation checklist**

| # | Datum / action today | New location | Flag |
|---|---|---|---|
| 1 | Date "Sun 4 Oct" (app-bar title) | Large title | – |
| 2 | Quick check chip "Quick check · N" (only when N > 0) → `/quick-check` | Header capsule button, same text and condition | – |
| 3 | Vibe score in ring | Ring center | – |
| 4 | "Vibe · {label}" | Hero title (same string) | – |
| 5 | Vibe band icon (bolt/check/trend/restart) | **Removed**: decorative, it duplicates the label. Ring color and label carry the band | ⚪ |
| 6 | Vibe insight line | Hero body | – |
| 7 | Tap Vibe → "How the vibe is scored" sheet (title, explainer, 5 component rows with value + bar) | Tap hero (whole area, + chevron); sheet restyled, same content | – |
| 8 | Today kcal value, target, % | "982 kcal" + "of 2,200 kcal · 45%" + bar | ⚫ ⚪ ("kcal / 2200" → "of 2,200 kcal · 45%") |
| 9 | Today protein value, target, % | "48 g" + "of 140 g · 34%" + bar | ⚪ |
| 10 | Rings for kcal and protein | **Linear bars** (the ring is reserved for Vibe); % kept as text | ⚪ |
| 11 | "+ Meal" → ate sheet | Card title trailing text button "+ Meal" (`Text('Meal')` with a `add_rounded` icon, so `textCI('Meal')` still matches) | – |
| 12 | "Nothing logged yet today." | Same, under the bars | – |
| 13 | Week spent / budget, pace label "on pace" / "N% ahead", bar + elapsed marker | Week block | ⚪ "on pace" → "On pace" |
| 14 | Month spent / budget, pace label, bar + marker | Month block | ⚪ |
| 15 | "Projected month: €254 (trailing week × 4.33)" / "Projection after 7 days of data" | Under month bar | – |
| 16 | €52 eaten this week · €3.97 per home meal · €122 saved vs eating out ('–' fallbacks) | Card footer metrics | – |
| 17 | Other spend rows: icon, label, bar (+ month marker) when limited, "€x / €y" or "€x", over-pace warning icon (> 1.15, semantic "Over pace") | Two-line rows, same data; the warning icon moves next to the amount; the amount turns `warningInk` when over | – |
| 18 | "No other spending this month." | Same, card body | – |
| 19 | Title "Other spend · month" | 🔵 **"Other spend"** + trailing meta **"This month"** | 🔵 `OTHER SPEND · MONTH` → find `Other spend` |
| 20 | Calories-this-week avg label (3 variants), coverage "x of y days logged" | Same strings | – |
| 21 | Streak "N-day streak" with tooltip (freeze explanation / days in a row), only ≥ 2 | Card title trailing, same tooltip | – |
| 22 | Week bars, tap to read a day, today muted, today label bold, dashed target | `WeekBars` restyled, same behavior | – |
| 23 | Footnote "Dashed line: your daily target. Today is still in progress." | Same | – |
| 24 | Card titles TODAY / FOOD SPEND / CALORIES THIS WEEK | 🔵 "Today" / "Food spend" / "Calories this week" | 🔵 ×3 |

---

## 2. Buy (`buy_screen.dart`, `pantry_view.dart`, `ledger_view.dart`)

### 2a. Shared header

```
  Buy                                 [▣²]  [+]     ← headlineLarge; Inbox icon (badge); Add menu
  8
  [  Pantry          |          Ledger  ]           ← AppSegmented, full width, 40
  ◌ Reading 1 scan…                    Inbox        ← only while scans run: 16 spinner,
                                                       bodySmall secondary, S text button
```
`[+]` (tooltip "Add") opens a popup menu (7.14) with leading icons:
`receipt_long_outlined` **Scan receipt** · `kitchen_outlined` **Pantry photo** ·
`payments_outlined` **Log expense** · `add_box_outlined` **Add pantry item**.

🟠 **MOVED**: the four action buttons (filled "Scan receipt", tonal icon buttons "Pantry photo",
"Log expense", "Add pantry item") move into the header **Add** menu, with the menu item text
equal to the old tooltips. They stay one tap away through ⊕ as well (Scan receipt, Pantry,
Expense), except "Add pantry item", which is only here and in the empty state. Reason: the row
duplicated ⊕ and spent 56 dp of fixed chrome on every visit. The reachability test needs:
open `find.byTooltip('Add')`, then `textCI('Scan receipt')`, `textCI('Pantry photo')`,
`textCI('Log expense')`, `textCI('Add pantry item')`.

### 2b. Pantry

```
  [⌕ Search pantry                              ]  ← search field 44
  12
 │ ⓘ 1 item has no macros          Fill with AI │  ← AppNotice warning, tappable (→ review), S text button
 │   Recipes count them as 0 kcal               │     (spinner 16 replaces the button while filling)
    Use soon                                       ← group header (x=32)
 ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌──    ← pantry tiles, horizontal
 │Spinach    │ │Bananas    │ │Chicken b… │
 │210 g · 1 day│3 pc · 2 days│650 g · 2 days        (days in warningInk; ≤1 day criticalInk)
 └───────────┘ └───────────┘ └───────────┘
    Running low
 ┌──────────────┐
 │Whole milk    │                                  ← tile; meta: ↘ 150 ml
 │↘ 150 ml      │
 └──────────────┘
    🌿 Produce                                     ← group header with category icon 16
 │ Bananas                                  3 pc │  ← AppRow: title w500, meta, trailing nums.body
 │ €0.75 · 2 days left                           │
 │ ───────────────────────────────────────────── │
 │ Onions                                  600 g │
 │ €1.50 · 24 days left                          │
 │ ───────────────────────────────────────────── │
 │ Red bell pepper                          2 pc │
 │ €1.40 · 3 days left · check                   │
    🐟 Meat & fish
 │ Chicken breast                          650 g │
 │ €6.49 · 2 days left                           │
   … more categories …
 │ Out of stock (4)                           ⌄ │  ← single-row group, expands in place (AnimatedSize)
    Staples · always assumed
  [Salt] [Olive oil] [ⓘ Cumin] [Paprika] …         ← action chips (fill), tap → item sheet
 │ ☑ Review macros · 12 unconfirmed            › │  ← single-row group
```

- The row meta joins with " · " exactly as today: value, "N days left" / "use today",
  "check", "no macros". "no macros" renders in `warningInk`. The rest stays `textSecondary`.
- Swipe left on a row → "Out" (critical background, white label and icon), commit + undo
  snackbar, unchanged.
- Search with no matches: `EmptyState(icon: search_off_rounded, title: 'No items match', message: null)`. ⚪ new string.
- Pantry empty: `EmptyState(icon: kitchen_outlined, title: 'Your pantry is empty', message: …, action: tonal 'Add an item')`, unchanged copy.
- Loading: skeleton (search field + 3 tile blocks + 6 rows).

**Hierarchy**: (1) the title and segmented control (where am I). (2) Use soon, the tiles that
drive action, plus the macros notice when present. (3) The category lists with their
quantities aligned right.

**Preservation checklist (Pantry + header)**

| # | Datum / action today | New location | Flag |
|---|---|---|---|
| 1 | Title "Buy" | Large title | – |
| 2 | Inbox icon + count badge → `/inbox` (tooltip "Inbox") | Header icon button, same tooltip and badge | – |
| 3 | Scan receipt (filled) | Add menu item "Scan receipt" | 🟠 |
| 4 | Pantry photo (tooltip) | Add menu item "Pantry photo" | 🟠 |
| 5 | Log expense (tooltip) | Add menu item "Log expense" | 🟠 |
| 6 | Add pantry item (tooltip) | Add menu item "Add pantry item" | 🟠 |
| 7 | "Reading N scan(s)…" + Inbox text button | Status row under the segmented control | – |
| 8 | Pantry / Ledger switch | `AppSegmented` (labels as Text, icons dropped) | ⚪ icons removed |
| 9 | Search pantry (filters by name/key) | Search field, same `hintText: 'Search pantry'` | – |
| 10 | "N item(s) has/have no macros", "Recipes count them as 0 kcal", Fill with AI (spinner), tap → review | `AppNotice` warning; same strings; tap whole notice → review | – |
| 11 | Use soon: name, qty, days left, tap → item sheet (sorted by days) | Pantry tiles, same order | 🔵 `USE SOON` → `Use soon` |
| 12 | Running low: name, qty, tap → item sheet | Pantry tiles (name / ↘ qty) | ⚪ "Name · qty" splits into 2 lines |
| 13 | Category groups (header = category label), sorted by category index | Group header + `AppGroup` | ⚪ casing |
| 14 | Per-row category avatar icon | 🟠 moves to the **group header** (one per category); rows lose it | ⚪ |
| 15 | Row: name, stock value €, days left / use today, "check", "no macros", qty on hand | Same fields, same order | – |
| 16 | Row tap → item sheet; swipe left → mark out + undo | Same | – |
| 17 | "Out of stock (n)" expand/collapse | Single-row group, chevron rotates | – |
| 18 | Staples chips (help icon when no macros), tap → item sheet | Action chips (fill), same | – |
| 19 | "Review macros · N unconfirmed" → reviewMacros | Single-row group with chevron, **same string** | – |
| 20 | Empty pantry state + "Add an item" | Same | – |

### 2c. Ledger

```
  (header + segmented as 2a)
  [All] [🧺 Groceries] [⌂ Household] [⚘ Clothes] [🍴 Eating out] …   ← choice chips, h-scroll, 16 side padding
    Yesterday                               €7.80   ← group header + day total (nums.body w600 secondary)
 │ (🍴) Café                                €7.80 │  ← glyph circle 36, title, trailing nums.body
 │      12:12                                     │
    Friday                                 €43.44
 │ (🧺) Lidl                               €43.44 │
 │      18:12 · 3 items · scanned                 │
    Thursday                               €14.50
 │ (🍴) Ramen place                        €14.50 │
 │      13:12                                     │
```
- One `AppGroup` per day, rows separated by hairlines, 12 between groups (header 24 above).
- Swipe left → delete + undo (detail "Its N pantry items were taken back out"), unchanged.
- Empty: `EmptyState(receipt_long_outlined, 'No transactions yet', 'Scan a receipt or log an expense with the + button.')`, unchanged (the "+" now also exists in the header).
- Filtered amounts (`_amount`) unchanged.

| # | Datum / action today | New location | Flag |
|---|---|---|---|
| 1 | Filter chips All + 6 categories (with icons); tap again = clear | Choice chips (selected = accent fill) | – |
| 2 | Day label (Today/Yesterday/weekday/date) + day total | Group header left + right | – |
| 3 | Row: category icon, title (merchant / note / line / category), time, "N items", "N stocked", original-currency amount, "scanned", amount (filtered) | Same; icon in a glyph circle | – |
| 4 | Tap → transaction sheet; swipe → delete + undo | Same | – |
| 5 | Empty state | Same | – |

### 2d. Item sheet (`ingredient_sheet.dart`): shot 24

```
            ───
  Chicken breast                          [✎]      ← headlineSmall; tooltip "Edit details" (close icon when editing)
  (review mode: "Check macros · 2 of 12"           Skip)
  16
         (−)      650 g       (+)                  ← tonal circles 44, nums.hero + "on hand"
                 on hand
  12
       [⊘ I'm out]   [✓ Looks right]               ← action chips, centered
  Avg cost €9.98 per kg                            ← bodySmall secondary, centered
  16
 │ Nutrition per 100 g            ✦ AI estimate │  ← fill-colored inset panel (see note)
 │ 165 kcal   31 g      0 g      3.6 g           │
 │ ●kcal      ●protein  carbs    fat             │
 │ [✓ Confirm] [⌸ Scan label] [✎ Edit]          │
```
Note: a sheet already sits on a surface, so the nutrition block uses a **fill-colored inset
panel** (`AppColors.fill`, radius 16, padding 16) instead of a white card. It's the single
allowed exception to "no container in a container", because it groups status + numbers +
actions. Title row: `titleMedium` "Nutrition per 100 g" 🔵 (was `NUTRITION PER 100 G`) +
`StatusPill` label variant ("AI estimate" / "Confirmed" / "From label" / "Unknown", same
strings).

Edit mode (unchanged fields, restyled): Name; Quantity + `AppSegmented` g/ml/pc; Price paid
(new only, helper); Grams per piece (pc); Category (dropdown in a filled field); Nutrition per
100 g/ml + helper + five macro fields (new only); Keeps for (days) | Low below (unit); Staple
switch row with subtitle; bottom row: destructive text "Delete" (existing) · primary
"Save" / "Add to pantry". Macro edit mode: label-read note, flags in `criticalInk`, five
fields, "Cancel" text + primary M "Save macros". Busy: `LinearProgressIndicator` (h4, radius 2)
in the panel. Errors in `criticalInk`.

| # | Datum / action today | New location | Flag |
|---|---|---|---|
| 1 | Name / "New pantry item"; review progress "Check macros · i of n"; Skip; edit toggle (tooltip Edit details / Done editing) | Title row | – |
| 2 | Qty stepper ±step, "on hand" | Big stepper | – |
| 3 | I'm out; Looks right | Action chips | – |
| 4 | Avg cost per kg/l/piece | Caption | – |
| 5 | Nutrition card: status pill, macros (kcal/protein/carbs/fat), unknown text / "Asking the AI…", Confirm / Ask AI / Scan label / Enter·Edit, progress, error | Inset panel, same labels ("Confirm", "Confirmed", "AI estimate", "Edit", "Save macros", field label "kcal") | 🔵 `NUTRITION PER 100 G` → `Nutrition per 100 g` |
| 6 | Full edit form (all fields above), Delete + undo, Save / Add to pantry | Same | – |

---

## 3. Cook (`cook_screen.dart`)

```
  Cook                                       [✎]   ← headlineLarge; tooltip "Write a recipe"
  8
  [✦ What do you want to cook?             🎙]    ← ask field 48; mic inside (primary)
  12
 │ ☀ Today's pick                    ⇄ Swap │     ← eyebrow (primary) + S text button
 │ Garlic chicken & spinach rice bowls       │     ← headlineSmall 22/28
 │ Uses your spinach before it wilts ·       │     ← bodyMedium secondary
 │ 51 g protein                              │
 │ 16                                        │
 │ €2.62      634       51 g      30 min     │     ← Metric ×4, nums.medium
 │ per portion ● kcal   ● protein  total     │
 │ (ⓘ Missing Chicken breast)                │     ← StatusPill warning, only when not ready
 │ 16                                        │
 │ [ − 3 + ]  [ 🍲     I cooked this       ] │     ← PortionStepper + primary L (52), 12 gap
 │   max 3                                   │
  section 28
  In the fridge                                     ← section title (titleLarge, x=16)
 │ Red lentil & chickpea dal        [Eat 1] ⋯ │    ← title 2 lines max; S tonal; more_horiz
 │ 2 left · 2 d · 26 g protein               │
 │ ───────────────────────────────────────── │
 │ ⚠ Garlic chicken & spinach rice bowls      │    ← expired: leading warning 20 (serious)
 │ 2 left · past its fridge date · 51 g pr…   │       and the phrase in warningInk
  Cook again
 │ ✓  Red lentil & chickpea dal  ★         › │     ← leading status 20; favorite star 16 inline
 │    Ready · up to 8 portions               │
 │ ───────────────────────────────────────── │
 │ ✓  Lighter bacon carbonara              › │
 │    Ready · up to 4 portions               │
 │ ───────────────────────────────────────── │
 │ 🛒 Salmon traybake                       › │     ← cart 20 secondary
 │    Missing Salmon fillet                  │
```
- The card is the hero, padding 20, and the whole card taps through to the recipe.
- After cooking today, the button reads "Cooked · again?" with `check_rounded`, unchanged.
- Fridge row height: the title wraps to at most 2 lines. The trailing cluster (S button 36 +
  icon button 40) takes 88 dp, not today's 160.
- Pull to refresh stays (RefreshIndicator in `primary`).
- The ask bar keeps tap-to-send / hold-to-talk on the **mic icon inside the field** (the
  `GestureDetector` wraps the suffix `IconButton`; tooltip unchanged). Busy: prefix spinner
  16. Listening: hint "Listening…", icon `graphic_eq`.

**States**
- Loading pick: skeleton card (eyebrow real, title bar 70%, hook bar 90%, 4 metric blocks, a
  stepper + button block) with "Planning from your pantry…" in `bodySmall` secondary.
- No recipe (shopping / no key / error): the same card with the eyebrow, the message in
  `bodyMedium`, the bullet list as plain rows ("Spinach  ~€2"), and the action as a tonal M
  button ("Add key" / "Try again").
- Error: `AppNotice` critical in the card's place.
- Cook again empty: `EmptyState(menu_book_outlined, 'Your recipe rotation lives here', …)`, unchanged.

**Hierarchy**: (1) the pick title and the "I cooked this" button. (2) Its numbers (cost, kcal,
protein, time). (3) The fridge ("Eat 1"). (4) The rotation. The ask field is always available
but quiet.

| # | Datum / action today | New location | Flag |
|---|---|---|---|
| 1 | Title "Cook"; Write a recipe (tooltip) | Header | – |
| 2 | Ask field (send on submit), mic: tap = listen or send, hold = talk; busy spinner; "Listening…" | Ask field with internal mic, same tooltip and behaviors | 🟠 mic moves *inside* the field (still one tap) |
| 3 | Eyebrow "TODAY'S PICK" / "FROM YOUR RECIPES" | "Today's pick" / "From your recipes" | ⚪ casing |
| 4 | Swap (AI pick, key, not cooked today) | Eyebrow row trailing | – |
| 5 | Title, hook | Same | – |
| 6 | €/portion, kcal (dot), protein (dot), total min | Metric row | – |
| 7 | Feasibility pill "Stock for N portions" / "Missing X" | StatusPill label (warning) | – |
| 8 | Portion stepper with "max N" hint; I cooked this / Cooked · again? | Same | – |
| 9 | Card tap → recipe | Same | – |
| 10 | Pull to refresh | Same | – |
| 11 | No-recipe states: shopping list with costs, key prompt + "Add key", error + "Try again" | Same, restyled | – |
| 12 | Loading skeleton "Planning from your pantry…" | Same | – |
| 13 | Fridge: title, "N left", days "N d" / "past its fridge date", protein, leading fridge/warning icon | Same text; the leading icon only for the expired warning | ⚪ fridge icon removed (redundant with section) |
| 14 | Eat 1; menu: Still good (+2 days), Toss the rest, Undo this cook | Same (S tonal + `more_horiz_rounded` menu); "Toss the rest" in `criticalInk` | – |
| 15 | Section titles IN THE FRIDGE / COOK AGAIN | 🔵 "In the fridge" / "Cook again" (section title style, outside the group) | 🔵 ×2 |
| 16 | Cook again rows: favorite star or menu icon, title, Ready · up to N / Missing … / Short on …, trailing check or cart, tap → recipe | Leading status icon (check `good` / cart `textSecondary`), inline ★ for favorites, subtitle unchanged, trailing chevron | 🟠 status icon trailing → leading; ⚪ restaurant icon dropped |
| 17 | Cook again empty state | Same | – |

---

## 4. Recipe detail (`recipe_detail_screen.dart`)

```
  ←                                   ☆    ⋯       ← compact bar; Favorite (tooltip), menu
 │ ⇄ Ready with swaps                           │  ← AppNotice success / warning (only if feasibilityStatus)
 │ summary text                                 │
 │ You asked: "carbonara but lighter"           │     meta line
  12
  Garlic chicken & spinach rice                    ← headlineMedium 26/32, x=16
  bowls
  Uses your spinach before it wilts · 51 g protein ← bodyLarge secondary
  Spinach has 1 day left and the chicken 2; rice   ← bodySmall secondary
  keeps the portion cheap.
  16
 │ Per portion                                  │  ← SectionCard
 │ 634        51 g       82 g       11 g        │  ← nums.medium ×4
 │ ● kcal     ● protein  carbs      fat         │
 │ ──────────────────────────────────────────── │
 │ €2.62      30 min           4 d              │  ← nums.medium ×3
 │ cost       20 min active    keeps in fridge  │
  The AI estimate differed a lot; these numbers come from your pantry data.   ← bodySmall, only if flagged
  Ingredients · 3 portions                         ← section title
 │ ✓  Chicken breast                       540 g │  ← leading status 20, title, meta, nums.body
 │    have 650 g                                 │
 │ ✓  White rice                           300 g │
 │    have 1.6 kg                                │
 │ ▢  Olive oil                             21 ml │  ← staple: inventory_2_outlined secondary
 │    staple                                     │
  Left out: …                                      ← bodySmall secondary, x=32
  To buy                                           ← section title (only if list)
 │ 🛒 Salmon fillet · 2 × 125 g            ~€5   │
  Steps
 │ ① Cube the chicken and rinse the rice.       │  ← step circle 24 (fill bg, labelMedium w600),
 │ ② Simmer the rice in 600 ml salted water,    │     text 16/24, 16 between steps
 │   covered, for 15 min.                       │
  [high protein] [meal prep]                       ← tags (7.8), 16 above
 ─────────────────────────────────────────────── hairline
 [ − 3 + ]   [ 🍲        I cooked this        ]    ← bottom bar, canvas 94% + blur
   max 3
```

**Hierarchy**: (1) the title. (2) The "I cooked this" bar (always visible). (3) Per-portion
numbers. (4) Ingredients with stock status. (5) Steps.

| # | Datum / action today | New location | Flag |
|---|---|---|---|
| 1 | Favorite toggle (tooltip Favorite / Remove favorite; star) | App bar; star `onSurface` (filled when favorite) instead of yellow | ⚪ star color |
| 2 | Menu: Edit, Save to Cook again (suggested only), Delete (+ undo) | App bar `more_horiz_rounded`, same items; Delete in `criticalInk` | – |
| 3 | Verdict: Ready now / Ready with swaps / Needs shopping + summary + "You asked: …" | `AppNotice` (success / warning) | – |
| 4 | Title, hook, why | Same | – |
| 5 | Per portion: cost, kcal, protein, carbs, fat, total min (+ "N min active"), "N d keeps in fridge" | Two metric rows in one card | – |
| 6 | AI-divergence footnote | Same | – |
| 7 | Ingredients header with portions | Section title "Ingredients · N portions" (casing only, not in test list) | ⚪ |
| 8 | Ingredient rows: status icon (staple / to buy / not in pantry / short / have), name + prep note, status text + "instead of X", total qty; long-press → "I'm out of X" / "Adjust quantity" (when in pantry, not staple) | Same; long-press sheet restyled as a menu-style sheet with 2 rows | – |
| 9 | Left out list | Same | – |
| 10 | To buy list (reason icon, name · package, ~cost) | Section + group | – |
| 11 | Steps (numbered) / "No steps written." | Card with numbered steps | – |
| 12 | Tags | Tag style (not buttons) | ⚪ |
| 13 | Bottom: stepper (max hint) + I cooked this | Bottom bar | – |

---

## 5. Capture sheet ⊕ (`capture_sheet.dart`)

```
            ───
  Log something                                   ← headlineSmall (new title)
  16
 ┌────────────┐ ┌────────────┐ ┌────────────┐
 │    🧾      │ │    🖼      │ │    ▣       │      ← capture tiles 104 tall, fill bg
 │Scan receipt│ │From photos │ │  Pantry    │
 │Choose photo│ │Screenshots │ │Stocktake ph│
 └────────────┘ └────────────┘ └────────────┘
 ┌────────────┐ ┌────────────┐ ┌────────────┐
 │    💳      │ │    🍲      │ │    🍴      │
 │  Expense   │ │  I cooked  │ │   I ate    │
 │Non-food too│ │Deducts stock│ │Fridge or o…│
 └────────────┘ └────────────┘ └────────────┘
  24 + safe area
```
- Sheet padding 20, grid gap 10. The subtitle may wrap to 2 lines at large text scale (tile
  height then grows: use `mainAxisExtent` 104 at 1.0×, letting the grid size to content above
  1.15×).
- Order unchanged.

| # | Action today | New location | Flag |
|---|---|---|---|
| 1 | Scan receipt (Camera / Choose photo) | Tile 1 | – |
| 2 | From photos (Screenshots) | Tile 2 | – |
| 3 | Pantry (Stocktake photo) | Tile 3 | – |
| 4 | Expense (Non-food too) | Tile 4 | – |
| 5 | I cooked (Deducts stock) | Tile 5, text "I cooked" unchanged | – |
| 6 | I ate (Fridge or other) | Tile 6 | – |
| 7 | (no title) | Adds the title "Log something" (same as the ⊕ tooltip) | ⚪ new string |

---

## 6. Inbox + Receipt review (`inbox_screen.dart`, `review_screen.dart`, `fx_widgets.dart`)

### 6a. Inbox

```
  ←  Inbox
 │ 🔑 Add a Gemini API key                     › │  ← AppNotice info (tap → Settings), only without a key
 │    Scans wait here until the AI can read them.│
  12
 │ ✎  Aldi · €8.36                             › │  ← one AppGroup; leading 20 (primary for review)
 │    Today 03:04 · 1 to check · totals differ   │
 │ ───────────────────────────────────────────── │
 │ ✎  Migros Zürich · €24.74 (CHF 23.10)       › │
 │    Yesterday 06:04 · converted from CHF ·     │
 │    ready to file                              │
 │ ───────────────────────────────────────────── │
 │ ⊗  Could not read this scan                   │  ← failed: error_outline critical
 │    Today 02:10 · timeout                      │
 │          Discard   Retake   [Try again]       │  ← text, text, S tonal; right-aligned, 8 gap
```
- Processing row: leading spinner 20 (2.5 stroke → 2), title "Reading…".
- Queued row: `schedule_rounded`, "Receipt waiting" / "Pantry photo waiting", actions Discard + Try again.
- Empty: `EmptyState(inbox_outlined, 'All clear', 'Scans that need a look land here. Clean receipts are filed automatically.')`.

| # | Datum / action today | New location | Flag |
|---|---|---|---|
| 1 | Key card (title, subtitle, tap → settings), only without a key | `AppNotice` info + chevron, same strings | ⚪ light-blue container removed |
| 2 | Job rows: status icon, title variants (waiting / Reading… / merchant · amount (CHF …) / Could not read this scan), subtitle (day time · attention · flags · ready to file / error) | Group rows, same strings (`(CHF 23.10)` kept) | – |
| 3 | Tap needs-review → review | Row + chevron | – |
| 4 | Failed/queued actions: Discard, Retake (failed), Try again | Action row inside the row | – |
| 5 | Empty "All clear" | Same | – |

### 6b. Review (shots 12, 13)

```
  ←  Aldi
  Sun 4 Oct · 4 lines                              ← bodyMedium secondary, x=16
  12
 │ ▦ Items add up to €8.36 but the receipt says  │ ← AppNotice warning (total mismatch)
 │   €10.27. Fix an amount below or file it as is.│
    Check 1                                        ← group header
 │ ☑ 🧺 Chicken thighs                     €3.49 │ ← checkbox, category icon 16 secondary, title, amount nums.body
 │      ~600 g · new item · hard to read         │
 │   [Amount  € 3.49      ] [Quantity  600   g ] │ ← two fields, 8 gap
 │   [Groceries] [Household] [Clothes] [Eating… →│ ← choice chips, h-scroll
 │                               Mark as correct │ ← S text button, right
    3 look good
 │ ✓ Broccoli, UHT whole milk, Kitchen roll Show │ ← single row: check_circle good, title, trailing S text "Show"
 ───────────────────────────────────────────────
  Discard                  €8.36    [✓ Looks good] ← bottom bar: destructive text · nums.medium total · primary M
```
FX variant (shot 13): the conversion block is an `AppNotice` **info** (fill) with
`currency_exchange` in `primary`, the title "Receipt in CHF" (titleSmall), the line
"CHF 23.10 → €24.74" in `nums.medium` (the → renders in Inter), the meta
"1 CHF = 1.0712 EUR · European Central Bank rate, 3 Oct", and the actions
`✎ Change rate` · `Wrong currency?` (+ `Try again` without a rate). Without a rate, the notice
turns **warning**. The bottom total shows home currency (`nums.medium`) over the original
(`bodySmall` secondary).

- Each line editor is its own `AppGroup` (open lines) and stays a single group for collapsed
  lines. The merge prompt "Same as "X"?" with Yes / No, new renders inside the line as a row
  with `merge_type` 18 `warning` and two S text buttons.
- Currency-uncertain and date-adjusted banners use `AppNotice` warning with the same text and
  actions ("Change", "It's right").
- Rate sheet and currency sheet: bottom sheet 7.14. The rate sheet uses `AppSegmented` "Amount
  charged | Exchange rate" (icons dropped), a field with helper, the computed line in
  `bodyMedium` secondary, the "Use last rate" action chip, and a full-width primary L
  "Convert all lines". The currency sheet uses choice chips + an "Other (3-letter code)" field.

| # | Datum / action today | New location | Flag |
|---|---|---|---|
| 1 | Title merchant / "Pantry photo"; date · N lines | Compact bar + subtitle | – |
| 2 | Total-mismatch banner (contains "receipt says") | `AppNotice` warning, same text | – |
| 3 | Conversion card: "Receipt in CHF", foreign → home, rate + source label, Change/Set rate, Wrong currency?, Try again, busy spinner | `AppNotice` info/warning, same strings | – |
| 4 | Currency-uncertain banner + Change / It's right; date-adjusted banner | `AppNotice` warning | – |
| 5 | "Check N" lines: include checkbox, category icon, name, qty (~ inferred), new item, category, hard to read, was X (pantry), amount (+ original), merge prompt Yes / No, new, Amount + Quantity fields, category chips, Mark as correct | Same inside the line group | ⚪ header casing "Check 1" |
| 6 | "N look good" / "N items detected" collapsed summary + Show; expanded editors | Same | ⚪ casing |
| 7 | Bottom: Discard, total (+ original), Looks good / Set rate / Update pantry | Same order | – |

---

## 7. Settings (`settings_screen.dart`) + Stats, Quick check

```
  Settings
    Goals                                          ← group header
 │ Monthly food budget                      €300 │ ← value in textSecondary (nums.body w400)
 │ Weekly: €69 (÷ 4.33)                          │
 │ ───────────────────────────────────────────── │
 │ Daily calories                      2,200 kcal│
 │ Daily protein                           140 g │
 │ Meals per day                               3 │
 │ Recipes target daily ÷ meals per portion      │
 │ Target cost per portion                    €3 │
    Monthly limits · other spending
 │ Household                                 €40 │
 │ …  Other                             no limit │
    Cooking profile
 │ Diet                                          │ ← chip cell: title, 8, Wrap of toggle chips
 │ [vegetarian] [vegan] [✓ high protein] …       │
 │ ───────────────────────────────────────────── │
 │ Allergies                                     │
 │ Hard rule: recipes never include these        │
 │ [peanut ×] [+ Add]                            │ ← input chips + action chip
 │ … Dislikes, Cuisines you like, Equipment      │
 │ Max active cooking time                30 min │
 │ Default portions                            3 │
 │ More than 1 = meal prep                       │
 │ Log the first portion when I cook        (◯●) │ ← switch row
 │ The rest goes to the fridge                   │
    Rhythm
 │ Notifications                            (◯●) │
 │ Daily pick at                           07:30 │
 │ Meal reminders                                │
 │ Only when prepped portions are in the fridge  │
 │ [12:30 ×] [19:00 ×] [+ Add]                   │
 │ Sunday recap                             (◯●) │
 │ File clean receipts automatically        (◯●) │
    AI
 │ 🔑 Gemini API key                     Change › │
 │    Stored in the device keystore              │
 │    Test connection   Remove                   │ ← S text buttons (Remove in criticalInk), inside the same cell
 │ Model                                      🔒 │
 │ gemini-3.5-flash-lite (fallback: …)           │
    Appearance & region
 │ [ System | Light | Dark ]                     │ ← AppSegmented in a cell
 │ Currency (ISO code)                       EUR │
 │ Country (ISO code)                         DE │
 │ Recipe language                            en │
 │ New day starts at                        4:00 │
 │ A late snack counts toward the previous day   │
 │ Week starts on Sunday                    (◯●) │
    Data
 │ ☑ Quick check                               › │ ← leading icon 20 secondary, subtitle, chevron
 │   Verify the pantry items most likely to be wrong
 │ 📈 Stats                                    › │
 │ ⇪ Export backup                             › │
 │ ⟲ Import backup                             › │
 │ 🎓 Run onboarding again                     › │
  Trackcalfin 1.0                                  ← labelSmall textTertiary, centered, 24 above
```
- Values are `textSecondary` (not bold): titles lead, values follow.
- Group headers are no longer green. They use `titleSmall` `textSecondary`.
- Edit prompts are dialogs (7.14), unchanged behavior. The time picker is themed.
- Loading: skeleton groups (not a spinner).

| # | Datum / action today | New location | Flag |
|---|---|---|---|
| 1 | Every Goals row (5) with values and subtitles | Goals group | ⚫ "2,200 kcal" |
| 2 | Monthly limits rows (5, "no limit") | Group | – |
| 3 | Cooking profile: Diet, Allergies (+ subtitle), Dislikes, Cuisines, Equipment, Max active time, Default portions (+ subtitle), Log first portion switch | Group (chip cells + rows) | – |
| 4 | Rhythm: Notifications, Daily pick at, Meal reminders (chips + Add, max 4), Sunday recap, File clean receipts | Group | – |
| 5 | AI: API key (Add/Change, keystore text, Test connection, Remove), Model (locked) | Group | – |
| 6 | Appearance: System / Light / Dark segmented; Currency; Country; Recipe language; New day starts at; Week starts on Sunday | Group | ⚪ segment icons removed |
| 7 | Data: Quick check, Stats, Export backup, Import backup (dialog "Replace all data?" → Cancel / Choose file), Run onboarding again | Group with chevrons; the import dialog confirm uses the destructive filled style | – |
| 8 | Section titles (uppercase, green) | Sentence case, secondary (not in test list) | ⚪ |
| 9 | Footer "Trackcalfin 1.0" | Same | – |

**Stats** (shot 16): compact bar "Stats". Section titles "Median time to log · 30 days",
"AI calls · 30 days", "Recent calls" (casing only). Median rows are a group: label, "N logs",
trailing "1.8 s" (`nums.body`) + `check_circle_rounded` `good` / `warning_amber_rounded`
`warning` 18 (semantics unchanged). AI-call summaries are rows: title (prompt name) + meta.
Recent calls are expansion rows with monospace raw text 11/16 in a fill panel. Empty texts
unchanged ("No logs measured yet.", "No AI calls yet.") as `bodyMedium` secondary inside the
group. All data is kept.

**Quick check** (shot 17): compact bar "Quick check · i / n". The card is surface, radius 24,
padding 28, centered: glyph circle 64 (fill) with the category icon 32 `textSecondary`;
"Still have spinach?" `headlineMedium`; "The app thinks ~210 g" `bodyLarge` secondary;
StatusPill "Not checked in a while"; hint "Swipe right if yes, left if it's gone"
`bodySmall` secondary. Swipe backgrounds: `good` / `critical` @ 14% with icon + label in the ink
colors. Bottom row: tonal M **Gone** · tonal M **Adjust** · primary M **Yes** (equal widths,
8 gap). Done state: `verified_rounded` 48 `good`, title `headlineMedium`, detail `bodyMedium`
secondary, primary M "Done". **Fix (functional, flag to Guardian)**: the screen snapshots
`ref.read(quickCheckProvider)` on first build. Opened cold (route, or the weekly-recap
notification deep link) before `ingredientsProvider` emits, the deck is empty and it shows
"Nothing to check" while the Dashboard says "Quick check · 2" (seen in shot 17). Wait for
`ingredientsProvider.hasValue` (show a skeleton card) before snapshotting the deck.

**Recipe editor** (shot 25): compact bar "New recipe" / "Edit recipe" + text button "Save".
Fields in order: Title; a row "Default portions" (`bodyLarge`) with a `PortionStepper` right;
Prep min | Cook min | Fridge days (3 fields, 8 gap); section title "Ingredients (per portion)"
(`titleLarge`); ingredient rows [Ingredient (autocomplete, flex 5)] [Qty (flex 2)] [unit
dropdown as a compact filled field 64 wide] [remove `close_rounded` 20 icon button]; "+ Add
ingredient" text button; helper `bodySmall` secondary; Steps multiline field (min 4 lines).
Every action is kept.

---

## 8. Log sheets (shots 21–24, 26 + transaction sheet)

**Ate** (21)
```
            ───
  What did you eat?                                ← headlineSmall
  16
  Red lentil & chickpea dal                [Eat 1] ← AppRow on the sheet surface, S tonal
  2 left · 462 kcal · 26 g protein
  ─────────────────────────────────────────────
  (Nothing prepped in the fridge.)                 ← bodyMedium secondary when empty
  16
  [ ✎  Something else                          ]  ← tonal M, full width
```
Manual mode: "What was it?" (hint "Kebab, protein bar…"), then a row kcal | Protein g |
Cost (prefix currency), then a primary L full-width "Log meal". The leading fridge icon on rows
is removed (the sheet is about the fridge). ⚪

**Expense** (22)
```
  Log an expense
  16
 [ €  0.00                                   ⌨ ] ← field: nums.hero 44 value, prefix in displayMedium
                                                    secondary; suffix icon toggle (tooltips unchanged)
  €12.50 · Eating out. Press enter to save.        ← bodySmall secondary (when parsed)
  16
 ┌────────────────────┐ ┌────────────────────┐
 │ 🍴  Eating out      │ │ 🧺  Groceries       │  ← category buttons, 2 columns, 52 tall, radius 14,
 └────────────────────┘ └────────────────────┘     fill bg; the parsed one = primaryContainer
 ┌────────────────────┐ ┌────────────────────┐
 │ ⌂  Household       │ │ ⚘  Clothes          │
 └────────────────────┘ └────────────────────┘
 ┌────────────────────┐ ┌────────────────────┐
 │ ★  Entertainment   │ │ ⋯  Other            │
 └────────────────────┘ └────────────────────┘
  ≡ Add a note                                     ← text button → note field
```
Tapping a category commits (R2, unchanged). The order stays relevance-sorted. Each label is a
`Text` with the category label (the reachability test finds them). Errors ("Type an amount
first", "Tap a category to save") show as the field's error text.

**Cooked** (23): title "What did you cook?" (`headlineSmall`) with a `PortionStepper` (hint
"portions") on the right, centered on the title. Rows: leading 20 (`wb_sunny_outlined` in
`primary` for today's pick, otherwise `restaurant_menu_outlined` secondary), title, subtitle
("Today's pick" / "Last time: N portions" / "Saved"), trailing status 20 (`check_circle_rounded`
`good` "In stock" / `info_outline_rounded` `warning` "Stock short"). Tap commits (unchanged).
Empty: `EmptyState`. Draggable 0.6 → 0.92, unchanged.

**Item sheet** (24): see 2d. (Shot 24 currently doesn't open the sheet: the step taps
`find.text('Chicken breast').first`, which is the half-off-screen "Use soon" chip. The
Implementer should tap the list row instead.)

**Vibe sheet** (26): see Dashboard row 7.

**Transaction sheet**: title "Edit expense" / merchant / "Receipt"; Amount field (single) or
"Total €x" (`nums.medium`); FX meta line; "Merchant or note" field; choice chips (categories
with icons); date row (`event_outlined` 20 + date, chevron; tap → date picker); line list for
receipts (rows with icon 16, name, raw text, amount); primary L "Save" full width. All kept.

| # | Datum / action (all sheets) | New location | Flag |
|---|---|---|---|
| 1 | Ate: fridge rows (title, N left, kcal, protein) + Eat 1; empty text; Something else; manual fields + Log meal; undo | Same | ⚪ row icon removed |
| 2 | Expense: amount (text/number mode toggle, tooltips), parse hint, category chips = commit (relevance order, parsed highlight), Add a note → field, errors, undo | Category **buttons** in a 2-column grid; rest same | 🟠 chips → grid buttons (same tap = commit) |
| 3 | Cooked: portions stepper (hint "portions"), rows (icon, title, subtitle, status icon), tap = cook, empty | Same | – |
| 4 | Item sheet | see 2d | 🔵 |
| 5 | Transaction sheet fields, chips, date, lines, Save | Same | – |

---

## 9. Onboarding (`onboarding_screen.dart`)

```
  ▬▬▬▬ ▬▬▬▬ ▬▬▬▬ ▬▬▬▬ ▬▬▬▬ ▬▬▬▬                ← 6 segments, h4, gap 4, primary / track, x=16..374
  40
  [app mark 72]                                  ← welcome page only (CustomPainter, §10)
  24
  Your kitchen, on autopilot                     ← headlineLarge 30/36, left
  12
  Snap receipts, cook from what you have, and    ← bodyLarge 16/22, textSecondary
  see where the money and protein go. Every log
  takes about 3 seconds; the AI does the typing.
  32
  ✓ After I put the groceries away, I snap the   ← habit rows: check_circle_outline 20 primary,
    receipt.                                       bodyMedium onSurface, 12 between
  ✓ After I close the fridge with my lunch box,
    I tap "Ate it".
  ✓ While the coffee brews, I glance at today's
    pick.

  (flexible space)
  [               Get started                 ]  ← primary L, full width, 16 margins
  16 + safe area
```
Pages 2–6: an icon 28 in `primary` at the top-left (no container) in place of the mark, then the
title and body, then the content: goals = 3 filled fields (12 apart, label inside); staples =
toggle chips; API key = obscured field "API key (optional)"; pantry sweep = 3 rows in one
`AppGroup` (Fridge / Freezer / Cupboard with leading icons 20, chevron, tap = start scan) +
"N photos queued" `bodySmall`; rhythm = a group with "Daily pick at  07:30 ›" and "Portions I
usually cook" + `PortionStepper`.
Bottom bar for pages > 0: `[Back]` text button (left) + primary L **Next** / **Start**
expanded to the right, 12 gap.
**Everything is left-aligned.** The centered icon over left text goes away.

| # | Datum / action today | New location | Flag |
|---|---|---|---|
| 1 | Progress (6 segments) | Same, refined | – |
| 2 | Welcome icon, title "Your kitchen, on autopilot", body, 3 habits | App mark replaces the kitchen icon; same strings | ⚪ icon → brand mark |
| 3 | Goals: title "Your goals", body, budget (currency prefix), kcal, protein; saved on Next | Same | – |
| 4 | Staples: 15 filter chips (10 preselected), ensureStaples on Next | Toggle chips | – |
| 5 | API key field, saved on Next (+ fill macros) | Same | – |
| 6 | Pantry sweep: Fridge / Freezer / Cupboard → startScan, count | Group rows (were outlined buttons) | 🟠 buttons → tappable rows (same tap) |
| 7 | Rhythm: Daily pick at (time picker), Portions I usually cook (−/+), subtitle | Rows; the stepper becomes `PortionStepper` | – |
| 8 | Back / Get started / Next / Start (finish → notifications permission → /cook) | Bottom bar; same labels | – |

---

## 10. Floating nav + ⊕ (all tab roots)

| # | Today | New | Flag |
|---|---|---|---|
| 1 | 4 tabs Dashboard / Buy / Cook / Settings with labels, badge on Buy, selected capsule (mint) | Same tabs and labels; neutral indicator, accent icon and label | – |
| 2 | Re-tap the current tab → go to the branch root | Same | – |
| 3 | ⊕ (tooltip "Log something") → capture sheet | Same, 60 dp | – |
| 4 | iOS 26 native Liquid Glass bar | Untouched (its tint follows `scheme.primary`, now `#1D6A4A` / `#74C99E`) | – |

---

## Summary of flags for the Guardian

**🔵 Test-copy changes (casing only, behavior unchanged)**

| Old finder | New text | Where |
|---|---|---|
| `TODAY` | `Today` | Dashboard card title (also a ledger day label exists in the Buy tab, offstage) |
| `FOOD SPEND` | `Food spend` | Dashboard |
| `OTHER SPEND · MONTH` | `Other spend` (+ separate trailing `This month`) | Dashboard |
| `CALORIES THIS WEEK` | `Calories this week` | Dashboard |
| `USE SOON` | `Use soon` | Pantry |
| `IN THE FRIDGE` | `In the fridge` | Cook (twice in the smoke test) |
| `COOK AGAIN` | `Cook again` | Cook |
| `NUTRITION PER 100 G` | `Nutrition per 100 g` | Item sheet |

Every other test-copy string is unchanged: `Vibe ·`, `Spinach`, `Ledger`, `Lidl`, the recipe
title, `I cooked this`, `in the fridge` (snackbar), `Aldi`, `Looks good`, `receipt says`,
`(CHF 23.10)`, `Migros`, `Receipt in CHF`, `European Central Bank rate`, `Cook`,
`Log something`, `I cooked`, `1 item has no macros`, `Fill with AI`,
`Add a Gemini API key in Settings first.`, `Cumin`, `Review macros ·`, `AI estimate`,
`Confirm`, `Confirmed`, `Edit`, field `kcal`, `Save macros`, `Monthly food budget`,
`Your kitchen, on autopilot`, `Get started`, `Your goals`.

**🟠 Moved actions**
1. Buy: Scan receipt, Pantry photo, Log expense and Add pantry item go into the header
   **Add** menu (tooltip "Add"). They're one extra tap, and the first three are also in ⊕.
2. Cook: the mic button moves inside the ask field (same tooltip, same tap and hold behavior).
3. Cook again: the readiness icon moves from trailing to leading. Rows gain a chevron.
4. Pantry: the category icon moves from every row to the category header.
5. Expense sheet: category chips become a 2-column grid of buttons (tap still commits).
6. Onboarding sweep: outlined buttons become tappable group rows.

**⚫ Format**: integers ≥ 1,000 are grouped ("2,200"): Dashboard kcal target, Settings
daily calories.

**Functional bug found during the audit (not a design change)**: Quick check opened cold
shows an empty deck (see §7).

**Screenshot pipeline**: 08-cook-scrolled doesn't scroll (`find.byType(Scrollable).first` is
the ask field's own Scrollable; use the largest vertical Scrollable). 24-ingredient-sheet taps
the off-screen use-soon chip (tap the row, e.g. `find.text('Chicken breast').last`, or scroll).
