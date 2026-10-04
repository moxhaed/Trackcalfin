# Behavioral baseline (pre-redesign)

Owner: Integrity Guardian. This is the contract a visual redesign must preserve. Every number,
write, route, sheet, input and action below must behave the same after the redesign; only how it
looks may change. Line numbers refer to commit `d004e5b` (its `lib/` equals `220cb9c`).

**Baseline run.** `flutter analyze`: no issues. `flutter test`: 136 tests green before this work.
After the guard tests: 164 pass and 1 is skipped (a known bug, §10.1), about 2.5 min on 4 cores.

**Security model.** The app has no authentication or user accounts. Its only secret is the Gemini
API key, kept in `SecureSecretStore` (Android Keystore or iOS Keychain; desktop dev builds fall back to
`<appSupport>/.gemini_key`), `lib/platform/secret_store.dart:24-64`. The key never goes into Isar,
backups or logs. Data is local (Isar) except the calls in §6.

## 1. Calculations and where they are shown

The rule is that the LLM proposes and Dart computes. Every number in the UI comes from `lib/domain` or
`lib/core` or, where noted ⚠, from arithmetic inside `lib/features`. The redesign may change how a
value is formatted, but never what it is.

| Quantity | Formula | Code | Shown in |
|---|---|---|---|
| WAC (avg cost / base unit) | price unknown (≤0) → qty only; empty stock → unit cost; else (q₀·c₀ + q·u)/(q₀+q) | `domain/costing.dart:10-32` | Pantry row value (⚠ `qty×avgCost`, `pantry_view.dart:214`), item sheet "Avg cost per kg/l/piece" (⚠ ×1000 for g/ml, `ingredient_sheet.dart:335-337`) |
| Expiry | purchase: keep sooner lot (two-lot FIFO); deplete to ≤ last lot → lastPurchase+shelfLife; 0 → null | `costing.dart:43-58` | — |
| Days left / use soon | `daysBetween(now, expiresAt)` clamped ≥0; shelf-stable (staple or ≥180 d) → null; use soon ≤ 3 d | `costing.dart:60-73` | Pantry "Use soon" chips, row "N days left", `daysLeftLabel` (`features/common/format.dart:21`) |
| Low stock | `!staple && qty>0 && threshold>0 && qty ≤ threshold` | `data/isar/collections/ingredient.dart:78` | Pantry "Running low" |
| Unit conversion | g/ml/pc via gramsPerPiece and density; `format` 1000 g → "1 kg", one decimal below 10 | `domain/units.dart:18-37, 73-87` | every quantity (`qty()` in `format.dart:6`) |
| Recipe nutrition and cost per portion | Σ over stock and staple rows of per100 × grams/100; cost Σ qty×WAC; missing rows add their estimates | `domain/nutrition.dart:39-68`; stored by `RecipeService.refreshNumbers` (`application/recipe_service.dart:16-29`) | Pick card, Recipe detail "Per portion", Cook-again ordering |
| Label → per-100 | energy from kJ/4.184, carbs minus fiber, flags `too_dense` / `energy_mismatch` (Atwater ±15 kcal or 20 %) | `nutrition.dart:76-120` | Item sheet macro editor flags |
| Feasibility | per stock row `floor(have/perPortion)` → maxPortionsNow (99 = unbounded); missing → 0; readiness = mean min(have/need, 1) | `domain/feasibility.dart:49-90` | Pick pill "Stock for N / Missing X", stepper hint "max N", Recipe detail verdict and rows, Cook again "Ready · up to N" / "Missing …", Cooked sheet ✓/ⓘ |
| Depletion | plan snapshots cost and nutrition **before** deducting; deducts min(requested, on hand); shortfall clears `lastVerifiedAt`; revert restores exactly | `domain/depletion.dart:35-107` | cook snackbar, "Some stock ran out" snackbar |
| Dashboard week/month food | Σ groceries lines in [weekStart/monthStart, now] | `domain/dashboard.dart:167-168` | Food spend "€x / €y" |
| Weekly budget | `round(monthly / 4.33)` | `dashboard.dart:178`; Settings subtitle ⚠ `settings_screen.dart:52` | Food spend, Settings "Weekly: … (÷ 4.33)" |
| Pace | `spent / (budget × max(elapsedFraction, 0.2))`; color good ≤1, warning ≤1.15, serious ≤1.3, else critical | `dashboard.dart:149-152`; `app/theme.dart:49-55` | pill "on pace" / ⚠ "`round((pace−1)×100)`% ahead" (`dashboard_screen.dart:286`), PaceBar marker = elapsed fraction |
| ×4.33 projection | trailing n days (7..28, by data age) food → weekly = Σ/n×7; projected = weekly × 4.33; null while < 7 days of data | `dashboard.dart:169-176, 253` | "Projected month: … (trailing week × 4.33)" or "Projection after 7 days of data" |
| Other spend | per non-food category: month spent, profile limit, pace | `dashboard.dart:181-190` | Other spend rows (whole currency units), ⚠ icon when pace > 1.15 |
| Eaten / per meal / saved | eaten = Σ log.foodCostMinor this week; per meal = home cost / home portions (non-quickAdd); saved = portions × eating-out average (90-day mean of ≥3 tx, else profile 15.00) − home cost | `dashboard.dart:219-231, 258`; average in `app/providers.dart:199-213` | Food spend metrics row |
| Today intake | today's `DailyLog.totals`; ring % = ⚠ `round(v/target×100)` | `dashboard.dart:232, 260`; `dashboard_screen.dart:216` | Today card |
| Week average | mean over completed past days this week, else last week ("Last week" label) | `dashboard.dart:197-217` | Calories this week header, coverage "n of m days logged" |
| Vibe score | components 0-100: food = paceScore(monthPace) (not while collecting), nonfood (aggregate pace), protein = avg/target, kcal = 100−clamp((|d|−5 %)×400), logging = coverage. Weighted 30/15/20/15/20 over present parts, rounded. Labels ≥85 Locked in, ≥70 On track, ≥50 Drifting, else Reset mode. One insight from the lowest part | `domain/vibe.dart:20-124`; pick title and protein come from `todayPickProvider` (`providers.dart:216, 234`) | Vibe card (ring, label, insight), explanation sheet (each part, rounded) |
| Streak | consecutive logged days (meal or transaction), one freeze per calendar week that bridges a single gap | `domain/streak.dart:16-42`; input set in `providers.dart:217-227` | "N-day streak" (shown when ≥2), freeze tooltip |
| FX | `Currency.convert` = round(major × rate × 10^digits); line conversion puts rounding drift on the largest line; implied rate = home/foreign; plausible 1e-5 < r < 1e5 | `core/currency.dart:38-55`; `domain/fx.dart:25-46` | Inbox card "€x (CHF y)", Review conversion card and per-line home amounts, rate sheet preview (⚠ `fx_widgets.dart:152-160`) |
| Receipt totals | adjustments spread proportionally, cent-exact; primary category = largest category sum; mismatch flag when |Σ−total| > max(1 %, 2 minor) | `domain/receipt_math.dart:10-38`; `validation/receipt_validator.dart:111-122` | Review banner "Items add up to … but the receipt says …"; ⚠ Review bottom total = Σ included lines (`review_screen.dart:150, 258-262`) |
| Money formatting | `format` (symbol, letter codes get a space, `whole`, `signed`); `compact` = whole units from 20 up or when there are no cents; `parse` reads the first `\d+([.,]\d{1,2})?`; `toInput` | `core/money.dart:22-49`; currency and digits from the profile (`application/profile_service.dart:53`) | every amount |
| Day keys | logical day starts at `dayRolloverHour` (default 4); week start from the profile; DST-safe day arithmetic | `core/day_clock.dart` | all "today/week/month" values |
| Quick check deck | exact, in stock and (never verified or older than 7 d perishable / 21 d other, or expired); unverified first, then by value; at most 10 | `domain/quick_check.dart:12-29` | Dashboard "Quick check · N", Quick check screen |
| Quick text | first amount → minor units; learned keyword, then built-in keyword → category; remaining text = note | `domain/quick_text_parser.dart:62-94`; learning `:97-107` | Expense sheet preview "€x · Category. Press enter to save." |
| Daily fallback | ready saved recipes not cooked in 3 d, score 0.5·expiry use + 0.3·protein fit + 0.2·cost fit | `domain/daily_fallback.dart:21-53` | Pick card "FROM YOUR RECIPES" |
| Recipe verdict | not ready, or max < default portions → missing_items; substitutes or omitted → ready_with_swaps; else ready | `validation/recipe_validator.dart:227-232`; ⚠ re-derived live in `recipe_detail_screen.dart:217-224` | Recipe detail verdict banner |
| Stats | median time-to-log per action (30 d); AI calls per task (failed, repaired, median latency, tokens) | `application/metrics_service.dart:23-31`; ⚠ `stats_screen.dart:156-162` | Stats screen |

