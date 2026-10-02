# 03 · Algorithmic Engines (the pure-Dart math)

Everything here lives in `lib/domain/`, has no Flutter, Isar or HTTP imports, and is covered by unit tests. Engines take plain values or DTO snapshots and return plain results. Use cases load from Isar, call engines, and write back in one transaction.

Conventions:
- **Money:** `int` minor units (cents) for every stored amount. Per-unit costs are `double` minor units per base unit (e.g. `0.998` = €9.98/kg). Totals are rounded half-up only when stored.
- **Quantities:** `double` in the ingredient's **base unit** (`g`, `ml`, `pc`).
- **Days:** a `dateKey` is `yyyymmdd` (int) in local time **with a rollover hour** (default 04:00), so a 00:30 snack counts toward the previous day.

---

## 3.1 DayClock (date keys, weeks, months)

```dart
int dateKey(DateTime t, {int rolloverHour = 4}) {
  final d = t.subtract(Duration(hours: rolloverHour));
  return d.year * 10000 + d.month * 100 + d.day;
}
DateTime weekStart(DateTime now, {int weekStartsOn = DateTime.monday}); // 00:00 + rollover
DateTime monthStart(DateTime now);
double elapsedFraction(DateTime start, DateTime end, DateTime now); // 0..1
```
Test cases: 23:59 and 03:59 on the next day share a key, while 04:00 starts a new one. Weeks that span a month boundary. DST transition days.

## 3.2 UnitConverter

Base units: **g** (mass), **ml** (volume), **pc** (countable). Every ingredient has exactly one base unit.

```dart
double toGrams(double qty, BaseUnit unit, Ingredient i) => switch (unit) {
  BaseUnit.g  => qty,
  BaseUnit.ml => qty * (i.densityGPerMl ?? 1.0),
  BaseUnit.pc => qty * (i.gramsPerPiece ?? _missing('gramsPerPiece')),
};

/// Converts a quantity expressed in `from` into the ingredient's base unit.
double toBase(double qty, BaseUnit from, Ingredient i) {
  if (from == i.baseUnit) return qty;
  final grams = toGrams(qty, from, i);
  return switch (i.baseUnit) {
    BaseUnit.g  => grams,
    BaseUnit.ml => grams / (i.densityGPerMl ?? 1.0),
    BaseUnit.pc => grams / (i.gramsPerPiece ?? _missing('gramsPerPiece')),
  };
}
```
Human-unit parsing (kg, l, cl, oz, lb, "stk", "x") lives here too and is used by the manual purchase form and `QuickTextParser`. The AI prompts already output base units.

## 3.3 CostingEngine: weighted average cost (WAC)

WAC is chosen over FIFO lots because it needs one number per ingredient, is robust to imprecise depletion, and is accurate enough for a personal budget.

```
applyPurchase(ing, qtyAdded, lineTotalMinor, purchasedAt):
  unitCost = lineTotalMinor / qtyAdded                       // minor units per base unit
  if ing.qtyOnHand <= 0 or ing.costIsEstimate:               // a price paid replaces an estimate
      ing.avgCostPerUnitMinor = unitCost
  else:
      ing.avgCostPerUnitMinor =
        (ing.qtyOnHand * ing.avgCostPerUnitMinor + qtyAdded * unitCost)
        / (ing.qtyOnHand + qtyAdded)
  ing.qtyOnHand      += qtyAdded
  ing.lastPurchasedAt = purchasedAt
  ing.lastPurchaseQty = qtyAdded
  ExpiryEstimator.onPurchase(ing, purchasedAt)
```
- `lineTotalMinor` is **net** of discounts, and basket-level adjustments are allocated first (§3.10). WAC therefore reflects what you actually paid.
- Setting stock to 0 (Quick Check "out") keeps `avgCostPerUnitMinor` as the last known price, which is still used for estimates.
- `purchasedAt` is the date printed on the receipt, not the day it was scanned (§3.16).
- A pantry photo (`stock_mode: set`) never overrides a price paid. For an item with no price yet it sets the AI's shelf-price estimate (`applyEstimate`, `costIsEstimate = true`).
- A receipt line that adds no stock (already counted, or used up) still prices the item when no paid average for what's on hand exists (`learnPrice`).

