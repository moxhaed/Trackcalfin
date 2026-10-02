# 05 · AI Layer & Master System Prompts

The master prompts are **runtime assets**. The app loads them verbatim as the `systemInstruction`:

| Prompt | File | Task |
|---|---|---|
| **A** | [`assets/prompts/receipt_extraction.v4.md`](../assets/prompts/receipt_extraction.v4.md) | Receipt or pantry image → structured JSON (expenses, categories, stock quantities, the exact product, a shop price for pantry items, new-ingredient profiles) |
| **B** | [`assets/prompts/daily_recipe.v2.md`](../assets/prompts/daily_recipe.v2.md) | Inventory JSON → one stock-only recipe JSON (quantities per portion, estimates, hook line). Salt and oil only when they are in the inventory. |
| **C** | [`assets/prompts/spontaneous_recipe.v2.md`](../assets/prompts/spontaneous_recipe.v2.md) | User text/voice + inventory JSON → feasibility verdict + adapted recipe + shopping list JSON |
| **D** | [`assets/prompts/nutrition_estimate.v1.md`](../assets/prompts/nutrition_estimate.v1.md) | Ingredients with unknown macros → typical values per 100 g, density, piece weight |
| **E** | [`assets/prompts/nutrition_label.v1.md`](../assets/prompts/nutrition_label.v1.md) | Photo of a nutrition facts panel → the printed values, unconverted |
| **F** | [`assets/prompts/price_lookup.v1.md`](../assets/prompts/price_lookup.v1.md) | Products from a pantry photo → their shop price, searched with Google (one pack, its size, the store and the site) |
| **G** | [`assets/prompts/quick_log.v2.md`](../assets/prompts/quick_log.v2.md) | What the user says they did ("bought a Coke Zero for 1.29 and drank it") or asks ("where is it cheaper?") + pantry, fridge and recipes → actions to log, price checks to answer |

Those files are the single source of truth. This document covers how they're called, fed, and verified.

## 5.1 Design principles behind the prompts

1. **The model decides, Dart counts.** The prompts ask for *choices* (ingredients, quantities, categories, keys) plus estimates as a cross-check. Dart recomputes every number that reaches the UI from Isar data.
2. **A closed vocabulary.** Every categorical field is an enum, and every ingredient reference is a key copied from the input. That makes validation mechanical.
3. **Base units at the source.** The model outputs `g`, `ml` and `pc` and integer minor-unit money. Dart never parses "1,5 kg" out of AI text.
4. **B and C share one `Recipe` object.** One DTO, one validator and one recipe card cover both. B simply never uses `role: "missing"` or `substitutes_for`.
5. **Each prompt ends with a self-check** of its most common failure modes (totals, keys, quantities, allergens, lengths).
6. **Injection-hardened.** Image text and `user_request` are declared as data, and Dart validation rejects anything outside the contract anyway.
7. **Versioned filenames** (`*.v1.md`). `AiCallLog.promptVersion` records which version produced each output, so changes can be A/B-compared on your own history.

## 5.2 Call configuration

| | Prompt A | Prompt B | Prompt C |
|---|---|---|---|
| Model | `gemini-3.5-flash-lite` | `gemini-3.5-flash-lite` | `gemini-3.5-flash-lite` |
| Fallback (any API error from the main model) | `gemini-3.8-flash` | `gemini-3.8-flash` | `gemini-3.8-flash` |
| Thinking level | `low` (raise to `medium` if long or crumpled receipts misread) | `medium` | `medium` |
| Media resolution | `high` (small receipt fonts) | — | — |
| `responseMimeType` | `application/json` | `application/json` | `application/json` |
| Response schema | Recommended (Sprint 20) | Recommended | Recommended |
| Temperature / topP / topK | **Leave unset.** Gemini 3.x models are tuned for the defaults. Determinism comes from the schema and Dart validation, not from sampling. | same | same |
| `maxOutputTokens` | 16 384 | 8 192 | 8 192 |
| Timeout | 60 s | 45 s | 45 s |
| Approximate input tokens | system ~2.5k + known keys ~1–2k + images | system ~2k + inventory ~45 tokens/item | system ~2.3k + inventory |
| Typical output tokens (excluding thinking) | ~60 per receipt line | ~900 | ~1 100 |

