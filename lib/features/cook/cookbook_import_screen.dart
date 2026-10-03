import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar_community/isar.dart';

import '../../app/bootstrap.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../application/cookbook_import_service.dart';
import '../../core/enums.dart';
import '../../data/isar/collections/schemas.dart';
import '../../domain/cookbook.dart';
import '../../domain/feasibility.dart';
import '../../domain/stock_index.dart';
import '../../domain/units.dart';
import '../common/format.dart';
import '../common/widgets.dart';

final cookbookImportServiceProvider = Provider(
  (ref) => CookbookImportService(
    isar: ref.watch(isarProvider),
    ai: ref.watch(aiGatewayProvider),
    dir: () async => '${await appDataPath()}/cookbooks',
    now: ref.watch(nowProvider),
  ),
);

final cookbookImportProvider = StreamProvider.family<CookbookImport?, int>(
  (ref, id) => ref.watch(isarProvider).cookbookImports.watchObject(id, fireImmediately: true),
);

/// Imports still being read or reviewed, newest first.
final openCookbookImportsProvider = StreamProvider<List<CookbookImport>>(
  (ref) => ref
      .watch(isarProvider)
      .cookbookImports
      .where()
      .statusEqualTo(CookbookStatus.open)
      .sortByCreatedAtDesc()
      .watch(fireImmediately: true),
);

/// The import being read right now, and what the current pass does.
class CookbookRun {
  const CookbookRun({this.id, this.label = '', this.stopping = false});
  final int? id;
  final String label;

  /// Stop was tapped: the call under way finishes (and is kept), then it stops.
  final bool stopping;
  bool get running => id != null;
}

/// Reads one import pass by pass, one call at a time, until it is done, stopped, or a pass
/// fails for now (a daily limit, no connection). Keeps going when its screen is closed.
class CookbookRunner extends Notifier<CookbookRun> {
  bool _stop = false;

  @override
  CookbookRun build() => const CookbookRun();

  Future<void> start(int id) async {
    if (state.running) return;
    _stop = false;
    final service = ref.read(cookbookImportServiceProvider);
    var failures = 0;
    try {
      while (!_stop) {
        final job = await service.get(id);
        if (job == null || job.status != CookbookStatus.open || !job.hasWork) break;
        state = CookbookRun(id: id, label: service.nextLabel(job));
        final p = await service.step(id);
        if (p.error != null) {
          // Two passes in a row that the model couldn't answer: something is off with the book.
          if (p.transient || ++failures >= 2) break;
        } else {
          failures = 0;
        }
        if (!p.more) break;
      }
    } catch (_) {
      // The import was deleted or the database closed: nothing left to read.
    } finally {
      state = const CookbookRun();
    }
  }

  void stop() {
    if (!state.running) return;
    _stop = true;
    state = CookbookRun(id: state.id, label: state.label, stopping: true);
  }
}

final cookbookRunProvider = NotifierProvider<CookbookRunner, CookbookRun>(CookbookRunner.new);