## 3.4 ExpiryEstimator (two-lot FIFO approximation)

A single `expiresAt` per ingredient, meaning the soonest expiry of what's on hand, gives the "use soon" signal without lot tracking.

```
onPurchase(ing, at):
  fresh = at + ing.shelfLifeDays
  ing.expiresAt = (qtyBefore > 0 && ing.expiresAt != null) ? min(ing.expiresAt, fresh) : fresh

onDeplete(ing):                      // after qtyOnHand decreases
  if ing.qtyOnHand == 0: ing.expiresAt = null
  else if ing.qtyOnHand <= ing.lastPurchaseQty:       // the older lot is used up
      ing.expiresAt = ing.lastPurchasedAt + ing.shelfLifeDays

daysLeft(ing, today) = ing.expiresAt == null ? null : max(0, daysBetween(today, ing.expiresAt))
useSoon = daysLeft != null && daysLeft <= 3
```
Items with `shelfLifeDays >= 180` get `daysLeft = null` (shelf-stable) in AI context.

## 3.5 NutritionEngine

`Ingredient.per100` is per **100 g** for `g` and `pc` items and per **100 ml** for `ml` items.

```
nutrientsFor(ing, qtyBase):
  basis = ing.baseUnit == ml ? qtyBase : toGrams(qtyBase, ing.baseUnit, ing)
  return ing.per100 * (basis / 100)                    // kcal, protein, carbs, fat, fiber

recipePerPortion(recipe, stock):
  Σ over ingredients with role stock (ingredient resolvable):  nutrientsFor(ing, toBase(ri.qtyPerPortion, ri.unit, ing))
  + Σ over role missing:  ri.estNutritionPerPortion      // model estimate, flagged as such in UI

recipeCostPerPortion(recipe, stock):
  Σ stock:    toBase(ri.qtyPerPortion) * ing.avgCostPerUnitMinor   // salt and oil included
  + Σ missing: ri.estCostMinor
```
There are no staples: every ingredient is a pantry item that was scanned (or bought by hand), so its cost and macros count. An item with no price yet counts as 0, and the recipe screen names it ("No price yet for …"), along with items priced from a pantry photo's estimate.

Snapshots are written to `Recipe.perPortion` / `costPerPortionMinor` at generation, and **again at cook time** into `CookSession` (prices move, and history must not change retroactively).

**Atwater sanity check** (used by `ReceiptValidator` on AI nutrition profiles):
`|kcal − (4·protein + 4·carbs + 9·fat)| / max(kcal, 1) ≤ 0.20` (with a 15 kcal absolute tolerance for low-energy foods), else flag `nutrition_suspect`.

## 3.6 FeasibilityChecker (saved recipes, no AI)

```
check(recipe, portions, stock):
  for ri in recipe.ingredients where role == stock:
     ing  = stock[ri.ingredientId] ?? matcher.resolve(ri.key, ri.name)
     need = toBase(ri.qtyPerPortion, ri.unit, ing) * portions
     have = ing?.qtyOnHand ?? 0
     perIngredientMax = floor(have / toBase(ri.qtyPerPortion))   // pc: floor to 0.5 granularity, then floor overall
     if have < need: shortfalls.add(ri, need - have)
  maxPortionsNow = min(perIngredientMax)            // seasonings count too; 0 if any role missing
  ready = shortfalls.isEmpty && no role missing
  readinessScore = Σ min(have/need, 1) / count      // for "almost ready" sorting
```
Used for the *Cook again* badges, the offline daily-pick fallback, the portion-stepper hint ("up to 3"), and **overriding Prompt C's verdict**.