## 2. Business rules (must hold after the redesign)

1. **One use case = one Isar write transaction** (CLAUDE.md, schema invariant 7). Every service write
   below is a single `writeTxn`. The UI never writes to Isar directly. The exceptions are reads:
   `review_screen.dart:38,50,68`, `recipe_editor_screen.dart:46-79` and `cook_actions.dart:61` read Isar.
2. **Cooking deducts stock and creates a `CookSession`** (`application/cook_service.dart:35-95`).
   It also logs the first portion when `autoLogFirstPortion` is on (default), sets portionsRemaining =
   N − 1, and promotes a suggested or dismissed recipe to saved. Undo (`:98-122`) puts the stock back
   exactly, removes the session's meals, sets status `undone` and decrements `timesCooked`.
3. **Intake is logged when a portion is eaten** (`eatPortion` `:125-154`, `quickAddMeal` `:210-238`,
   the notification "Ate it" → `eatOldest` `:160`). The `DailyLog` totals are recomputed on every write.
4. **Undo instead of confirm** (R1). Hot paths commit on the last tap and show `showUndo`/`showUndoOn`
   (`features/common/widgets.dart:447-469`, 5 s, action "Undo"). These are: expense chip, eat, cook,
   manual meal, pantry swipe-out, ledger swipe-delete, item delete, recipe delete. The only
   confirmation dialog is Import backup (`settings_screen.dart:272-283`), which is destructive and intended.
