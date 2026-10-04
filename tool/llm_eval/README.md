# LLM eval: does a model's answer end up as the right pantry?

`tool/model_eval_test.dart` compares Gemini models on real data and needs a key. This eval needs no key: any model can stand in for Gemini, and the app's own code judges the answers. It tests what the user sees after filing, not the JSON: "6 cans of cola", "8 tortillas", "15 ml of soy sauce gone".

## Cases

[`cases.json`](cases.json) has 37 cases, each with what the pantry must hold once the answer is filed.

- **Scans:** receipts from Lidl, Rewe, Aldi, Edeka, Penny, Kaufland, Netto, Coop (CHF) and Tesco (GBP), plus fridge and cupboard photos described in words. Each runs through Prompt A.
- **Say it:** sentences run through Prompt G against a shared kitchen (`kitchen`).

Some cases start with items the pantry keeps in another unit, such as a cola in ml or wraps in grams, to check the switch to pieces. An `expect` entry names the item by a key pattern and gives what it should hold: the unit, an amount range, and optionally a piece-name pattern. `any` lists acceptable alternatives, for things counted either way (sliced cheese, canned chickpeas).

## Running it

```sh
# 1. The requests the app sends (system prompt + user turn, the photo described in words)
LLM_EVAL=dump flutter test tool/llm_eval/llm_eval_test.dart

# 2. A stand-in model answers build/llm_eval/requests/<case>.md into
#    build/llm_eval/answers/<model>/<case>.json (the bare JSON, as Gemini would).

# 3. Every answer through the real ScanService / QuickLogService, then the pantry is checked
LLM_EVAL=check flutter test tool/llm_eval/llm_eval_test.dart   # → build/llm_eval/report.md
```

`LLM_EVAL_ONLY=<regex>` picks cases; `LLM_EVAL_OUT` moves the folder.

For step 2, Claude Code agents were used: one per group of 3 to 6 requests, told to read only their request files and answer each on its own. Haiku stands in for Flash-Lite and Sonnet for Flash. The prompts' own examples avoid every product used here, so a pass means the rule was applied, not copied.

An answer the app rejects counts as a failure. In the app, a rejected answer costs a second request (the repair round), and spending fewer requests was part of the goal.

## Results (3 Oct 2026)

| Round | Prompts | Haiku | Sonnet | What changed after it |
|---|---|---|---|---|
| Baseline | A v4, G v2 (before) | 20 / 26 | – | A cola kept in ml stayed in ml ("2.6 l" after six cans). Yogurt 4×125 g became 500 g. Wraps and yogurt kept in grams stayed in grams. A 1.5 l bottle rounded to 5 cans. A new item without macros was rejected (a repair request). |
| 1 | A v5, G v3 | 25 / 26 | 26 / 26 | A new item without a profile is now accepted; its macros are estimated later in a batch. |
| 2 | + sliced bread, 10 new cases | 34 / 36 | 36 / 36 | Missing profile fields now get defaults. "Only bottles over 0.5 l are measured, even in a multipack" (6×1.5 l water had come back as 6 bottles). |
| 3 | + Tesco UK | 37 / 37 | 15 / 15 (scans) | None. |
