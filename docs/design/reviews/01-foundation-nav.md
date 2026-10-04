# Review 01: Phase 0 + 1 (foundations, navigation, headers)

Reviewed: `build/rounds/p0/*` and `p1/*` (light and dark), `p1-all/contact-light.png` (all 27
shots), and in the worktree `lib/app/theme.dart`, `lib/app/floating_nav.dart` and
`lib/features/common/widgets.dart` (TabHeader, PageBar, HeaderButton). Judged against
`DESIGN_SYSTEM.md`. The screenshots decide; the code only checked token fidelity.

## Summary

This is a big step up from 00-before (app average 5.0). The canvas is warm and neutral, the
surfaces are white, the type is Inter, every tab root has a real large title, and the
navigation is calm with the accent spent only on selection and ⊕. No mint remains on any
surface. Token fidelity in `theme.dart` is excellent: every hex, the type scale, radii, motion,
inputs, chips, switch, sheet, snackbar and badge match the spec. The nav and header set
**narrowly misses** its polish bar because of three alignment and spacing defects in the
header system. They're cheap to fix.

## (a) Scores

### Nav + page headers as a component set (shots 01, 02, 04, 07, 09, 11, 14, 20, 27)

| Category | Light | Dark | Notes |
|---|---|---|---|
| Hierarchy | 8.5 | 8.5 | The 30/36 large titles give every tab a title moment, and the pill stays subordinate. ⊕ is the loudest object, which is correct for the global action |
| Typography | 9.0 | 9.0 | Title 30 w700, compact title 17 w600, tab labels 11 w500/w600, header button 14 w600, all as spec |
| Spacing | 7.5 | 7.5 | Header → first content is **0** (Cook), **4** (Dashboard) or **6** (Buy) instead of 8 everywhere |
| Alignment | 7.5 | 7.5 | The "Quick check · 2" capsule ends at x = 382 while the cards end at 374 (clearly visible in 01 and 02) |
| Color | 9.0 | 8.5 | Neutral indicator with accent icon and label is right. In dark, the 60 dp mint ⊕ is a touch loud but correct |
| Contrast | 9.0 | 9.0 | Unselected labels ≈ 5.8:1. Badges: white on `#CC3A31` (light) and `#2A0B07` on `#EE7468` (dark) as spec |
| Consistency | 8.5 | 8.5 | TabHeader on all 4 roots, PageBar on every pushed screen, the same capsule and icon-button language |
| Density | 8.5 | 8.5 | The 60 header and 60 pill are compact, and content starts higher than before |
| Usability | 9.0 | 9.0 | 44+ targets, tooltips kept, selection haptic, ⊕ press scale, the snackbar clears the pill |
| Polish | 8.0 | 8.0 | Blur, shadows and border are good. It's held back by the misaligned capsule, the inconsistent header gap, and the hard slice when content scrolls under the header (02: a white card cut by an invisible edge) |
| **Overall** | **8.3** | **8.3** | After the 3 must-fixes, the projection is 8.7 (spacing 8.5, alignment 9, polish 8.5–9) |

### App-wide (all 27 shots)

| | Light | Dark | Why not higher yet |
|---|---|---|---|
| Typography | **7.0** | **7.0** | Inter and the scale are in, but the uppercase tracked `SectionCard` / `_Header` / `_Label` labels remain everywhere. Metric values are still proportional `titleMedium`, not `nums`. The snackbar copy wraps with an orphan |
| Color | **7.5** | **7.5** | No mint, and the data hues and status ladder are correct. Remaining accent misuse: green UPPERCASE Settings section labels, green glyph icons in ledger rows, solid-green toggle chips (Equipment), and tinted "on pace" / "AI estimate" pills |

## (b) Verdict against the P0 + P1 definition of done

| Criterion | Result |
|---|---|
| Typography ≥ 7 app-wide | ✅ 7.0 (light and dark) |
| Color ≥ 7 app-wide | ✅ 7.5 |
| Nav/headers ≥ 8.5 on hierarchy | ✅ 8.5 |
| …consistency | ✅ 8.5 |
| …polish | ❌ **8.0** |
| No mint left on canvas, cards, chips or nav | ✅ |
| "→" renders in shot 13 | ✅ "CHF 23.10 → €24.74" |
| Snackbar above the pill (27) | ✅ 13 dp clear in both themes. The dark snackbar uses an inverse light surface as spec |

**Not yet. It's a conditional pass:** fix the three MUST-FIX-NOW items, re-shoot 01, 02, 04, 07,
10 and 11 in light and dark, and P0 + P1 can be committed. A full Director re-review isn't
needed if the verification notes below hold.

## Rulings on the declared deviations

