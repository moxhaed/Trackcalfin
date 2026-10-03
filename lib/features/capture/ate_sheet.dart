import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/enums.dart';
import '../../data/isar/collections/schemas.dart';
import '../../domain/costing.dart';
import '../../domain/nutrition.dart';
import '../common/format.dart';
import '../common/widgets.dart';
import '../cook/cook_actions.dart';

Future<void> showAteSheet(BuildContext context, {bool quickAddFirst = false}) => showModalBottomSheet(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  builder: (_) => AteSheet(quickAddFirst: quickAddFirst),
);

/// Eat a prepped portion or something from the pantry (1 tap), or log something else by hand.
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
  String _query = '';

  @override
  void dispose() {
    for (final c in [_title, _kcal, _protein, _cost]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Pantry items to eat from: what matches the search, use-soon items first.
  List<Ingredient> _pantry(List<Ingredient> all) {
    final now = DateTime.now();
    final q = _query.trim().toLowerCase();
    final items =
        all
            .where((i) => i.qtyOnHand > 0 && (q.isEmpty || i.name.toLowerCase().contains(q) || i.key.contains(q)))
            .toList()
          ..sort((a, b) {
            final da = ExpiryEstimator.daysLeft(a, now) ?? 999;
            final db = ExpiryEstimator.daysLeft(b, now) ?? 999;
            return da != db ? da.compareTo(db) : a.name.compareTo(b.name);
          });
    return items.take(q.isEmpty ? 4 : 6).toList();
  }

  /// One piece at once (a banana, a can); grams and ml ask how much.
  Future<void> _eatPantry(Ingredient ing) async {
    final amount = ing.baseUnit == BaseUnit.pc ? 1.0 : await _askAmount(ing);
    if (amount == null || !mounted) return;
    final cook = ref.read(cookServiceProvider);
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final id = await cook.eatFromPantry(ing.id, amount);
    if (id == null || !mounted) return;
    celebrate();
    unawaited(ref.read(metricsServiceProvider).record('eat', _timer.elapsed));
    final key = ref.read(dayClockProvider).dateKey(DateTime.now());
    nav.pop();
    final n = ing.needsNutrition ? null : NutritionEngine.nutrientsFor(ing, amount);
    final verb = ing.category == IngredientCategory.beverages ? 'Drank' : 'Ate';
    showUndoOn(
      messenger,
      '$verb ${ing.name} · ${qty(amount, ing.baseUnit)}',
      detail: n == null ? 'Its macros aren\'t known yet' : '${n.kcal.round()} kcal · ${n.proteinG.round()} g protein',
      onUndo: () => cook.deleteMeal(key, id),
    );
  }

  /// The dialog owns its text controller (see showTextPrompt for why).
  Future<double?> _askAmount(Ingredient ing) => showDialog<double>(
    context: context,
    builder: (_) => _AmountDialog(ing: ing),
  );

  Future<void> _logManual() async {
    final kcal = double.tryParse(_kcal.text.replaceAll(',', '.'));
    if (kcal == null) return;
    final protein = double.tryParse(_protein.text.replaceAll(',', '.')) ?? 0;
    final cost = ref.read(moneyProvider).parse(_cost.text) ?? 0;
    final cook = ref.read(cookServiceProvider);
    final metrics = ref.read(metricsServiceProvider);
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final id = await cook.quickAddMeal(
      title: _title.text.trim().isEmpty ? 'Meal' : _title.text.trim(),
      kcal: kcal,
      proteinG: protein,
      costMinor: cost,
    );
    celebrate();
    unawaited(metrics.record('eat', _timer.elapsed));
    if (!mounted) return;
    final key = ref.read(dayClockProvider).dateKey(DateTime.now());
    nav.pop();
    showUndoOn(messenger, 'Logged ${kcal.round()} kcal', onUndo: () => cook.deleteMeal(key, id));
  }

  @override
  Widget build(BuildContext context) {
    final fridge = ref.watch(fridgeProvider).value ?? const [];
    final all = ref.watch(ingredientsProvider).value ?? const <Ingredient>[];
    final stocked = all.any((i) => i.qtyOnHand > 0);
    final pantry = _pantry(all);
    final muted = context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('What did you eat?', style: context.text.titleLarge),
              const SizedBox(height: 8),
              if (!_manual) ...[
                if (fridge.isEmpty && !stocked)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('Nothing prepped in the fridge.', style: context.text.bodyMedium),
                  ),
                for (final s in fridge)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.kitchen_outlined),
                    title: Text(s.recipeTitle),
                    subtitle: Text(
                      '${s.portionsRemaining} left · ${s.perPortion.kcal.round()} kcal · '
                      '${s.perPortion.proteinG.round()} g protein',
                    ),
                    trailing: FilledButton.tonal(
                      onPressed: () async {
                        final nav = Navigator.of(context);
                        final outer = nav.context;
                        nav.pop();
                        await eatFromFridge(outer, ref, s);
                      },
                      child: const Text('Eat 1'),
                    ),
                  ),
                if (stocked) ...[
                  const SizedBox(height: 8),
                  Text('From the pantry', style: context.text.titleSmall),
                  const SizedBox(height: 6),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Banana, yogurt, a can of cola…',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                  for (final ing in pantry)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(ing.name),
                      subtitle: Text('${qty(ing.qtyOnHand, ing.baseUnit)} on hand', style: muted),
                      trailing: FilledButton.tonal(
                        onPressed: () => _eatPantry(ing),
                        child: Text(ing.baseUnit == BaseUnit.pc ? 'Eat 1' : 'Eat…'),
                      ),
                    ),
                  if (pantry.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('Nothing in the pantry by that name.', style: muted),
                    ),
                ],
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _manual = true),
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Something else'),
                ),
              ] else ...[
                TextField(
                  controller: _title,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'What was it?', hintText: 'Kebab, protein bar…'),
                ),
                const SizedBox(height: 10),
                // Two to a row, so each label is whole and its unit fits next to the number.
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _kcal,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Calories', suffixText: 'kcal'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _protein,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Protein', suffixText: 'g'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _cost,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Cost (optional)',
                    prefixText: '${ref.watch(moneyProvider).symbol} ',
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(onPressed: _logManual, child: const Text('Log meal')),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// How much of a gram/ml pantry item was eaten: a preset, or a typed amount.
class _AmountDialog extends StatefulWidget {
  const _AmountDialog({required this.ing});
  final Ingredient ing;

  @override
  State<_AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<_AmountDialog> {
  final _other = TextEditingController();

  @override
  void dispose() {
    _other.dispose();
    super.dispose();
  }

  void _submit() {
    final v = double.tryParse(_other.text.replaceAll(',', '.'));
    if (v != null && v > 0) Navigator.of(context).pop(v);
  }

  @override
  Widget build(BuildContext context) {
    final ing = widget.ing;
    final presets = ing.baseUnit == BaseUnit.ml
        ? const <double>[100, 200, 250, 330, 500]
        : const <double>[30, 50, 100, 150, 200];
    return AlertDialog(
      title: Text('How much ${ing.name}?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final p in presets)
                ActionChip(label: Text(qty(p, ing.baseUnit)), onPressed: () => Navigator.of(context).pop(p)),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _other,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: 'Other amount', suffixText: ing.baseUnit.label),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: _submit, child: const Text('Eat')),
      ],
    );
  }
}
