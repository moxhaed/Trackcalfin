import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/enums.dart';
import '../../data/isar/collections/schemas.dart';
import '../../domain/cookbook.dart';
import '../../domain/stock_index.dart';
import '../common/widgets.dart';
import 'cookbook_import_screen.dart';

/// Saved cookbook recipes with their fit, by book.
final cookbookRecipesProvider = Provider<List<(Recipe, CookbookFit)>>((ref) {
  final recipes = ref.watch(recipesProvider).value ?? const <Recipe>[];
  final stock = StockIndex(ref.watch(ingredientsProvider).value ?? const <Ingredient>[]);
  return [
    for (final r in recipes)
      if (r.origin == RecipeOrigin.cookbook && r.status != RecipeStatus.archived && r.status != RecipeStatus.dismissed)
        (r, CookbookReview.fit(r, stock)),
  ];
});

/// Cook tab: imports being read, and each saved cookbook with how much of it is cookable now.
class CookbookShelf extends ConsumerWidget {
  const CookbookShelf({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imports = ref.watch(openCookbookImportsProvider).value ?? const <CookbookImport>[];
    final saved = ref.watch(cookbookRecipesProvider);
    final run = ref.watch(cookbookRunProvider);
    if (imports.isEmpty && saved.isEmpty) return const SizedBox.shrink();
    final books = <String, List<CookbookFit>>{};
    for (final (r, f) in saved) {
      books.putIfAbsent(r.sourceBook ?? 'Cookbook', () => []).add(f);
    }
    final names = books.keys.toList()..sort();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SectionCard(
        title: 'Cookbooks',
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
        child: Column(
          children: [
            for (final job in imports)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: run.id == job.id
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.auto_stories_outlined),
                title: Text(job.bookTitle),
                subtitle: Text(
                  run.id == job.id
                      ? '${run.label} · ${job.drafts.length} recipes so far'
                      : [
                          if (job.hasWork) job.lastError != null ? 'Paused' : 'Not finished',
                          '${job.unsaved.length} to review',
                        ].join(' · '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/cookbook-import/${job.id}'),
              ),
            for (final name in names)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.menu_book_outlined),
                title: Text(name),
                subtitle: Text(
                  '${books[name]!.length} recipes · ${books[name]!.where((f) => f.ready).length} cookable now',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Uri(path: '/cookbooks', queryParameters: {'book': name}).toString()),
              ),
          ],
        ),
      ),
    );
  }
}

enum _Show { all, ready, almost }

/// The recipes of one imported cookbook (or all of them), cookable ones first.
class CookbooksScreen extends ConsumerStatefulWidget {
  const CookbooksScreen({super.key, this.book});
  final String? book;

  @override
  ConsumerState<CookbooksScreen> createState() => _CookbooksScreenState();
}

class _CookbooksScreenState extends ConsumerState<CookbooksScreen> {
  var _show = _Show.all;

  @override
  void initState() {
    super.initState();
    // Items bought since the import may now match ingredients that were missing.
    unawaited(ref.read(cookbookImportServiceProvider).relink());
  }

  @override
  Widget build(BuildContext context) {
    final money = ref.watch(moneyProvider);
    final all = [
      for (final (r, f) in ref.watch(cookbookRecipesProvider))
        if (widget.book == null || r.sourceBook == widget.book) (r, f),
    ];
    int gap(CookbookFit f) => f.missing.length + f.short.length;
    final rows =
        all
            .where(
              (x) => switch (_show) {
                _Show.all => true,
                _Show.ready => x.$2.ready,
                _Show.almost => !x.$2.ready && gap(x.$2) <= 2,
              },
            )
            .toList()
          ..sort((a, b) {
            final g = gap(a.$2).compareTo(gap(b.$2));
            if (g != 0) return g;
            return (a.$1.sourcePage ?? 1 << 30).compareTo(b.$1.sourcePage ?? 1 << 30);
          });
    final ready = all.where((x) => x.$2.ready).length;
    final almost = all.where((x) => !x.$2.ready && gap(x.$2) <= 2).length;
    return Scaffold(
      appBar: AppBar(title: Text(widget.book ?? 'Cookbooks')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: Text('All · ${all.length}'),
                selected: _show == _Show.all,
                onSelected: (_) => setState(() => _show = _Show.all),
              ),
              ChoiceChip(
                label: Text('Cookable now · $ready'),
                selected: _show == _Show.ready,
                onSelected: (_) => setState(() => _show = _Show.ready),
              ),
              ChoiceChip(
                label: Text('Missing 1–2 · $almost'),
                selected: _show == _Show.almost,
                onSelected: (_) => setState(() => _show = _Show.almost),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (rows.isEmpty) const EmptyState(icon: Icons.menu_book_outlined, title: 'Nothing here with this filter'),
          for (final (r, f) in rows)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                f.ready ? Icons.check_circle : Icons.shopping_cart_outlined,
                color: f.ready ? context.colors.good : context.colors.warning,
                semanticLabel: f.ready ? 'Cookable now' : 'Needs shopping',
              ),
              title: Text(r.title),
              subtitle: Text([if (r.sourcePage != null) 'p. ${r.sourcePage}', f.summary].join(' · ')),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(money.format(f.costPerPortionMinor), style: context.text.labelMedium),
                  Text('a portion', style: context.text.labelSmall),
                ],
              ),
              onTap: () => context.push('/recipe/${r.id}'),
            ),
        ],
      ),
    );
  }
}
