import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/isar/collections/schemas.dart';
import '../buy/ingredient_sheet.dart';
import '../common/category_style.dart';
import '../common/format.dart';
import '../common/widgets.dart';

/// Swipe deck: right = still have it, left = out, "Adjust" = fix the amount.
class QuickCheckScreen extends ConsumerStatefulWidget {
  const QuickCheckScreen({super.key});

  @override
  ConsumerState<QuickCheckScreen> createState() => _QuickCheckScreenState();
}

class _QuickCheckScreenState extends ConsumerState<QuickCheckScreen> {
  /// The deck, taken once. It must not follow the pantry while the cards are swiped (each
  /// answer changes the pantry), so it is read a single time, as soon as the pantry has loaded.
  List<Ingredient>? _deck;
  int _i = 0;
  int _fixed = 0;
  final _timer = LogTimer();

  static const _cardRadius = 24.0;

  @override
  Widget build(BuildContext context) {
    // Opened cold (a route, or the weekly-recap notification), the pantry stream hasn't emitted
    // yet and the deck would be empty: wait for the first emission before taking it.
    final pantry = ref.watch(ingredientsProvider);
    if (_deck == null && pantry.hasValue) _deck = ref.read(quickCheckProvider);
    final deck = _deck;
    if (deck == null) {
      return Scaffold(
        appBar: const PageBar(title: 'Quick check'),
        body: pantry.hasError ? _error(context, pantry.error!) : _loading(context),
      );
    }
    final done = _i >= deck.length;
    return Scaffold(
      appBar: PageBar(title: done ? 'Quick check' : 'Quick check · ${_i + 1} / ${deck.length}'),
      body: done ? _done(context, deck.length) : _card(context, deck[_i]),
    );
  }