5. **The last tap commits** (R2): the expense category chip *is* the save (`expense_sheet.dart:150-156`);
   a recipe tap in the Cooked sheet cooks; "Eat 1" eats.
6. **Receipts file themselves or go to the Inbox** (R5): they auto-commit only when `autoCommitEligible`
   (`receipt_validator.dart:26-34`: receipt kind; no total_mismatch, foreign_currency,
   currency_uncertain, merge_proposed or date_adjusted flag; no low-confidence line; no stock line with
   unknown qty) and the profile switch "File clean receipts automatically" is on (`scan_service.dart:176-180`).
   Everything else is `needsReview`. A foreign receipt cannot commit without a plausible rate
   (`MissingExchangeRate`, `scan_service.dart:274-276`; the UI opens the rate sheet instead,
   `review_screen.dart:56, 64-67`).
7. **Allergen rejection**: a recipe ingredient whose key or name hits a profile allergy is a *hard*
   error, and the AI runner gets one repair retry (`recipe_validator.dart:56-63`,
   `validation/allergens.dart:191`). The daily pick may not use missing items (`allowMissing: false`).
8. **Staples are never deducted** (`depletion.dart:42`) and are skipped in feasibility (`feasibility.dart:56, 71`).
9. **Swap**: at most 2 a day. A failed swap puts the old pick back (`daily_pick_service.dart:42, 170-190`).
   Swap shows only if the pick came from the AI, a key is set, and it hasn't been cooked today
   (`cook_screen.dart:138`).
10. **AI is asynchronous** (R4). A scan only enqueues; processing happens in the background
    (`scan_flow.dart:15-48`) on resume or reconnect (`app/integrations.dart:41-57`) and when a key is
    saved. **Opening a screen must never call Gemini** (guarded by a test).
11. **Settings clamps**: meals per day 1-8, default portions 1-12, day rollover 0-8
    (`settings_screen.dart:71, 134, 206`). A money tile left empty means 0 = "no limit"; a limit of 0
    removes the category entry (`:89-97`). Every settings write re-plans notifications (`:38-41, 608-612`).
12. **Macro sources**: typed macros are `user`; label numbers saved unchanged are `label`
    (`ingredient_sheet.dart:158-171`). A new item with blank macros stays `none` (the AI fills it).
    Switching an item to or from ml resets its macros to `none` (`:209-214`).

## 3. Navigation map (`lib/app/router.dart`)

| Route | Navigator | Screen | Reached from |
|---|---|---|---|
| `/` | shell branch 0 | DashboardScreen | tab, initial |
| `/buy` (`?tab=ledger` → Ledger) | shell branch 1 | BuyScreen | tab; `router.go('/buy')` from the scan shortcut and the share intent |
| `/cook` | shell branch 2 | CookScreen | tab; onboarding finish `context.go('/cook')`; notification payload (daily pick, meal) |
| `/settings` | shell branch 3 | SettingsScreen | tab; `context.go('/settings')` from Inbox "Add a Gemini API key" and Pick "Add key" |
| `/inbox` | root | InboxScreen | Buy inbox icon and "Inbox" text button; notification payload (scan result) |
| `/inbox/:id` | root | ReviewScreen | tap a `needsReview` job card |
| `/recipe/new` | root | RecipeEditorScreen | Cook "Write a recipe" |
| `/recipe/:id` | root | RecipeDetailScreen | pick card, Cook again row, Ask result (`context.push`), editor save (`pushReplacement`) |
| `/recipe/:id/edit` | root | RecipeEditorScreen(id) | Recipe menu "Edit"; save → `context.pop()` |
| `/quick-check` | root | QuickCheckScreen | Dashboard chip, Settings tile, weekly-recap notification payload |
| `/stats` | root | StatsScreen | Settings tile |
| `/onboarding` | root | OnboardingScreen | initial when `!onboardingDone`; Settings "Run onboarding again" |