/// Cook tab → "Import cookbook (PDF)": pick one PDF, keep a copy, open its review and start reading.
Future<void> importCookbook(BuildContext context, WidgetRef ref) async {
  final router = GoRouter.of(context);
  final messenger = ScaffoldMessenger.maybeOf(context);
  final service = ref.read(cookbookImportServiceProvider);
  final run = ref.read(cookbookRunProvider.notifier);
  try {
    final picked = await FilePicker.pickFile(
      dialogTitle: 'Import a cookbook',
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    if (picked == null) return;
    final id = await service.create(fileName: picked.name, bytes: await picked.readAsBytes());
    unawaited(router.push('/cookbook-import/$id'));
    unawaited(run.start(id));
  } catch (e) {
    messenger?.showSnackBar(
      SnackBar(content: Text(e is CookbookException ? e.message : 'Could not open the file: $e')),
    );
  }
}

/// A draft with its Dart numbers: matched to the pantry, have and missing, cost per portion.
class CookbookRow {
  CookbookRow(this.draft, this.recipe, this.fit, {required this.duplicate});
  final CookbookDraft draft;
  final Recipe recipe;
  final CookbookFit fit;

  /// A recipe with this title is already saved.
  final bool duplicate;
}

/// The unsaved drafts of an import, matched to the pantry as it is now.
final cookbookRowsProvider = Provider.family<List<CookbookRow>, int>((ref, id) {
  final job = ref.watch(cookbookImportProvider(id)).value;
  if (job == null) return const [];
  final pantry = ref.watch(ingredientsProvider).value ?? const <Ingredient>[];
  final saved = ref.watch(recipesProvider).value ?? const <Recipe>[];
  final titles = {
    for (final r in saved)
      if (r.status != RecipeStatus.dismissed) CookbookPlanner.normalizeTitle(r.title),
  };
  final stock = StockIndex(pantry);
  final matcher = CookbookMatcher(pantry);
  return [
    for (final d in job.unsaved)
      () {
        final r = CookbookReview.toRecipe(d, book: job.bookTitle, matcher: matcher, stock: stock);
        return CookbookRow(
          d,
          r,
          CookbookReview.fit(r, stock),
          duplicate: titles.contains(CookbookPlanner.normalizeTitle(d.title)),
        );
      }(),
  ];
});

enum _Show { all, ready, almost }

enum _Sort { book, missing, cost }

/// Reading a cookbook and choosing what to keep. Nothing is saved until "Save".
class CookbookImportScreen extends ConsumerStatefulWidget {
  const CookbookImportScreen({super.key, required this.id});
  final int id;

  @override
  ConsumerState<CookbookImportScreen> createState() => _CookbookImportScreenState();
}

class _CookbookImportScreenState extends ConsumerState<CookbookImportScreen> {
  final _selected = <int>{};
  final _seen = <int>{};
  var _show = _Show.all;
  var _sort = _Sort.book;
  bool _saving = false;

  /// New drafts start ticked, unless a recipe with that title is already saved.
  void _adopt(List<CookbookRow> rows) {
    for (final r in rows) {
      if (_seen.add(r.draft.entry) && !r.duplicate) _selected.add(r.draft.entry);
    }
  }

  List<CookbookRow> _visible(List<CookbookRow> rows) {
    final out = rows.where(
      (r) => switch (_show) {
        _Show.all => true,
        _Show.ready => r.fit.ready,
        _Show.almost => !r.fit.ready && r.fit.missing.length + r.fit.short.length <= 2,
      },
    );
    final list = out.toList();
    int byPage(CookbookRow a, CookbookRow b) => (a.draft.page ?? 1 << 30).compareTo(b.draft.page ?? 1 << 30);
    switch (_sort) {
      case _Sort.book:
        list.sort(byPage);
      case _Sort.missing:
        list.sort((a, b) {
          final m = (a.fit.missing.length + a.fit.short.length).compareTo(b.fit.missing.length + b.fit.short.length);
          return m != 0 ? m : byPage(a, b);
        });
      case _Sort.cost:
        list.sort((a, b) {
          final c = a.fit.costPerPortionMinor.compareTo(b.fit.costPerPortionMinor);
          return c != 0 ? c : byPage(a, b);
        });
    }
    return list;
  }

  Future<void> _save(CookbookImport job) async {
    if (_selected.isEmpty || _saving) return;
    final service = ref.read(cookbookImportServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    final picked = {..._selected};
    final ids = await service.save(job.id, picked);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _selected.removeAll(picked);
    });
    celebrate();
    showUndoOn(
      messenger,
      ids.length == 1 ? 'Saved 1 recipe from ${job.bookTitle}' : 'Saved ${ids.length} recipes from ${job.bookTitle}',
      detail: 'They are in the Cook tab under Cookbooks.',
      onUndo: () {
        _selected.addAll(picked);
        service.unsave(job.id, ids);
      },
    );
  }

  Future<void> _discard(CookbookImport job) async {
    final service = ref.read(cookbookImportServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    ref.read(cookbookRunProvider.notifier).stop();
    await service.discard(job.id);
    router.pop();
    showUndoOn(messenger, 'Import of ${job.bookTitle} discarded', onUndo: () => service.restore(job.id));
  }

  @override
  Widget build(BuildContext context) {
    final job = ref.watch(cookbookImportProvider(widget.id)).value;
    if (job == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('This import is gone.')),
      );
    }
    final rows = ref.watch(cookbookRowsProvider(widget.id));
    _adopt(rows);
    final visible = _visible(rows);
    final run = ref.watch(cookbookRunProvider);
    final money = ref.watch(moneyProvider);
    final ready = rows.where((r) => r.fit.ready).length;
    final almost = rows.where((r) => !r.fit.ready && r.fit.missing.length + r.fit.short.length <= 2).length;
    final saved = job.drafts.length - rows.length;
    final count = _selected.where((e) => rows.any((r) => r.draft.entry == e)).length;

    final header = <Widget>[
      _Progress(job: job, run: run),
      if (rows.isNotEmpty) ...[
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            ChoiceChip(
              label: Text('All · ${rows.length}'),
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
        Row(
          children: [
            PopupMenuButton<_Sort>(
              tooltip: 'Sort',
              initialValue: _sort,
              onSelected: (s) => setState(() => _sort = s),
              itemBuilder: (_) => const [
                PopupMenuItem(value: _Sort.book, child: Text('Book order')),
                PopupMenuItem(value: _Sort.missing, child: Text('Fewest missing')),
                PopupMenuItem(value: _Sort.cost, child: Text('Cheapest')),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sort, size: 18),
                    const SizedBox(width: 6),
                    Text(switch (_sort) {
                      _Sort.book => 'Book order',
                      _Sort.missing => 'Fewest missing',
                      _Sort.cost => 'Cheapest',
                    }),
                  ],
                ),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => setState(() => _selected.addAll(visible.map((r) => r.draft.entry))),
              child: const Text('Select all'),
            ),
            TextButton(
              onPressed: () => setState(() => _selected.removeAll(visible.map((r) => r.draft.entry))),
              child: const Text('None'),
            ),
          ],
        ),
      ],
      if (saved > 0)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            saved == 1 ? '1 recipe saved to your recipes.' : '$saved recipes saved to your recipes.',
            style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant),
          ),
        ),
      if (rows.isNotEmpty && visible.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text('Nothing here with this filter.', style: context.text.bodyMedium),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(job.bookTitle, overflow: TextOverflow.ellipsis),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'discard') _discard(job);
            },
            itemBuilder: (_) => const [PopupMenuItem(value: 'discard', child: Text('Discard this import'))],
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: header.length + visible.length,
        itemBuilder: (context, i) {
          if (i < header.length) return header[i];
          final row = visible[i - header.length];
          return _DraftTile(
            row: row,
            selected: _selected.contains(row.draft.entry),
            money: money.format(row.fit.costPerPortionMinor),
            onChanged: (v) => setState(() => v ? _selected.add(row.draft.entry) : _selected.remove(row.draft.entry)),
            onOpen: () => _showRecipe(context, row),
          );
        },
      ),
      bottomNavigationBar: rows.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  onPressed: count == 0 || _saving ? null : () => _save(job),
                  icon: const Icon(Icons.bookmark_add_outlined),
                  label: Text(count == 1 ? 'Save 1 recipe' : 'Save $count recipes'),
                ),
              ),
            ),
    );
  }

  void _showRecipe(BuildContext context, CookbookRow row) => showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => _RecipeSheet(
      row: row,
      selected: _selected.contains(row.draft.entry),
      onChanged: (v) => setState(() => v ? _selected.add(row.draft.entry) : _selected.remove(row.draft.entry)),
    ),
  );
}

