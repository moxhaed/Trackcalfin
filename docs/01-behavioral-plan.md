# 01 · Behavioral Optimization Plan

> Goal: every tracking action takes **≤ 3 seconds of the user's attention**, and the app earns a daily open without relying on willpower.

## 1.1 Why trackers die (the three failure modes we design against)

| Failure mode | What happens | Our countermeasure |
|---|---|---|
| **Entry cost > perceived value** | Itemized forms, mandatory fields and review screens make logging feel like admin work. After about a week the user stops. | The AI does the data entry and the user only confirms, by exception. Logs commit on the last tap. There are no forms on the hot paths. |
| **Data drift → distrust** | Stock numbers slowly diverge from reality. The app suggests a recipe with eggs you don't have, trust collapses, and the app gets abandoned. This kills pantry apps specifically. | Correction is cheap and happens in context (tap "I'm out" on a recipe row), plus a 30-second swipe "Quick Check" deck aimed at likely-wrong items. |
| **Guilt spiral** | You miss two days, the streak resets to 0 and red numbers pile up. Opening the app now feels bad, so you avoid it (the *ostrich effect*). | Coverage replaces streaks, streaks get automatic freezes, the act of logging is never punished, and there is a fresh start each week and month. |

## 1.2 Fogg Behavior Model applied (B = M · A · P)

Motivation is volatile, so we design for the **low-motivation day**. The lever we control is **Ability**: we cut time, decisions ("brain cycles") and non-routine steps. We then attach each behavior to a **Prompt** that already exists in daily life. The **Celebration** that follows wires in the habit.

| Behavior | Prompt (trigger) | Ability lever | Motivation / celebration |
|---|---|---|---|
| Log groceries | Unpacking groceries (anchor), the e-receipt arriving (share sheet), long-pressing the app icon | Auto-capture camera, async AI extraction, **auto-commit** when the receipt passes every check | Toast "€43.12 · 14 items stocked" with a haptic tick. The pantry count goes up (endowed progress). |
| Log a non-food expense | Right after paying (phone already in hand) | Amount keypad pre-focused. **Tapping the category chip is the save.** Chips are ordered by time of day and recency. | Tick and haptic. Deliberately no budget scolding at this moment. |
| Decide what to cook | Morning notification with the hook line | **One** suggestion, not a list (no choice overload). Cost, macros and time are already computed. | Curiosity (variable reward). "Uses your spinach before it wilts" adds loss aversion. |
| Log a cook | Finishing cooking | One tap on "I cooked this ×3". Portions default to your history. Undo instead of confirm. | "1 logged, 2 in the fridge · 51 g protein each" |
| Log eating a prepped portion | Meal-time notification | **Action button on the notification**, so no app open | "Protein today: 96 / 140 g" |
| Fix stock | Weekly recap, or a mismatch detected while cooking | One swipe per item, with only suspect items shown | "Pantry accuracy: 97%" |
| Ask for a recipe | Standing at the fridge wondering what to make | Hold the mic, speak, let go. Speech-to-text runs on device. | A feasibility badge ("Ready now") as instant relief |

### Tiny Habits anchor recipes (shown once in onboarding, one per screen)
- *"After I put the groceries away, I snap the receipt."*
- *"After I close the fridge with my lunch box, I tap **Ate it**."*
- *"While the coffee brews, I glance at today's pick."*
- *"On Sunday evening, when the recap arrives, I swipe the Quick Check (30 s)."*

## 1.3 The 3-second budget: flow by flow

| # | Action | Entry point | Interactions | Attention time | What removes the friction |
|---|---|---|---|---|---|
| A | Log groceries | Long-press the app icon → *Scan*, or the ⊕ button → *Scan* | 1 tap + camera auto-capture | ~3 s | Document scanner auto-capture. The AI runs in the background. **Auto-commit** when totals match and no line is low-confidence. Review happens later, only when something is off. |
| B | Non-food expense | ⊕ → *Expense* | Type the amount, then 1 chip tap | ≤ 3 s | Chip tap = commit. Or type `12.5 lunch` → Enter (local parser, no AI). |
| C | Cook | Today's-pick card, or *Cook again* | 1 tap (2 to change portions) | ≤ 2 s | Portion stepper pre-set from the last time you cooked this recipe, else your default. Undo snackbar for 5 s. |
| D | Eat a prepped portion | Meal-time notification action | 1 tap, no app open | ≤ 1 s | Picks the oldest active fridge batch automatically. |
| E | Stock correction | Quick Check deck | 1 swipe per item | ≤ 1 s per item | Right = still have it, left = out, up = adjust. Only algorithmically suspect items appear. |
| F | Ask for a recipe | Hold the mic on the Cook tab | 1 gesture | Speak, then read the card | Your words appear instantly while Gemini works, and a skeleton card shows no dead spinner. |
| G | Onboarding pantry seed | First launch | 3 photos | ~2 min once | Pantry-photo mode fills 20–40 items at once (the cold-start fix). |

