import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../platform/notifications.dart';
import '../capture/scan_flow.dart';
import '../common/format.dart';
import '../common/widgets.dart';

/// Cold start in about 3 minutes: goals, key, kitchen sweep, rhythm.
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
  int _portions = 3;
  int _pickMinute = 450;
  int _monthStart = 1;
  int _sweeps = 0;

  static const _pages = 5;

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
      _monthStart = p.monthStartDay.clamp(1, 31);
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
      p.monthStartDay = _monthStart;
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  for (var i = 0; i < _pages; i++)
                    Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: i <= _index ? context.scheme.primary : context.colors.track,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _page,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _index = i),
                children: [_welcome(context), _goals(context), _apiKey(context), _sweep(context), _rhythm(context)],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  if (_index > 0)
                    TextButton(
                      onPressed: () =>
                          _page.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () async {
                      if (_index == 1) await _saveGoals();
                      if (_index == 2 && _key.text.trim().isNotEmpty) {
                        await ref.read(secretStoreProvider).writeApiKey(_key.text.trim());
                        ref.invalidate(hasApiKeyProvider);
                        // Items already in the pantry get their macros while the user carries on.
                        unawaited(ref.read(nutritionServiceProvider).fillMissing());
                      }
                      _next();
                    },
                    child: Text(_index == _pages - 1 ? 'Start' : (_index == 0 ? 'Get started' : 'Next')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _page0(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String body,
    Widget? child,
  }) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      children: [
        Icon(icon, size: 44, color: context.scheme.primary),
        const SizedBox(height: 16),
        Text(title, style: context.text.headlineSmall),
        const SizedBox(height: 8),
        Text(body, style: context.text.bodyLarge?.copyWith(color: context.scheme.onSurfaceVariant)),
        if (child != null) ...[const SizedBox(height: 24), child],
      ],
    );
  }

  Widget _welcome(BuildContext context) => _page0(
    context,
    icon: Icons.kitchen_outlined,
    title: 'Your kitchen, on autopilot',
    body:
        'Snap receipts, cook from what you have, and see where the money and protein go. '
        'Every log takes about 3 seconds; the AI does the typing.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _Habit('After I put the groceries away, I snap the receipt.'),
        _Habit('After I close the fridge with my lunch box, I tap "Ate it".'),
        _Habit('While the coffee brews, I glance at today\'s pick.'),
      ],
    ),
  );

  Widget _goals(BuildContext context) => _page0(
    context,
    icon: Icons.flag_outlined,
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
        const SizedBox(height: 4),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('My month starts on'),
          subtitle: const Text('Paid on the 17th? Start your month then.'),
          trailing: Text(monthStartLabel(_monthStart), style: context.text.titleSmall),
          onTap: () async {
            final day = await showMonthStartPicker(context, current: _monthStart);
            if (day != null) setState(() => _monthStart = day);
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _kcal,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Daily calories', suffixText: 'kcal'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _protein,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Daily protein', suffixText: 'g'),
        ),
      ],
    ),
  );

  Widget _apiKey(BuildContext context) => _page0(
    context,
    icon: Icons.key_outlined,
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

  Widget _sweep(BuildContext context) => _page0(
    context,
    icon: Icons.photo_camera_outlined,
    title: 'Snap your kitchen',
    body:
        'Recipes only use what the app has seen, salt and oil included. Snap it all: the AI '
        'recognizes each product and what it usually costs. Got recent receipts? Scan them too. '
        'If something shows up twice, you get asked whether it is the same one before anything is counted.',
    child: Column(
      children: [
        for (final (label, icon, hint) in [
          ('Fridge', Icons.kitchen_outlined, 'pantry'),
          ('Freezer', Icons.ac_unit, 'pantry'),
          ('Cupboard', Icons.door_sliding_outlined, 'pantry'),
          ('Spices & oils', Icons.local_dining_outlined, 'pantry'),
          ('A receipt', Icons.receipt_long_outlined, 'receipt'),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              onPressed: () async {
                await startScan(context, ref, hint: hint);
                setState(() => _sweeps++);
              },
              icon: Icon(icon),
              label: Text(label),
            ),
          ),
        if (_sweeps > 0) Text('$_sweeps photo${_sweeps == 1 ? '' : 's'} queued', style: context.text.bodySmall),
      ],
    ),
  );

  Widget _rhythm(BuildContext context) {
    String hm(int m) => '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';
    return _page0(
      context,
      icon: Icons.schedule,
      title: 'Your rhythm',
      body: 'One recipe idea each morning, and a meal-time nudge only when prepped food is waiting.',
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Daily pick at'),
            trailing: Text(hm(_pickMinute), style: context.text.titleMedium),
            onTap: () async {
              final t = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(hour: _pickMinute ~/ 60, minute: _pickMinute % 60),
              );
              if (t != null) setState(() => _pickMinute = t.hour * 60 + t.minute);
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Portions I usually cook'),
            subtitle: const Text('More than 1 means meal prep'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: _portions > 1 ? () => setState(() => _portions--) : null,
                  icon: const Icon(Icons.remove),
                ),
                Text('$_portions', style: context.text.titleMedium),
                IconButton(onPressed: () => setState(() => _portions++), icon: const Icon(Icons.add)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Habit extends StatelessWidget {
  const _Habit(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_outline, size: 20, color: context.scheme.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: context.text.bodyMedium)),
      ],
    ),
  );
}