**Offline daily-pick ranking** (fallback when Prompt B can't run): among `ready` recipes not cooked in the last 3 days, score by
`0.5·expiryUse + 0.3·proteinFit + 0.2·costFit`, where `expiryUse` is the share of the recipe's stock grams that come from `useSoon` items, `proteinFit = min(protein/target, 1)`, and `costFit = min(targetCost/cost, 1)`.

## 3.7 DepletionEngine + CookRecipe / UndoCook

```
plan(recipe, portions, stock) → CookPlan:
  for ri in recipe.ingredients where role == stock:
     ing       = stock[ri.ingredientId]
     requested = toBase(ri.qtyPerPortion, ri.unit, ing) * portions
     deducted  = min(requested, ing.qtyOnHand)
     shortfall = requested - deducted
     deltas.add(StockDelta(ing.id, requested, deducted, shortfall))
  perPortion      = NutritionEngine.recipePerPortion(recipe, stock)     // BEFORE deduction
  costPerPortion  = NutritionEngine.recipeCostPerPortion(recipe, stock) // WAC at this moment
  // salt, oil and spices are deducted like everything else. role missing: cannot be cooked → blocked in UI
```

`CookRecipe` writes all of this in **one `writeTxn`**:
1. `ing.qtyOnHand -= delta.deducted` (never below 0), then `ExpiryEstimator.onDeplete`.
2. If `shortfall > 0`: set `ing.lastVerifiedAt = null`, which puts it in the Quick Check deck. The user physically had more than the app thought, so a purchase was missed.
3. Insert `CookSession(portionsCooked: n, portionsRemaining: n − (autoLogFirstPortion ? 1 : 0), perPortion, costPerPortion, deltas, fridgeExpiresAt: now + recipe.fridgeLifeDays)`.
4. If `autoLogFirstPortion`: add a `MealEntry` to today's `DailyLog` and recompute its totals (§3.8).
5. `recipe.timesCooked++`, `lastCookedAt`, `lastPortionsCooked = n`, and if the status was `suggested` it becomes `saved`.

`UndoCook(sessionId)`, available from the snackbar and later from the session detail while no fridge portion has been eaten:
`ing.qtyOnHand += delta.deducted` for each delta → remove the auto-logged `MealEntry` → `session.status = undone` → decrement `recipe.timesCooked`.

## 3.8 EatPortion and DailyLog

```
EatPortion(sessionId, portions = 1, at = now):
  s = cookSessions.get(sessionId)
  eaten = min(portions, s.portionsRemaining)
  s.portionsRemaining -= eaten;  if 0 → s.status = finished
  log = dailyLogs.getByDateKey(dateKey(at)) ?? DailyLog(dateKey)
  log.meals.add(MealEntry(nutrition: s.perPortion * eaten, costMinor: s.costPerPortionMinor * eaten, ...))
  recomputeTotals(log)            // totals = Σ meals; always recomputed, never incremented
DiscardPortions(sessionId, n): s.portionsRemaining -= n; s.portionsDiscarded += n   // waste metric
```
When there are several active sessions, a notification action picks the **oldest** one (`cookedAt` ascending).

## 3.9 DashboardAggregator

Inputs: committed transactions for `[monthStart − 28 d, now]`, DailyLogs from the earliest of last week's start, the month's start and 28 days back, the day of the first logged meal, CookSessions for the waste count, and the profile.

The food budget can be read two ways, and the Food card switches between them (**Eaten | Spent**, `UserProfile.foodBasis`, Eaten by default):
- **Spent** (cash basis): groceries count on the day they were paid. A big shop that lasts two weeks lands on one day, so the week jumps.
- **Eaten**: groceries count when they are eaten, at what they cost (`DailyLog.foodCostMinor`: cooked portions at the batch's cost per portion, pantry items at their average cost, quick adds at the cost typed). This is the real weekly cost of food.

Both are computed every time (`DashboardState.spent`, `.eaten`), and the card shows the other one's week as a small number, so both stay a glance away. Non-food categories are spend only.

### Food spent (cash basis: what left your wallet)
```
groceries(tx range) = Σ line.totalMinor where line.category == groceries

weekFood        = groceries(weekStart .. now)
monthFood       = groceries(monthStart .. now)
N               = clamp(daysSinceFirstTransaction, 7, 28)        // cold start: show "collecting data" if < 7
trailingWeekly  = groceries(now − N d .. now) / N * 7
projectedMonth  = trailingWeekly * 4.33
weeklyBudget    = monthlyFoodBudget / 4.33
weekPace        = weekFood  / (weeklyBudget      * max(elapsedFraction(week),  0.2))
monthPace       = monthFood / (monthlyFoodBudget * max(elapsedFraction(month), 0.2))
```
- **4.33** is used in exactly two places: converting the monthly budget into a weekly one, and projecting the month from the trailing weekly average. The trailing average smooths out lumpy big shops.
- The `0.2` floor on the elapsed fraction stops one big Monday shop from reading as "400% over pace".

### Food eaten (value of what was eaten, from DailyLog)
```
eaten(range)    = Σ log.foodCostMinor over the days in range
week, month     = eaten(weekStart .. today), eaten(monthStart .. today)
N               = clamp(daysSinceFirstLoggedMeal, 7, 28)   // "projection after 7 days of logged meals" before that
trailingWeekly  = eaten(today − N d .. today) / N * 7
projectedMonth  = trailingWeekly * 4.33
weekPace, monthPace: as for spent, against the same food budget
costPerMeal     = homeCost / Σ home meal portions          // "€2.14 per home meal"
savedVsOut      = homeMeals * eatingOutAvg − homeCost
eatingOutAvg    = mean(eating_out transactions, last 90 d) if count ≥ 3 else profile.eatingOutAvgMealMinor
```
Spent and Eaten are two views of the same money, never added together. Eating out is in neither: it is its own line under Other spend, and a meal eaten out logged with Say it costs 0 in the meal log. Home meals (cost per meal, saved vs eating out) are cooked ones: a can of cola from the pantry counts as eaten food, but not as a meal.

### Non-food spend
For each `c ∈ {household, clothes, eatingOut, entertainment, other}`: `monthSpend[c]` vs `limit[c]`, with `pace[c]` as above. There's **no ×4.33 projection** for these lumpy categories (one pair of shoes isn't a trend). Bars show month-to-date against the limit, with a pace marker at `limit · elapsedFraction(month)`.

### Macros (intake = what was eaten)
```
completedDays = { d in [weekStart, today) : dailyLog(d).mealsCount > 0 }
avgKcal       = Σ totals.kcal over completedDays / |completedDays|      // same for protein
today         = dailyLog(today).totals                                  // live rings, excluded from the average
coverage      = |completedDays| / |[weekStart, today)|
if |completedDays| == 0: show last week's average, labelled "last week"
```
Averaging over **completed, logged days** keeps the number honest about intake. An unlogged day is missing data, not 0 kcal, and coverage keeps that visible.

## 3.10 Receipt math (inside CommitScan)

```
adjustments = lines where lineType == adjustment          // negative basket discounts
products    = lines where lineType == product
for p in products:
  p.totalMinor += round(adjustmentsTotal * p.totalMinor / Σ products.totalMinor)
fix rounding drift on the largest line so Σ lines == receipt total
drop adjustment lines; keep deposit/fee lines (category other)
```
`primaryCategory` = the category with the largest share of the total (used for icons and filters).

## 3.11 Vibe Check (VibeScorer)

Each component is scored 0–100. Components without a goal set are dropped, and the remaining weights are renormalized.

```
S_food     = 100 − clamp((monthPace − 1) * 200, 0, 100)      // on/under pace 100 · 25% over 50 · 50% over 0
                                                             // monthPace of the basis the Food card shows
S_nonfood  = same formula on Σ non-food spend vs Σ limits (monthly pace)
S_protein  = clamp(avgProtein / proteinTarget, 0, 1) * 100
d          = |avgKcal − kcalTarget| / kcalTarget
S_kcal     = 100 − clamp((d − 0.05) * 400, 0, 100)           // ±5% 100 · ±17.5% 50 · ±30% 0
S_logging  = coverage * 100

Vibe = 0.30·S_food + 0.15·S_nonfood + 0.20·S_protein + 0.15·S_kcal + 0.20·S_logging
Label: ≥85 "Locked in" · 70–84 "On track" · 50–69 "Drifting" · <50 "Reset mode"
```

**Insight line** (algorithmic templates, no AI): take the lowest component and fill its template.

| Lowest | Template |
|---|---|
| food (spent) | "Food spend is {x}% ahead of pace — a pantry-only day saves ~{costPerMeal}." |
| food (eaten) | "You're eating {x}% ahead of the food budget's pace, ~{costPerMeal} a meal. Cheaper picks bring it down." |
| nonfood | "{category} is at {pct}% of its limit with {days} days to go." |
| protein | "Protein is {x}% under target — {todayPickTitle} has {p} g." |
| kcal (over) | "Averaging {x}% above your calorie target this week." |
| kcal (under) | "Averaging {x}% under your calorie target — prepped portions help." |
| logging | "Log one meal today to keep this week's picture accurate." |
| all ≥ 85 | "Everything's on track — {coverage} days logged, ~{savedVsOut} saved." |
| week start (≤ 1 day in) | "New week, clean slate — {weeklyBudget} to plan with." |

## 3.12 QuickTextParser (non-food expense in one line)

```
input: "12.50 lunch" | "cinema 11" | "zara 39,99 jeans"
amount   = first match of  (\d+(?:[.,]\d{1,2})?)   → minor units
keywords = remaining tokens, lowercased
category = learnedKeywords[token] (user-taught, wins)
        ?? builtInMap[token]      // lunch|dinner|coffee|cafe|pizza|kebab|bar|beer → eatingOut
                                  // cinema|movie|concert|netflix|spotify|game|book|museum → entertainment
                                  // shirt|shoes|jeans|jacket|zara|h&m|uniqlo → clothes
                                  // detergent|soap|ikea|cleaning|toilet|shampoo → household
                                  // groceries|supermarket|lidl|aldi|rewe|market → groceries
        ?? lastUsedCategory
merchant/note = keywords joined
```
When the user changes the category after a parse, `(firstKeyword → category)` is upserted into `UserProfile.learnedKeywords`.

## 3.13 IngredientMatcher

```
normalize(raw):  uppercase → strip prices, weights, counts
                 (e.g. \d+[.,]?\d*\s?(G|KG|ML|L|CL|STK|X|%)\b) → strip punctuation → collapse spaces
                 "HOCHL.BRUSTFILET 500G 4,99" → "HOCHL BRUSTFILET"

resolve(line) — first hit wins:
  1. alias:  ingredients.where().aliasesElementEqualTo(normalize(line.rawText))   // user-confirmed mappings win
  2. key:    ingredients.getByKey(line.ingredientKey)                              // AI reused a known key
  3. fuzzy:  best of similarity(line.ingredientKey, existing.key) and
             similarity(line.name, existing.name) ≥ 0.85
             (normalized Levenshtein on keys + token-set ratio on names)
             → propose merge (amber "Same as Chicken breast?"), don't auto-merge
  4. new:    create Ingredient from line.newIngredient profile

onCommit: add normalize(rawText) to ingredient.aliases (dedupe, keep the newest 20)
```
The same matcher remaps unknown keys in Prompt B/C outputs (by `key`, then by `name`).

## 3.14 Quick Check candidate selection

```
candidates = ingredients where qtyOnHand > 0 and (
      lastVerifiedAt == null                                    // shortfall or never verified
   || now − lastVerifiedAt > (isPerishable ? 7 d : 21 d)       // perishable: shelfLifeDays ≤ 14
   || (expiresAt != null && expiresAt < now))
order by: shortfall-flagged first, then value at risk (qtyOnHand · avgCost) desc
take 10
```

## 3.15 Tests to write first (TDD targets per engine)

| Engine | Must-have cases |
|---|---|
| DayClock | rollover boundaries, week spanning months, DST day |
| UnitConverter | pc without `gramsPerPiece` throws, ml↔g with density, identity |
| CostingEngine | first purchase, purchase onto existing stock, purchase after stock was 0, a zero-quantity guard |
| ExpiryEstimator | older lot consumed, purchase onto non-empty stock keeps the earlier date |
| NutritionEngine | ml item uses per-100 ml, pc item uses grams, missing item estimate added |
| FeasibilityChecker | exact fit, shortfall, pc half-units, seasonings counted, missing → 0 portions |
| DepletionEngine | shortfall clamps at 0 and flags, undo restores exactly, snapshot taken before deduction |
| DashboardAggregator | cold start (< 7 days), 0.2 pace floor, completed-days average excludes today, spent vs eaten separation |
| VibeScorer | weight renormalization with missing goals, each template chosen correctly |
| QuickTextParser | comma decimals, amount first or last, learned keyword beats built-in |
| IngredientMatcher | alias beats AI key, fuzzy proposes but doesn't auto-merge, normalization strips weights |

## 3.16 Scan checks: the receipt's date, pantry questions, duplicates

Pure Dart in `ReceiptValidator` and `ScanService`, no AI. They decide what a scan does to the pantry, and when to ask first.

**Date (R6).** A receipt is filed on its printed date. That date becomes `Transaction.occurredAt`, so the spend lands in the week and month it was paid, and it's the purchase date `ExpiryEstimator` counts freshness from.
```
printed date missing           → photo date, flag date_missing   (review)
printed date > photo + 1 day   → photo date, flag date_adjusted  (review: misread)
printed date > 365 days back   → kept,       flag date_old       (review: misread year?)
otherwise                      → kept, however old
```
The review screen shows "Bought Sat 26 Sep (6 days ago)" and lets you change the date (`ScanService.setPurchaseDate`). That reruns the pantry questions and the duplicate check, and fetches the ECB rate for the new day when the rate was automatic.

**Pantry questions (R9).** Each grocery line has a `StockEffect`: `add` (receipt default), `replace` (pantry-photo default, because the photo counts what's there) or `none` (only the money is filed). A line asks (`stockCheck`) when that default may be wrong:
```
pantry photo, item already on hand (qtyOnHand > 0)    → onHand:  "Same one" (replace) or "Extra" (add)
receipt, item counted after the purchase              → counted: "Already counted" (none) or "Add" (add)
   (lastCountedAt > purchasedAt: a pantry photo, Quick Check or hand adjustment since)
receipt, daysBetween(purchasedAt, photo) > shelfLife  → usedUp:  "Used up" (none) or "Still have it" (add)
```
Any question holds the scan for review, and the review screen offers "All the same / All extra" when a pantry photo has several. `lastCountedAt` is only set by looking (pantry photo at its capture time, Quick Check, hand adjustments), never by a purchase. Two lines for the same item on one pantry photo add up.

**Duplicate receipts (R10).** `sameReceipt`: same calendar day, same total (printed total or line sum), and the same store when both name one ("Migros" matches "Migros Zürich"). `ScanService` checks the transactions of that day (compared in the receipt's own currency, including the printed total of the scan they came from) and the receipts waiting in the Inbox. A match sets `duplicateOfTxId` or `duplicateOfJobId` and holds the scan for review, with **Discard this one** and **It's a different one**.

**Shop price (pantry photos).** Prompt A names the exact product and estimates the usual price of one pack; Prompt F then looks the price up on Google for every item without a price paid ([05 §5.10](05-ai-layer-and-prompts.md#510-exact-products-and-shop-prices-prompts-a-v4-and-f)). Dart decides what is used and asked:
```
needsPrice(item)   = no item yet, or avgCostPerUnitMinor = 0, or costIsEstimate
priceSource        = web (Google found it) | estimate (Prompt A) | null when !needsPrice: not used, not asked
priceToConfirm     = priceSource != null && packagePriceMinor / packageQty usable && !priceConfirmed
on commit          → unit cost = packagePriceMinor / packageQty
                     confirmed or typed → applyCheckedPrice (a real price, costIsEstimate = false)
                     unanswered         → applyEstimate     (marked "~" until a receipt replaces it)
                     neither overrides a price paid (§3.3)
```
Every price to confirm holds the photo for review (pantry photos never auto-commit anyway). Merging a line into an existing item in review re-runs `checkPrice` against that item.
