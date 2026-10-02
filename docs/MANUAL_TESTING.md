# Manual test plan: first run on a real phone

The automated tests (159 of them) cover the math, the database, the AI pipeline against a fake Gemini, and the main screens. What they **can't** cover is anything that needs a real phone: the camera, the real Gemini API, notifications, the share sheet, voice input and background work. This checklist is for that.

**Time:** about 60–90 minutes. You don't have to do it all at once. Sections 1–4 are the important ones.
**Tick boxes as you go.** GitHub renders them as checkboxes when you edit the file.

## Before you start

You'll need:
- An Android phone with USB debugging on (or an iPhone plus a Mac with Xcode).
- A Gemini API key from [Google AI Studio](https://aistudio.google.com/).
- 3–4 real receipts: a supermarket receipt, a restaurant or café receipt, a long receipt if you have one, and ideally one in **another currency**. No foreign receipt? Photograph one on a screen: search the web for "Migros receipt" or "US grocery receipt".
- Something in your fridge to photograph.

When something goes wrong, note the **test ID** (e.g. `R3`), what you expected, what happened, and a screenshot. For anything AI-related, also open **Settings → Stats → Recent calls**, expand the call and copy the text. That shows exactly what Gemini answered. Paste all of that into the next session.

---

## 0 · Build and install

- [ ] **A1 · It builds.** `flutter pub get`, then `flutter run --release` with the phone plugged in (iOS: set your signing team in Xcode first).
  *Expect:* the app installs. If Gradle or Xcode fails, copy the **first** error block. That's the one that matters.
- [ ] **A2 · Icon and name.** Look at the home screen.
  *Expect:* a green icon with a bowl and a leaf, labeled "Trackcalfin".
- [ ] **A3 · First launch.** Open the app.
  *Expect:* onboarding starts, with no crash and no blank screen.

## 1 · Onboarding and API key

- [ ] **O1 · Goals.** Enter your real food budget, calories and protein. *Expect:* **Next** moves on.
- [ ] **O2 · API key.** Paste your key. *Expect:* **Next** moves on. There is no staples page any more.
- [ ] **O3 · Kitchen sweep.** Tap **Fridge** and take a photo, then **Spices & oils**. *Expect:* you're back in onboarding with "2 photos queued". The page also offers **A receipt**.
- [ ] **O4 · Finish.** Set your daily pick time and tap **Start**.
  *Expect:* a notification permission prompt appears (allow it), then the Cook tab opens.
- [ ] **K1 · Test connection.** Go to **Settings → AI → Test connection**. *Expect:* "Gemini is reachable".
- [ ] **K2 · Bad key message.** Change the key to `abc`, test again, then put the real key back.
  *Expect:* a readable error message, not a crash.

## 2 · Receipts (the most important section)

- [ ] **R1 · Clean supermarket receipt.** Tap ⊕ → **Scan receipt**, photograph a clear, flat receipt, and carry on using the app.
  *Expect:* within about 20 s, either "Lidl €xx · N items stocked" (filed automatically) or "Receipt needs a quick look". The **Ledger** shows the receipt, and the **Pantry** shows the grocery items with sensible quantities.
- [ ] **R2 · Review screen.** Open a receipt from the **Inbox** (the tray icon on the Buy tab).
  *Expect:* lines that need a look are open at the top, and everything else is collapsed under "N look good". Fix one amount or quantity and tap **Looks good**.
- [ ] **R3 · Totals mismatch.** If a receipt shows "Items add up to … but the receipt says …", check whether a line is missing or misread. Note what the AI got wrong.
- [ ] **R4 · Long receipt.** Tap ⊕ → **From photos** and pick 2 photos of the same long receipt.
  *Expect:* one receipt, with no line counted twice.
- [ ] **R5 · Restaurant receipt.** Scan a café or restaurant receipt.
  *Expect:* every line is "Eating out" and nothing is added to the pantry.
- [ ] **R6 · Blurry photo.** Photograph something that isn't a receipt, or a very blurry one.
  *Expect:* the Inbox says "Could not read this scan" and offers **Retake**.
- [ ] **R7 · Same store again.** Scan a second receipt from a store you've already scanned.
  *Expect:* items you bought before are recognized as the same pantry item (no duplicates like "Chicken breast" and "Chicken breasts").
- [ ] **R8 · "Same as …?"** If a line asks "Same as X?", tap **Yes**.
  *Expect:* the quantity is kept, converted to the unit of the existing item if needed.
- [ ] **R9 · Delete and undo.** In the Ledger, swipe a scanned receipt away.
  *Expect:* the snackbar says its pantry items were taken back out. Tap **Undo**: both the receipt and the pantry quantities come back.
- [ ] **R10 · Nutrition sanity.** Open a newly created pantry item.
  *Expect:* its kcal and protein per 100 g look plausible.

## 2b · Receipt dates, duplicates and pantry photos (new)

- [ ] **P1 · Old receipt.** Scan a receipt that is a week or more old.
  *Expect:* it waits in the Inbox. The review says "Bought Wed 23 Sep (9 days ago)" and explains that it's filed on that day. Fresh things that don't keep that long (meat, bread, herbs) show "Probably used up?" with **Used up** selected. After **Looks good**, the Ledger shows it on the printed date, and the Dashboard counts it in that week. Used-up items aren't added to the pantry, and the rest show days left counted from the purchase date.
- [ ] **P2 · Change the date.** In a receipt's review, tap **Date** and pick another day.
  *Expect:* the header changes, and the "used up" questions follow the new date.
- [ ] **P3 · Same receipt twice.** Scan a receipt you already filed.
  *Expect:* the Inbox card says "already filed?" and the review says "This looks like a receipt you already filed: …". **Discard this one** removes it, and the Ledger still has one copy.
- [ ] **P4 · Same one or extra?** Photograph something that's already in the pantry (⊕ → **Pantry**).
  *Expect:* "Already in your pantry: 500 g" with **Same one** and **Extra · 1 kg in all**. Pick **Extra** and tap **Update pantry**: the quantity adds up. With several such items, **All the same / All extra** sets them at once.
- [ ] **P5 · Product and price.** In the same kind of review, look at an item.
  *Expect:* the exact product with brand and pack size ("Barilla Spaghetti n.5, 500 g") and "~€1.99 a pack". After **Update pantry**, a new item's value shows with "~" in the pantry, and its sheet says "About €3.98 per kg (shop price estimate)". A later receipt for it changes that to "Avg cost …".
- [ ] **P6 · Receipt after a photo.** Photograph a few groceries, then scan a receipt from before the photo that has one of them.
  *Expect:* "You counted it today, after this purchase… Is this already part of it?" with **Already counted** selected. Filing it adds the money but not the item a second time.
- [ ] **P7 · Salt and oil count.** Open a recipe that uses salt or oil you haven't scanned.
  *Expect:* the row says it's not in the pantry (or "have 0 g"), and today's pick doesn't use it. After you scan it, the recipe's cost includes it. If a pantry item has no price yet, the recipe says so under the cost.
- [ ] **U1 · Upgrade from an install with staples.** Open the pantry on a phone that ran the previous version.
  *Expect:* your old staples (salt, oil, spices) are regular items. The ones you never bought are under **Out of stock**. The ones that showed stock appear in **Quick check**, because their amounts were never deducted.

## 3 · Foreign-currency receipts (new)

- [ ] **F1 · Automatic rate.** Scan a receipt in another currency (e.g. CHF, USD, GBP).
  *Expect:* it waits in the Inbox with "converted from CHF". Opening it shows a card like **"CHF 23.10 → €24.74"**, labeled "European Central Bank rate", and each line shows the euro amount with the printed amount underneath.
- [ ] **F2 · Amount charged.** Tap **Change rate** → **Amount charged**, type what your bank charged (or any close number), then **Convert all lines**.
  *Expect:* the total equals exactly what you typed, and the card says "from the amount your card was charged".
- [ ] **F3 · Exchange rate.** Tap **Change rate** → **Exchange rate** and type a rate.
  *Expect:* the preview shows the new total, and the lines update.
- [ ] **F4 · File it.** Tap **Looks good**.
  *Expect:* the Ledger shows the euro total with the original amount (e.g. "CHF 23.10") next to it. Tapping it shows "Paid CHF 23.10 · 1 CHF = …". The Dashboard counts it in euros.
- [ ] **F5 · Offline.** Scan a foreign receipt while online but don't file it yet. Turn on airplane mode, open it, tap **Wrong currency?** and pick a currency you've never used (e.g. SEK).
  *Expect:* "No exchange rate yet…", the button says **Set rate**, and **Try again** answers "Still no rate…". **Amount charged** still works offline. Now pick the currency you used in F1 again: *expect* your last rate to be used automatically ("the last rate you used").
- [ ] **F6 · Wrong currency.** On a foreign receipt, tap **Wrong currency?** and pick another currency, then set it back.
  *Expect:* the rate is fetched again. Picking your home currency removes the conversion card.
- [ ] **F7 · Yen or similar (optional).** If you can, scan a JPY receipt.
  *Expect:* ¥1,200 shows as ¥1,200 (not ¥12.00) and converts to a sensible euro amount.

## 4 · Cooking, fridge and eating

- [ ] **C1 · Today's pick.** Open the Cook tab.
  *Expect:* one recipe built from your pantry, with cost per portion, kcal, protein and time. The hook line mentions something real ("Uses your spinach…").
- [ ] **C2 · Swap.** Tap **Swap** twice.
  *Expect:* a different recipe each time. The third tap says "Swap limit reached for today".
- [ ] **C3 · Cook.** Set portions to 3 and tap **I cooked this**.
  *Expect:* "1 logged, 2 in the fridge · N g protein each". The pantry quantities drop, **In the fridge** shows 2 portions, and the Dashboard's today ring moves.
- [ ] **C4 · Undo cook.** Tap **Undo** on that snackbar, or use the fridge item's ⋮ menu → **Undo this cook**.
  *Expect:* the pantry is back exactly as before and the meal disappears from today.
- [ ] **C5 · Eat 1.** Cook again, then tap **Eat 1** on the fridge card.
  *Expect:* "Logged …" with "Protein today: X / Y g", and the portion count drops.
- [ ] **C6 · Toss / +2 days.** Use the fridge item's ⋮ menu.
  *Expect:* **Toss** empties it, and **Still good** extends the date.
- [ ] **C7 · Ran out.** Cook something whose ingredient you have less of than the app thinks.
  *Expect:* a "ran out sooner than expected" note, and the item appears in **Quick check**.
- [ ] **C8 · "I'm out".** On a recipe, long-press an ingredient → **I'm out of …**.
  *Expect:* the pantry shows it as out. If it was in today's pick, the pick refreshes.

## 4b · Macros on pantry items (new)

- [ ] **M1 · Oil and flour get macros.** Scan or add **Olive oil** and **Flour**, then open **Buy → Pantry** with a key set.
  *Expect:* within a few seconds, tapping **Olive oil** shows about 800 kcal per 100 ml and **Flour** about 350 kcal per 100 g, both marked "AI estimate". If the "items have no macros" card shows, tap **Fill with AI**.
- [ ] **M2 · Recipes count them.** Open a saved recipe that uses oil or flour.
  *Expect:* its kcal went up compared with before the update (10 ml oil adds about 80 kcal per portion).
- [ ] **M3 · Scan a label.** Open an item you have the package for → **Scan label** → photograph the nutrition table.
  *Expect:* the fields fill with the per-100 g (or per-100 ml) values from the package, with the product name above. **Save macros** marks it "From label". Try a US-style per-serving label too: the numbers should be scaled to 100 g.
- [ ] **M4 · Confirm or edit.** On an "AI estimate" item, tap **Confirm**, and on another tap **Edit**, change the kcal, and save.
  *Expect:* both show "Confirmed".
- [ ] **M5 · Review queue.** At the bottom of the pantry, tap **Review macros**.
  *Expect:* one sheet per unconfirmed item ("Check macros · 1 of N"). **Confirm** or **Skip** moves to the next one; swiping the sheet down stops.
- [ ] **M6 · New item without numbers.** **Add an item** named `Tahini`, leave the nutrition fields empty, and save.
  *Expect:* a moment later its sheet shows about 600 kcal per 100 g as an AI estimate.

## 5 · Ask ("What do you want to cook?")

- [ ] **Q1 · Typed request.** Type `carbonara for two but lighter` and send.
  *Expect:* a recipe with a green "Ready now / Ready with swaps" or amber "Needs shopping" banner that matches what you actually have.
- [ ] **Q2 · Voice.** Hold the mic, say a dish, and let go (allow microphone access).
  *Expect:* your words appear in the box and a recipe follows.
- [ ] **Q3 · Not food.** Ask "what's the weather".
  *Expect:* a polite "can only help with cooking" message and no recipe.
- [ ] **Q4 · Allergy.** In **Settings → Allergies**, add `peanut`, then ask for "chicken satay".
  *Expect:* a peanut-free version, with the change mentioned. Remove the allergy afterwards if it isn't real.
- [ ] **Q5 · Shopping list.** Ask for something you clearly can't make (e.g. "salmon sushi").
  *Expect:* "Needs shopping" plus a **To buy** list with estimated prices.

## 6 · Expenses

- [ ] **E1 · 3-tap expense.** Tap ⊕ → **Expense**, type `12.50`, and tap a category chip.
  *Expect:* it's saved instantly (no Save button) and the snackbar has **Undo**.
- [ ] **E2 · Text mode.** Tap the keyboard icon and type `9.80 lunch`.
  *Expect:* "Eating out" is pre-selected, and Enter saves it.
- [ ] **E3 · Learning.** Type `6 bouldering`, pick **Entertainment**, then next time type `8 bouldering`.
  *Expect:* the second time, Entertainment is pre-selected.
- [ ] **E4 · Time of day.** Open the expense sheet around lunchtime.
  *Expect:* **Eating out** is the first chip.

## 7 · Notifications

- [ ] **N1 · Meal-time "Ate it".** With portions in the fridge, go to **Settings → Meal reminders**, add a time 2 minutes from now, and lock the phone.
  *Expect:* a notification like "Lunch: Dal (2 left)" with **Ate it** and **Not now**. Tapping **Ate it** on the lock screen logs the meal without opening the app. Check the Dashboard's today ring afterwards.
- [ ] **N2 · Daily pick.** Set **Daily pick at** to 3 minutes from now, reopen the app once, then lock the phone.
  *Expect:* "Today: <recipe title>" arrives, and tapping it opens the Cook tab.
- [ ] **N3 · Plan tonight.** After 19:00, open the app and then leave it.
  *Expect:* the next morning's notification names a **real recipe**, not a generic message.
- [ ] **N4 · Scan result.** Scan a receipt and leave the app straight away.
  *Expect:* a "Scan processed" notification when it's done.
- [ ] **N5 · Status bar icon (Android).**
  *Expect:* a small white bowl icon, not a white square.
- [ ] **N6 · Restart.** Schedule a meal reminder, restart the phone, and wait.
  *Expect:* the reminder still arrives.

## 8 · Shortcuts and sharing

- [ ] **S1 · App-icon shortcuts.** Long-press the app icon.
  *Expect:* **Scan receipt**, **Log expense** and **I cooked**, and each opens the right flow.
- [ ] **S2 · Share a screenshot (Android).** In your gallery, share a receipt screenshot to Trackcalfin.
  *Expect:* the app opens on Buy and the scan is queued. (iOS needs an extra Share Extension, so skip this there.)

## 9 · Offline

- [ ] **X1 · Everything but AI works offline.** Turn on airplane mode and log an expense, cook something, eat a portion, and check the Dashboard.
  *Expect:* it all works.
- [ ] **X2 · Scans wait.** Still offline, scan a receipt.
  *Expect:* "Receipt waiting" in the Inbox. Turn airplane mode off and reopen the app: it gets processed.
- [ ] **X3 · Offline pick.** With no connection and no pick yet today (or with the key removed).
  *Expect:* the Cook tab shows **FROM YOUR RECIPES**, a saved recipe you can cook right now.

## 10 · Dashboard sanity check

- [ ] **D1 · Week spend.** Add up this week's grocery lines in the Ledger. *Expect:* it matches "Food spend · Week".
- [ ] **D2 · Budget.** *Expect:* the weekly budget = monthly budget ÷ 4.33.
- [ ] **D3 · Vibe explanation.** Tap the Vibe card. *Expect:* a breakdown of the parts, and the insight line makes sense.
- [ ] **D4 · Dark mode.** Go to **Settings → Appearance → Dark**. *Expect:* everything stays readable.

## 11 · Backup (do this before trusting the app with real data)

- [ ] **B1 · Export.** Go to **Settings → Export backup** and save it to Drive or Files.
- [ ] **B2 · Import.** Delete a test expense, then **Import backup** with the file.
  *Expect:* the expense is back, and the counts in the message make sense.

## 12 · Speed check (after a few days of use)

- [ ] **T1 · Time to log.** Go to **Settings → Stats**.
  *Expect:* median times for expense, cook and eat under 3 s (green ticks). Anything slower tells us which flow to simplify.
- [ ] **T2 · AI health.** On the same screen, look at failed and repaired calls.
  *Expect:* few failures. If Prompt A fails often, copy one raw response from **Recent calls**.

---

## Report template (paste into the next session)

```
Device: (e.g. Pixel 8, Android 16)
Passed: A1–A3, O1–O4, R1, R2, ...
Failed:
- R4: two photos of one receipt counted "Milk" twice. Screenshot attached.
- F2: typed €25.10, total showed €25.09.
AI raw responses (Settings → Stats → Recent calls): ...
Build errors (first block only): ...
Anything that felt slow or confusing: ...
```