Multiply by the current per-token price of the model to budget. At ~1 pick a day, ~3 scans a week and ~1 ask a day, volume is small.

### Request anatomy (REST, `generateContent`)

```http
POST https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash-lite:generateContent
x-goog-api-key: <from flutter_secure_storage>
Content-Type: application/json
```
```json
{
  "systemInstruction": { "parts": [{ "text": "<contents of receipt_extraction.v4.md>" }] },
  "contents": [{
    "role": "user",
    "parts": [
      { "text": "<input JSON envelope, see 5.3>" },
      { "inlineData": { "mimeType": "image/jpeg", "data": "<base64 page 1>" } },
      { "inlineData": { "mimeType": "image/jpeg", "data": "<base64 page 2>" } }
    ]
  }],
  "generationConfig": {
    "responseMimeType": "application/json",
    "responseJsonSchema": { "...": "mirror of the prompt's OUTPUT section" },
    "thinkingConfig": { "thinkingLevel": "low" },
    "mediaResolution": "MEDIA_RESOLUTION_HIGH",
    "maxOutputTokens": 16384
  }
}
```
> ⚠️ **Verify field names against the live API reference before Sprint 17.** I couldn't open Google's docs pages from the build environment. Everything above follows the documented `generateContent` shape as of this writing, but in particular: (a) Gemini 3.x also accepts a **per-part** `mediaResolution`, (b) the thinking-level values for 3.8 Flash are reported as `low | medium | high` (no `minimal`), and (c) newer API surfaces may name the schema field differently. `GeminiClient` keeps these in one `_buildBody()` method, so a correction is a one-line change.

Read the reply from `candidates[0].content.parts[*].text`, skipping any part flagged `thought: true`. Check `candidates[0].finishReason` (`STOP` = ok, `MAX_TOKENS` = truncated) and record `usageMetadata` token counts in `AiCallLog`.

## 5.3 Input envelopes (built by `ContextBuilders` from Isar)

### Prompt A input
```json
{
  "today": "2026-09-28",
  "currency": "EUR",
  "minor_unit_digits": 2,
  "country": "DE",
  "output_language": "en",
  "user_hint": "receipt",
  "known_ingredients": [
    { "key": "chicken_breast", "name": "Chicken breast", "unit": "g" },
    { "key": "egg", "name": "Egg", "unit": "pc" }
  ]
}
```
- `known_ingredients` is **every** ingredient (including stock 0), sorted by `lastPurchasedAt` desc, capped at 400. At ~15 tokens each that's cheap, and it's what makes the model reuse keys instead of inventing near-duplicates.
- Images are the document scanner's pages in order, long edge ≤ 2400 px, JPEG ~85.

### Inventory item (Prompts B and C)
```json
{ "key": "chicken_breast", "name": "Chicken breast", "qty": 650, "unit": "g", "g_per_pc": null,
  "cost_per_unit_minor": 0.998, "kcal_100": 110, "protein_100": 23.1, "carbs_100": 0, "fat_100": 1.9, "days_left": 2 }
```
| Field | From Isar |
|---|---|
| `key`, `name`, `unit` | `Ingredient.key`, `.name`, `.baseUnit` |
| `qty` | `qtyOnHand`, rounded (0 decimals for g/ml, 1 for pc) |
| `g_per_pc` | `gramsPerPiece` (pc items only) |
| `cost_per_unit_minor` | `avgCostPerUnitMinor`, 3 decimals |
| `kcal_100` … `fat_100` | `per100` (fiber omitted to save tokens) |
| `days_left` | `ExpiryEstimator.daysLeft`, null when shelf-stable |

Selection: `qtyOnHand ≥ 5 g/ml (or ≥ 1 pc)`, sorted by `days_left` ascending (nulls last) so spoiling items come first. Salt, oil and spices are inventory items like any other. There is no staples list: what isn't in the inventory isn't in the kitchen, and the prompts say so.

### Prompt B input
`today, weekday, output_language, currency, minor_unit_digits, portions (= profile.defaultPortions), targets_per_portion { kcal = dailyKcal / mealsPerDay, protein_g = dailyProtein / mealsPerDay, max_cost_minor = targetCostPerPortion }, profile {diet, allergies, dislikes, cuisines_liked, equipment, max_active_minutes}, inventory, recent_recipes (titles suggested or cooked in the last 14 days, newest first, max 20), rejected_today`.

