import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../platform/notifications.dart';
import '../capture/scan_flow.dart';
import '../common/widgets.dart';

const defaultStaples = [
  'Salt',
  'Black pepper',
  'Olive oil',
  'Vegetable oil',
  'Sugar',
  'Flour',
  'Garlic powder',
  'Paprika',
  'Cumin',
  'Chili flakes',
  'Oregano',
  'Soy sauce',
  'Vinegar',
  'Stock cubes',
  'Butter',
];

/// Cold start in about 3 minutes: goals, staples, key, pantry sweep, rhythm.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _page = PageController();
  int _index = 0;
  final _budget = TextEditingController(text: '300');
  final _kcal = TextEditingController(text: '2200');
  final _protein = TextEditingController(text: '140');
  final _key = TextEditingController();
  final Set<String> _staples = {...defaultStaples.take(10)};
  int _portions = 3;
  int _pickMinute = 450;
  int _sweeps = 0;

  static const _pages = 6;

  @override
  void initState() {
    super.initState();
    final p = ref.read(profileProvider).value;
    if (p != null && p.onboardingDone) {
      _budget.text = (p.monthlyFoodBudgetMinor / 100).round().toString();
      _kcal.text = p.dailyKcalTarget.round().toString();
      _protein.text = p.dailyProteinTargetG.round().toString();
      _portions = p.defaultPortions;
      _pickMinute = p.dailyPickMinuteOfDay;
    }
  }

  @override
  void dispose() {
    for (final c in [_budget, _kcal, _protein, _key]) {
      c.dispose();
    }
    _page.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < _pages - 1) {
      _page.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
    } else {
      _finish();
    }
  }

  Future<void> _saveGoals() async {
    final money = ref.read(moneyProvider);
    await ref.read(profileServiceProvider).update((p) {
      p.monthlyFoodBudgetMinor = money.parse(_budget.text) ?? p.monthlyFoodBudgetMinor;
      p.dailyKcalTarget = double.tryParse(_kcal.text) ?? p.dailyKcalTarget;
      p.dailyProteinTargetG = double.tryParse(_protein.text) ?? p.dailyProteinTargetG;
    });
  }

  Future<void> _finish() async {
    await ref.read(profileServiceProvider).update((p) {
      p.defaultPortions = _portions;
      p.dailyPickMinuteOfDay = _pickMinute;
      p.onboardingDone = true;
    });
    await Notifications.instance.requestPermission();
    unawaited(ref.read(todayPickProvider.notifier).refresh());
    if (mounted) context.go('/cook');
  }

  @override
  Widget build(BuildContext context) {
    final track = context.colors.track;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Six segments, 4 tall, 4 apart, on the 16 margins.
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.x3, AppSpace.screen, 0),
              child: Semantics(
                label: 'Step ${_index + 1} of $_pages',
                excludeSemantics: true,
                child: Row(
                  children: [
                    for (var i = 0; i < _pages; i++) ...[
                      if (i > 0) const SizedBox(width: AppSpace.x1),
                      Expanded(
                        child: AnimatedContainer(
                          duration: AppMotion.short,
                          curve: AppMotion.standard,
                          height: 4,
                          decoration: BoxDecoration(
                            color: i <= _index ? context.scheme.primary : track,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _page,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  _welcome(context),
                  _goals(context),
                  _staplesPage(context),
                  _apiKey(context),
                  _sweep(context),
                  _rhythm(context),
                ],
              ),
            ),
            // The commit is full width. Later pages add a Back text button on its left.
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.x2, AppSpace.screen, AppSpace.x4),
              child: Row(
                children: [
                  if (_index > 0) ...[
                    // Pulled back by the button's own 12 padding, so "Back" sits on the margin.
                    Transform.translate(
                      offset: const Offset(-AppSpace.x3, 0),
                      child: TextButton(
                        onPressed: () =>
                            _page.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: AppSpace.x3),
                  ],
                  Expanded(
                    child: FilledButton(
                      style: AppTheme.largeButton,
                      onPressed: () async {
                        if (_index == 1) await _saveGoals();
                        if (_index == 2) await ref.read(pantryServiceProvider).ensureStaples(_staples.toList());
                        if (_index == 3 && _key.text.trim().isNotEmpty) {
                          await ref.read(secretStoreProvider).writeApiKey(_key.text.trim());
                          ref.invalidate(hasApiKeyProvider);
                          // Staples from the previous page get their macros while the user carries on.
                          unawaited(ref.read(nutritionServiceProvider).fillMissing());
                        }
                        _next();
                      },
                      child: Text(_index == _pages - 1 ? 'Start' : (_index == 0 ? 'Get started' : 'Next')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// One page: the mark (welcome) or a 28 accent icon at the top left, a 30/36 title, a
  /// secondary body, then the page's content. Everything sits on the 16 margin, left-aligned.
  /// [iconInk] is where the glyph's ink starts on its 24 grid (the flag's pole is at 5), so the
  /// icon shifts left by that much, scaled to 28, and its edge lands on the margin.
  Widget _pageOf(
    BuildContext context, {
    IconData? icon,
    double iconInk = 0,
    required String title,
    required String body,
    Widget? child,
  }) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.x10, AppSpace.screen, AppSpace.x6),
      children: [
        // A bare icon in a ListView would stretch and center itself: pin it to the start.
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: icon == null
              ? const _BrandMark()
              : Transform.translate(
                  offset: Offset(-iconInk * 28 / 24, 0),
                  child: Icon(icon, size: 28, color: context.scheme.primary),
                ),
        ),
        const SizedBox(height: AppSpace.x6),
        Semantics(header: true, child: NoWidowText(title, style: context.text.headlineLarge)),
        const SizedBox(height: AppSpace.x3),
        NoWidowText(body, style: context.text.bodyLarge?.copyWith(color: context.scheme.onSurfaceVariant)),
        if (child != null) ...[const SizedBox(height: AppSpace.x8), child],
      ],
    );
  }

  Widget _welcome(BuildContext context) => _pageOf(
    context,
    title: 'Your kitchen, on autopilot',
    body:
        'Snap receipts, cook from what you have, and see where the money and protein go. '
        'Every log takes about 3 seconds; the AI does the typing.',
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Habit('After I put the groceries away, I snap the receipt.'),
        _Habit('After I close the fridge with my lunch box, I tap "Ate it".'),
        _Habit('While the coffee brews, I glance at today\'s pick.'),
      ],
    ),
  );

  Widget _goals(BuildContext context) => _pageOf(
    context,
    icon: Icons.flag_outlined,
    iconInk: 5,
    title: 'Your goals',
    body: 'These drive the Vibe Check. Change them any time in Settings.',
    child: Column(
      children: [
        TextField(
          controller: _budget,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Monthly food budget',
            prefixText: '${ref.watch(moneyProvider).symbol} ',
          ),
        ),
        const SizedBox(height: AppSpace.x3),
        TextField(
          controller: _kcal,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Daily calories', suffixText: 'kcal'),
        ),
        const SizedBox(height: AppSpace.x3),
        TextField(
          controller: _protein,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Daily protein', suffixText: 'g'),
        ),
      ],
    ),
  );

  Widget _staplesPage(BuildContext context) => _pageOf(
    context,
    icon: Icons.inventory_2_outlined,
    iconInk: 2,
    title: 'Staples you always have',
    body: 'These are assumed available and never counted, so the app never nags you about salt.',
    child: Wrap(
      spacing: AppSpace.x2,
      children: [
        for (final s in defaultStaples)
          AppToggleChip(
            label: s,
            selected: _staples.contains(s),
            onSelected: (v) => setState(() => v ? _staples.add(s) : _staples.remove(s)),
          ),
      ],
    ),
  );

  Widget _apiKey(BuildContext context) => _pageOf(
    context,
    icon: Icons.key_outlined,
    iconInk: 1,
    title: 'Connect Gemini',
    body:
        'Receipt reading and recipes use your own Gemini API key (from Google AI Studio). '
        'It stays in the device keystore. You can skip this and add it later.',
    child: TextField(
      controller: _key,
      obscureText: true,
      decoration: const InputDecoration(labelText: 'API key (optional)'),
    ),
  );

  Widget _sweep(BuildContext context) => _pageOf(
    context,
    icon: Icons.photo_camera_outlined,
    iconInk: 2,
    title: 'Snap your kitchen',
    body:
        'Three photos (fridge, freezer, cupboard) fill your pantry in one go. '
        'You review them in the Inbox. Skip if you prefer to start with your next receipt.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppGroup(
          separatorIndent: AppGroup.indentIcon,
          children: [
            for (final (label, icon) in [
              ('Fridge', Icons.kitchen_outlined),
              ('Freezer', Icons.ac_unit_rounded),
              ('Cupboard', Icons.door_sliding_outlined),
            ])
              AppRow(
                leading: Icon(icon, size: 20),
                title: label,
                chevron: true,
                onTap: () async {
                  await startScan(context, ref, hint: 'pantry');
                  if (mounted) setState(() => _sweeps++);
                },
              ),
          ],
        ),
        if (_sweeps > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.x4, AppSpace.x2, AppSpace.x4, 0),
            child: Text('$_sweeps photo${_sweeps == 1 ? '' : 's'} queued', style: context.text.bodySmall),
          ),
      ],
    ),
  );

  Widget _rhythm(BuildContext context) {
    String hm(int m) => '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';
    return _pageOf(
      context,
      icon: Icons.schedule_rounded,
      iconInk: 2,
      title: 'Your rhythm',
      body: 'One recipe idea each morning, and a meal-time nudge only when prepped food is waiting.',
      child: AppGroup(
        children: [
          AppRow(
            title: 'Daily pick at',
            value: hm(_pickMinute),
            chevron: true,
            onTap: () async {
              final t = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(hour: _pickMinute ~/ 60, minute: _pickMinute % 60),
              );
              if (t != null) setState(() => _pickMinute = t.hour * 60 + t.minute);
            },
          ),
          AppRow(
            title: 'Portions I usually cook',
            subtitle: 'More than 1 means meal prep',
            trailing: PortionStepper(value: _portions, onChanged: (v) => setState(() => _portions = v)),
          ),
        ],
      ),
    );
  }
}