  Widget _error(BuildContext context, Object error) => ListView(
    padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.headerGap, AppSpace.screen, 0),
    children: [AppNotice(kind: NoticeKind.critical, message: "Couldn't load your pantry.", meta: '$error')],
  );

  /// The card in its real layout while the pantry loads, so nothing jumps when the deck arrives.
  Widget _loading(BuildContext context) {
    return AppSkeleton(
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.headerGap, AppSpace.screen, AppSpace.x4),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_cardRadius)),
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SkeletonBlock(width: 64, height: 64, radius: 32),
                        const SizedBox(height: AppSpace.x6),
                        SkeletonLine(width: 200, style: context.text.headlineMedium),
                        const SizedBox(height: AppSpace.x2),
                        SkeletonLine(width: 150, style: context.text.bodyLarge),
                        const SizedBox(height: AppSpace.x6),
                        SkeletonLine(width: 220, style: context.text.bodySmall),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.screen, 0, AppSpace.screen, AppSpace.x4),
              child: Row(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) const SizedBox(width: AppSpace.x2),
                    const Expanded(child: SkeletonBlock(height: 44, radius: 22)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _done(BuildContext context, int total) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.x6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_rounded, size: 48, color: context.colors.good),
            const SizedBox(height: AppSpace.x4),
            Text(
              total == 0 ? 'Nothing to check' : 'Pantry verified',
              style: context.text.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpace.x2),
            Text(
              total == 0
                  ? 'Every item was confirmed recently.'
                  : '$total items checked, $_fixed corrected, in ${_timer.elapsed.inSeconds} s.',
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(color: context.scheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpace.x6),
            FilledButton(
              // Opened cold (a notification) there's no page to pop to: go to the Dashboard.
              onPressed: () => Navigator.of(context).canPop() ? Navigator.of(context).pop() : context.go('/'),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _answer(Ingredient ing, bool have) async {
    final pantry = ref.read(pantryServiceProvider);
    if (have) {
      await pantry.verify(ing.id);
    } else {
      await pantry.markOut(ing.id);
      _fixed++;
    }
    tick();
    setState(() => _i++);
    if (_i >= _deck!.length) unawaited(ref.read(metricsServiceProvider).record('quick_check', _timer.elapsed));
  }

  Widget _card(BuildContext context, Ingredient ing) {
    final c = context.colors;
    final secondary = context.scheme.onSurfaceVariant;
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.headerGap, AppSpace.screen, AppSpace.x4),
            child: Dismissible(
              key: ValueKey('qc-${ing.id}'),
              onDismissed: (d) => _answer(ing, d == DismissDirection.startToEnd),
              background: _swipeBg(
                context,
                c.good,
                c.goodInk,
                Icons.check_rounded,
                'Still have it',
                Alignment.centerLeft,
              ),
              secondaryBackground: _swipeBg(
                context,
                c.critical,
                c.criticalInk,
                Icons.close_rounded,
                "It's gone",
                Alignment.centerRight,
              ),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_cardRadius)),
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GlyphCircle(ingredientIcon(ing.category), size: 64, iconSize: 32),
                        const SizedBox(height: AppSpace.x6),
                        Center(
                          child: NoWidowText(
                            'Still have ${ing.name.toLowerCase()}?',
                            style: context.text.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: AppSpace.x2),
                        Text(
                          'The app thinks ~${qty(ing.qtyOnHand, ing.baseUnit)}',
                          style: context.text.bodyLarge?.copyWith(color: secondary),
                          textAlign: TextAlign.center,
                        ),
                        if (ing.lastVerifiedAt == null) ...[
                          const SizedBox(height: AppSpace.x3),
                          StatusPill(
                            label: 'Not checked in a while',
                            color: secondary,
                            ink: secondary,
                            icon: Icons.history_rounded,
                          ),
                        ],
                        const SizedBox(height: AppSpace.x6),
                        Text(
                          'Swipe right if yes, left if it\'s gone',
                          style: context.text.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.screen, 0, AppSpace.screen, AppSpace.x4),
            child: _actions(ing),
          ),
        ),
      ],
    );
  }

  /// Gone, Adjust and Yes side by side; when large text leaves them too narrow to hold a label
  /// in one piece, Yes (the commit) goes full width under the other two.
  Widget _actions(Ingredient ing) {
    final gone = FilledButton.tonalIcon(
      style: AppTheme.tonalButton(context),
      onPressed: () => _answer(ing, false),
      icon: const Icon(Icons.close_rounded),
      label: const Text('Gone'),
    );
    final adjust = FilledButton.tonalIcon(
      style: AppTheme.tonalButton(context),
      onPressed: () async {
        await showIngredientSheet(context, ingredient: ing);
        _fixed++;
        setState(() => _i++);
      },
      icon: const Icon(Icons.tune_rounded),
      label: const Text('Adjust'),
    );
    final yes = FilledButton.icon(
      onPressed: () => _answer(ing, true),
      icon: const Icon(Icons.check_rounded),
      label: const Text('Yes'),
    );
    if (MediaQuery.textScalerOf(context).scale(1) > 1.15) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: gone),
              const SizedBox(width: AppSpace.x2),
              Expanded(child: adjust),
            ],
          ),
          const SizedBox(height: AppSpace.x2),
          yes,
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: gone),
        const SizedBox(width: AppSpace.x2),
        Expanded(child: adjust),
        const SizedBox(width: AppSpace.x2),
        Expanded(child: yes),
      ],
    );
  }

  /// What a swipe will do, in the status ink on a 14 % wash of its color.
  Widget _swipeBg(BuildContext context, Color tint, Color ink, IconData icon, String label, Alignment align) =>
      Container(
        alignment: align,
        padding: const EdgeInsets.symmetric(horizontal: 28),
        decoration: BoxDecoration(
          color: tint.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(_cardRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: ink, size: 32),
            const SizedBox(height: AppSpace.x1),
            Text(label, style: context.text.labelLarge?.copyWith(color: ink)),
          ],
        ),
      );
}
