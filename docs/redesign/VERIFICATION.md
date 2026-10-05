# Verification protocol (every Implementer change set)

Owner: Integrity Guardian. Run all of it on every change set before answering
**APPROVE / APPROVE WITH NOTES / VETO**. The contract is `docs/redesign/BASELINE.md`.

```bash
export PATH=/opt/flutter-sdk/flutter/bin:$PATH
WT=/home/user/trackcalfin-impl          # tree under review (the Implementer worktree)
G=/tmp/claude-0/-home-user-Trackcalfin/959da1af-9ea6-51de-b8b3-a820cf5d3c3b/scratchpad/guardian
BASE=$(sed -n 's/^# commit: //p' $G/baseline_inventory.txt)   # last approved commit (d004e5b at Phase 1)
```

## 1. Scope (allowed files only)

```bash
$G/contract_inventory.sh scope --tree $WT        # exit 1 = something outside the allowlist
git -C $WT diff --stat $BASE                      # plus untracked: git -C $WT status --short
```
* Allowed: `lib/app/theme.dart`, `lib/app/floating_nav.dart`, `lib/app/shell.dart`, `lib/features/**`,
  `assets/fonts/**` (each family with its `OFL.txt`), `pubspec.yaml` (`fonts:`/`assets:` only; the
  script compares everything else), `tool/screenshots_test.dart`, `docs/design/**`.
* Off-limits, VETO unless the Guardian has agreed to a named bug fix: `lib/domain`,
  `lib/application`, `lib/data`, `lib/core`, `lib/platform`, `lib/main.dart`, `lib/app/{router,providers,
  integrations,app,bootstrap,messenger}.dart`, `*.g.dart`, `assets/prompts`, native folders,
  `pubspec.lock` (skip-worktree, never commit it), and `test/**` (Guardian-owned; the Implementer may
  not edit or delete guard tests).
* New dependencies in `pubspec.yaml` are a VETO.

## 2. Static checks and the full suite

```bash
cd $WT && flutter analyze                                           # must say "No issues found!"
cd $WT && dart format -l 120 --output=none --set-exit-if-changed $(git diff --name-only $BASE -- 'lib/*.dart' | grep -v '\.g\.dart$')
cd $WT && flutter test                                              # all green; 164 pass + 1 skipped at Phase 1
cd $WT && flutter test test/widget                                  # guard tests only (~2 min)
```
If `$WT` doesn't have the current guard tests yet, run them in a scratch copy rather than in the
Implementer's worktree:
`R=$G/verify-tree; rm -rf $R && mkdir -p $R && (cd $WT && tar --exclude=./build --exclude=./.git -cf - .) | tar -xf - -C $R && cp -r /home/user/Trackcalfin/test/. $R/test/ && (cd $R && flutter test)`.
Any red test is a VETO until the cause is fixed. If
a test fails because the Director changed **copy** (flagged in `docs/design/SCREENS.md`), the
Guardian updates the finder (case-insensitive or wording) and keeps every behavioral assertion. A
failure in a DB assertion, a value assertion or an `expectTappable` is never fixed in the test.

## 3. Behavioral call-site inventory

```bash
$G/contract_inventory.sh diff --tree $WT     # exit 1 = something REMOVED
```
The script normalizes away whitespace, trailing commas, comments and line positions, and counts per
feature area. A pure restyle or an extract-widget refactor in the same area produces an empty diff
(verified by reformatting all of `lib/features` at `-l 70`).
* **REMOVED or fewer**: each line needs a reason, such as an action moved into a menu that the
  Director flagged (it should show up again in ADDED or MOVED), or a duplicate call merged. An
  unexplained removal of a provider, service call, navigation, sheet, handler, `Dismissible`,
  `RefreshIndicator`, popup-menu value, Dismissible key, tooltip, semantics label, metric or
  glass-nav channel key is a **VETO**.
* **MOVED between areas**: fine if the call still runs on the same user action. Check it.
* **ADDED**: check that it only changes presentation. A new handler that calls a service, a new
  provider `read` with a method call, or a new navigation is a behavior change and needs the
  Director's flag plus Guardian sign-off.

After an approved commit, re-baseline: `$G/contract_inventory.sh snapshot --ref <approved-commit> >
$G/baseline_inventory.txt`.

## 4. Read the diff (what a script can't judge)