**Measurement:** each use case records `startedAt → committedAt` in a tiny local metric, and Settings → Stats shows the median time-to-log per action. If a flow's median passes 3 s, it gets redesigned before any new feature is added.

## 1.4 Friction-killing design rules (non-negotiable)

1. **R1 · Undo, never confirm.** Every write commits instantly, shows a 5-second undo snackbar and stays editable later. No confirmation dialogs anywhere.
2. **R2 · The last tap commits.** No "Save" buttons on hot paths. The chip, the stepper release or the notification action *is* the save.
3. **R3 · Defaults from history.** Portions come from the last cook of that recipe, category from the merchant or keyword memory, chip order from the time of day.
4. **R4 · AI is asynchronous.** The user never waits on a spinner to finish a log. Scans go into a queue and results come back through the *Inbox* badge or a notification.
5. **R5 · Review by exception.** High-confidence data commits on its own. Only amber items (low confidence, totals mismatch, possible duplicate ingredient, a receipt that may already be filed, an item that may already be counted or used up) ask for attention.
6. **R6 · One suggestion, not ten.** The daily pick is a single recipe with a *Swap* button (max 2 swaps a day).
7. **R7 · Correct in context.** Any ingredient row, anywhere, supports long-press → *I'm out / Adjust*. Fixing data is part of using the app, not a chore.
8. **R8 · Entry points outside the app.** Quick actions on the app icon, the share sheet (e-receipts), notification action buttons, and later a home-screen widget.
9. **R9 · Nothing mandatory.** Every field except the amount is optional. Missing data degrades one card, never a whole flow.
10. **R10 · Never punish the act of logging.** The moment after a log shows only neutral or positive feedback. Over-budget warnings live on the Dashboard, which the user visits on their own terms.

## 1.5 The retention loop (Hook model on a daily cycle)

```
 TRIGGER (external → internal)      ACTION (≤3 s)            VARIABLE REWARD               INVESTMENT
 ─────────────────────────────      ─────────────            ───────────────               ──────────
 07:30 "Today: Lemon chicken orzo   open card / nothing      novel recipe, uses what       each log sharpens stock
  · uses your spinach"                                       you have, costed + macro'd    → better future picks
 12:30 "Lunch: Chili (2 left)"      [Ate it]                 protein ring fills            intake history
 19:00 finish cooking               I cooked this ×3         "3 portions · €2.10 each"     recipe joins "Cook again"
 After shopping                     snap receipt             "€43 · 14 items stocked"      pantry grows, aliases learned
 Sun 18:00 weekly recap             swipe Quick Check        "~€48 saved vs eating out"    stock accuracy ↑
```

After a few weeks, **internal triggers** take over: *"What's today's pick?"* (curiosity) and *"Am I on budget?"* (mild money anxiety that the Vibe Check settles). The **investment** step matters most for retention. The more you log, the better the pantry reflects reality and the better the suggestions get, so leaving means losing a system that knows your kitchen.

### Notification budget (max 3 per day, each one actionable)

| Notification | When | Actions | Condition |
|---|---|---|---|
| Daily pick | User time (default 07:30) | Tap → Cook tab | A pick exists for today |
| Meal time | User times (default 12:30, 19:00) | **[Ate it] [Not now]** | Fridge has active portions |
| Scan processed | When the AI finishes | [Review] | Only if it needs review, or as a summary after an auto-commit |
| Fridge expiry | Morning, folded into the daily pick | [Still eating it (+2 d)] [Toss] | A batch is past `fridgeExpiresAt` |
| Weekly recap | Sunday 18:00 | [Quick Check · 30 s] | Always (can be muted) |

Every notification without an action button is a candidate for deletion.

## 1.6 Motivation without guilt