/// A habit line: an accent check and a sentence, 12 apart.
class _Habit extends StatelessWidget {
  const _Habit(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpace.x3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The 20 icon sits on the first 21-high text line.
        Icon(Icons.check_circle_outline_rounded, size: 20, color: context.scheme.primary),
        const SizedBox(width: AppSpace.x3),
        Expanded(child: NoWidowText(text, style: context.text.bodyMedium)),
      ],
    ),
  );
}

/// The app mark at 72 × 72 (radius 18): a port of `assets/branding/app_icon.svg` (a 1024 box),
/// the one brand moment of the app. It stays the same in dark mode, because it's the icon.
class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: 'Trackcalfin',
    child: const SizedBox.square(dimension: 72, child: CustomPaint(painter: _BrandMarkPainter())),
  );
}

class _BrandMarkPainter extends CustomPainter {
  const _BrandMarkPainter();

  // The icon's own palette (not UI chrome): field, halo, leaves, vein, bowl, rim.
  static const _halo = Color(0xFF347F5E);
  static const _leaf = Color(0xFFA8E6C1);
  static const _leafSmall = Color(0xFF7FD3A4);
  static const _bowl = Color(0xFFF6F3EA);
  static const _rim = Color(0xFFE4DDCB);

  @override
  void paint(Canvas canvas, Size size) {
    Paint fill(Color c) => Paint()..color = c;
    Paint stroke(Color c, double w) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round;

    canvas
      ..clipRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(size.width / 4)))
      ..scale(size.width / 1024, size.height / 1024)
      // The field and its soft halo.
      ..drawRect(const Rect.fromLTWH(0, 0, 1024, 1024), fill(AppTheme.seed))
      ..drawCircle(const Offset(512, 512), 400, fill(_halo.withValues(alpha: 0.55)));

    // The big leaf with its vein, then the small leaf.
    final leaf = Path()
      ..moveTo(512, 486)
      ..cubicTo(402, 430, 386, 300, 470, 196)
      ..cubicTo(590, 262, 614, 392, 512, 486)
      ..close();
    final vein = Path()
      ..moveTo(512, 486)
      ..cubicTo(500, 400, 488, 320, 470, 240);
    final small = Path()
      ..moveTo(560, 470)
      ..cubicTo(610, 420, 690, 410, 760, 440)
      ..cubicTo(720, 510, 640, 530, 560, 470)
      ..close();
    canvas
      ..drawPath(leaf, fill(_leaf))
      ..drawPath(vein, stroke(AppTheme.seed, 16))
      ..drawPath(small, fill(_leafSmall));

    // The bowl, its foot and the line across it.
    final bowl = Path()
      ..moveTo(212, 520)
      ..lineTo(812, 520)
      ..cubicTo(812, 690, 678, 818, 512, 818)
      ..cubicTo(346, 818, 212, 690, 212, 520)
      ..close();
    canvas
      ..drawPath(bowl, fill(_bowl))
      ..drawRRect(RRect.fromLTRBR(402, 826, 622, 866, const Radius.circular(20)), fill(_bowl))
      ..drawLine(const Offset(300, 560), const Offset(724, 560), stroke(_rim, 18));
  }

  @override
  bool shouldRepaint(_BrandMarkPainter oldDelegate) => false;
}
