import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../application/nutrition_service.dart';
import '../../core/enums.dart';
import '../../data/isar/collections/schemas.dart';
import '../../domain/units.dart';
import '../../platform/photo_capture.dart';
import '../common/format.dart';
import '../common/widgets.dart';

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

/// Quick adjust (stepper), macros (confirm, scan label, edit) and full edit of one pantry item.
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
  late bool _staple = _ing.isStaple;

  bool _macroEditing = false;

  /// Reading a label or asking the AI.
  bool _busy = false;
  String? _macroError;
  LabelDraft? _label;

  static String _fmt(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
  static double? _num(TextEditingController c) => double.tryParse(c.text.replaceAll(',', '.').trim());

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

  Future<void> _confirmMacros() async {
    await ref.read(nutritionServiceProvider).confirm(_ing.id);
    tick();
    _next();
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
    List<String> paths;
    try {
      paths = await PhotoCapture.pick(camera: true);
    } catch (e) {
      setState(() => _macroError = 'Could not open the camera: $e');
      return;
    }
    if (paths.isEmpty || !mounted) return;
    setState(() {
      _busy = true;
      _macroError = null;
    });
    final images = [for (final p in paths) await File(p).readAsBytes()];
    final draft = await ref.read(nutritionServiceProvider).readLabel(_ing.id, images);
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
      ..trackingMode = _staple ? TrackingMode.staple : TrackingMode.exact
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
    if (_ing.needsNutrition) unawaited(ref.read(nutritionServiceProvider).fillMissing());
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final money = ref.watch(moneyProvider);
    final existing = widget.ingredient != null;
    final review = widget.review;
    // The big ± around the on-hand quantity: 44 neutral circles.
    final round = IconButton.styleFrom(
      backgroundColor: context.colors.fill,
      foregroundColor: context.scheme.onSurface,
      minimumSize: const Size(44, 44),
    );
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpace.sheet, 0, AppSpace.sheet, AppSpace.x6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NoWidowText(existing ? _ing.name : 'New pantry item', style: context.text.headlineSmall),
                        if (review != null) ...[
                          const SizedBox(height: AppSpace.tight),
                          Text(
                            'Check macros · ${review.index} of ${review.total}',
                            style: context.text.bodyMedium?.copyWith(color: context.scheme.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (review != null)
                    TextButton(onPressed: _busy ? null : _next, child: const Text('Skip'))
                  else if (existing)
                    IconButton(
                      tooltip: _editing ? 'Done editing' : 'Edit details',
                      onPressed: () => setState(() => _editing = !_editing),
                      icon: Icon(_editing ? Icons.close_rounded : Icons.edit_outlined),
                    ),
                ],
              ),
              if (existing && !_ing.isStaple && review == null) ...[
                const SizedBox(height: AppSpace.x4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      style: round,
                      tooltip: 'Less',
                      onPressed: _ing.qtyOnHand > 0 ? () => _adjust(-_step) : null,
                      icon: const Icon(Icons.remove_rounded, size: 20),
                    ),
                    const SizedBox(width: AppSpace.x6),
                    Column(
                      children: [
                        Text.rich(valueSpan(context, qty(_ing.qtyOnHand, _ing.baseUnit), context.nums.hero)),
                        Text('on hand', style: context.text.bodySmall),
                      ],
                    ),
                    const SizedBox(width: AppSpace.x6),
                    IconButton.filledTonal(
                      style: round,
                      tooltip: 'More',
                      onPressed: () => _adjust(_step),
                      icon: const Icon(Icons.add_rounded, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.x3),
                Center(
                  child: Wrap(
                    spacing: AppSpace.x2,
                    alignment: WrapAlignment.center,
                    children: [
                      AppActionChip(
                        icon: Icons.remove_shopping_cart_outlined,
                        label: "I'm out",
                        onPressed: () async {
                          await ref.read(pantryServiceProvider).markOut(_ing.id);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                      ),
                      AppActionChip(
                        icon: Icons.verified_outlined,
                        label: 'Looks right',
                        onPressed: () async {
                          await ref.read(pantryServiceProvider).verify(_ing.id);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                if (_ing.avgCostPerUnitMinor > 0) ...[
                  const SizedBox(height: AppSpace.x2),
                  Center(
                    child: Text(
                      'Avg cost ${money.format((_ing.avgCostPerUnitMinor * (_ing.baseUnit == BaseUnit.pc ? 1 : 1000)).round())}'
                      ' per ${_ing.baseUnit == BaseUnit.pc ? 'piece' : (_ing.baseUnit == BaseUnit.g ? 'kg' : 'l')}',
                      textAlign: TextAlign.center,
                      style: context.text.bodySmall,
                    ),
                  ),
                ],
              ],
              if (existing) ...[
                const SizedBox(height: AppSpace.x4),
                _nutritionCard(context, _liveIn(ref.watch(ingredientsProvider).value)),
              ],
              if (_editing) ...[
                const SizedBox(height: AppSpace.x4),
                TextField(
                  controller: _name,
                  autofocus: !existing,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: AppSpace.x3),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _qty,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: 'Quantity', suffixText: _unit.label),
                      ),
                    ),
                    const SizedBox(width: AppSpace.x2),
                    AppSegmented<BaseUnit>(
                      expand: false,
                      segments: {for (final u in BaseUnit.values) u: u.label},
                      selected: _unit,
                      onChanged: (u) => setState(() => _unit = u),
                    ),
                  ],
                ),
                if (!existing) ...[
                  const SizedBox(height: AppSpace.x3),
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
                  const SizedBox(height: AppSpace.x3),
                  TextField(
                    controller: _gpp,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Grams per piece', suffixText: 'g'),
                  ),
                ],
                const SizedBox(height: AppSpace.x3),
                DropdownButtonFormField<IngredientCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [for (final c in IngredientCategory.values) DropdownMenuItem(value: c, child: Text(c.label))],
                  onChanged: (v) => setState(() => _category = v ?? _category),
                ),
                if (!existing) ...[
                  const SizedBox(height: 12),
                  Text('Nutrition per 100 ${_unit == BaseUnit.ml ? 'ml' : 'g'}', style: context.text.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    'Leave empty and the AI fills it in. You can scan the label later.',
                    style: context.text.bodySmall,
                  ),
                  const SizedBox(height: AppSpace.x2),
                  _macroFields(),
                ],
                const SizedBox(height: AppSpace.x3),
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
                const SizedBox(height: AppSpace.x3),
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
                        style: TextButton.styleFrom(
                          foregroundColor: context.colors.criticalInk,
                          iconColor: context.colors.criticalInk,
                        ),
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: const Text('Delete'),
                      ),
                    const Spacer(),
                    FilledButton(
                      style: AppTheme.largeButton,
                      onPressed: _save,
                      child: Text(existing ? 'Save' : 'Add to pantry'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
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
        if (i > 0) const SizedBox(width: AppSpace.tight),
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

  /// Macros with where they came from, and the three ways to confirm them. A sheet is already a
  /// surface, so this is an inset fill panel rather than a card (§2d).
  Widget _nutritionCard(BuildContext context, Ingredient cur) {
    final c = context.colors;
    final secondary = context.scheme.onSurfaceVariant;
    final n = cur.per100;
    final confirmed = cur.nutritionConfirmedAt != null;
    final pill = cur.needsNutrition
        ? StatusPill(label: 'Unknown', color: c.warning, ink: c.warningInk, icon: Icons.help_outline_rounded)
        : confirmed
        ? StatusPill(
            label: cur.nutritionSource == DataSource.label ? 'From label' : 'Confirmed',
            color: c.good,
            ink: c.goodInk,
            icon: Icons.verified_outlined,
          )
        : StatusPill(label: 'AI estimate', color: secondary, ink: secondary, icon: Icons.auto_awesome_outlined);
    final flags = _label?.numbers?.flags ?? const <String>[];
    final muted = context.text.bodySmall;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpace.card),
      decoration: BoxDecoration(color: c.fill, borderRadius: BorderRadius.circular(AppRadius.tile)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Nutrition per 100 ${cur.baseUnit == BaseUnit.ml ? 'ml' : 'g'}',
                  style: context.text.titleMedium,
                ),
              ),
              const SizedBox(width: AppSpace.x3),
              pill,
            ],
          ),
          const SizedBox(height: AppSpace.x3),
          if (_macroEditing) ...[
            if (_label != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.x2),
                child: Text(
                  'Read from ${_label!.productName ?? 'the label'}. Check the numbers, then save.',
                  style: muted,
                ),
              ),
            for (final f in flags)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.x2),
                child: Text(switch (f) {
                  'energy_mismatch' => "The calories don't match the macros. Check the photo.",
                  'too_dense' => 'These numbers are higher than any food per gram. Check the photo.',
                  _ => f,
                }, style: context.text.bodySmall?.copyWith(color: c.criticalInk)),
              ),
            _macroFields(),
            const SizedBox(height: AppSpace.x3),
            Row(
              children: [
                Transform.translate(
                  offset: const Offset(-12, 0),
                  child: TextButton(
                    onPressed: () => setState(() => _macroEditing = false),
                    child: const Text('Cancel'),
                  ),
                ),
                const Spacer(),
                FilledButton(onPressed: _saveMacros, child: const Text('Save macros')),
              ],
            ),
          ] else ...[
            if (cur.needsNutrition)
              Text(_busy ? 'Asking the AI…' : 'Recipes count this as 0 kcal until it has numbers.', style: muted)
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: AppSpace.block),
            Wrap(
              spacing: AppSpace.x2,
              runSpacing: AppSpace.x2,
              children: [
                if (!cur.needsNutrition && !confirmed)
                  AppActionChip(icon: Icons.check_rounded, label: 'Confirm', onPressed: _busy ? null : _confirmMacros),
                if (cur.needsNutrition)
                  AppActionChip(icon: Icons.auto_awesome_outlined, label: 'Ask AI', onPressed: _busy ? null : _askAi),
                AppActionChip(
                  icon: Icons.document_scanner_outlined,
                  label: 'Scan label',
                  onPressed: _busy ? null : _scanLabel,
                ),
                AppActionChip(
                  icon: Icons.edit_outlined,
                  label: cur.needsNutrition ? 'Enter' : 'Edit',
                  onPressed: _busy ? null : () => _editMacros(cur.per100),
                ),
              ],
            ),
          ],
          if (_busy) ...[
            const SizedBox(height: AppSpace.x3),
            ClipRRect(borderRadius: BorderRadius.circular(2), child: const LinearProgressIndicator()),
          ],
          if (_macroError != null) ...[
            const SizedBox(height: AppSpace.x2),
            Text(_macroError!, style: context.text.bodySmall?.copyWith(color: c.criticalInk)),
          ],
        ],
      ),
    );
  }
}

// Used by other screens to show a human quantity for an ingredient row.
String ingredientQty(Ingredient i) => UnitConverter.format(i.qtyOnHand, i.baseUnit);
