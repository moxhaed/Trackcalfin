import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/enums.dart';
import '../../domain/feasibility.dart';
import '../../domain/stock_index.dart';
import '../common/widgets.dart';
import '../cook/cook_actions.dart';

Future<void> showCookedSheet(BuildContext context) =>
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => const CookedSheet());

/// Set portions once, then one tap on a recipe logs the cook.
class CookedSheet extends ConsumerStatefulWidget {
  const CookedSheet({super.key});

  @override
  ConsumerState<CookedSheet> createState() => _CookedSheetState();
}

class _CookedSheetState extends ConsumerState<CookedSheet> {
  int? _portions;
  final _timer = LogTimer();

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).value;
    final recipes = ref.watch(recipesProvider).value ?? const [];
    final pick = ref.watch(todayPickProvider).value?.recipe;
    final stock = StockIndex(ref.watch(ingredientsProvider).value ?? const []);
    final portions = _portions ?? profile?.defaultPortions ?? 1;
    final list =
        recipes
            .where((r) => r.status != RecipeStatus.archived && r.status != RecipeStatus.dismissed)
            .where((r) => r.id == pick?.id || r.favorite || r.timesCooked > 0 || r.status == RecipeStatus.saved)
            .toList()
          ..sort((a, b) {
            if (a.id == pick?.id) return -1;
            if (b.id == pick?.id) return 1;
            return (b.lastCookedAt ?? b.createdAt).compareTo(a.lastCookedAt ?? a.createdAt);
          });
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      builder: (context, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 16, 8),
            child: Row(
              children: [
                Expanded(child: Text('What did you cook?', style: context.text.titleLarge)),
                PortionStepper(value: portions, onChanged: (v) => setState(() => _portions = v), hint: 'portions'),
              ],
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? const EmptyState(
                    icon: Icons.menu_book_outlined,
                    title: 'No recipes yet',
                    message: "Today's pick and recipes you save or cook show up here.",
                  )
                : ListView.builder(
                    controller: controller,
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final r = list[i];
                      final f = FeasibilityChecker.check(r.ingredients, portions, stock);
                      return ListTile(
                        leading: Icon(r.id == pick?.id ? Icons.wb_sunny_outlined : Icons.restaurant_menu),
                        title: Text(r.title),
                        subtitle: Text(
                          r.id == pick?.id
                              ? "Today's pick"
                              : (r.lastPortionsCooked > 0 ? 'Last time: ${r.lastPortionsCooked} portions' : 'Saved'),
                        ),
                        trailing: f.ready
                            ? Icon(Icons.check_circle, color: context.colors.good, semanticLabel: 'In stock')
                            : Icon(Icons.info_outline, color: context.colors.warning, semanticLabel: 'Stock short'),
                        onTap: () async {
                          final nav = Navigator.of(context);
                          final outer = nav.context;
                          nav.pop();
                          await cookNow(outer, ref, r, portions, timer: _timer);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