* **Tabs** (`app/shell.dart:25`): `shell.goBranch(i, initialLocation: i == current)`, so re-tapping the
  current tab resets that branch. The Buy tab shows an inbox badge = jobs in needsReview or failed
  (`providers.dart:133-136`). The ⊕ button opens the capture sheet (`showCaptureSheet`).
* **Back**: root routes get an AppBar back button; system back pops. A recipe delete pops with
  `GoRouter.pop`. Review commit/discard and every sheet use `Navigator.pop`. Quick check "Done" pops.
* **Sheets** (all `useRootNavigator: true`): capture, expense, ate, cooked, ingredient (also chained
  by `reviewMacros`), transaction, rate, currency, vibe explanation, row long-press (I'm out /
  Adjust). **Dialogs**: Settings `_prompt` (numbers, money, text, tags, API key), Import confirm,
  date picker (transaction), time pickers (settings, onboarding). Popup menus: fridge row, recipe AppBar.
* **Deep links**: notification payloads `'/cook'`, `'/inbox'`, `'/quick-check'`
  (`platform/notifications.dart:142, 166, 178, 189`). These are pushed by `main.dart:39-47`, or are
  the initial location at launch (`main.dart:49-50`). Action `'ate'` → `CookService.eatOldest` (in
  the foreground or a background isolate, `notifications.dart:18-24`). Quick actions `scan` / `expense`
  / `cooked` (`integrations.dart:78-103`). The share intent queues images as receipts and goes to `/buy`
  (`:105-130`). On resume (`:56-72`) the app processes scans, fills missing macros, runs housekeeping
  (once every 20 h) and schedules notifications. On pause it plans tomorrow after 19:00.
* **iOS 26 glass nav** (`app/floating_nav.dart:252-337`): platform view `trackcalfin/glass-nav`. Its
  creation params are `tabs[{label,symbol,activeSymbol}]`, `captureLabel`, `index`, `badges`, `dark`,
  `tint`, `onTint`. Flutter → native: `update`. Native → Flutter: `select(int)` and `capture`. While a
  popup is open (`PopupObserver`, `:26-46`), a Flutter pill covers the native view.

## 4. State transitions

* **ScanJob** (`application/scan_service.dart`): `queued` → `processing` (attempts+1) →
  `needsReview` | `failed` (non-transient error, or ≥3 attempts) | back to `queued` (no key, or a
  transient error with < 3 attempts). `needsReview` → `committed` (exactly once, with transactionId)
  | `discarded`. `failed` / `queued` → Retry (`queued`, attempts 0) | Discard. Jobs stuck in
  `processing` go back to `queued`.