### Prompt C input
Same as B, minus `portions`, `weekday`, `recent_recipes` and `rejected_today`, plus `user_request` (raw STT or typed text), `requested_portions` (parsed locally by regex: `for (\d+)`, `(\d+) portions?`, else null) and `default_portions`.

## 5.4 The user turn

The user turn is **the JSON envelope only** (plus images for A). No natural-language wrapper is needed, because the system prompt defines everything. For the repair retry, append the model's previous output as a `model` turn and then this `user` turn:

```
Your previous response failed validation:
- <error 1, e.g. "items[3].total_minor must be an integer">
- <error 2, e.g. "ingredients[2].key 'parmesan' is not in inventory">
Return the corrected JSON object only.
```

## 5.5 Validation pipeline

```
raw text ─► JSON.parse ─► DTO (freezed, strict enums) ─► task validator ─► Dart recompute ─► flags ─► persist
     └─ fail ───────────────────┴──► one repair retry ──► still failing → failed + AiCallLog
```

### ReceiptValidator (Prompt A)
| # | Check | On failure |
|---|---|---|
| R1 | JSON and enums valid, integers where required | repair retry |
| R2 | `|Σ items.total_minor − receipt_total_minor| ≤ max(2, 1% of total)` | flag `total_mismatch` → review |
| R3 | Line money in [−50 000, 100 000] minor units | flag the line as low |
| R4 | Quantity bounds: g/ml ≤ 25 000, pc ≤ 60 | flag the line as low |
| R5 | Keys match `^[a-z][a-z0-9_]{1,40}$`. A known key must exist. A new key goes through the fuzzy check (§3.13). | remap, or `merge_proposed` → review |
| R6 | `purchased_at` is printed and not in the future. Old receipts keep their date: the expense is filed on that day and freshness counts from it. | none printed → `capturedAt` + `date_missing`; future → `capturedAt` + `date_adjusted`; over a year back → kept + `date_old`. All three go to review, where the date can be changed. |
| R7 | New-ingredient profile: required fields, `kcal ≤ 900/100 g`, **Atwater check** (§3.5) | flag `nutrition_suspect` (still committed, editable) |
| R8 | `currency` equals the profile currency (a `currency_uncertain` warning is flagged too) | flag `foreign_currency` → review with a conversion card (see §5.8) |
| R9 | Each grocery line's quantity belongs in the pantry ([03 §3.16](03-algorithms.md#316-scan-checks-the-receipts-date-pantry-questions-duplicates)) | pantry photo of an item already on hand → "Same one / Extra"; receipt item counted after the purchase → "Already counted / Add"; receipt older than the item keeps → "Used up / Still have it". The money is filed either way. |
| R10 | No other receipt with the same day, total and store is filed or waiting in the Inbox | `duplicateOfTxId` / `duplicateOfJobId` → review: "Discard this one / It's a different one" |

**Auto-commit** (when `autoCommitCleanScans` is on) requires: `image_type == receipt`, no `total_mismatch`, no `low` confidence line, no grocery line with `qty_source == unknown`, no `merge_proposed`, no `foreign_currency`, no `currency_uncertain` and no date flag (`ScanDraft.clean`), plus no R9 question and no R10 match. Otherwise the job goes to `needsReview`. Pantry scans always go to review (a diff screen), because they overwrite quantities.

