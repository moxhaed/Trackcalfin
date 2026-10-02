# 05 · AI Layer & Master System Prompts

The master prompts are **runtime assets**. The app loads them verbatim as the `systemInstruction`:

| Prompt | File | Task |
|---|---|---|
| **A** | [`assets/prompts/receipt_extraction.v2.md`](../assets/prompts/receipt_extraction.v2.md) | Receipt or pantry image → structured JSON (expenses, categories, stock quantities, new-ingredient profiles) |
| **B** | [`assets/prompts/daily_recipe.v1.md`](../assets/prompts/daily_recipe.v1.md) | Inventory JSON → one stock-only recipe JSON (quantities per portion, estimates, hook line) |
| **C** | [`assets/prompts/spontaneous_recipe.v1.md`](../assets/prompts/spontaneous_recipe.v1.md) | User text/voice + inventory JSON → feasibility verdict + adapted recipe + shopping list JSON |
| **D** | [`assets/prompts/nutrition_estimate.v1.md`](../assets/prompts/nutrition_estimate.v1.md) | Ingredients with unknown macros → typical values per 100 g, density, piece weight |
| **E** | [`assets/prompts/nutrition_label.v1.md`](../assets/prompts/nutrition_label.v1.md) | Photo of a nutrition facts panel → the printed values, unconverted |

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
  "systemInstruction": { "parts": [{ "text": "<contents of receipt_extraction.v2.md>" }] },
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

Selection: `trackingMode == exact && qtyOnHand ≥ 5 g/ml (or ≥ 1 pc)`, sorted by `days_left` ascending (nulls last) so spoiling items come first. Staples go in a separate `staples: [key, ...]` array.

### Prompt B input
`today, weekday, output_language, currency, minor_unit_digits, portions (= profile.defaultPortions), targets_per_portion { kcal = dailyKcal / mealsPerDay, protein_g = dailyProtein / mealsPerDay, max_cost_minor = targetCostPerPortion }, profile {diet, allergies, dislikes, cuisines_liked, equipment, max_active_minutes}, inventory, staples, recent_recipes (titles suggested or cooked in the last 14 days, newest first, max 20), rejected_today`.

### Prompt C input
Same as B, minus `portions`, `weekday`, `recent_recipes` and `rejected_today`, plus `user_request` (raw STT or typed text), `requested_portions` (parsed locally by regex: `for (\d+)`, `(\d+) portions?`, else null) and `default_portions`.

## 5.4 The user turn

The user turn is **the JSON envelope only** (plus images for A). No natural-language wrapper is needed, because the system prompt defines everything. For the repair retry, append the model's previous output as a `model` turn and then this `user` turn:

```
Your previous response failed validation:
- <error 1, e.g. "items[3].total_minor must be an integer">
- <error 2, e.g. "ingredients[2].key 'parmesan' is not in inventory or staples">
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
| R6 | `purchased_at` not in the future and ≤ 60 days old | use `capturedAt`, flag |
| R7 | New-ingredient profile: required fields, `kcal ≤ 900/100 g`, **Atwater check** (§3.5) | flag `nutrition_suspect` (still committed, editable) |
| R8 | `currency` equals the profile currency (a `currency_uncertain` warning is flagged too) | flag `foreign_currency` → review with a conversion card (see §5.8) |

**Auto-commit** (when `autoCommitCleanScans` is on) requires: `image_type == receipt`, no `total_mismatch`, no `low` confidence line, no grocery line with `qty_source == unknown`, no `merge_proposed`, no `foreign_currency` and no `currency_uncertain`. Otherwise the job goes to `needsReview`. Pantry scans always go to review (a diff screen), because they overwrite quantities.

### RecipeValidator (Prompts B and C)
| # | Check | On failure |
|---|---|---|
| V1 | JSON, enums, required keys, `recipe != null` unless status allows it | repair retry |
| V2 | **Allergen screen**: ingredient keys and names vs `profile.allergies` + a synonym table (e.g. gluten → wheat, pasta, bread, flour, couscous, barley, rye, soy sauce; dairy → milk, cheese, butter, cream, yogurt; peanut → groundnut, satay; plus tree nuts, egg, fish, shellfish, sesame, soy) | **reject** → repair retry with an explicit error. Never displayed. |
| V3 | Every `stock` key exists in inventory | `IngredientMatcher.resolve(key, name)` → remap + flag `remapped_key`. Unresolvable: B → repair retry, C → convert to `missing`. |
| V4 | Every `staple` key is in staples | try stock lookup, else drop if < 5 g/ml, else `missing` |
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
| `stock, staple, missing` | `IngredientRole.*` |
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

Every number in a recipe comes from `Ingredient.per100`, so an ingredient with no macros silently counts as 0 kcal. `nutritionSource == none` marks that state. Onboarding staples, items added by hand with empty macro fields, and scanned items without a profile all start there.

- **D, estimate** (`NutritionService.fillMissing`): batches of up to 40 unknown items, `thinkingLevel: low`, no images. It runs on app resume, after the API key is saved, after onboarding, after a scan is filed, and from *Fill with AI* in the pantry. The model returns food-table values **per 100 g** plus `density_g_per_ml`, and Dart converts ml items to per 100 ml (`NutritionEngine.per100For`). The DTO rejects missing or unknown keys, macros over 100 g per 100 g, and ml or pc items without a density or piece weight, which triggers the usual repair retry. Items the user filled in while the call was running are left alone.
- **E, label** (`NutritionService.readLabel`): one or more photos, `mediaResolution: high`. The model only transcribes one column (per 100 g, per 100 ml or per serving with its size) and the energy in kcal and/or kJ. Dart does the conversion (`NutritionEngine.fromLabel`): kJ → kcal, per serving → per 100, g ↔ ml by the ingredient's density, and fiber taken out of US-style total carbohydrate. It flags `energy_mismatch` (Atwater) and `too_dense` (more than 9.1 kcal or 1.05 g of macros per gram). Nothing is saved until the user checks the numbers in the ingredient sheet and taps *Save macros*.

Confirmation lives in `Ingredient.nutritionConfirmedAt`: set by a saved label (`nutritionSource: label`), by typed numbers (`user`) or by *Confirm* on an AI estimate. Changing an ingredient's macros, unit or piece weight refreshes the stored numbers of every non-archived recipe that uses it (`RecipeService.refreshUsing`). Cook sessions keep their snapshot.

## 5.10 References

- Gemini 3.8 Flash announcement and model ID: [Introducing Gemini 3.8 Flash](https://blog.google/innovation-and-ai/models-and-research/gemini-models/3-8-flash-and-3-8-flash-cyber/), [Gemini API: What's new in Gemini 3.8 Flash](https://ai.google.dev/gemini-api/docs/latest-model)
- Structured output (`responseMimeType`, `responseJsonSchema` / `responseSchema`): [Gemini API structured outputs](https://ai.google.dev/gemini-api/docs/generate-content/structured-output), [Improving structured outputs in the Gemini API](https://blog.google/technology/developers/gemini-api-structured-outputs/)
- Dart SDK status: [deprecated-generative-ai-dart](https://github.com/google-gemini/deprecated-generative-ai-dart) → [Firebase AI Logic](https://firebase.google.com/docs/ai-logic/generate-structured-output)
- Isar community fork: [isar_community on pub.dev](https://pub.dev/packages/isar_community)
