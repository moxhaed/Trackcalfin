# 07 · Counting food the way it is used

A six-pack of cola has to be six cans, not 1.98 l. A pack of tortillas is eight tortillas, and a pack of four yogurts is four cups. A tablespoon of soy sauce comes off the bottle without anyone working out millilitres. This document is the product design behind that. It came before the code.

## 7.1 What went wrong

| Symptom | Cause |
|---|---|
| A six-pack of cola still lands as litres after the "count cans" fix | An item already in the pantry locked its unit. Prompt A v4 told the model to keep it ("a cola known in ml stays in ml"), and `ReceiptValidator.alignUnit` converted every line into it. A cola first saved in ml stayed in ml forever. |
| Tortillas, wraps and buns are counted in grams | The piece rule listed cans, cups, bars and eggs. A pack that prints its weight ("8 Tortillas 320 g") got weighed. |
| A pack of four yogurts is 500 g | Same: the multipack's weight was printed, so the model weighed it. |
| No way to log "a tablespoon of soy sauce" | No spoons anywhere in the app. Say it relied on the model doing the arithmetic. When it answered in another unit than the item's, Dart rejected the whole answer and asked Gemini again. |
| Hitting the Gemini limits | A pantry photo cost two requests (the photo and a Google price search). Every rejected answer costs one more (the repair round). |

## 7.2 The rule: count it the way you'll say you used it

Every pantry item is counted one way, chosen when it is first seen.

| Counted in | When | Examples | How you log it |
|---|---|---|---|
| **pieces** | it comes as separate things you take one at a time | cans and bottles up to 0.5 l, yogurt cups, tortillas and wraps, buns, rolls, croissants, eggs, sausages, bars, single-serve packs, ready meals, frozen pizzas, fruit by the piece | "I ate a tortilla", "I drank a can": one tap |
| **grams** | it is measured out | rice, pasta, flour, sugar, meat, a block of cheese, a 500 g tub of yogurt, loose vegetables by weight | grams, or spoons and cups |
| **ml** | it is poured | milk, oil, soy sauce, vinegar, juice cartons, drink bottles over 0.5 l | ml, or spoons, cups and glasses |

A pack counts its pieces: six cans are 6, a pack of 8 tortillas is 8, four yogurt cups are 4. The weight printed on the pack still matters: it gives the size of one piece (320 g / 8 = 40 g a tortilla), which the macros and conversions need.

A piece has a name ("can", "tortilla", "cup", "egg", "bun") and a size ("330 ml", "40 g"). The app shows amounts with the name: "5 cans", "Eat 1 tortilla", "3 cups left". Items without a name say "pc" as before.

## 7.3 The model reads; Dart counts

The model reports what it sees. The app decides and does every calculation.

For every grocery line a scan returns:
- `unit`: pieces, grams or ml, by the rule above. **Always by the rule, even for an item the pantry already has.** The model no longer copies the pantry's unit.
- `qty`: how much in that unit (6 for a six-pack).
- for pieces: `piece_name` ("can") and the size of one piece, `piece_size` with `piece_unit` (330 ml).

Dart then decides:

| Pantry item | Line | What happens |
|---|---|---|
| new | any | created in the line's unit, with the piece name and size |
| same unit | same unit | added as before |
| pieces | grams or ml | converted with the piece size: a 1.5 l bottle of cola counted in 330 ml cans adds 4.5 cans |
| **grams or ml** | **pieces, with a piece size** | **the item switches to pieces when the scan is filed**: the amount on hand, the cost per unit, the low-stock line and the last purchase are converted with the piece size. Review shows "Counted in cans from now on". |
| grams or ml | pieces, no size | converted if the item knows its piece weight, else the quantity is unknown and review asks |

A switch only goes **towards** pieces. Going back to grams is a hand edit in the item's sheet, so a bad reading can't flip an item back and forth. This is how an item stuck in the wrong unit (your cola in litres) fixes itself on the next receipt or pantry photo of it. Nothing needs re-entering.

Recipes keep their own unit per ingredient and convert through `UnitConverter.toBase`. A switched item still works in every saved recipe.

## 7.4 Spoons and other measures, in Dart

A fixed table, the same in every country:

| Measure | Is | Notes |
|---|---|---|
| tsp | 5 ml | |
| tbsp | 15 ml | |
| cup | 240 ml | |
| glass | 250 ml | drinks |
| pinch | 0.4 g | salt, spices |
| handful | 30 g | nuts, crisps, berries |

A measure converts into the item's own unit:
- **ml items**: directly. 1 tbsp soy sauce = 15 ml.
- **gram items**: through the item's density, the grams one ml weighs. 1 tbsp sugar = 15 ml × 0.85 = 13 g, 1 tsp salt = 5 ml × 1.2 = 6 g. An item without a density counts 1 g per ml. New items get their density from the same scan or Say-it answer that creates them (no extra request).
- **piece items**: through the piece size. A glass from 330 ml cans is 0.76 of a can.

Where you meet it:
- **Ate**: an item counted in pieces eats one with one tap ("Eat 1 tortilla"). For grams and ml, the amount dialog offers the measures that fit the item (spoons for oils, sauces, spices and spreads; a glass for drinks; grams for the rest), plus a typed amount.
- **Say it**: the model passes the amount on as said ("1 tbsp", "2 cans", "a glass"), and Dart converts it. A unit that differs from the item's is no longer an error, so it no longer costs a second request.

## 7.5 One request per thing you do

| You | Gemini requests before | After |
|---|---|---|
| photograph a receipt | 1 | 1 |
| photograph the pantry | 2: the photo, then a Google price search | 1. The Google search runs when you tap **Look up on Google** in review. *Settings → AI → Look up prices after every pantry photo* turns it back on for every photo. |
| Say it | 1, plus 1 more whenever the answer used another unit than the item's | 1 |
| either, when the answer leaves out a new item's profile or part of it | 1 more (the repair round) | none: the item is saved, and its macros are estimated later, in a batch of up to 40 items |
| eat, use or count something in the pantry | 0 | 0 |
| new items' macros | 0: the scan or Say-it answer brings them | 0 |

Today's Pick (about 1 a day), Ask, label photos and cookbook imports are unchanged.

The prompts are shorter where Dart now does the work. The model no longer converts units or totals, and no longer matches the pantry's unit. It makes one judgement per line ("pieces, grams or ml?") and reads what is printed.

## 7.6 How it is tested

- Dart unit tests: the measures table, the conversions, the unit switch, the validator's decisions, the DTOs against each prompt's example.
- An LLM-in-the-loop eval (`tool/llm_eval/`): realistic receipts, pantry photos (described in text) and Say-it sentences. A stand-in model answers each from the real prompt and the real input the app builds. Claude Haiku and Sonnet stand in, since there is no Gemini key in development. Each answer then runs through the real `ScanService` and `QuickLogService` on a test database, and the case checks the pantry afterwards: "6 cans of cola", "8 tortillas", "4 yogurt cups", "the cola that was in ml is now 6 + 6 cans", "15 ml of soy sauce gone". See `tool/llm_eval/README.md`.

Results on 3 Oct 2026. The baseline (prompts v4 and v2, before this change) passed 20 of 26 cases with Haiku: the cola kept in ml stayed in litres, a yogurt 4-pack became 500 g, and wraps stayed in grams. After three rounds of fixes, Haiku passes 37 of 37 and Sonnet passes every case it was given (26 of 26, 36 of 36, then 15 of 15 scans).