- **Vibe Check, not a report card.** One composite score (0–100) with a plain-language label (*Locked in · On track · Drifting · Reset mode*) and **one** insight line that points to the next best action ("Protein is 18% under — today's pick has 51 g"). The formula is in [03-algorithms.md](03-algorithms.md#311-vibe-check-vibescorer).
- **Coverage over streaks.** "Logged 5 of 6 days" is honest and forgiving. A streak counter exists but gets **1 automatic freeze per week**, so it doesn't reset to 0 over one missed day.
- **Fresh-start effect.** Pacing resets on Monday and on the 1st of the month, and the insight line uses this ("New week, clean slate — €69 to plan with").
- **Positive framing of savings.** "~€48 saved vs eating out this week" is computed from your own eating-out average. It shows the payoff of cooking.
- **Loss aversion, pointed at waste.** "€3.20 of spinach expires tomorrow" appears *inside* the daily pick's hook, where it drives action (cooking) rather than guilt.
- **Celebrate the behavior, not the outcome.** Haptic plus a micro-animation plus one neutral or positive stat, immediately after the action (Fogg's "Shine").

## 1.7 Trust maintenance: keeping stock accurate

Stock accuracy is the **core trust metric**. Drift comes from untracked consumption (snacking, sharing), portions cooked by feel, and missed receipts. We don't try to prevent drift. We make it cheap to detect and fix.

**Suspect-item detection (algorithmic):**
1. **Shortfall at cook time.** The depletion wanted 200 g but stock had 120 g, so a purchase was missed. Stock is set to 0 and the item is flagged.
2. **Stale verification.** `qtyOnHand > 0` and `lastVerifiedAt` is more than 21 days ago (perishables: more than 7 days).
3. **Past estimated expiry** with `qtyOnHand > 0`.
4. **In-context denial.** The user taps "I'm out" on a recipe row. Stock goes to 0, and if the row was part of today's pick, the pick is regenerated.

**Quick Check deck:** up to 10 suspect items, one card each ("Still have rice? ~800 g"). Swipe right = yes (sets `lastVerifiedAt`), left = out (qty 0), up = adjust (numeric stepper). A pantry photo (Prompt A, `stock_mode: set`) is the bulk version of the same flow.

## 1.8 UX layout

Three tabs plus a **global capture button (⊕)** beside the bottom bar. ⊕ opens a speed dial: round buttons stacked above it, each with a label saying what it does. **Say it** (talk or type what you did; the AI logs it after you check it) sits right above the ⊕, closest to the thumb; then **Scan receipt · I ate · I cooked · Expense · Receipt from photos · Pantry photo** (count the food you already have). The ⊕ turns into ✕ to close. Settings live behind the gear on the Dashboard.

### Tab 1: Dashboard (read-only, 100% algorithmic)
```
┌──────────────────────────────────────────┐
│ Mon 28 Sep                          [⚙]  │
│  ╭─────╮  VIBE · On track (78)           │
│  │ 78  │  Protein 18% under target —     │
│  ╰─────╯  today's pick has 51 g.         │
├──────────────────────────────────────────┤
│ TODAY   kcal 1,240/2,200 ◔   P 68/140 g ◑│
├──────────────────────────────────────────┤
│ FOOD                     [Eaten | Spent]  │
│ Week    €27 / €69    ████░░░░░░  on pace  │
│ Month  €118 / €300   proj. €245 (×4.33)   │
│ €41 spent this week · €2.14 per meal      │
│ ▮▮ Past months: eaten and spent       ›   │
├──────────────────────────────────────────┤
│ OTHER SPEND · month                       │
│ Household      €22 / €40   █████░░░░      │
│ Eating out     €58 / €60   █████████▲     │
│ Clothes         €0 / €50                  │
│ Entertainment  €18 / €40   ████░░░░░      │
├──────────────────────────────────────────┤
│ THIS WEEK  avg 2,050 kcal · 121 g protein │
│ ▂▅▇▆▃  (completed days)   coverage 4/5    │
│ ~€48 saved vs eating out                  │
└──────────────────────────────────────────┘
      Dashboard       (⊕)       Buy    Cook
```

**Past months** opens Food by month: a pair of columns per budget month (eaten, spent) against the budget, and a card per month with its weeks, what was thrown away, and whether more was bought than eaten. It answers "was last month really over, or did I just stock up?"

**Where it's cheaper.** Every receipt line keeps its store and product, so the app knows what each store charged last. After a receipt is filed it says when another store sold something clearly cheaper ("Chicken breast: 26% cheaper at Aldi"), an item's sheet lists the stores cheapest first, Running low says where to buy, and Say it answers "where is it cheaper?". All from the user's own receipts, in Dart: no AI call except reading the question.

### Tab 2: Buy (Pantry, List & Ledger)
```
┌──────────────────────────────────────────┐
│ Buy                           Inbox (2)  │
│ [ Scan receipt ]                          │
│ [ Pantry | List · 3 | Ledger ]            │
├──────────────────────────────────────────┤
│ USE SOON                                  │
│  Spinach 210 g · 1 d   Chicken 650 g · 2 d│
│ RUNNING LOW                               │
│  Eggs 2 pc   Milk 150 ml                  │
│ ALL · by category              [search]   │
│  Meat & fish  ▸  Dairy & eggs  ▸  …       │
│  (swipe left = out · tap = adjust)        │
└──────────────────────────────────────────┘
```
- **Inbox:** scans that need review, and failed scans ("Retake?"). The review card shows high-confidence lines collapsed as ✓ and amber lines expanded, plus a totals-mismatch banner, and a single **Looks good** button.
- **List:** the shopping list. Running-low and recently-out items are one-tap suggestions; lines are grouped by the store each is cheapest at; a receipt with an item ticks it off. Recipes add what they're missing. **Send the list** shares it as text.
- **Ledger:** reverse-chronological transactions with category filter chips. Tap to edit (a scanned receipt shows its photo for 30 days), swipe to delete (with undo).
- **Review** has a **Photo** button: check a hard-to-read line against the receipt itself.

### Tab 3: Cook (Recipe & Meal Prep)
```
┌──────────────────────────────────────────┐
│ TODAY'S PICK                     [Swap]  │
│ Garlic chicken & spinach rice bowls      │
│ Uses your spinach before it wilts        │
│ €2.55/portion · 633 kcal · 51 g P · 30min│
│ [ − 3 + ]      [ I COOKED THIS ]         │
├──────────────────────────────────────────┤
│ IN THE FRIDGE                             │
│  Turkey chili · 2 left · 2 d   [Eat 1]    │
├──────────────────────────────────────────┤
│ COOK AGAIN · ready now                    │
│  Egg fried rice      ✓ up to 3 portions   │
│  Lentil bolognese    ✓ up to 4 portions   │
│  Salmon traybake     ✗ missing: salmon    │
├──────────────────────────────────────────┤
│ ( What do you want to cook?   [hold mic] )│
└──────────────────────────────────────────┘
```
- **Cook again** is fully algorithmic, with no AI call. Most people rotate about 10 recipes, so re-cooking a known recipe is the most common path, and its feasibility badges come from `FeasibilityChecker`.
- Tapping a recipe opens its detail: ingredients (each row long-press → *I'm out / Adjust*), steps, a per-portion macro and cost breakdown, and a favorite toggle.

## 1.9 Onboarding (cold start in about 3 minutes)

1. **API key**: paste once, stored in secure storage.
2. **Goals**: three sliders with sensible defaults (monthly food budget, kcal, protein), the day the month starts on (payday; the 1st by default) and optional per-category limits.
3. **Kitchen sweep**: photos of fridge, freezer, cupboard, and spices and oils → Prompt A in pantry mode → one review → 20–40 items seeded, each with the exact product and its usual shop price. Recent receipts can be scanned too: they're filed on their printed dates, and an item that shows up on both a receipt and a photo is asked about ("Same one or extra?", "Already counted?") instead of being counted twice. Endowed progress: "Your pantry knows 34 items." There is no staples list: nothing is assumed to be in the kitchen, so salt and oil are counted, deducted and costed like everything else.
4. **Rhythm**: daily-pick time, meal reminder times, default portions.
5. **Instant value**: today's pick is generated right away, so the first session ends with a costed, macro-counted recipe built from your own food.

## 1.10 Anti-patterns we explicitly avoid

- Manual itemized purchase entry as the main path (it exists only as a fallback edit screen).
- A mandatory review step after every scan.
- A list of ten AI suggestions each morning.
- Streaks that reset to zero, red totals at the moment of logging, and badges or points unrelated to your goals.
- Notifications without an action, or more than 3 per day.
- Any feature whose failure (offline, AI error) blocks a log. Every log path works offline.
