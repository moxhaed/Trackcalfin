# 06 · Sprint Plan (30–60 minute daily sprints)

**Build order:** deterministic core first, AI last. By Sprint 16 you have a fully working **offline** app with manual entry: ledger, pantry, cooking, fridge and a complete dashboard. Everything after that is AI that *removes typing* from an app that already works. If Gemini is down, or you pause the project, you still have a useful tool.

### How to run a sprint
1. **5 min:** read the linked spec section. Write the "Done when" as a failing test or a checklist.
2. **30–45 min:** build. Domain engines are test-first.
3. **5–10 min:** run `dart format`, `flutter analyze` and `flutter test`, then commit with `S<nn>: <title>`.
4. If a sprint runs past 60 min, stop, commit what's green, and split the rest into `S<nn>b`.

Legend: 🧮 pure-Dart engine (test-first) · 🗄️ Isar · 🎨 UI · 🤖 Gemini · 📱 platform

---

## M0 · Foundation

| # | Sprint | Build | Done when | Spec |
|---|---|---|---|---|
| S01 | Project skeleton 🎨 | `flutter create`, folder layout, `flutter_riverpod`, `go_router` shell with 3 tabs + Settings route + ⊕ placeholder, lints, register `assets/prompts/` in `pubspec.yaml` | The app runs, tabs switch, `flutter analyze` is clean | [02 §2.4](02-infrastructure-and-data-flow.md#24-folder-structure) |
| S02 | Isar bootstrap 🗄️ | `isar_community` packages, enums + all 8 collections + embedded classes, `build_runner`, `isarProvider` opened in `main()` | The app starts and the Isar Inspector shows 8 empty collections | [04](04-database-schema.md) |
| S03 | Core value objects 🧮 | `Money` (minor units, formatting), `UnitConverter`, `DayClock` (rollover, week and month bounds) | Tests from [03 §3.15](03-algorithms.md#315-tests-to-write-first-tdd-targets-per-engine) for these three are green | [03 §3.1–3.2](03-algorithms.md#31-dayclock-date-keys-weeks-months) |
| S04 | Settings 🎨🗄️ | `UserProfile` form: budgets, category limits, kcal and protein, diet, allergies, portions, reminder times. API key field → `flutter_secure_storage` | Values survive an app restart, and the key is never written to Isar | [04 §4.11](04-database-schema.md#411-supporting-collection--userprofile-singleton-goals--settings) |

## M1 · Money in (no AI)

| # | Sprint | Build | Done when | Spec |
|---|---|---|---|---|
| S05 | Quick Expense sheet 🎨🗄️ | ⊕ → Expense: amount keypad, category chips ordered by recency and time of day, **chip tap = commit**, undo snackbar. `LogQuickExpense` use case. | An expense is logged in 3 interactions, undo removes it, and the ledger list shows it | [01 §1.3 B](01-behavioral-plan.md#13-the-3-second-budget-flow-by-flow) |
| S06 | QuickTextParser 🧮 | `"12.5 lunch"` → amount + category, with built-in keywords + `learnedKeywords`. Text field on the Expense sheet. | Parser tests green, and a correction teaches a keyword | [03 §3.12](03-algorithms.md#312-quicktextparser-non-food-expense-in-one-line) |
| S07 | Pantry list 🎨🗄️ | Ingredient CRUD (name, unit, qty, category, per-100 nutrition, staple toggle), grouped list, search, *Use soon* / *Running low* sections, swipe = out | You can add 10 items by hand and they group and sort correctly | [01 §1.8 Tab 2](01-behavioral-plan.md#tab-2-buy-inventory--ledger) |
| S08 | CostingEngine + ApplyPurchase 🧮🗄️ | WAC + `ExpiryEstimator`. A manual "Add purchase" form writes `Transaction` + stock in one txn. | WAC and expiry tests green. A manual purchase updates qty, cost and `expiresAt`. | [03 §3.3–3.4](03-algorithms.md#33-costingengine-weighted-average-cost-wac) |

## M2 · Spend dashboard

| # | Sprint | Build | Done when | Spec |
|---|---|---|---|---|
| S09 | DashboardAggregator: spend 🧮 | Week and month to date, trailing weekly average, ×4.33 projection, weekly budget, pace with the 0.2 floor, non-food per-category totals | Fixture tests green, including cold start (< 7 days) | [03 §3.9](03-algorithms.md#39-dashboardaggregator) |
| S10 | Spend cards 🎨 | Reactive provider (merged `watchLazy` + debounce + day-rollover ticker), food-spend card, other-spend bars with pace markers | Logging an expense updates the dashboard in under 200 ms, with no manual refresh | [02 Flow 6](02-infrastructure-and-data-flow.md#flow-6-reactive-dashboard) |

## M3 · Cook engine (no AI)

| # | Sprint | Build | Done when | Spec |
|---|---|---|---|---|
| S11 | Recipes by hand 🎨🗄️ | Recipe editor (ingredients picked from the pantry, qty per portion, steps), recipe list, favorite toggle | 3 of your real recipes are saved | [04 §4.7](04-database-schema.md#47-core-collection--recipe) |
| S12 | Nutrition + Feasibility 🧮 | `NutritionEngine`, recipe costing, `FeasibilityChecker` (`maxPortionsNow`, shortfalls, readiness score). *Cook again* badges. | Tests green. Badges show "✓ up to N" or "✗ missing X". | [03 §3.5–3.6](03-algorithms.md#35-nutritionengine) |
| S13 | Depletion + CookRecipe 🧮🗄️ | `DepletionEngine`, `CookRecipe` (one txn: deduct, add `CookSession`, auto-log the first portion), `UndoCook`, portion stepper + "I cooked this" | Tests green: shortfall clamps and flags, undo restores stock exactly | [03 §3.7](03-algorithms.md#37-depletionengine--cookrecipe--undocook) |
| S14 | Fridge + EatPortion 🎨🗄️ | Fridge strip (active sessions, "Eat 1", "Toss"), `EatPortion` → `DailyLog` with recomputed totals, fridge-expiry prompt | Cooking 3 portions leaves 2 in the fridge, each "Eat 1" logs one to today, and the invariants hold | [03 §3.8](03-algorithms.md#38-eatportion-and-dailylog) |

## M4 · Complete dashboard → offline app done ✅

| # | Sprint | Build | Done when | Spec |
|---|---|---|---|---|
| S15 | Macros card 🧮🎨 | Completed-day averages, today rings, coverage, spent vs eaten, cost per meal, saved vs eating out. "Quick add meal" (manual kcal and protein) for food you didn't cook. | Fixture tests green, and the rings update after "Eat 1" | [03 §3.9](03-algorithms.md#39-dashboardaggregator) |
| S16 | Vibe Check 🧮🎨 | `VibeScorer` (weights, renormalization, labels) + insight templates + hero card | Tests cover every template branch | [03 §3.11](03-algorithms.md#311-vibe-check-vibescorer) |

## M5 · AI plumbing

| # | Sprint | Build | Done when | Spec |
|---|---|---|---|---|
| S17 | GeminiClient 🤖 | `dio` client: `generateContent`, key header, JSON mime type, thinking level, media resolution, timeouts, 429/5xx backoff, `finishReason` handling, `AiCallLog` writes. **Verify field names against the live docs first.** | A smoke call with a trivial JSON prompt returns parsed JSON and a log row | [05 §5.2](05-ai-layer-and-prompts.md#52-call-configuration) |
| S18 | Prompts + ContextBuilders 🤖🧮 | `PromptRepository` (asset loading, version from filename), `InventorySerializer`, and the A/B/C envelope builders | Snapshot tests of the envelope JSON built from a fixture Isar state | [05 §5.3](05-ai-layer-and-prompts.md#53-input-envelopes-built-by-contextbuilders-from-isar) |
| S19 | DTOs + validators 🧮 | `freezed` DTOs for the A/B/C outputs, enum mappers, `ReceiptValidator`, `RecipeValidator` (incl. allergen screen), repair-retry loop | Fixture tests with valid, broken, allergen and over-quantity outputs behave as specified | [05 §5.5](05-ai-layer-and-prompts.md#55-validation-pipeline) |
| S20 | Response schemas 🤖 *(hardening)* | Mirror each prompt's `OUTPUT` types as a `responseJsonSchema` map. Test each against the live API. | 10 consecutive calls per prompt parse with no repair retry | [05 §5.2](05-ai-layer-and-prompts.md#request-anatomy-rest-generatecontent) |

## M6 · Scanning (Prompt A)

| # | Sprint | Build | Done when | Spec |
|---|---|---|---|---|
| S21 | Capture + queue 📱🗄️ | ⊕ → Scan with the document scanner (multi-page), compression, `ScanJob(queued)`, instant toast, `ImageStore` | Snap → back in the app in under 3 s, with the job persisted even offline | [01 §1.3 A](01-behavioral-plan.md#13-the-3-second-budget-flow-by-flow) |
| S22 | ProcessScan 🤖 | Queue worker: `queued → processing → needsReview / failed`, retry on resume and connectivity | A real receipt becomes draft lines in the job | [02 Flow 1](02-infrastructure-and-data-flow.md#flow-1-receipt-scan--ledger--pantry) |
| S23 | IngredientMatcher 🧮 | Normalize, then alias → key → fuzzy (propose only) → new | Matcher tests green | [03 §3.13](03-algorithms.md#313-ingredientmatcher) |
| S24 | Inbox review + CommitScan 🎨🗄️ | Review card (collapsed ✓ lines, amber lines, totals banner, untick, merge proposals), `CommitScan` in one txn (adjustment allocation, new ingredients, WAC, alias learning), **auto-commit** rule | A clean receipt auto-commits. A messy one takes 1 tap after fixes. The second scan from the same store maps via aliases. | [03 §3.10](03-algorithms.md#310-receipt-math-inside-commitscan) |
| S25 | Pantry photo + onboarding 🎨🤖 | `stock_mode: set` diff screen → `ApplyPantrySnapshot`. Onboarding flow (key, goals, staples, 3-photo sweep, first pick). | A fresh install ends onboarding with 20+ items and a recipe | [01 §1.9](01-behavioral-plan.md#19-onboarding-cold-start-in-about-3-minutes) |
| S26 | Share intake 📱 | `receive_sharing_intent` for images and screenshots → `ScanJob` | Sharing an e-receipt screenshot from another app lands in the queue | [01 R8](01-behavioral-plan.md#14-friction-killing-design-rules-non-negotiable) |

## M7 · AI cooking (Prompts B and C)

| # | Sprint | Build | Done when | Spec |
|---|---|---|---|---|
| S27 | AskRecipe (Prompt C) 🤖🎨 | Ask bar + hold-to-talk (`speech_to_text`), local portion parse, skeleton card, verdict badge (Dart-overridden), shopping list, Save / I cooked this | "Carbonara for two" gives an honest verdict with Dart numbers | [02 Flow 3](02-infrastructure-and-data-flow.md#flow-3-spontaneous-request) |
| S28 | GenerateDailyPick (Prompt B) 🤖 | Generate on open when missing, a feasibility re-check of an existing pick, Swap (max 2 a day, `rejected_today`), offline fallback ranking | Airplane mode still gives a pick. Online gives a fresh, validated one. | [03 §3.6](03-algorithms.md#36-feasibilitychecker-saved-recipes-no-ai) |
| S29 | Plan tonight, notify tomorrow 📱 | Generate tomorrow's pick on pause after 19:00 or after an evening cook. Schedule the morning notification with the hook. `workmanager` fallback window. | The notification arrives at 07:30 with the real recipe hook | [02 §2.7](02-infrastructure-and-data-flow.md#27-background-work--notifications) |

## M8 · Habit loop

| # | Sprint | Build | Done when | Spec |
|---|---|---|---|---|
| S30 | Actionable meal reminders 📱 | Schedule reminders only when the fridge has portions. **[Ate it]** runs `EatPortion` in a background isolate. | Tapping "Ate it" on the lock screen updates the dashboard without opening the app | [02 §2.7](02-infrastructure-and-data-flow.md#27-background-work--notifications) |
| S31 | Quick Check deck 🎨🧮 | Candidate selection + swipe deck (right = keep, left = out, up = adjust), long-press "I'm out" on any ingredient row, regenerate the pick when affected | 10 items verified in under 30 s | [03 §3.14](03-algorithms.md#314-quick-check-candidate-selection) |
| S32 | Entry points + recap 📱🎨 | `quick_actions` (Scan / Expense / Cooked), Sunday recap notification (algorithmic stats), coverage + streak with weekly freeze, time-to-log metric in Settings → Stats | Every hot path is reachable from the home screen in 1 tap | [01 §1.5–1.6](01-behavioral-plan.md#15-the-retention-loop-hook-model-on-a-daily-cycle) |
| S33 | Backup + housekeeping 🗄️📱 | JSON export/import + `copyToFile` → share sheet, image cleanup (> 30 days), pruning of stale suggestions, `AiCallLog` cap | Export, reinstall and import restore everything | [02 §2.10](02-infrastructure-and-data-flow.md#210-backup) |

---

## Milestone checkpoints

| After | You have |
|---|---|
| S08 | An expense tracker with a hand-managed pantry and correct WAC costing |
| S16 | **A complete offline app**: ledger, pantry, recipes, cooking with depletion, fridge portions, and a full dashboard with Vibe Check |
| S20 | A hardened AI pipeline, ready for features |
| S26 | Groceries logged by photo, with review by exception |
| S29 | A daily AI recipe from your own stock, plus on-demand "Can I cook this?" |
| S33 | The full habit loop: actionable notifications, cheap stock correction, backups |

## Later ideas (deliberately out of scope)
- A home-screen widget (today's rings + "Eat 1").
- **Eating-out meal logging** with macro estimates (the dashboard's intake blind spot today; it would need a small Prompt D).
- AI nutrition fill for hand-added ingredients (same Prompt D: name → per-100 profile).
- Barcode lookup via Open Food Facts for packaged items.
- A shopping list generated from low stock + favorite recipes (algorithmic).