/// File, pages and how far the reading got, with Stop / Continue / Try again.
class _Progress extends ConsumerWidget {
  const _Progress({required this.job, required this.run});
  final CookbookImport job;
  final CookbookRun run;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mine = run.id == job.id;
    final busyElsewhere = run.running && !mine;
    final total = job.entries.length;
    final handled = job.entries.where((e) => e.state != CookbookEntryState.pending).length;
    final failed = job.entries.where((e) => e.state == CookbookEntryState.failed).length;
    final notFound = job.entries.where((e) => e.state == CookbookEntryState.notFound).length;
    final read = job.drafts.length;
    final runner = ref.read(cookbookRunProvider.notifier);
    final service = ref.read(cookbookImportServiceProvider);
    final soFar = read == 1 ? '1 recipe so far' : '$read recipes so far';
    final String status;
    if (mine) {
      status = '${run.label} · $soFar${run.stopping ? ' · stopping after this part' : ''}';
    } else if (job.hasWork) {
      status = job.lastError ?? (handled == 0 && !job.indexDone ? 'Ready to read.' : 'Paused · $soFar');
    } else {
      status = [
        read == 1 ? '1 recipe read' : '$read recipes read',
        if (notFound > 0) '$notFound listed but not found',
        if (failed > 0) "$failed couldn't be read",
      ].join(' · ');
    }
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.picture_as_pdf_outlined, color: context.scheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.fileName, style: context.text.titleSmall, overflow: TextOverflow.ellipsis),
                    Text(
                      [
                        if (job.pageCount != null) '${job.pageCount} pages',
                        '${(job.sizeBytes / 1048576).toStringAsFixed(job.sizeBytes < 10485760 ? 1 : 0)} MB',
                        if (total > 0) '$total recipes listed',
                      ].join(' · '),
                      style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (mine || job.hasWork) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(value: job.indexDone && total > 0 ? handled / total : (mine ? null : 0)),
          ],
          const SizedBox(height: 8),
          Text(
            status,
            style: context.text.bodyMedium?.copyWith(
              color: !mine && job.lastError != null ? context.colors.critical : null,
            ),
          ),
          if (!mine && job.hasWork && job.lastError != null)
            Text(
              'What was read so far is kept. Continue later, for example after the daily limit resets.',
              style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant),
            ),
          if (busyElsewhere)
            Text(
              'Another cookbook is being read. This one goes on after it.',
              style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant),
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              if (mine)
                OutlinedButton.icon(
                  onPressed: run.stopping ? null : runner.stop,
                  icon: const Icon(Icons.pause, size: 18),
                  label: const Text('Stop'),
                ),
              if (!mine && job.hasWork)
                FilledButton.tonalIcon(
                  onPressed: busyElsewhere ? null : () => runner.start(job.id),
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: Text(handled == 0 && !job.indexDone && job.lastError == null ? 'Start reading' : 'Continue'),
                ),
              if (!mine && failed > 0)
                TextButton(
                  onPressed: busyElsewhere
                      ? null
                      : () async {
                          await service.retryFailed(job.id);
                          await runner.start(job.id);
                        },
                  child: Text(failed == 1 ? 'Try the failed one again' : 'Try the $failed failed again'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DraftTile extends StatelessWidget {
  const _DraftTile({
    required this.row,
    required this.selected,
    required this.money,
    required this.onChanged,
    required this.onOpen,
  });
  final CookbookRow row;
  final bool selected;
  final String money;
  final ValueChanged<bool> onChanged;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final d = row.draft;
    final f = row.fit;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Checkbox(value: selected, onChanged: (v) => onChanged(v ?? false)),
      title: Text(d.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            [
              if (d.page != null) 'p. ${d.page}',
              'serves ${d.servings}',
              if (d.prepMinutes + d.cookMinutes > 0) minutesLabel(d.prepMinutes + d.cookMinutes),
            ].join(' · '),
          ),
          Text(f.summary),
          if (row.duplicate || d.flags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (row.duplicate)
                    StatusPill(label: 'Already in your recipes', color: c.warning, icon: Icons.copy_all_outlined),
                  for (final flag in d.flags.where((f) => f.startsWith('allergen:')))
                    StatusPill(
                      label: 'Contains ${flag.split(':').last}',
                      color: c.critical,
                      icon: Icons.warning_amber_rounded,
                    ),
                  if (d.flags.any((f) => f.startsWith('qty_suspect:')))
                    StatusPill(label: 'Check the amounts', color: c.warning, icon: Icons.scale_outlined),
                ],
              ),
            ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(
            f.ready ? Icons.check_circle : Icons.shopping_cart_outlined,
            color: f.ready ? c.good : c.warning,
            size: 20,
            semanticLabel: f.ready ? 'Cookable now' : 'Needs shopping',
          ),
          Text(money, style: context.text.labelMedium),
          Text('a portion', style: context.text.labelSmall),
        ],
      ),
      isThreeLine: true,
      onTap: onOpen,
    );
  }
}

