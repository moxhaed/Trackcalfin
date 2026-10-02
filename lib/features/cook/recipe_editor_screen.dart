import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar_community/isar.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/enums.dart';
import '../../data/isar/collections/schemas.dart';

class _Row {
  _Row({this.ingredient, this.name = '', this.qty = '', this.unit = BaseUnit.g, this.role = IngredientRole.stock});
  Ingredient? ingredient;
  String name;
  String qty;
  BaseUnit unit;
  IngredientRole role;
}

/// Write or edit a recipe by hand (quantities per portion).
class RecipeEditorScreen extends ConsumerStatefulWidget {
  const RecipeEditorScreen({super.key, this.id});
  final int? id;

  @override
  ConsumerState<RecipeEditorScreen> createState() => _RecipeEditorScreenState();
}

class _RecipeEditorScreenState extends ConsumerState<RecipeEditorScreen> {
  final _title = TextEditingController();
  final _steps = TextEditingController();
  final _prep = TextEditingController(text: '10');
  final _cook = TextEditingController(text: '20');
  final _fridge = TextEditingController(text: '3');
  int _portions = 2;
  final _rows = <_Row>[];
  Recipe? _existing;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final isar = ref.read(isarProvider);
    final profile = await isar.userProfiles.get(1);
    _portions = profile?.defaultPortions ?? 2;
    if (widget.id != null) {
      final r = await isar.recipes.get(widget.id!);
      if (r != null) {
        _existing = r;
        _title.text = r.title;
        _steps.text = r.steps.join('\n');
        _prep.text = '${r.prepMinutes}';
        _cook.text = '${r.cookMinutes}';
        _fridge.text = '${r.fridgeLifeDays}';
        _portions = r.defaultPortions;
        final all = await isar.ingredients.where().findAll();
        for (final ri in r.ingredients) {
          final ing = all.where((i) => i.id == ri.ingredientId || i.key == ri.key).firstOrNull;
          _rows.add(
            _Row(
              ingredient: ing,
              name: ri.name,
              qty: ri.qtyPerPortion == ri.qtyPerPortion.roundToDouble()
                  ? ri.qtyPerPortion.toStringAsFixed(0)
                  : ri.qtyPerPortion.toString(),
              unit: ri.unit,
              role: ri.role,
            ),
          );
        }
      }
    }
    if (_rows.isEmpty) _rows.add(_Row());
    setState(() => _loaded = true);
  }

  @override
  void dispose() {
    for (final c in [_title, _steps, _prep, _cook, _fridge]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) return;
    final r =
        _existing ??
        (Recipe()
          ..origin = RecipeOrigin.manual
          ..status = RecipeStatus.saved);
    r
      ..title = _title.text.trim()
      ..defaultPortions = _portions
      ..prepMinutes = int.tryParse(_prep.text) ?? 0
      ..cookMinutes = int.tryParse(_cook.text) ?? 0
      ..activeMinutes = int.tryParse(_prep.text) ?? 0
      ..fridgeLifeDays = int.tryParse(_fridge.text) ?? 3
      ..steps = _steps.text.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList()
      ..ingredients = [
        for (final row in _rows)
          if ((row.ingredient != null || row.name.trim().isNotEmpty) &&
              (double.tryParse(row.qty.replaceAll(',', '.')) ?? 0) > 0)
            RecipeIngredient()
              ..key = row.ingredient?.key ?? ''
              ..ingredientId = row.ingredient?.id
              ..name = row.ingredient?.name ?? row.name.trim()
              ..qtyPerPortion = double.parse(row.qty.replaceAll(',', '.'))
              ..unit = row.unit
              ..role = row.ingredient == null ? IngredientRole.missing : IngredientRole.stock,
      ];
    if (r.status == RecipeStatus.suggested) r.status = RecipeStatus.saved;
    final id = await ref.read(recipeServiceProvider).save(r);
    if (!mounted) return;
    if (widget.id == null) {
      context.pushReplacement('/recipe/$id');
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pantry = ref.watch(ingredientsProvider).value ?? const <Ingredient>[];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? 'New recipe' : 'Edit recipe'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
              children: [
                TextField(
                  controller: _title,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('Default portions', style: context.text.bodyLarge),
                    const Spacer(),
                    IconButton(
                      onPressed: _portions > 1 ? () => setState(() => _portions--) : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Text('$_portions', style: context.text.titleMedium),
                    IconButton(onPressed: () => setState(() => _portions++), icon: const Icon(Icons.add)),
                  ],
                ),
                Row(
                  children: [
                    for (final (c, l) in [(_prep, 'Prep min'), (_cook, 'Cook min'), (_fridge, 'Fridge days')]) ...[
                      Expanded(
                        child: TextField(
                          controller: c,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: l),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Text('Ingredients (per portion)', style: context.text.titleMedium),
                const SizedBox(height: 8),
                for (final (i, row) in _rows.indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Autocomplete<Ingredient>(
                            initialValue: TextEditingValue(text: row.ingredient?.name ?? row.name),
                            displayStringForOption: (o) => o.name,
                            optionsBuilder: (v) =>
                                pantry.where((p) => p.name.toLowerCase().contains(v.text.toLowerCase())).take(8),
                            onSelected: (o) => setState(() {
                              row.ingredient = o;
                              row.name = o.name;
                              row.unit = o.baseUnit;
                            }),
                            fieldViewBuilder: (context, controller, focus, onSubmit) => TextField(
                              controller: controller,
                              focusNode: focus,
                              decoration: const InputDecoration(hintText: 'Ingredient', isDense: true),
                              onChanged: (v) {
                                row.name = v;
                                if (row.ingredient != null && row.ingredient!.name != v) row.ingredient = null;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            initialValue: row.qty,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(hintText: 'Qty', isDense: true),
                            onChanged: (v) => row.qty = v,
                          ),
                        ),
                        const SizedBox(width: 4),
                        DropdownButton<BaseUnit>(
                          value: row.unit,
                          underline: const SizedBox(),
                          items: [for (final u in BaseUnit.values) DropdownMenuItem(value: u, child: Text(u.label))],
                          onChanged: (u) => setState(() => row.unit = u ?? row.unit),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () => setState(() => _rows.removeAt(i)),
                          icon: const Icon(Icons.close, size: 18),
                        ),
                      ],
                    ),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => setState(() => _rows.add(_Row())),
                    icon: const Icon(Icons.add),
                    label: const Text('Add ingredient'),
                  ),
                ),
                Text(
                  'Ingredients not in your pantry are saved as "to buy".',
                  style: context.text.labelSmall?.copyWith(color: context.scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _steps,
                  minLines: 4,
                  maxLines: 12,
                  decoration: const InputDecoration(
                    labelText: 'Steps',
                    hintText: 'One step per line',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
    );
  }
}
