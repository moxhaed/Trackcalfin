import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../common/widgets.dart';
import '../cook/cook_actions.dart';

Future<void> showAteSheet(BuildContext context, {bool quickAddFirst = false}) => showModalBottomSheet(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  builder: (_) => AteSheet(quickAddFirst: quickAddFirst),
);

/// Eat a prepped portion (1 tap) or log something else by hand.
class AteSheet extends ConsumerStatefulWidget {
  const AteSheet({super.key, this.quickAddFirst = false});
  final bool quickAddFirst;

  @override
  ConsumerState<AteSheet> createState() => _AteSheetState();
}

class _AteSheetState extends ConsumerState<AteSheet> {
  late bool _manual = widget.quickAddFirst;
  final _title = TextEditingController();
  final _kcal = TextEditingController();
  final _protein = TextEditingController();
  final _cost = TextEditingController();
  final _timer = LogTimer();

  @override
  void dispose() {
    for (final c in [_title, _kcal, _protein, _cost]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _logManual() async {
    final kcal = double.tryParse(_kcal.text.replaceAll(',', '.'));
    if (kcal == null) return;
    final protein = double.tryParse(_protein.text.replaceAll(',', '.')) ?? 0;
    final cost = ref.read(moneyProvider).parse(_cost.text) ?? 0;
    final cook = ref.read(cookServiceProvider);
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final id = await cook.quickAddMeal(
      title: _title.text.trim().isEmpty ? 'Meal' : _title.text.trim(),
      kcal: kcal,
      proteinG: protein,
      costMinor: cost,
    );
    celebrate();
    unawaited(ref.read(metricsServiceProvider).record('eat', _timer.elapsed));
    if (!mounted) return;
    final key = ref.read(dayClockProvider).dateKey(DateTime.now());
    nav.pop();
    showUndoOn(messenger, 'Logged ${kcal.round()} kcal', onUndo: () => cook.deleteMeal(key, id));
  }

  @override
  Widget build(BuildContext context) {
    final fridge = ref.watch(fridgeProvider).value ?? const [];
    final secondary = context.scheme.onSurfaceVariant;
    // The sheet pads 4 and the fridge rows add their own 16, so their text sits on the title's
    // x = 20. Everything else adds 16 itself.
    Widget inset(Widget child) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.x4),
      child: child,
    );
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpace.x1, 0, AppSpace.x1, AppSpace.x6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              inset(Semantics(header: true, child: Text('What did you eat?', style: context.text.headlineSmall))),
              const SizedBox(height: AppSpace.x4),
              if (!_manual) ...[
                if (fridge.isEmpty)
                  inset(
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpace.x4),
                      child: Text(
                        'Nothing prepped in the fridge.',
                        style: context.text.bodyMedium?.copyWith(color: secondary),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpace.x4),
                    child: Column(
                      children: [
                        for (final (i, s) in fridge.indexed) ...[
                          if (i > 0)
                            const Divider(height: 0.5, thickness: 0.5, indent: AppSpace.x4, endIndent: AppSpace.x4),
                          AppRow(
                            title: s.recipeTitle,
                            subtitle:
                                '${s.portionsRemaining} left · ${s.perPortion.kcal.round()} kcal · '
                                '${s.perPortion.proteinG.round()} g protein',
                            trailing: FilledButton.tonal(
                              style: AppTheme.tonalButton(context, small: true),
                              onPressed: () async {
                                final nav = Navigator.of(context);
                                final outer = nav.context;
                                nav.pop();
                                await eatFromFridge(outer, ref, s);
                              },
                              child: const Text('Eat 1'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                inset(
                  FilledButton.tonalIcon(
                    style: AppTheme.tonalButton(context),
                    onPressed: () => setState(() => _manual = true),
                    icon: const Icon(Icons.edit_note_rounded),
                    label: const Text('Something else'),
                  ),
                ),
              ] else
                inset(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _title,
                        autofocus: true,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(labelText: 'What was it?', hintText: 'Kebab, protein bar…'),
                      ),
                      const SizedBox(height: AppSpace.x3),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _kcal,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'kcal'),
                            ),
                          ),
                          const SizedBox(width: AppSpace.x2),
                          Expanded(
                            child: TextField(
                              controller: _protein,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Protein g'),
                            ),
                          ),
                          const SizedBox(width: AppSpace.x2),
                          Expanded(
                            child: TextField(
                              controller: _cost,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Cost',
                                prefixText: ref.watch(moneyProvider).symbol,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpace.x4),
                      FilledButton(style: AppTheme.largeButton, onPressed: _logManual, child: const Text('Log meal')),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
