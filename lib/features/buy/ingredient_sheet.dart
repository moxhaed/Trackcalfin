import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../application/nutrition_service.dart';
import '../../core/enums.dart';
import '../../core/money.dart';
import '../../data/isar/collections/schemas.dart';
import '../../domain/shopping.dart';
import '../../domain/units.dart';
import '../../platform/photo_capture.dart';
import '../common/format.dart';
import '../common/store_prices.dart';
import '../common/widgets.dart';
import 'shopping_view.dart';

/// In review mode ([review] set) the sheet pops `true` to move on to the next item.
Future<bool?> showIngredientSheet(BuildContext context, {Ingredient? ingredient, ({int index, int total})? review}) =>
    showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => IngredientSheet(ingredient: ingredient, review: review),
    );

/// Steps through [items] one sheet at a time; dismissing a sheet stops the review.
Future<void> reviewMacros(BuildContext context, List<Ingredient> items) async {
  for (final (i, ing) in items.indexed) {
    if (!context.mounted) return;
    final next = await showIngredientSheet(context, ingredient: ing, review: (index: i + 1, total: items.length));
    if (next != true) return;
  }
}

/// Quick adjust (stepper), macros (scan a label, edit) and full edit of one pantry item.
class IngredientSheet extends ConsumerStatefulWidget {
  const IngredientSheet({super.key, this.ingredient, this.review});
  final Ingredient? ingredient;
  final ({int index, int total})? review;

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
  late final _fiber = TextEditingController(text: _fmt(_ing.per100.fiberG));
  late final _gpp = TextEditingController(text: _ing.gramsPerPiece == null ? '' : _fmt(_ing.gramsPerPiece!));
  late final _shelf = TextEditingController(text: '${_ing.shelfLifeDays}');
  late final _low = TextEditingController(text: _ing.lowStockThreshold > 0 ? _fmt(_ing.lowStockThreshold) : '');
  late BaseUnit _unit = _ing.baseUnit;
  late IngredientCategory _category = _ing.category;

  // What the item was in its stored unit, so a unit switch can re-express it.
  late final _origUnit = _ing.baseUnit;
  late final _origGpp = _ing.gramsPerPiece;
  late final _origQty = _ing.qtyOnHand;
  late final _origLow = _ing.lowStockThreshold;
  bool _qtyTouched = false;
  bool _lowTouched = false;
  String? _gppError;

  bool _macroEditing = false;

  /// Reading a label or asking the AI.
  bool _busy = false;
  String? _macroError;
  LabelDraft? _label;