```bash
git -C $WT diff $BASE -U0 -- lib/features lib/app/shell.dart lib/app/floating_nav.dart \
 | grep -E '^[-+][^-+]' \
 | grep -E "ref\.(read|watch|listen|invalidate)|context\.(push|go|pop|pushReplacement)|Navigator|GoRouter|show[A-Z][A-Za-z]*(<[^>]*>)?\(|notifyApp|on(Pressed|Tap|Changed|Submitted|Dismissed|LongPress[A-Za-z]*|Selected|SelectionChanged|Refresh|Deleted|PageChanged)\s*:|confirmDismiss|Dismissible|RefreshIndicator|PopupMenu|Semantics\(|tooltip:|semanticLabel:|excludeSemantics|ValueKey|extendBody|paddingOf|viewInsets|useRootNavigator|isScrollControlled|celebrate\(|tick\(|\.record\(|hint: '|value: '"
```
Then, line by line:
1. **UI-resident logic** (BASELINE §9). Any `-` line inside those ranges must be a pure move.
   Arithmetic, conditions, parsing (`double.tryParse(...replaceAll(',', '.'))`, `money.parse`),
   clamps, flags and the order of awaits must be byte-identical in substance.
2. **`confirmDismiss` still returns `false`** in the pantry row, and the key stays
   `ing-{id}-{qtyOnHand}`. Returning `true`, or a key without qty, breaks Undo (the row is removed and
   isn't rebuilt), or Flutter asserts that a dismissed Dismissible is still in the tree. The Ledger
   row keeps `onDismissed` with key `tx-{id}`. Quick check keeps startToEnd = "still have it".
3. **Undo plumbing**: messengers are captured *before* `await`s or `pop` (`ScaffoldMessenger.of(context)`
   then `showUndoOn(messenger, …)`). A sheet that closes first must still show its Undo on the root
   messenger (`appMessengerKey`). Snackbars must not sit under the floating nav.
4. **`extendBody` and bottom padding**: every tab body keeps `MediaQuery.paddingOf(context).bottom + …`
   so the last row, the pick card buttons and Cook-again rows can scroll above the nav. Sheets keep
   `viewInsets.bottom` padding so the keyboard doesn't cover fields.
5. **Floating nav and iOS glass contract** (`floating_nav.dart`): view type `trackcalfin/glass-nav`,
   creation params (`tabs[label,symbol,activeSymbol]`, `captureLabel`, `index`, `badges`, `dark`,
   `tint`, `onTint`), methods `update` / `select` / `capture`, `PopupObserver` cover, `_nativeGlass`
   gate. `ios/Runner/GlassNav.swift` can't change, so neither can these keys. Tab order and the
   `goBranch(..., initialLocation: index == current)` re-tap reset stay.
6. **Sheets and routes**: `useRootNavigator: true` (so sheets cover the nav and `PopupObserver` sees
   them), `isScrollControlled` where there are text fields, same `show*` function for each entry
   point. Route strings are unchanged. Back still works (an AppBar or a back affordance on every
   root route).
7. **Inputs**: same keyboard types, `autofocus` on the expense amount, `onSubmitted` = save on the
   expense and ask fields, labels still distinguishable (tests find fields by label).
8. **Strings that code parses or matches**: PopupMenuItem values (`edit`/`save`/`delete`,
   `extend`/`toss`/`undo`), scan hints `'receipt'`/`'pantry'`, flag names
   (`total_mismatch`, `currency_uncertain`, `foreign_currency`, `date_adjusted`, `merge_proposed`,
   `estimate_divergence*`), `'ready_with_swaps'`, `'short'`, theme values
   `'system'`/`'light'`/`'dark'`, metric names, notification payload routes.
9. **Formatting functions** (`features/common/format.dart`, `fx_widgets.dart` `moneyFor`/`rateText`/
   `fxSourceLabel`): a change here changes every displayed value. Compare outputs. Grouping
   ("2,200") is an approved Director change, and so is a new label. Rounding or units are not.
10. **Haptics and metrics**: `celebrate()` / `tick()` and the `metricsServiceProvider.record(...)`
    calls stay with their actions (the Stats screen depends on them).

## 5. UI-contract walkthrough

For each screen in the change set, go through BASELINE §8 against the code and the Director's
screenshots (`build/rounds/<round>/`). Every datum is still shown (or deliberately moved, as
flagged) and every action is still reachable in ≤ the same number of taps, except where the
Director flagged one extra tap (Buy "Add" menu). The guard tests cover most of this automatically:

| File | Protects |
|---|---|
| `test/widget/display_fidelity_test.dart` | Dashboard (every card), Pick / fridge / Cook again, Recipe detail (per portion, ingredient totals, stepper recompute, verdict), Pantry and Ledger (values, days, per-filter totals), Inbox/Review (sums, receipt total, FX) equal the domain functions |
| `test/widget/action_reachability_test.dart` | nav tabs, ⊕ + capture entries, Dashboard (quick check, meal, vibe sheet values), Settings tiles and Stats |
| `test/widget/action_reachability_lists_test.dart` | Buy actions (direct or in an "Add" menu), search, item sheet actions, expense chips and toggle, Inbox, Ledger filters and sheet; Cook ask/mic, stepper, I cooked this, Eat 1, fridge menu, pull-to-refresh, rotation, editor; Swap with a key and **no AI calls on navigation**; Recipe detail favorite, menu, stepper, long-press |
| `test/widget/ui_flows_buy_test.dart` | swipe-out + Undo, expense chip + Undo, typed expense + keyword learning, ledger swipe-delete + Undo and edit, review untick + commit (WAC) + discard, Quick check swipe/Gone, cold-open Quick check (skipped until fixed) |
| `test/widget/ui_flows_cook_test.dart` | stepper → cooked amount + Undo, Eat 1 + Undo, fridge extend/toss, favorite + delete + Undo, detail stepper cook + long-press out, Cooked sheet, manual meal + Undo, Settings edits and clamps, onboarding end to end |
| `test/widget/layout_clearance_test.dart` | at the end of every tab list (Dashboard, Pantry, Ledger, Cook, Settings) the last text sits above the floating nav; Recipe detail's last text sits above its bottom bar |
| `test/widget/app_smoke_test.dart` | the original smoke flows (now matching labels in any case) |

The harness (`test/support/app_harness.dart`) renders the same 390 × 844 phone, with insets and
real fonts, as `tool/screenshots_test.dart`. RenderFlex overflows at phone width therefore fail the
suite.

## 6. Verdict rules

* **APPROVE**: scope clean, analyze clean, suite green, inventory has no unexplained removal, and
  every ADDED is presentation-only.
* **APPROVE WITH NOTES**: as above, with non-blocking issues to fix next round (contrast, a missing
  tooltip, a test finder the Guardian had to adapt for flagged copy).
* **VETO**: any off-limits file, red test, unexplained removed call site, changed number or
  rounding, lost action or route, changed write path, extra AI or network call, broken Undo,
  content hidden under the nav or keyboard, or a glass-channel or `PopupObserver` contract change.
  Each VETO names the file:line and the BASELINE section.

## 7. Rulings

**Quick check cold open (Director flag §7): confirmed bug, fix approved.** Reproduced: opening
`/quick-check` as the first route (the weekly-recap notification payload, `main.dart:49-50`) shows
"Nothing to check" while the deck has 2 items. Cause: `quick_check_screen.dart:30` snapshots
`ref.read(quickCheckProvider)` before `ingredientsProvider` has emitted. Approved fix, in
`lib/features/settings/quick_check_screen.dart` only:
* While `ref.watch(ingredientsProvider)` has no value, show a loading or skeleton card. Snapshot the
  deck **once** when the value arrives, with `QuickCheck.candidates(items, now)` or
  `ref.read(quickCheckProvider)`. The deck must not live-update: answering a card changes the
  candidates and would shift `_i`.
* Keep `_answer` (verify / markOut / `_fixed` / `tick` / metric `quick_check` at the end), the
  Dismissible key `qc-{id}` and direction mapping, Gone / Adjust / Yes, the Done summary and pop.
* No change to `lib/domain/quick_check.dart` or `providers.dart`.
* Acceptance: set `quickCheckColdOpenFixed = true` in `test/widget/ui_flows_buy_test.dart`. That
  test fails on the current code (verified) and must pass with the fix. The warm path is covered by
  "quick check: swipe right keeps an item, Gone marks the next one out".

**Director flags accepted for the tests**: section-title casing (finders are case-insensitive);
"Other spend" with a separate "This month" (smoke test matches the prefix); grouped thousands
(`value()` accepts "2200" and "2,200"); Buy actions in a header "Add" menu (`revealAction` opens
`find.byTooltip('Add')` when the action isn't on screen); mic inside the ask field (same tooltip);
Cook-again icon leading; expense chips becoming a 2-column button grid (tests find them by
category label inside `ExpenseSheet`); onboarding sweep rows (not used by the tests). The Director's
stability promises that the tests rely on: `PortionStepper` class and tooltips, one `TextField` on
Cook, one `PopupMenuButton<String>` on Cook (fridge) and on Recipe detail, the existing tooltips,
`ExpenseSheet` / `AteSheet` / `CookedSheet` / `IngredientSheet` / `TransactionSheet` /
`ReviewScreen` / `QuickCheckScreen` / `RecipeDetailScreen` / `RecipeEditorScreen` class names, and
`Dismissible` rows.

**Recommended (not required)**: add `onTap` to the nav tab `Semantics` (BASELINE §10.2). After that,
the Guardian adds `expectTappable` for the tabs.
