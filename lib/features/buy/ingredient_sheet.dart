import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/enums.dart';
import '../../data/isar/collections/schemas.dart';
import '../../domain/units.dart';
import '../common/format.dart';
import '../common/widgets.dart';

Future<void> showIngredientSheet(BuildContext context, {Ingredient? ingredient}) => showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (_) => IngredientSheet(ingredient: ingredient),
);

/// Quick adjust (stepper) plus full edit of one pantry item.
class IngredientSheet extends ConsumerStatefulWidget {
  const IngredientSheet({super.key, this.ingredient});
  final Ingredient? ingredient;

  @override
  ConsumerState<IngredientSheet> createState() => _IngredientSheetState();
}

class _IngredientSheetState extends ConsumerState<IngredientSheet> {
  late final Ingredient _ing = widget.ingredient ?? (Ingredient()..shelfLifeDays = 7);
  late bool _editing = widget.ingredient == null;
  late final _name = TextEditingController(text: _ing.name);
  late final _qty = TextEditingController(text: _fmt(_ing.qtyOnHand));
  late final _price = TextEditingController();
  late final _kcal = TextEditingController(text: _fmt(_ing.per100.kcal));
  late final _protein = TextEditingController(text: _fmt(_ing.per100.proteinG));
  late final _carbs = TextEditingController(text: _fmt(_ing.per100.carbsG));
  late final _fat = TextEditingController(text: _fmt(_ing.per100.fatG));
  late final _gpp = TextEditingController(text: _ing.gramsPerPiece == null ? '' : _fmt(_ing.gramsPerPiece!));
  late final _shelf = TextEditingController(text: '${_ing.shelfLifeDays}');
  late final _low = TextEditingController(text: _ing.lowStockThreshold > 0 ? _fmt(_ing.lowStockThreshold) : '');
  late BaseUnit _unit = _ing.baseUnit;
  late IngredientCategory _category = _ing.category;
  late bool _staple = _ing.isStaple;

