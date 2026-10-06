# Review 07: Final whole-app pass (Phase 9)

Shots: `trackcalfin-impl/build/rounds/final/{light,dark}` (all 30, contact sheets first), compared
with `build/rounds/00-before/*` and the two reference boards. Code read for Phase 9 only:
`lib/features/common/widgets.dart`, `lib/app/theme.dart`, plus call sites the shots pointed to.
Measured on the 2× PNGs (px ÷ 2 = dp). Every screen already passed its own review (01–06), so
this pass judges the app as one product and lists only what's still visible at that level.

## App-wide scores

| Category | Light | Dark | Notes |
|---|---|---|---|
| Hierarchy | 9.0 | 9.0 | One hero per screen (date + Vibe, Today's pick, the 650 on hand, the 44 amount). Large title → section title → group header → card title reads the same on every screen |
| Typography | 8.5 | 8.5 | Inter, tabular figures and smaller units everywhere. The first paragraph of the app (Vibe insight) still ends on a one-word line |
| Spacing | 8.5 | 8.5 | 8 / 12 / 16 / 24 / 28 rhythm holds across tabs, pushed screens and sheets |
| Alignment | 9.0 | 9.0 | x = 16 / 32 / 358 hold on all 30 shots, sheets at x = 20 |
| Color | 9.0 | 8.5 | Accent only on action and selection, one status hue per row. In dark, the L 52 mint buttons and the ⊕ are the brightest objects. Correct, but a touch loud (as in review 01) |
| Contrast | 9.0 | 9.0 | |
| Consistency | 8.5 | 8.5 | One container, one chip system, one header system. Left over: money placement in Inbox vs. Ledger/Review, Vibe "Other spend 100" vs. two red rows |
| Density | 8.5 | 8.5 | Inbox (Migros row 106 dp), one-row Ledger day cards, the tall Quick check card |
| Usability | 8.5 | 8.5 | The post-cook state of Today's pick (27) contradicts itself, and the Review loading state has no way back |
| Polish | 8.0 | 8.0 | The app is static: no number or label crossfades, default sheet timing. Content is sliced between the pill and ⊕ |
| **Overall** | **8.7** | **8.6** | Projected after the MUSTs: ≈ 8.9 / 8.8. After SHOULD 6: polish 9 |

**Verdict:** intentional, coherent and calm. It reads as one designed product, not AI-generic.
It's refined, but not yet premium, because nothing moves when a value changes and one hot path
(cook → after) shows a contradictory state.

## Before → after

Before, this was Material 3 with defaults: mint-tinted hero cards, green uppercase tracked
labels, three gauge rings, a saturated blue chart block, four action buttons on Buy, and a dark
mode that was green-black with mint on every surface (app average 5.0, dark 4.5). Now there's a
warm neutral canvas with white rounded surfaces, a real large title on every tab, Inter with
tabular figures and small units, status shown once (icon, word and one hue), a chart that
highlights only today, and a neutral dark mode that mirrors light token for token. It takes the
references' discipline (a big number with a grey qualifier, sentence-case section titles with
right-aligned meta, one highlighted bar) and none of their color-blocked cards or pastel fills.

## Remaining fixes (by impact)

### MUST
1. **Today's pick after cooking (27, Cook).** Right after "I cooked this", the hero shows
   "Missing Chicken breast", a stepper at **3 / max 0** and the same primary "I cooked this". It
   looks like the cook failed. Cause: `_TodayPickCard` reads `out.recipe`, a snapshot taken
   when the pick was planned, so `lastCookedAt` never updates, while the stock is live. In
   `lib/features/cook/cook_screen.dart`, resolve the recipe live
   (`ref.watch(recipesProvider).value?.firstWhereOrNull((x) => x.id == r.id) ?? r`) for
   `cookedToday`. Cooked state: `AppTheme.tonalButton` at L 52 with `check_rounded` +
   "Cooked · again?", and no feasibility status label. In every state, set
   `PortionStepper.hint = null` when `maxPortionsNow == 0` (the Missing label already says it).
   **Guardian: functional.**
2. **Vibe insight widow (01; behind 20–23 and 26).** "New week, clean slate: €69 to plan" /
   "with." is the first paragraph a user reads. In `_VibeHero` (`dashboard_screen.dart`
   ≈ l. 141), use `Text(vibe.insight…)` → `NoWidowText(vibe.insight, maxLines: 3, style: …)`.
   Expected: "New week, clean slate: €69 to" / "plan with."