| # | Deviation | Ruling |
|---|---|---|
| 1 | `FilledButton.tonal` labels in ink (theme can't split tonal from filled) | **Accept as interim.** In P2, add `AppTheme.tonalButton` (`backgroundColor: AppColors.fill`, `foregroundColor`/`iconColor: primary`, `labelLarge`, capsule, M 44 / S 36). Every tonal button touched in P3–P8 must use it ("Eat 1", "Add an item", "Try again", "Add key"). OutlinedButton themed as tonal is fine |
| 2 | One chip theme (selected = primary + check) | **Accept as interim.** P2 delivers the four variants of §7.8: *choice* (no checkmark: `showCheckmark: false`), *toggle* (`primaryContainer` bg, `onPrimaryContainer` w600 label, check 16), *action* (icon in `primary`), *input*. The Ledger "All" check goes in P5, the Equipment and Diet toggles in P7 |
| 3 | `bodySmall` defaults to `textSecondary` | **Accept.** It matches the spec's meta and caption usage. Where a 13 sp text must be ink, override explicitly |
| 4 | Floating label 13 / 0.75 | **Accept.** It renders at 13 as intended |
| 5 | `highlightColor = fill` | **Ruling: `fillStrong`.** At 6% the pressed state is barely visible on white. `DESIGN_SYSTEM.md` §4.5 and §12 are now consistent. Implement in P2 (one line). Not blocking |
| 6 | Cold-opened pushed screens keep a 16 title margin | **Accept.** That's correct when there's no back button |
| 7 | Deferred: dashboard top padding, green uppercase Settings `_Section`, uppercase `SectionCard` | **Partly accepted.** The dashboard top padding moves to **MUST-FIX-NOW** (it's part of the header system). `SectionCard` casing → P2 (with the Guardian's finder updates). The Settings `_Section` → **P2** (adopt `GroupHeader`: sentence case, `titleSmall`, `textSecondary`), not P7, because it's an accent misuse visible on a tab root |

## (c) Fix list for the Implementer

### MUST-FIX-NOW (blocks the P0 + P1 commit)

1. **Header capsule edge.** An action with a visible shape ends flush with the content at
   x = screen − 16. Give `HeaderButton` its own trailing `Padding(right: AppSpace.x2)` (or pass
   `actionsPadding: EdgeInsets.only(right: 16)` from `TabHeader` when the last action is a
   `HeaderButton`). Icon-only actions keep the current 8. *Verify*: in 01 and 02 @2× the capsule's
   right edge is at px 748, the same as the cards. (DESIGN_SYSTEM §7.5 "Header edges".)
2. **Header → content = 8 on every tab root.** The first content block's top sits at
   status + 60 + 8 = **115 dp (230 px @2×)**. Dashboard `ListView` top padding 4 → 8, Cook ask-bar
   top 0 → 8, Buy action-row top 6 → 8. Settings' first group header also starts at 8 (not 24).
   *Verify*: in 01, 04, 06, 07 and 14 the first block's top is at px 230 ± 1.
3. **Scrolled-under separation.** When content scrolls beneath `TabHeader` or `PageBar`, show a
   0.5 px `AppColors.separator` line at the header's bottom edge. The simplest route is
   `scrolledUnderElevation: 0.5` with `shadowColor: Colors.black.withValues(alpha: dark ? 0.6 : 0.3)`
   on both bars, or a bottom hairline driven by the `scrolledUnder` state. Show nothing at rest.
   *Verify*: in 02, 05 and 10 a fine line separates the header from the sliced card; in 01, 04 and
   07 there's no line.

### DEFER: Phase 2 (shared components)

4. `AppTheme.tonalButton` (ruling 1) and the four chip variants (ruling 2).
5. `highlightColor: AppColors.fillStrong` (ruling 5).
6. `SectionCard`: no `.toUpperCase()`, title `titleMedium` 17/22 w600 `onSurface`, title → content
   12. The Guardian updates the 🔵 finders. Settings `_Section`, pantry `_Header` and review `_Label`
   → `GroupHeader` (sentence case, `titleSmall`, `textSecondary`, x = 32).
7. `StatusPill` → status *label* (no container, icon 14 + `labelMedium` w600 in `goodInk` /
   `warningInk` / `criticalInk`). This removes the tinted "on pace" and "AI estimate" pills.
8. `Metric` values → `context.nums.medium` (tabular), captions `bodySmall`. This and item 6
   should lift app-wide typography to ≥ 8.
9. `AppSegmented` replaces the themed `SegmentedButton` (no check, no icons, sliding white
   thumb). It's visible in 04, 06 and 15.
10. Popup menu shadow: elevation 8 at black 50% is heavier than §6. Use black @ 12%, blur 24,
    y 8 (or elevation 3 with black @ 25%), light border none, dark 0.5 separator (already done).

### DEFER: Phases 3–9

11. **P3**: Dashboard content per SCREENS §1 (hero on the canvas, linear Today bars, two-line
    Other spend rows).
12. **P4**: the mic moves inside the ask field. The snackbar splits message and detail ("1 logged,
    2 in the fridge" / "51 g protein each"), which removes the orphan in 27. The Today's-pick
    eyebrow goes to sentence case.
13. **P5**: the Buy action row → header Add menu. Ledger glyph-circle icons → `textSecondary` (they're
    accent now, which is decorative green). Item-sheet nutrition → inset fill panel (it's
    currently a white card on a white sheet, so it has no edge).
14. **P7**: the Quick-check cold-start fix (shot 17 still shows "Nothing to check" under
    "Quick check · 2").
15. **P9**: tab labels at 1.3× text scale. "Dashboard" at 11 sp must not fade-clip. Clamp the
    pill labels' text scale to max 1.3 (`MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3)`
    on the label only). Verify with a text-scale shot.

## What's already right (keep it)
- `theme.dart` is an exact transcription of the token tables (ColorScheme light and dark,
  AppColors with all new fields and real `lerp`, AppNumbers, TextTheme with even leading,
  explicit component themes, `FadeForwards` / Cupertino transitions, NoSplash).
- The nav pill: 60 dp, surface @ 88% over blur 20, a 0.5 border, a two-layer shadow in light, a
  neutral sliding indicator, accent selection, selection haptic, and ⊕ with a 0.94 press scale
  and an accent-tinted shadow.
- `PageBar` back-button logic, `Semantics(header: true)` on titles, and the tooltips preserved.