* **Recipe** (`RecipeStatus`): `suggested` (daily or ask) → `saved` (cook, favorite, "Save to Cook
  again", edit-save) | `dismissed` (swap, or replaced by a new pick) → back to `suggested` when a swap
  fails. Housekeeping deletes uncooked, unfavorited suggested or dismissed recipes older than 30 days.
* **CookSession**: `active` → `finished` (portions reach 0 by eating, or cooked with N = 1) |
  `discarded` (toss the rest) | `undone` (undo cook). Deleting a fridge meal returns a portion and
  re-activates the session.
* **Profile and onboarding**: `onboardingDone=false` → initial `/onboarding`. Pages: welcome → goals
  (saved on Next) → staples (`ensureStaples` on Next) → API key (saved if typed) → pantry sweep
  (`startScan` hint pantry) → rhythm → Start (portions, pick time, done=true, request notification
  permission, refresh pick, go `/cook`). `schemaVersion` migrations run at startup.
* **Today's pick** (`providers.dart:152-172`, `daily_pick_service.dart:58-79`): keep the existing
  pick if it was cooked today or is still feasible. Otherwise: no key → offline fallback (marked
  isFallback) → AI → insufficient stock (shopping list) | error → fallback.

## 5. Persistence: collections written per use case

| Use case | Collections written | Called from (UI) |
|---|---|---|
| `LedgerService.logQuickExpense` | Transaction (+UserProfile learned keyword) | Expense sheet chip or enter |
| `.applyManualPurchase` | Ingredient (WAC), Transaction | Item sheet "Add to pantry" with a price |
| `.delete` / `.restore` | Transaction, Ingredient (stock it added) | Ledger swipe, expense Undo |
| `.update` | Transaction | Transaction sheet Save |
| `PantryService.upsert` | Ingredient (+Recipe numbers via `refreshUsing`) | Item sheet Save / Add |
| `.setQuantity` / `.markOut` / `.verify` | Ingredient | stepper, I'm out, Looks right, swipe, Quick check, row long-press |
| `.delete` / `.restore` / `.ensureStaples` | Ingredient | Item sheet Delete + Undo; onboarding |
| `CookService.cook` / `.undoCook` | Ingredient, CookSession, DailyLog, Recipe | I cooked this, Cooked sheet, Undo, fridge menu "Undo this cook" |
| `.eatPortion` / `.deleteMeal` / `.quickAddMeal` | CookSession, DailyLog | Eat 1 (fridge, Ate sheet), Undo, Ate manual |
| `.discardPortions` / `.extendFridge` | CookSession | fridge menu |
| `RecipeService.save` / `.setFavorite` / `.setStatus` / `.delete` / `.restore` | Recipe | editor, star, menu |
| `ScanService.enqueue` / `.process` / `.updateJob` / `.applyRate` / `.refreshRate` / `.retry` / `.discard` | ScanJob (+AiCallLog, +UserProfile fx memo) | capture, review, inbox |
| `ScanService.commit` | Transaction, Ingredient (WAC, aliases), ScanJob | Review "Looks good" / "Update pantry", auto-commit |
| `NutritionService.fillMissing` / `.setNutrition` / `.confirm` (`readLabel` writes nothing) | Ingredient, Recipe (+AiCallLog) | Fill with AI, Ask AI, Save macros, Confirm |
| `DailyPickService.ensure` / `.swap` / `.generate`; `AskService.ask` | Recipe (+AiCallLog) | Cook tab, Swap, ask bar |
| `ProfileService.update` | UserProfile | Settings, onboarding |
| `MetricsService.record` | MetricEvent | expense, scan, cook, eat, ask, quick_check |
| `BackupService.importJson` | everything (clear + import) | Settings Import |
| `Housekeeping.run`, `Migrations.run` | Recipe, AiCallLog, ScanJob, CookSession / Ingredient, UserProfile | resume / startup |

## 6. External APIs

| API | Client | Triggered by |
|---|---|---|
| Gemini `generateContent` (`https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent`, header `x-goog-api-key`; primary `gemini-3.5-flash-lite`, fallback `gemini-3.8-flash`, backoff 2 s/8 s; schema, thinking and media fields are simplified if the API rejects them) | `data/ai/gemini_client.dart:138, 206`; `AiRunner.run` (one repair retry, writes AiCallLog) `ai_runner.dart:40-93`; `AiGateway` (null without a key) | scan queue (receipt, prompt A); daily pick, ensure/swap (B); ask (C); fillMissing (D: Fill with AI, Ask AI, after commit/scan/key save/onboarding/item save); readLabel (E: Scan label); Settings "Test connection" |
| Frankfurter ECB rates (`https://api.frankfurter.dev/v1/{date|latest}?base=&symbols=`, 8 s timeout) | `data/fx/fx_rate_client.dart:26`; `FxService.quote` remembers the rate | scan processing of foreign receipts; Review "Try again" / currency change |
| Platform: camera and photos (`image_picker`), speech-to-text, local notifications, workmanager, secure storage, share_plus, file_picker, quick actions, share intent, connectivity | `lib/platform/*`, `integrations.dart`, Settings export/import | scan buttons, mic, notifications, backup |

## 7. Inputs and validation

| Screen or sheet | Field / control | Parsing and validation |
|---|---|---|
| Expense sheet | amount (number or text mode) | `QuickTextParser.parse` with the profile money format; null → "Type an amount first"; no category → "Tap a category to save"; enter = save with the parsed category |
| | note (optional) | joined with the parsed note by " · " |
| | category chips | ordered by recency of manual transactions; +3 to Eating out at 11-14 h and 18-22 h (⚠ `expense_sheet.dart:43-58`) |
| Ate sheet (manual) | title (default "Meal"), kcal (**required**: no number = no save), protein (default 0), cost (`money.parse`, default 0) | `double.tryParse` with ',' → '.' |
| Item sheet | name (required), qty, unit (g/ml/pc), price (new item only), grams per piece (pc, default 50), category, shelf days (default 7), low threshold, staple switch, macros ×5 | numbers via `double.tryParse(','→'.')`; price via `money.parse`; empty macros on a new item = unknown |
| | stepper −/+ | step pc 1, g/ml 50 (100 when ≥1000); clamp 0..100000; − disabled at 0 |
| Transaction sheet | amount (single-line tx only), merchant/note, category, date (2020-01-01 .. tomorrow) | `money.parse` |
| Review line | include checkbox, amount (receipt currency; a leading '−' makes it negative), qty, category chip (non-groceries clears `ingredientKey`), merge Yes/No, Mark as correct | ⚠ all in `review_screen.dart:379-546` |
| Rate sheet | amount charged (`money.parse` > 0 → implied rate) or rate (`double.tryParse`, plausible) | "Convert all lines" disabled until valid; "Use last rate" chip |
| Currency sheet | chip, or a 3-letter code (`^[A-Z]{3}$` on submit) | |
| Cook ask bar | text (empty = nothing, or mic when the field is empty) | `AskService.ask`; errors via snackbar |
| Recipe editor | title (required), default portions ≥1, prep/cook/fridge (int; defaults 0/0/3), rows (autocomplete from pantry; qty > 0 or the row is dropped; no pantry match → role missing), steps (one per line) | `_save` ⚠ `recipe_editor_screen.dart:89-126` |
| Settings prompts | number (`double.tryParse`), money (empty = 0, invalid keeps the old value), text (trim; upper case for currency and country, lower case for language), tags (trim, lower case, no duplicates), API key (empty = remove) | `settings_screen.dart:316-422, 551-604` |
| Onboarding | budget (`money.parse`), kcal and protein (`double.tryParse`); invalid input keeps the default | `onboarding_screen.dart:82-89` |

## 8. UI contract per screen (what each shows, and what each action calls)

Notation: *datum* → source; **action** → handler. (S) = sheet, (D) = dialog, (R) = route.

**Shell** (`shell.dart`, `floating_nav.dart`): four tabs Dashboard / Buy / Cook / Settings (labels,
selected state, Buy badge = `inboxCountProvider`). **Tab tap** → `goBranch`. **⊕ (tooltip "Log
something")** → capture (S). Bodies use `extendBody`, so every tab list pads its bottom by
`MediaQuery.paddingOf(context).bottom`.

**Capture (S)** `capture_sheet.dart`: **Scan receipt** → `startScan(hint: receipt)` (camera or
picker). **From photos** → `startScan(camera: false)`. **Pantry** → `startScan(hint: pantry)`.
**Expense** → expense (S). **I cooked** → cooked (S). **I ate** → ate (S). Each closes the sheet first.

**Dashboard** (`dashboard_screen.dart`): app bar date; **Quick check · N** chip (only when N > 0) →
`/quick-check`. Vibe card: score ring, label, insight; **tap** (when it has parts) → explanation (S)
with each part's name, rounded value and bar. Today: kcal and protein rings (%), eaten / target,
"Nothing logged yet today"; **Meal** → ate (S). Food spend: week and month spent/budget, pace pill,
PaceBar + elapsed marker, projection line, eaten this week / per home meal / saved vs eating out.
Other spend: per category spent/limit (whole units), bar, ⚠ icon "Over pace". Calories this week:
average label, coverage, streak with tooltip, 7 bars with a target line (**tap a bar** shows its
kcal), legend. No pull-to-refresh: the provider refreshes on DB changes and every 10 min.

**Buy** (`buy_screen.dart`): **Inbox** icon with badge → `/inbox`. **Scan receipt** →
`startScan(receipt)`. **Pantry photo** → `startScan(pantry)`. **Log expense** → expense (S). **Add
pantry item** → item (S, new). "Reading N scans… / Inbox" row while jobs are queued or processing.
**Pantry/Ledger** segmented switch (initial `?tab=ledger`).

**Pantry** (`pantry_view.dart`): empty state with **Add an item**. **Search** field (name or key
contains, case-insensitive; hides the banner, use soon, low and review link). Banner "N items have no
macros" (**Fill with AI** → `fillMissing` → snackbar with the result or error; **tile tap** →
`reviewMacros`). **Use soon** chips (name, qty · days) → item (S). **Running low** chips → item (S).
Category groups of in-stock items: row icon, name, subtitle [value · days left · "check" if never
verified · "no macros"], qty; **tap** → item (S); **swipe end-to-start** (in-stock only) →
`confirmDismiss`: `markOut`, haptic, Undo → `setQuantity(before)`, **returns false** (the row is
rebuilt from the stream; key `ing-{id}-{qty}`). **Out of stock (N)** expander. **Staples · always
assumed** chips → item (S). **Review macros · N unconfirmed** → `reviewMacros`.

**Item (S)** `ingredient_sheet.dart`: title, "Check macros · i of n" plus **Skip** in review mode;
**Edit details / Done editing** toggle. Stock block (existing, non-staple, not in review): **−/+**
→ `setQuantity`; qty "on hand"; **I'm out** → `markOut` + close; **Looks right** → `verify` + close;
"Avg cost …". Nutrition card: source pill (Unknown / AI estimate / Confirmed / From label), macros;
**Confirm** → `confirm` (+ next); **Ask AI** → `fillMissing`; **Scan label** → camera →
`readLabel` → editor with flags; **Edit/Enter** → editor; **Save macros** → `setNutrition`;
**Cancel**. Edit form (§7) with **Delete** (→ `delete`, Undo → `restore`) and **Save / Add to
pantry** → `upsert` (+`applyManualPurchase` or `setQuantity`) and then `fillMissing` if the macros
are unknown.

**Ledger** (`ledger_view.dart`): filter chips **All** + 6 categories (re-tap clears the filter;
amounts become the matching lines only). Day groups: label (Today / Yesterday / weekday / date) and
day total. Rows: icon, title (merchant, else note, else single line name, else category), subtitle
[time · N items · N stocked · original-currency amount · "scanned"], amount; **tap** → transaction
(S); **swipe** → `onDismissed`: `delete`, Undo → `restore` (detail "Its N pantry items were taken
back out").

**Transaction (S)**: amount (single line) or "Total", "Paid … · 1 X = r Y", merchant/note, category
chips, **date** picker, line list, **Save** → `LedgerService.update`.

**Inbox** (`inbox_screen.dart`): empty "All clear"; no-key card → `/settings`. Job cards: status
icon, title (status-based; needsReview: merchant · amount, or "Pantry photo · N items"), subtitle
(date time · N to check · totals differ · converted from X / needs an exchange rate · check the
currency · possible duplicates · ready to file). **Tap** (needsReview) → `/inbox/{id}`.
failed/queued: **Discard**, **Retake** (failed: discard + `startScan`), **Try again** → `retry` +
`processScansInBackground`.

**Review** (`review_screen.dart`): title merchant / "Pantry photo"; "date · N lines". Banners:
total mismatch (sum vs receipt), conversion card (**Set/Change rate** → rate (S) → `applyRate`;
**Wrong currency?** → currency (S) → flags + `refreshRate`; **Try again** → `refreshRate`),
currency uncertain (**Change**, **It's right**), date adjusted. "Check N" editors, "N look good"
(collapsed, **Show**). Line editor per §7. Bottom: **Discard** → `discard` + pop; total (home and
original); **Looks good / Update pantry / Set rate** → `_commit` (persist → `commit` → `fillMissing`
→ pop → `notifyApp`).

**Cook** (`cook_screen.dart`): **Write a recipe** → `/recipe/new`. Ask bar: one TextField (enter =
send), button tooltip **"Hold to talk, or tap to send"** (empty field: tap = listen; text: tap =
send; long-press start/end = listen/stop) → `AskService.ask` → push the recipe, or snackbar.
**Pull to refresh** → `todayPickProvider.refresh()`. Pick card: "TODAY'S PICK" / "FROM YOUR
RECIPES", **Swap** (conditions in §2.9) → `swap` (+ error snackbar), title, hook, cost per portion,
kcal, protein, total time, feasibility pill, **PortionStepper** (tooltips "Fewer/More portions",
1..12, default last cooked or recipe default, hint "max N"), **I cooked this / Cooked · again?** →
`cookNow`, **card tap** → `/recipe/{id}`. No pick: shopping list or messages; **Add key** →
`/settings` or **Try again** → `refresh(force)`. Skeleton while loading. Fridge: rows (title, "N
left · d / past its fridge date · protein"), **Eat 1** → `eatFromFridge`; **menu** (PopupMenuButton
values `extend`/`toss`/`undo`) → `extendFridge(+2)` / `discardPortions` + snackbar / `undoCook`.
Cook again: rows (★ favorite, title, Ready · up to N / Missing … / Short on …, ✓ or cart semantic
labels "Ready"/"Needs shopping"), sorted ready, then favorite, then readiness; **tap** → `/recipe/{id}`.

**Recipe detail** (`recipe_detail_screen.dart`): **Favorite / Remove favorite** → `setFavorite`.
**Menu** `edit` → `/recipe/{id}/edit`, `save` (suggested only) → `setStatus(saved)` + snackbar,
`delete` → `delete`, pop, Undo → `restore`. Verdict (asked recipes): Ready now / Ready with swaps /
Needs shopping, summary, "You asked: …". Title, hook, why. Per portion: cost, kcal, protein, carbs,
fat, time (active), keeps in fridge; divergence note. Ingredients · N portions: rows (icon, name +
prep note, status staple / to buy / not in pantry / have X, "instead of …", total = per portion × N);
**long-press** (in-pantry, non-staple) → (S) **I'm out of X** → `markOut` (+ force refresh of the
pick if it uses X) / **Adjust quantity** → item (S). Left out, To buy, Steps, tags. Bottom:
stepper + **I cooked this** → `cookNow`.

**Recipe editor**: **Save** (app bar) → `save` → `pushReplacement` (new) or `pop`. Fields per §7;
**Add ingredient**, row ✕ (remove), unit dropdown, portions −/+.

**Expense (S)**, **Ate (S)** (fridge rows **Eat 1** → close + `eatFromFridge`; **Something else** →
manual; **Log meal** → `quickAddMeal`, Undo → `deleteMeal`, metric `eat`), **Cooked (S)**
(DraggableScrollableSheet; stepper (profile default portions); list = the pick, favorites, cooked or
saved recipes (not archived or dismissed), pick first, then by last cooked; ✓/ⓘ semantic labels "In
stock"/"Stock short"; **tap** → close + `cookNow`).

**Settings** (`settings_screen.dart`): sections Goals (budget with weekly ÷4.33, kcal, protein,
meals/day, target cost per portion), Monthly limits (5 categories), Cooking profile (diet chips,
allergies, dislikes and cuisine tags with **Add**/✕, equipment chips, max active minutes, default
portions, auto-log first portion), Rhythm (notifications, daily pick time, meal reminders ≤4 with
**Add**/✕, Sunday recap, auto-file receipts), AI (API key tile → prompt → `writeApiKey` + invalidate
+ process queue, fill macros, refresh pick; **Test connection**; **Remove**; model shown, locked),
Appearance and region (theme System/Light/Dark, currency, country, language, day rollover, week
starts Sunday), Data (**Quick check**, **Stats**, **Export backup** → share or save JSON, **Import
backup** → confirm (D) → file picker → `importJson`, **Run onboarding again**), version.

**Quick check** (`quick_check_screen.dart`): title "Quick check · i / n". Card: icon, "Still have
x?", "The app thinks ~qty", "Not checked in a while". **Swipe right** = `verify`; **swipe left** =
`markOut` (+fixed). **Gone** / **Adjust** (item (S), then next) / **Yes**. Done: summary and
**Done** (pop), metric `quick_check`.

**Stats**: median time-to-log per action (✓ ≤ 3 s), AI calls per task, the last 15 calls
(expandable raw response).

**Onboarding**: progress bar (6 segments), pages per §4, **Back**, **Get started / Next / Start**,
staple FilterChips, Fridge / Freezer / Cupboard → `startScan(pantry)` with "N photos queued", daily
pick time picker, portions −/+.

## 9. Logic that lives in `lib/features` (restyle around it, do not rewrite it)

These are behavioral code paths inside files the Implementer may edit. Moving them into new widgets
is fine. Changing them is not. ⚠ marks them in the tables above.
`review_screen.dart` 54-129 (commit/rate/currency flow), 379-546 (line editing rules);
`ingredient_sheet.dart` 101-249 (macros, stepper, save rules); `expense_sheet.dart` 43-100;
`transaction_sheet.dart` 42-55; `recipe_editor_screen.dart` 46-126; `cooked_sheet.dart` 33-47;
`cook_screen.dart` 113-118, 138, 317-342, 404-442; `cook_actions.dart` (whole file);
`scan_flow.dart` (whole file); `pantry_view.dart` 27-63, 214-241; `ledger_view.dart` 25-37, 113-136;
`inbox_screen.dart` 60-95; `dashboard_screen.dart` 79-94, 216, 266-301; `settings_screen.dart` 37-41,
49-212 (the `update` lambdas and clamps), 250-300, 551-612; `onboarding_screen.dart` 74-100, 152-163;
`quick_check_screen.dart` 30, 64-75, 86; `fx_widgets.dart` 9-22, 152-164; `recipe_detail_screen.dart`
17-19 (`recipeProvider`), 40-41, 217-224, 264-317; `stats_screen.dart` 17-26, 156-162;
`common/format.dart` and `common/widgets.dart` 447-486 (`showUndo` messenger plumbing, haptics, LogTimer).

## 10. Findings at baseline (pre-existing, not regressions)

1. **Quick check opened cold shows an empty deck** (confirmed). `quick_check_screen.dart:30` reads
   `quickCheckProvider` once, before `ingredientsProvider` has emitted. Opening `/quick-check` as the
   first screen (the weekly-recap notification payload, `notifications.dart:178`, via
   `main.dart:49-50`) shows "Nothing to check" while the deck has 2 items. A UI-layer fix is approved
   (§ VERIFICATION). The regression test exists and is skipped until the fix lands
   (`ui_flows_buy_test.dart`, `quickCheckColdOpenFixed`).
2. **The Flutter nav tabs expose no tap action to accessibility.** `_PillTab` wraps its InkWell in
   `Semantics(excludeSemantics: true)` with no `onTap` (`floating_nav.dart:194-199`). Screen readers
   see a labelled button they cannot activate. The fix is additive (`onTap: onTap` on that
   `Semantics`). It is recommended, not required.
3. **The existing smoke tests run at 800 × 600 dp.** `LiveTestWidgetsFlutterBinding` ignores
   `tester.view.physicalSize`; only `binding.setSurfaceSize` sizes the surface. The new guard tests
   use the screenshot geometry (390 × 844, insets, real fonts) through `test/support/app_harness.dart`.
4. Some controls have no label: the item sheet −/+ and the onboarding and recipe-editor portion −/+
   buttons (icon-only, no tooltip). Adding tooltips is welcome. The tests avoid icon finders.
5. Undo of a pantry swipe restores the quantity, but `setQuantity` re-estimates `expiresAt` from
   now (`pantry_service.dart:77-81`). The expiry is not restored exactly. This is existing behavior;
   leave it as is.