3. **Full-screen spinner on Review load.** `review_screen.dart:159` returns
   `Scaffold(body: Center(child: CircularProgressIndicator()))`. It's the last one in
   `lib/features`, and it has no app bar, so there's no way back while it loads. Replace it with
   `Scaffold(appBar: const PageBar(), body: AppSkeleton(child: ListView(padding: (16, 8, 16, 0),
   children: [SkeletonLine(width: 120), 12, SkeletonBlock(height: 72, radius: 20), 24,
   SkeletonBlock(height: 160, radius: 20)])))`.
4. **Tab labels at 1.3×** (`lib/app/floating_nav.dart`, the label `Text`). "Dashboard" is
   57.5 dp at 1.0× in a 69 dp slot, so at 1.3× it's ≈ 75 dp and gets fade-clipped. Wrap the
   label in `MediaQuery.withClampedTextScaling(maxScaleFactor: 1.15)` (66 dp fits). iOS tab
   bars don't scale their labels either. This is review 01 item 15, still open.
5. **Vibe sheet contradicts the Dashboard (26 vs 02).** The sheet shows "Other spend pace 100"
   while Eating out and Entertainment show a red ⚠ over pace. The score is the aggregate
   (€34 of €190). In the `names` map of `_explainVibe`, rename the row to
   "Other spend, all categories". (A product call for later: score the worst category instead.)

### SHOULD
6. **Motion that's specced but missing (§9).** There's no `AnimatedSwitcher` anywhere in
   `lib`, and `AppMotion.sheetIn/sheetOut` are unused by all 10 `showModalBottomSheet` calls.
   Add `showAppSheet()` to `widgets.dart` with
   `sheetAnimationStyle: AnimationStyle(duration: AppMotion.sheetIn, reverseDuration: AppMotion.sheetOut)`.
   Wrap the `Metric` / `valueSpan` values, the Today and Food spend amounts, and the cook button
   label in `AnimatedSwitcher(duration: reduce ? Duration.zero : AppMotion.short)` with a fade
   only, keyed by the string.
7. **Inbox money placement (11).** Inbox puts the amount in the title ("Migros Zürich ·
   €24.74 (CHF 23.10)", a 106 dp row), while the Ledger and Review set it as a trailing value.
   In `inbox_screen.dart`, the title is the merchant and the trailing slot holds `€24.74`
   (`nums.body` w600) over `CHF 23.10` (`bodySmall` secondary), right-aligned, before the
   chevron. Expected: both rows 2 lines, ≈ 66 dp.
8. **Bottom scroll edge.** Content is sliced in the 13 dp gap between the pill and the ⊕ ("€1"
   in 01, "Missing Salmon fillet" in 07, "Diet" in 14). In `floating_nav.dart`, put an
   `IgnorePointer` gradient behind the pill and ⊕: from pill top − 24 to the screen bottom, the
   canvas color at alpha 0 → 0.85 (pill center) → 0.95. Same in dark.
9. **`Metric` captions at 1.3×.** "of 140 g protein · 34%" is 135 dp at 1.0× in a 151 dp
   column, so it wraps at 1.3× and can strand the " · ". Route the label through
   `separatedText` when it contains " · ".
10. **Raw error snackbar.** `cook_actions.dart:39` shows `SnackBar(Text('Could not log: $e'))`.
    Use `showInfo` with "Couldn't log this. Nothing was saved." and `$e` on the 13 detail line
    (add `detail` to `showInfo`).

## Phase 9 from code (no shots)
- **Reduced motion**: honored in RingGauge, PaceBar, WeekBars, AppSkeleton, AppSegmented and the
  pantry `AnimatedSize`. Page transitions (Cupertino / FadeForwards), NoSplash, the 280 nav
  indicator and the 120 ⊕ press are in place. Missing: crossfades and sheet timing (SHOULD 6).
- **Semantics**: the ring, PaceBar and per-bar WeekBars have labels, and the Today columns are
  merged. `header: true` is set on TabHeader, SectionCard, SectionTitle and GroupHeader;
  PageBar gets it from `AppBar`. Pass.
- **Text scale**: NoWidowText, SeparatedText and AppRow re-measure with the `TextScaler`, and
  Quick check stacks above 1.15×. The open items are MUST 4 and SHOULD 9. The 1.3× shot (28)
  and the empty and loading shots (29–31) weren't delivered, so "no overflow at 1.3×" and the
  empty and loading visuals can't be signed off yet.
- **States**: aside from MUST 3, spinners are inline at 16, except the Inbox "processing" leading
  icon at 20 (§7.18 says 16).

**Sign-off**: after MUST 1–5, re-shoot 01, 26, 27 and the 28–31 extras in light and dark. I'll
then add the "after" column to `AUDIT.md`.
