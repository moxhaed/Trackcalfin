import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar_community/isar.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/enums.dart';
import '../../data/isar/collections/schemas.dart';
import '../common/widgets.dart';

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
              ..role = row.ingredient == null
                  ? IngredientRole.missing
                  : (row.ingredient!.isStaple ? IngredientRole.staple : IngredientRole.stock),
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
    final secondary = context.scheme.onSurfaceVariant;
    return Scaffold(
      appBar: PageBar(
        title: widget.id == null ? 'New recipe' : 'Edit recipe',
        actions: [
          // The bar pads its end by 8 and the button its label by 12, which ends the label at
          // x = 370. 4 more puts it on the 16 margin.
          Transform.translate(
            offset: const Offset(AppSpace.x1, 0),
            child: TextButton(onPressed: _save, child: const Text('Save')),
          ),
        ],
      ),
      body: !_loaded
          ? const _EditorSkeleton()
          : ListView(
              padding: EdgeInsets.fromLTRB(
                AppSpace.screen,
                AppSpace.headerGap,
                AppSpace.screen,
                MediaQuery.paddingOf(context).bottom + AppSpace.x6,
              ),
              children: [
                TextField(
                  controller: _title,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: AppSpace.x3),
                Row(
                  children: [
                    Expanded(child: Text('Default portions', style: context.text.bodyLarge)),
                    PortionStepper(value: _portions, max: 99, onChanged: (v) => setState(() => _portions = v)),
                  ],
                ),
                const SizedBox(height: AppSpace.x3),
                Row(
                  children: [
                    for (final (i, (c, l)) in [
                      (_prep, 'Prep min'),
                      (_cook, 'Cook min'),
                      (_fridge, 'Fridge days'),
                    ].indexed) ...[
                      if (i > 0) const SizedBox(width: AppSpace.x2),
                      Expanded(
                        child: TextField(
                          controller: c,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: l),
                        ),
                      ),
                    ],
                  ],
                ),
                const SectionTitle('Ingredients (per portion)'),
                for (final (i, row) in _rows.indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpace.x2),
                    child: Row(
                      children: [
                        Expanded(
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
                              decoration: const InputDecoration(hintText: 'Ingredient'),
                              onChanged: (v) {
                                row.name = v;
                                if (row.ingredient != null && row.ingredient!.name != v) row.ingredient = null;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpace.x2),
                        // 72 is the least that still shows the "Qty" hint beside the unit and the remove button.
                        SizedBox(
                          width: 72,
                          child: TextFormField(
                            initialValue: row.qty,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(hintText: 'Qty'),
                            onChanged: (v) => row.qty = v,
                          ),
                        ),
                        const SizedBox(width: AppSpace.x2),
                        _UnitField(unit: row.unit, onChanged: (u) => setState(() => row.unit = u)),
                        IconButton(
                          tooltip: 'Remove ingredient',
                          style: IconButton.styleFrom(foregroundColor: secondary),
                          onPressed: () => setState(() => _rows.removeAt(i)),
                          icon: const Icon(Icons.close_rounded, size: 20),
                        ),
                      ],
                    ),
                  ),
                // The button's own 12 padding is pulled back so its label sits on the margin.
                Align(
                  alignment: Alignment.centerLeft,
                  child: Transform.translate(
                    offset: const Offset(-AppSpace.x3, 0),
                    child: TextButton.icon(
                      onPressed: () => setState(() => _rows.add(_Row())),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add ingredient'),
                    ),
                  ),
                ),
                Text('Ingredients not in your pantry are saved as "to buy".', style: context.text.bodySmall),
                const SizedBox(height: AppSpace.x4),
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

/// The unit picker of an ingredient row: a compact 64-wide field on the same fill as the
/// inputs beside it.
class _UnitField extends StatelessWidget {
  const _UnitField({required this.unit, required this.onChanged});
  final BaseUnit unit;
  final ValueChanged<BaseUnit> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 48,
      padding: const EdgeInsets.only(left: AppSpace.x3, right: AppSpace.x1),
      decoration: BoxDecoration(color: context.colors.fill, borderRadius: BorderRadius.circular(AppRadius.input)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<BaseUnit>(
          value: unit,
          isExpanded: true,
          isDense: true,
          borderRadius: BorderRadius.circular(AppRadius.menu),
          icon: Icon(Icons.expand_more_rounded, size: 18, color: context.scheme.onSurfaceVariant),
          style: context.text.bodyLarge,
          items: [for (final u in BaseUnit.values) DropdownMenuItem(value: u, child: Text(u.label))],
          onChanged: (u) => onChanged(u ?? unit),
        ),
      ),
    );
  }
}

/// The editor while the recipe loads: the fields in their real places, pulsing.
class _EditorSkeleton extends StatelessWidget {
  const _EditorSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget field({double? width}) => SkeletonBlock(width: width, height: 56, radius: AppRadius.input);
    return AppSkeleton(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.headerGap, AppSpace.screen, 0),
        children: [
          field(),
          const SizedBox(height: AppSpace.x4),
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[if (i > 0) const SizedBox(width: AppSpace.x2), Expanded(child: field())],
            ],
          ),
          const SizedBox(height: AppSpace.x6),
          for (var i = 0; i < 3; i++) ...[field(), const SizedBox(height: AppSpace.x2)],
        ],
      ),
    );
  }
}
