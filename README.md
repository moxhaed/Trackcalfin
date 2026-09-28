# Trackcalfin

A personal **micro-procurement, pantry and meal-prep tracker** built with Flutter, Dart and a local Isar database. Gemini 3.8 Flash does exactly three jobs: reading receipts, planning a daily recipe from your stock, and answering "can I cook this?". Everything else is deterministic Dart.

## Core principles

1. **≤ 3 seconds per log.** The AI does the data entry and you confirm by exception. The last tap commits, and undo replaces confirmation dialogs.
2. **LLM proposes, Dart disposes.** Gemini picks ingredients, quantities and categories. Dart computes every cost, macro, depletion, total and score.
3. **Offline-first.** Every log path and the whole Dashboard work without a network. AI calls queue or fall back.
4. **Cook ≠ eat.** Cooking depletes stock and fills the fridge. Eating a portion logs intake. That keeps meal prep honest.
5. **Stock accuracy is the trust metric.** Drift is expected, so detecting it is automatic and correcting it takes a swipe.

## Architecture docs

| # | Document | What's inside |
|---|---|---|
| 01 | [Behavioral Optimization Plan](docs/01-behavioral-plan.md) | Fogg B=MAP per behavior, 3-second flows, friction rules, retention loop, notification budget, wireframes, onboarding |
| 02 | [Infrastructure & Data Flow](docs/02-infrastructure-and-data-flow.md) | Stack, layers, folder layout, **every Gemini call** vs pure-Dart, sequence diagrams, background jobs, resilience, security |
| 03 | [Algorithmic Engines](docs/03-algorithms.md) | Exact formulas: WAC costing, expiry, nutrition, feasibility, depletion, dashboard (×4.33), Vibe Check, parsers, matcher |
| 04 | [Database Schema](docs/04-database-schema.md) | Isar collections (`Ingredient`, `Transaction`, `Recipe`, `DailyLog` + `CookSession`, `ScanJob`, `UserProfile`, `AiCallLog`), indexes, invariants |
| 05 | [AI Layer & Prompts](docs/05-ai-layer-and-prompts.md) | Call config, request anatomy, input envelopes, validation pipeline, evaluation |
| 06 | [Sprint Plan](docs/06-sprint-plan.md) | 33 sprints of 30–60 minutes, with a complete offline app by S16 |

## Master system prompts (runtime assets)

| Prompt | File |
|---|---|
| A · Receipt & expense extraction (image → JSON) | [`assets/prompts/receipt_extraction.v1.md`](assets/prompts/receipt_extraction.v1.md) |
| B · Daily stock-based recipe (inventory → recipe JSON) | [`assets/prompts/daily_recipe.v1.md`](assets/prompts/daily_recipe.v1.md) |
| C · Spontaneous recipe calculator (request + inventory → feasibility JSON) | [`assets/prompts/spontaneous_recipe.v1.md`](assets/prompts/spontaneous_recipe.v1.md) |

## Stack

Flutter · Riverpod · go_router · `isar_community` (Isar 3 API) · Gemini `gemini-3.8-flash` over REST (`dio`) · flutter_secure_storage · workmanager · flutter_local_notifications · speech_to_text · a document scanner plugin · quick_actions · receive_sharing_intent