  static String _fmt(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
  static double? _num(TextEditingController c) => double.tryParse(c.text.replaceAll(',', '.').trim());

  @override
  void dispose() {
    for (final c in [_name, _qty, _price, _kcal, _protein, _carbs, _fat, _gpp, _shelf, _low]) {
      c.dispose();
    }
    super.dispose();
  }

  double get _step => switch (_unit) {
    BaseUnit.pc => 1,
    BaseUnit.g => _ing.qtyOnHand >= 1000 ? 100 : 50,
    BaseUnit.ml => _ing.qtyOnHand >= 1000 ? 100 : 50,
  };

  Future<void> _adjust(double delta) async {
    final next = (_ing.qtyOnHand + delta).clamp(0, 100000).toDouble();
    await ref.read(pantryServiceProvider).setQuantity(_ing.id, next);
    tick();
    setState(() {
      _ing.qtyOnHand = next;
      _qty.text = _fmt(next);
    });
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    final isNew = widget.ingredient == null;
    final newQty = _num(_qty) ?? 0;
    final pantry = ref.read(pantryServiceProvider);
    _ing
      ..name = _name.text.trim()
      ..baseUnit = _unit
      ..category = _category
      ..trackingMode = _staple ? TrackingMode.staple : TrackingMode.exact
      ..per100 = Nutrition(
        kcal: _num(_kcal) ?? 0,
        proteinG: _num(_protein) ?? 0,
        carbsG: _num(_carbs) ?? 0,
        fatG: _num(_fat) ?? 0,
      )
      ..nutritionSource = DataSource.user
      ..gramsPerPiece = _unit == BaseUnit.pc ? (_num(_gpp) ?? 50) : null
      ..shelfLifeDays = int.tryParse(_shelf.text) ?? 7
      ..lowStockThreshold = _num(_low) ?? 0;
    final price = ref.read(moneyProvider).parse(_price.text);
    if (isNew) {
      _ing.qtyOnHand = 0;
      final id = await pantry.upsert(_ing);
      if (newQty > 0) {
        if (price != null && price > 0) {
          final profile = ref.read(profileProvider).value;
          await ref
              .read(ledgerServiceProvider)
              .applyManualPurchase(
                ingredientId: id,
                qty: newQty,
                totalMinor: price,
                currency: profile?.currency ?? 'EUR',
              );
        } else {
          await pantry.setQuantity(id, newQty);
        }
      }
    } else {
      await pantry.upsert(_ing);
      if ((newQty - widget.ingredient!.qtyOnHand).abs() > 1e-9) await pantry.setQuantity(_ing.id, newQty);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final money = ref.watch(moneyProvider);
    final existing = widget.ingredient != null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(existing ? _ing.name : 'New pantry item', style: context.text.titleLarge)),
                  if (existing)
                    IconButton(
                      tooltip: _editing ? 'Done editing' : 'Edit details',
                      onPressed: () => setState(() => _editing = !_editing),
                      icon: Icon(_editing ? Icons.close : Icons.edit_outlined),
                    ),
                ],
              ),
              if (existing && !_ing.isStaple) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      onPressed: _ing.qtyOnHand > 0 ? () => _adjust(-_step) : null,
                      icon: const Icon(Icons.remove),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      children: [
                        Text(qty(_ing.qtyOnHand, _ing.baseUnit), style: context.text.headlineSmall),
                        Text('on hand', style: context.text.labelSmall),
                      ],
                    ),
                    const SizedBox(width: 16),
                    IconButton.filledTonal(onPressed: () => _adjust(_step), icon: const Icon(Icons.add)),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.remove_shopping_cart_outlined, size: 18),
                      label: const Text("I'm out"),
                      onPressed: () async {
                        await ref.read(pantryServiceProvider).markOut(_ing.id);
                        if (context.mounted) Navigator.of(context).pop();
                      },
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.verified_outlined, size: 18),
                      label: const Text('Looks right'),
                      onPressed: () async {
                        await ref.read(pantryServiceProvider).verify(_ing.id);
                        if (context.mounted) Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  [
                    if (_ing.avgCostPerUnitMinor > 0)
                      'Avg cost ${money.format((_ing.avgCostPerUnitMinor * (_ing.baseUnit == BaseUnit.pc ? 1 : 1000)).round())}'
                          ' per ${_ing.baseUnit == BaseUnit.pc ? 'piece' : (_ing.baseUnit == BaseUnit.g ? 'kg' : 'l')}',
                    if (_ing.per100.kcal > 0)
                      '${_ing.per100.kcal.round()} kcal · ${_ing.per100.proteinG.toStringAsFixed(1)} g protein per 100 ${_ing.baseUnit == BaseUnit.ml ? 'ml' : 'g'}',
                  ].join('\n'),
                  textAlign: TextAlign.center,
                  style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant),
                ),
              ],
              if (_editing) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _name,
                  autofocus: !existing,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _qty,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: 'Quantity', suffixText: _unit.label),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SegmentedButton<BaseUnit>(
                      segments: [for (final u in BaseUnit.values) ButtonSegment(value: u, label: Text(u.label))],
                      selected: {_unit},
                      showSelectedIcon: false,
                      onSelectionChanged: (s) => setState(() => _unit = s.first),
                    ),
                  ],
                ),
                if (!existing) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: _price,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Price paid (optional)',
                      prefixText: '${money.symbol} ',
                      helperText: 'Adds a grocery expense and sets the cost per ${_unit.label}',
                    ),
                  ),
                ],
                if (_unit == BaseUnit.pc) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: _gpp,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Grams per piece', suffixText: 'g'),
                  ),
                ],
                const SizedBox(height: 10),
                DropdownButtonFormField<IngredientCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [for (final c in IngredientCategory.values) DropdownMenuItem(value: c, child: Text(c.label))],
                  onChanged: (v) => setState(() => _category = v ?? _category),
                ),
                const SizedBox(height: 12),
                Text('Nutrition per 100 ${_unit == BaseUnit.ml ? 'ml' : 'g'}', style: context.text.titleSmall),
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (final (c, l) in [
                      (_kcal, 'kcal'),
                      (_protein, 'Protein'),
                      (_carbs, 'Carbs'),
                      (_fat, 'Fat'),
                    ]) ...[
                      Expanded(
                        child: TextField(
                          controller: c,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(labelText: l),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _shelf,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Keeps for', suffixText: 'days'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _low,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: 'Low below', suffixText: _unit.label),
                      ),
                    ),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Staple'),
                  subtitle: const Text('Always assumed available, never deducted (salt, oil, spices)'),
                  value: _staple,
                  onChanged: (v) => setState(() => _staple = v),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (existing)
                      TextButton.icon(
                        onPressed: () async {
                          final pantry = ref.read(pantryServiceProvider);
                          final nav = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);
                          final removed = await pantry.delete(_ing.id);
                          nav.pop();
                          if (removed != null) {
                            showUndoOn(messenger, '${removed.name} deleted', onUndo: () => pantry.restore(removed));
                          }
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete'),
                      ),
                    const Spacer(),
                    FilledButton(onPressed: _save, child: Text(existing ? 'Save' : 'Add to pantry')),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Used by other screens to show a human quantity for an ingredient row.
String ingredientQty(Ingredient i) => UnitConverter.format(i.qtyOnHand, i.baseUnit);