/// One draft in full: each ingredient as printed, have or missing, and the short method.
class _RecipeSheet extends ConsumerStatefulWidget {
  const _RecipeSheet({required this.row, required this.selected, required this.onChanged});
  final CookbookRow row;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  ConsumerState<_RecipeSheet> createState() => _RecipeSheetState();
}

class _RecipeSheetState extends ConsumerState<_RecipeSheet> {
  late bool _selected = widget.selected;

  @override
  Widget build(BuildContext context) {
    final row = widget.row;
    final d = row.draft;
    final r = row.recipe;
    final f = row.fit;
    final c = context.colors;
    final money = ref.watch(moneyProvider);
    final stock = StockIndex(ref.watch(ingredientsProvider).value ?? const <Ingredient>[]);
    final printed = {for (final l in d.ingredients) l.name: l.asWritten};
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      builder: (context, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(d.title, style: context.text.titleLarge),
          const SizedBox(height: 4),
          Text(
            [
              if (d.page != null) 'Page ${d.page}',
              'serves ${d.servings}',
              if (d.prepMinutes > 0) '${d.prepMinutes} min prep',
              if (d.cookMinutes > 0) '${d.cookMinutes} min cooking',
            ].join(' · '),
            style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(f.summary, style: context.text.bodyMedium),
          Text(
            [
              '${money.format(f.costPerPortionMinor)} a portion at your prices',
              if (f.missing.isNotEmpty) 'not counting what is missing',
              if (f.unpriced > 0) '${f.unpriced} with no price yet',
            ].join(', '),
            style: context.text.bodySmall?.copyWith(color: context.scheme.onSurfaceVariant),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _selected,
            title: const Text('Save this recipe'),
            onChanged: (v) {
              setState(() => _selected = v ?? false);
              widget.onChanged(_selected);
            },
          ),
          Text(
            'INGREDIENTS · ${r.defaultPortions} ${r.defaultPortions == 1 ? 'PORTION' : 'PORTIONS'}',
            style: context.text.labelMedium,
          ),
          for (final ri in r.ingredients)
            Builder(
              builder: (context) {
                final ing = stock.resolve(ri);
                final short = f.feasibility.shortfalls.where((s) => s.item == ri).firstOrNull;
                final (IconData icon, Color color, String status) = switch ((ing, short)) {
                  (null, _) => (Icons.shopping_cart_outlined, c.warning, 'not in your pantry'),
                  (_, final Shortfall s) => (
                    Icons.trending_down,
                    c.serious,
                    'have ${UnitConverter.format(s.have, s.unit)}',
                  ),
                  (final Ingredient i, null) => (
                    Icons.check,
                    c.good,
                    'have ${UnitConverter.format(i.qtyOnHand, i.baseUnit)}',
                  ),
                };
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(icon, color: color, size: 20),
                  title: Text(ing == null ? ri.name : '${ri.name} → ${ing.name}'),
                  subtitle: Text(
                    [status, if ((printed[ri.name] ?? '').isNotEmpty) '"${printed[ri.name]}"'].join(' · '),
                  ),
                  trailing: Text(UnitConverter.format(ri.qtyPerPortion * r.defaultPortions, ri.unit)),
                );
              },
            ),
          if (r.omitted.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Optional, left out: ${r.omitted.join(', ')}', style: context.text.bodySmall),
            ),
          const SizedBox(height: 12),
          Text('METHOD (SHORTENED)', style: context.text.labelMedium),
          const SizedBox(height: 6),
          for (final (i, s) in d.steps.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(radius: 11, child: Text('${i + 1}', style: context.text.labelSmall)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(s)),
                ],
              ),
            ),
          if (d.flags.any((f) => f.startsWith('qty_suspect:')))
            Text(
              'Some amounts look large for one portion: check them against the book after saving.',
              style: context.text.bodySmall?.copyWith(color: c.serious),
            ),
        ],
      ),
    );
  }
}