### RecipeValidator (Prompts B and C)
| # | Check | On failure |
|---|---|---|
| V1 | JSON, enums, required keys, `recipe != null` unless status allows it | repair retry |
| V2 | **Allergen screen**: ingredient keys and names vs `profile.allergies` + a synonym table (e.g. gluten → wheat, pasta, bread, flour, couscous, barley, rye, soy sauce; dairy → milk, cheese, butter, cream, yogurt; peanut → groundnut, satay; plus tree nuts, egg, fish, shellfish, sesame, soy) | **reject** → repair retry with an explicit error. Never displayed. |
| V3 | Every `stock` key exists in inventory | `IngredientMatcher.resolve(key, name)` → remap + flag `remapped_key`. Unresolvable: B → repair retry, C → convert to `missing`. |
| V4 | No staples: salt, oil and spices are `stock` rows checked by V3 and V6 like everything else. A `staple` role is an enum error. | B: repair retry ("'Salt' needs 6 g … but only 0 is available"). C: shortfall or `missing` → shopping list. |
| V5 | Units convertible to the ingredient's base unit (`UnitConverter`) | flag `unit_mismatch`, exclude that row from the Dart numbers |
| V6 | Quantities: B needs `need ≤ have` (2% tolerance) | clamp `portions` down to `FeasibilityChecker.maxPortionsNow`, flag. If 0 → repair retry. |
| V6c | Quantities: C | Dart computes `maxPortionsNow` and shortfalls and **overrides `status`** |
| V7 | Bounds: per-portion kcal 150–2000, protein ≤ 150 g, any ingredient ≤ 1000 g per portion, portions 1–12, 1–12 steps | flag, or repair retry if the output is absurd |
| V8 | Dart recompute of `perPortion` and `costPerPortionMinor`, compared with `estimate_per_portion` | divergence > 25% on kcal or cost → flag `estimate_divergence` (usually a unit error). The **UI always shows the Dart numbers.** |
| V9 | Text lengths (title 45, hook 70, summary 120) | truncate with an ellipsis |

## 5.6 Mapping AI enums → Dart enums

| AI value | Dart |
|---|---|
| `groceries, household, clothes, eating_out, entertainment, other` | `SpendCategory.groceries … eatingOut … other` |
| `meat_fish, dairy_eggs, grains_pasta, legumes_nuts, canned_jarred, spices_condiments, oils_fats, snacks_sweets` | `IngredientCategory.meatFish …` (camelCase) |
| `product, adjustment, deposit, fee` | `LineType.*` |
| `printed, inferred, estimated, unknown` | `QtySource.*` |
| `stock, missing` | `IngredientRole.*` |
| `missing_est { cost_minor_per_portion, kcal_per_portion, protein_g_per_portion, carbs_g_per_portion, fat_g_per_portion }` | `RecipeIngredient.estCostMinor` + `estNutritionPerPortion` (fiber 0) |

Use an explicit `switch` per enum. An unknown value is a validation error (repair retry), never a silent default.

## 5.7 Evaluating prompt changes

- Keep `test/fixtures/ai/` with ~5 real receipts (images + your corrected JSON), 3 inventories and 5 spontaneous requests.
- `tool/eval_prompts.dart` (a dev-only CLI) runs a prompt version over the fixtures and prints a diff: line count, money-total accuracy, key-reuse rate, validation flags, Dart-vs-AI divergence.
- Change prompts only through a new file version (`*.v2.md`). Switch the app over after the eval is at least as good as the previous version.

## 5.8 Foreign-currency receipts

Prompt A v2 returns amounts in the receipt's own currency and minor units (¥1,200 is `1200`, 1.250 KWD is `1250`), plus that currency's ISO code. It never converts. Dart does the rest:

1. **Rate lookup** (`FxService`): the European Central Bank reference rate for the purchase day via [Frankfurter](https://frankfurter.dev/v1/) (free, no key; only the two currency codes and a date leave the device). Offline or for an unsupported currency, it falls back to the last rate used for that currency, then to asking.
2. **Review is always required** for a foreign receipt. A conversion card shows "CHF 23.10 → €24.74", the rate and where it came from. Each line shows the home amount with the printed amount underneath, and amounts are edited in the receipt currency so they match the paper.
3. **Changing the rate**: *Amount charged* (type what the bank charged, which includes card fees so the ledger matches the statement) or *Exchange rate*. Rates you enter are remembered for the next receipt in that currency. *Wrong currency?* re-picks the currency and fetches a new rate.
4. **Filing** converts every line with `FxMath.convertLines` (rounding drift goes on the largest line, so the lines add up to the converted total), costs stock in the home currency, and keeps `originalCurrency`, `originalTotalMinor` and `fxRate` on the `Transaction`. The ledger shows the printed amount next to the converted one.

## 5.9 Ingredient macros (Prompts D and E)

Every number in a recipe comes from `Ingredient.per100`, so an ingredient with no macros silently counts as 0 kcal. `nutritionSource == none` marks that state. Items added by hand with empty macro fields and scanned items without a profile start there (as did the onboarding staples of schema 2).

- **D, estimate** (`NutritionService.fillMissing`): batches of up to 40 unknown items, `thinkingLevel: low`, no images. It runs on app resume, after the API key is saved, after onboarding, after a scan is filed, and from *Fill with AI* in the pantry. The model returns food-table values **per 100 g** plus `density_g_per_ml`, and Dart converts ml items to per 100 ml (`NutritionEngine.per100For`). The DTO rejects missing or unknown keys, macros over 100 g per 100 g, and ml or pc items without a density or piece weight, which triggers the usual repair retry. Items the user filled in while the call was running are left alone.
- **E, label** (`NutritionService.readLabel`): one or more photos, `mediaResolution: high`. The model only transcribes one column (per 100 g, per 100 ml or per serving with its size) and the energy in kcal and/or kJ. Dart does the conversion (`NutritionEngine.fromLabel`): kJ → kcal, per serving → per 100, g ↔ ml by the ingredient's density, and fiber taken out of US-style total carbohydrate. It flags `energy_mismatch` (Atwater) and `too_dense` (more than 9.1 kcal or 1.05 g of macros per gram). Nothing is saved until the user checks the numbers in the ingredient sheet and taps *Save macros*.

Confirmation lives in `Ingredient.nutritionConfirmedAt`: set by a saved label (`nutritionSource: label`), by typed numbers (`user`) or by *Confirm* on an AI estimate. Changing an ingredient's macros, unit or piece weight refreshes the stored numbers of every non-archived recipe that uses it (`RecipeService.refreshUsing`). Cook sessions keep their snapshot.

## 5.9b Units: pieces or grams (Prompt A v4)

A quantity is stored in the unit the item gets used up in, because that is how the user talks about it later ("I drank a cola", "200 g of rice"). v4 of Prompt A spells it out:

| Unit | For | Example |
|---|---|---|
| `pc` | what is eaten or drunk whole, one at a time: cans and bottles up to 0.5 l, yogurt and dessert cups, bars, ready meals, eggs, fruit and bread sold by the piece | "6x0,33l Cola" → 6 pc, `grams_per_piece` 340 |
| `g` | what is measured out in cooking or shared over servings: flour, rice, pasta, meat, cheese, a 500 g tub of yogurt | "Joghurt 500g" → 500 g |
| `ml` | what is poured over several servings: milk, oil, juice cartons, drink bottles over 0.5 l | "1,5l Cola" → 1500 ml |

v3 turned a six-pack of cans into 1980 ml. An item already in the pantry keeps its unit (`known_ingredients`), and `ReceiptValidator.alignUnit` converts ml and pieces by the piece weight, counting g and ml alike. To move an existing item to another unit, edit it in its sheet: the amount on hand, the cost per unit, the low-stock threshold and the last purchase are converted with the piece weight (`UnitConverter.factor`), and switching to pieces asks for that weight. Nothing is recounted.

## 5.10 Exact products and shop prices (Prompts A v4 and F)

Every grocery line names the exact product the model recognized (`product`: brand, name, variant and pack size, such as "Barilla Spaghetti n.5, 500 g"), read from the packaging or decoded from the receipt line. On a receipt this helps the quantity, because the identified product's pack size replaces a guessed one. A pantry photo has no prices, so Prompt A also gives each item a `shelf_price`: the usual price of one pack at a typical supermarket in `country`, in the home currency, plus the pack size, from the model's own knowledge.

**Prompt F looks those prices up on Google.** Right after a pantry photo is read, `ScanService` sends the items that still need a price (none paid yet: `ReceiptValidator.needsPrice`) to [`price_lookup.v1`](../assets/prompts/price_lookup.v1.md) with Grounding with Google Search on. The model searches the shops of `country` and returns, per item, the regular price of one pack, the pack's size in the item's unit, the store and the site (`found: false` when no result shows a price). Up to 20 items per call, `thinkingLevel: low`, a 90 s timeout. *Settings → AI → Look up prices on Google* (`UserProfile.lookUpPrices`) turns it off.

The request differs from the others:
```json
{
  "tools": [{ "google_search": {} }],
  "systemInstruction": { "parts": [{ "text": "<contents of price_lookup.v1.md>" }] },
  "contents": [{ "role": "user", "parts": [{ "text": "{\"country\":\"DE\",\"currency\":\"EUR\",\"items\":[...]}" }] }],
  "generationConfig": { "thinkingConfig": { "thinkingLevel": "low" }, "maxOutputTokens": 4096 }
}
```
- No `responseMimeType` or `responseJsonSchema`: in JSON mode the API leaves out the grounding sources. The prompt asks for the bare JSON object, `GeminiClient.stripFences` cuts away any text around it, and `PriceLookup.parse` checks it as strictly as the other DTOs: every input id exactly once, a found price of 1 to 100 000 minor units for one pack, a plausible pack size. A failed check gets the usual repair round, and the first round's searches still back the repaired answer.
- A 400 on a search request (a model or key without Google Search) goes to the fallback model but never steps down `compatLevel`: it says nothing about the other calls.

The answer's `groundingMetadata` is kept with the scan: `webSearchQueries` (`ScanJob.priceQueries`), the pages read (`groundingChunks[].web`, kept on a line as `priceLinks` when the site matches the `source` the model named) and `searchEntryPoint.renderedContent` (`ScanJob.priceSearchHtml`). Google requires showing these search suggestions, unmodified, next to anything taken from the search, and a tap must lead to the Google results page. The review screen renders the HTML in a web view on Android and iOS (`SearchSuggestions`: JavaScript off, a tapped chip opens the browser) and shows one chip per search where there is no web view (Linux desktop, tests).

Dart keeps the decisions:
- Review asks about every shop price that will be used (`DraftLine.priceToConfirm`): "Google found €1.79 for 500 g at Lidl. Is that the price?" with **Yes**, **Change** (price and pack size) and a link to the page. Where nothing was found it asks about the photo's estimate ("Estimated at €8.99 for 750 ml. Is that about what it costs?"). With several, **All correct** confirms them at once.
- Filing turns the pack price into a unit cost and applies it only where no price was paid. A confirmed or typed price counts as a real one (`CostingEngine.applyCheckedPrice`, `costIsEstimate: false`). An unanswered one stays an estimate (`applyEstimate`): the pantry marks it with "~", and recipes list the items whose prices are estimates. The next receipt for the item replaces either, instead of averaging with it.
- When the lookup fails (quota, timeout, no search support, an answer that fails the checks twice), the photo's estimates stand, `ScanJob.priceLookupError` says why, and review offers **Try again** (`ScanService.retryPrices`). Prices already found or confirmed are left alone.
- Receipt lines never get a shop price: the receipt prints what was paid.

Cost: one lookup is one model call plus the searches the model runs, usually one per item. Grounding with Google Search is billed per search query beyond a free monthly allowance (see Google's pricing page for the current numbers). At a few pantry photos a month that stays small, and the switch turns it off.

## 5.11 Say it: logging what the user says (Prompt G)

The ⊕ menu's **Say it** (also a home-screen shortcut) takes one sentence, spoken (on-device speech to text, the same as Ask) or typed, and logs everything in it: "bought a Coke Zero for 1.29 and drank it", "two portions of the chili and a döner for 7.50 at lunch", "cooked the bean pasta for three, ate one", "we're out of milk". It also answers "where is Coke Zero cheapest?" from the user's own receipts.

**Call.** `QuickLogService.interpret` sends [`quick_log.v2`](../assets/prompts/quick_log.v2.md) the sentence (`said`), `now` and the weekday, the currency, and what it may refer to: every pantry item (key, name, unit, on hand), the fridge (batch id, title, portions left, day cooked) and the saved recipes (id, title). JSON mode with `AiSchemas.quickLog`, `thinkingLevel: low`, 4 096 output tokens, 30 s timeout, one call per use. The input is about 20 tokens per pantry item, so ~2–4k tokens with a full pantry.

**Output.** A list of actions, each with a `type`, plus `total_paid_minor` (one amount for several items) and `question` (one short question when a detail is missing; then that action is left out). Every action has the same fields, null where they don't apply:

| type | What it needs | What Dart does |
|---|---|---|
| `buy` | pantry `key` (or a new key + `new_ingredient`), `qty` + `unit`, `paid_minor` or `est_price_minor`, `merchant` | adds the item at that price (`CostingEngine.applyPurchase`); all buys of one message are one grocery transaction |
| `expense` | `category` (not groceries), `paid_minor`, `name`, `merchant` | a transaction in that category |
| `eat` · fridge | `batch_id`, `portions` | takes portions from the batch; the meal costs what the batch cost per portion |
| `eat` · pantry | `key`, `qty` + `unit` | takes it out of stock; calories from the item's per-100 values, cost from its average cost (`MealSource.pantry`) |
| `eat` · out | `name`, `nutrition` (the model's estimate of the whole thing eaten) | a meal with cost 0: its money is an eating-out expense, and food eaten counts groceries only |
| `cook` | `recipe_id`, `portions`, `ate_portions` | the same as **I cooked this** (depletion, fridge batch, recipe stats); eats `ate_portions`, or the first portion when the user didn't say and **Log the first portion** is on |
| `throw_away` | fridge `batch_id` + `portions`, or pantry `key` + `qty` (null = all) | discards portions, or takes stock out |
| `count` | `key`, `qty` + `unit` | sets what is on hand, as a count (`ExpiryEstimator.onCount`); what went counts as eaten (`FoodUse`) |
| `price_check` | pantry `key` (null for an item not in the pantry), `name` | nothing is saved: the card answers from `PriceBook` (each store's last price per unit, cheapest first). The model never gives a price |

**Checks** (`QuickLog.parse`, a failure gets the repair round): keys, batch ids and recipe ids exist (a key bought earlier in the same message counts); quantities are in the item's own unit; a new key comes with a full `new_ingredient`; a buy without a price has an estimate (no amount paid is ever invented); money is 1 to 100 000 minor units; `when` is `YYYY-MM-DDTHH:MM`, not after now and at most 14 days back; no actions means there must be a question.

**Dart works out every number** (`QuickLogPlanner`, pure). It runs the actions in order on plain copies of the data, so a buy comes before the eat that follows it, and returns one step per action for the card: "Bought Cola Zero · 1 pc · €1.29 · Groceries", "Drank Cola Zero · 1 pc · 1 kcal · €0.84". A total for several items is split by their usual prices (the last item takes the rounding, so the lines add up). A buy priced only at the usual price is marked "~" and offers **Enter the price paid**. Eating more than is left logs what was there and says so. A batch or item that disappeared since is left out with a note.

A price check is an answer, not something to log: its line has no tick box ("Chicken breast: cheapest at Aldi, 4% less than Lidl" · "Aldi €9.58/kg · Lidl €9.98/kg · Rewe €13.73/kg"), and a card with only answers has **Done** instead of **Log it**. v2 added `price_check` to v1; nothing else changed.

**Confirm, then one transaction, then Undo.** Nothing is saved until **Log it**. Unticking a step plans again without it. `QuickLogService.apply` plans once more on the database inside one write transaction and saves the result. New ingredients and cook sessions carry negative stand-in ids until then, and are swapped for real ones in purchases, cook deltas and meals. It also keeps copies of everything it changed. **Undo** puts those copies back and deletes what was created, in one transaction. Deleting a pantry meal later from the day's log puts its stock back too.

## 5.12 References

- Gemini 3.8 Flash announcement and model ID: [Introducing Gemini 3.8 Flash](https://blog.google/innovation-and-ai/models-and-research/gemini-models/3-8-flash-and-3-8-flash-cyber/), [Gemini API: What's new in Gemini 3.8 Flash](https://ai.google.dev/gemini-api/docs/latest-model)
- Structured output (`responseMimeType`, `responseJsonSchema` / `responseSchema`): [Gemini API structured outputs](https://ai.google.dev/gemini-api/docs/generate-content/structured-output), [Improving structured outputs in the Gemini API](https://blog.google/technology/developers/gemini-api-structured-outputs/)
- Dart SDK status: [deprecated-generative-ai-dart](https://github.com/google-gemini/deprecated-generative-ai-dart) → [Firebase AI Logic](https://firebase.google.com/docs/ai-logic/generate-structured-output)
- Isar community fork: [isar_community on pub.dev](https://pub.dev/packages/isar_community)
- Grounding with Google Search (`google_search` tool, `groundingMetadata`, search suggestion display requirements): [Gemini API: Grounding with Google Search](https://ai.google.dev/gemini-api/docs/google-search)