  static String _fmt(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
  static double? _num(TextEditingController c) => double.tryParse(c.text.replaceAll(',', '.').trim());

  /// Pieces close to a whole number are whole (1980 ml of 340 g cans is 6, not 5.8).
  static String _fmtIn(double v, BaseUnit unit) {
    if (unit == BaseUnit.pc && (v - v.roundToDouble()).abs() <= 0.25) return _fmt(v.roundToDouble());
    return _fmt(unit == BaseUnit.pc ? v : v.roundToDouble());
  }

  /// New units per stored unit, with the piece weight typed now; null if it can't be worked out.
  double? get _unitFactor => UnitConverter.factor(
    _origUnit,
    _unit,
    fromGramsPerPiece: _origGpp,
    toGramsPerPiece: _unit == BaseUnit.pc ? _num(_gpp) : null,
    density: _ing.densityGPerMl,
  );

  /// An existing item switched units (cola from ml to cans): show its amount and low-stock
  /// threshold in the new unit, unless the user typed their own.
  void _reexpress() {
    if (widget.ingredient == null) return;
    final f = _unitFactor;
    if (f == null) return;
    if (!_qtyTouched) _qty.text = _fmtIn(_origQty * f, _unit);
    if (!_lowTouched && _origLow > 0) _low.text = _fmtIn(_origLow * f, _unit);
  }

  @override
  void dispose() {
    for (final c in [_name, _qty, _price, _kcal, _protein, _carbs, _fat, _fiber, _gpp, _shelf, _low]) {
      c.dispose();
    }
    super.dispose();
  }

  /// The item as stored now: the AI or a label scan may have changed it since the sheet opened.
  Ingredient _liveIn(List<Ingredient>? all) => all?.firstWhereOrNull((i) => i.id == _ing.id) ?? _ing;

  Nutrition _typedMacros() => Nutrition(
    kcal: _num(_kcal) ?? 0,
    proteinG: _num(_protein) ?? 0,
    carbsG: _num(_carbs) ?? 0,
    fatG: _num(_fat) ?? 0,
    fiberG: _num(_fiber) ?? 0,
  );

  void _showMacros(Nutrition n) {
    _kcal.text = _fmt(n.kcal);
    _protein.text = _fmt(n.proteinG);
    _carbs.text = _fmt(n.carbsG);
    _fat.text = _fmt(n.fatG);
    _fiber.text = _fmt(n.fiberG);
  }

  void _next() {
    if (widget.review != null && mounted) Navigator.of(context).pop(true);
  }

  Future<void> _askAi() async {
    setState(() {
      _busy = true;
      _macroError = null;
    });
    final r = await ref.read(nutritionServiceProvider).fillMissing();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _macroError = r.error;
    });
  }

  Future<void> _scanLabel() async {
    final store = ref.read(imageStoreProvider);
    final nutrition = ref.read(nutritionServiceProvider);
    List<String> paths;
    try {
      paths = await PhotoCapture.pick(camera: true);
    } catch (e) {
      if (mounted) setState(() => _macroError = 'Could not open the camera: $e');
      return;
    }
    if (paths.isEmpty || !mounted) return;
    setState(() {
      _busy = true;
      _macroError = null;
    });
    // Scaled down like scan photos: the camera's full-size photo is several MB.
    final images = [for (final p in paths) await store.readScaled(p)];
    final draft = await nutrition.readLabel(_ing.id, images);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _macroError = draft.error;
      if (draft.ok) {
        _label = draft;
        _showMacros(draft.numbers!.per100);
        _macroEditing = true;
      }
    });
  }

  void _editMacros(Nutrition current) => setState(() {
    _showMacros(current);
    _label = null;
    _macroError = null;
    _macroEditing = true;
  });

  Future<void> _saveMacros() async {
    final n = _typedMacros();
    final read = _label?.numbers?.per100;
    // Label numbers the user corrected are their own numbers.
    final source = read != null && n.sameAs(read) ? DataSource.label : DataSource.user;
    await ref.read(nutritionServiceProvider).setNutrition(_ing.id, n, source);
    tick();
    if (!mounted) return;
    setState(() {
      _macroEditing = false;
      _label = null;
    });
    _next();
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
    if (!mounted) return;
    setState(() {
      _ing.qtyOnHand = next;
      _qty.text = _fmt(next);
    });
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    final isNew = widget.ingredient == null;
    if (!isNew && _unit != _origUnit && _unit == BaseUnit.pc && (_num(_gpp) ?? 0) <= 0) {
      // Without it the amount and the price per piece can't be worked out.
      setState(() => _gppError = 'How much does one weigh?');
      return;
    }
    final newQty = _num(_qty) ?? 0;
    // Everything from ref before the first await: the sheet can be swiped away while it saves.
    final pantry = ref.read(pantryServiceProvider);
    final ledger = ref.read(ledgerServiceProvider);
    final nutrition = ref.read(nutritionServiceProvider);
    final currency = ref.read(profileProvider).value?.currency ?? 'EUR';
    if (isNew) {
      // Blank macros stay unknown so the AI fills them in; typed ones are the user's own.
      final typed = _typedMacros();
      _ing
        ..per100 = typed
        ..nutritionSource = typed.isZero ? DataSource.none : DataSource.user
        ..nutritionConfirmedAt = typed.isZero ? null : DateTime.now();
    } else {
      // Macros are edited in their own card; keep what is stored now.
      final live = _liveIn(ref.read(ingredientsProvider).value);
      _ing
        ..per100 = live.per100
        ..nutritionSource = live.nutritionSource
        ..nutritionConfirmedAt = live.nutritionConfirmedAt
        ..densityGPerMl = live.densityGPerMl;
      // Per 100 g and per 100 ml differ: switching to or from ml needs new numbers.
      if ((_ing.baseUnit == BaseUnit.ml) != (_unit == BaseUnit.ml)) {
        _ing
          ..nutritionSource = DataSource.none
          ..nutritionConfirmedAt = null;
      }
    }
    _ing
      ..name = _name.text.trim()
      ..baseUnit = _unit
      ..category = _category
      ..gramsPerPiece = _unit == BaseUnit.pc ? (_num(_gpp) ?? 50) : null
      ..shelfLifeDays = int.tryParse(_shelf.text) ?? 7
      ..lowStockThreshold = _num(_low) ?? 0;
    final price = ref.read(moneyProvider).parse(_price.text);
    if (isNew) {
      _ing.qtyOnHand = 0;
      final id = await pantry.upsert(_ing);
      if (newQty > 0) {
        if (price != null && price > 0) {
          await ledger.applyManualPurchase(ingredientId: id, qty: newQty, totalMinor: price, currency: currency);
        } else {
          await pantry.setQuantity(id, newQty);
        }
      }
    } else {
      final f = _unit == _origUnit ? null : _unitFactor;
      if (f != null) {
        // The same food in another unit: one unit costs more or less, the amount isn't recounted.
        _ing
          ..avgCostPerUnitMinor = _ing.avgCostPerUnitMinor / f
          ..lastPurchaseQty = _ing.lastPurchaseQty * f;
        if (!_qtyTouched) _ing.qtyOnHand = newQty;
      }
      await pantry.upsert(_ing);
      if ((newQty - _ing.qtyOnHand).abs() > 1e-9) await pantry.setQuantity(_ing.id, newQty);
    }
    if (_ing.needsNutrition) unawaited(nutrition.fillMissing());
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final money = ref.watch(moneyProvider);
    final existing = widget.ingredient != null;
    final review = widget.review;
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(existing ? _ing.name : 'New pantry item', style: context.text.titleLarge),
                        if (review != null)
                          Text(
                            'Check macros · ${review.index} of ${review.total}',
                            style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),
                  if (review != null)
                    TextButton(onPressed: _busy ? null : _next, child: const Text('Skip'))
                  else if (existing)
                    IconButton(
                      tooltip: _editing ? 'Done editing' : 'Edit details',
                      onPressed: () => setState(() => _editing = !_editing),
                      icon: Icon(_editing ? Icons.close : Icons.edit_outlined),
                    ),
                ],
              ),
              if (existing && review == null) ...[
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
                    ActionChip(
                      avatar: const Icon(Icons.playlist_add, size: 18),
                      label: const Text('Add to list'),
                      onPressed: () => addToShoppingList(context, ref, [ShoppingSuggestion(_ing.name, _ing.key, '')]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _costLine(money),
                  textAlign: TextAlign.center,
                  style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant),
                ),
                StorePricesCard(ing: _ing),
              ],
              if (existing) ...[
                const SizedBox(height: 12),
                _nutritionCard(context, _liveIn(ref.watch(ingredientsProvider).value)),
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
                        onChanged: (_) => _qtyTouched = true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SegmentedButton<BaseUnit>(
                      segments: [for (final u in BaseUnit.values) ButtonSegment(value: u, label: Text(u.label))],
                      selected: {_unit},
                      showSelectedIcon: false,
                      onSelectionChanged: (s) => setState(() {
                        _unit = s.first;
                        _gppError = null;
                        _reexpress();
                      }),
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
                    decoration: InputDecoration(
                      labelText: 'Grams per piece',
                      suffixText: 'g',
                      helperText: 'What one weighs: an egg 55, a 330 ml can 340',
                      errorText: _gppError,
                    ),
                    onChanged: (_) => setState(() {
                      _gppError = null;
                      _reexpress();
                    }),
                  ),
                ],
                const SizedBox(height: 10),
                DropdownButtonFormField<IngredientCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [for (final c in IngredientCategory.values) DropdownMenuItem(value: c, child: Text(c.label))],
                  onChanged: (v) => setState(() => _category = v ?? _category),
                ),
                if (!existing) ...[
                  const SizedBox(height: 12),
                  Text('Nutrition per 100 ${_unit == BaseUnit.ml ? 'ml' : 'g'}', style: context.text.titleSmall),
                  Text(
                    'Leave empty and the AI fills it in. You can scan the label later.',
                    style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 6),
                  _macroFields(),
                ],
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
                        onChanged: (_) => _lowTouched = true,
                      ),
                    ),
                  ],
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
                          // Already swiped away: popping would close the screen under it.
                          if (mounted) nav.pop();
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

  /// What one kg, litre or piece costs, and whether that is a price paid or an estimate.
  String _costLine(MoneyFormat money) {
    if (_ing.avgCostPerUnitMinor <= 0) {
      return _ing.qtyOnHand > 0 ? 'No price yet. Recipes count it as free until a receipt has it.' : '';
    }
    final per = switch (_ing.baseUnit) {
      BaseUnit.pc => 'piece',
      BaseUnit.g => 'kg',
      BaseUnit.ml => 'l',
    };
    final price = money.format((_ing.avgCostPerUnitMinor * (_ing.baseUnit == BaseUnit.pc ? 1 : 1000)).round());
    return _ing.costIsEstimate ? 'About $price per $per (shop price estimate)' : 'Avg cost $price per $per';
  }

  Widget _macroFields() => Row(
    children: [
      for (final (i, (c, l)) in [
        (_kcal, 'kcal'),
        (_protein, 'Protein'),
        (_carbs, 'Carbs'),
        (_fat, 'Fat'),
        (_fiber, 'Fiber'),
      ].indexed) ...[
        if (i > 0) const SizedBox(width: 6),
        Expanded(
          child: TextField(
            controller: c,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l),
          ),
        ),
      ],
    ],
  );

  /// Macros with where they came from, and the three ways to confirm them.
  Widget _nutritionCard(BuildContext context, Ingredient cur) {
    final c = context.colors;
    final n = cur.per100;
    // Where the numbers come from. An estimate needs no confirming: fix it when it looks wrong.
    final pill = switch (cur.nutritionSource) {
      DataSource.none => StatusPill(label: 'Unknown', color: c.warning, icon: Icons.help_outline),
      DataSource.label => StatusPill(label: 'From label', color: c.good, icon: Icons.verified_outlined),
      DataSource.user => StatusPill(label: 'Your numbers', color: c.good, icon: Icons.verified_outlined),
      DataSource.aiEstimate => StatusPill(label: 'AI estimate', color: c.kcal, icon: Icons.auto_awesome_outlined),
    };
    final flags = _label?.numbers?.flags ?? const <String>[];
    final muted = context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant);
    return SectionCard(
      title: 'Nutrition per 100 ${cur.baseUnit == BaseUnit.ml ? 'ml' : 'g'}',
      trailing: pill,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_macroEditing) ...[
            if (_label != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Read from ${_label!.productName ?? 'the label'}. Check the numbers, then save.',
                  style: muted,
                ),
              ),
            for (final f in flags)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(switch (f) {
                  'energy_mismatch' => "The calories don't match the macros. Check the photo.",
                  'too_dense' => 'These numbers are higher than any food per gram. Check the photo.',
                  _ => f,
                }, style: context.text.bodySmall?.copyWith(color: c.serious)),
              ),
            _macroFields(),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton(onPressed: () => setState(() => _macroEditing = false), child: const Text('Cancel')),
                const Spacer(),
                FilledButton(onPressed: _saveMacros, child: const Text('Save macros')),
              ],
            ),
          ] else ...[
            if (cur.needsNutrition)
              Text(_busy ? 'Asking the AI…' : 'Recipes count this as 0 kcal until it has numbers.', style: muted)
            else
              Row(
                children: [
                  Expanded(
                    child: Metric(value: '${n.kcal.round()}', label: 'kcal', dotColor: c.kcal),
                  ),
                  Expanded(
                    child: Metric(value: '${_fmt(n.proteinG)} g', label: 'protein', dotColor: c.protein),
                  ),
                  Expanded(
                    child: Metric(value: '${_fmt(n.carbsG)} g', label: 'carbs'),
                  ),
                  Expanded(
                    child: Metric(value: '${_fmt(n.fatG)} g', label: 'fat'),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (cur.needsNutrition)
                  ActionChip(
                    avatar: const Icon(Icons.auto_awesome_outlined, size: 18),
                    label: const Text('Ask AI'),
                    onPressed: _busy ? null : _askAi,
                  ),
                ActionChip(
                  avatar: const Icon(Icons.document_scanner_outlined, size: 18),
                  label: const Text('Scan label'),
                  onPressed: _busy ? null : _scanLabel,
                ),
                ActionChip(
                  avatar: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(cur.needsNutrition ? 'Enter' : 'Edit'),
                  onPressed: _busy ? null : () => _editMacros(cur.per100),
                ),
              ],
            ),
          ],
          if (_busy) ...[const SizedBox(height: 12), const LinearProgressIndicator()],
          if (_macroError != null) ...[
            const SizedBox(height: 8),
            Text(_macroError!, style: context.text.bodySmall?.copyWith(color: context.scheme.error)),
          ],
        ],
      ),
    );
  }
}

// Used by other screens to show a human quantity for an ingredient row.
String ingredientQty(Ingredient i) => UnitConverter.format(i.qtyOnHand, i.baseUnit);
