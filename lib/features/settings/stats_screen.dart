import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/enums.dart';
import '../../data/isar/collections/schemas.dart';
import '../common/widgets.dart';

class _Stats {
  _Stats(this.medians, this.logs);
  final Map<String, ({int median, int count})> medians;
  final List<AiCallLog> logs;
}

final _statsProvider = FutureProvider.autoDispose<_Stats>((ref) async {
  final isar = ref.watch(isarProvider);
  final medians = await ref.watch(metricsServiceProvider).medians();
  final logs = await isar.aiCallLogs
      .where()
      .atGreaterThan(DateTime.now().subtract(const Duration(days: 30)))
      .sortByAtDesc()
      .findAll();
  return _Stats(medians, logs);
});

/// Settings → Stats: is every log still under 3 seconds? What does the AI cost?
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  static const _labels = {
    'expense': 'Expense',
    'scan': 'Scan (to queued)',
    'cook': 'Cook',
    'eat': 'Eat',
    'ask': 'Ask (incl. AI)',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(_statsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: stats.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (s) {
          final byTask = <AiTask, List<AiCallLog>>{};
          for (final l in s.logs) {
            byTask.putIfAbsent(l.task, () => []).add(l);
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SectionCard(
                title: 'Median time to log · 30 days',
                child: s.medians.isEmpty
                    ? const Text('No logs measured yet.')
                    : Column(
                        children: [
                          for (final e in s.medians.entries)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              title: Text(_labels[e.key] ?? e.key),
                              subtitle: Text('${e.value.count} logs'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${(e.value.median / 1000).toStringAsFixed(1)} s',
                                    style: context.text.titleSmall,
                                  ),
                                  const SizedBox(width: 6),
                                  if (e.key != 'ask')
                                    Icon(
                                      e.value.median <= 3000 ? Icons.check_circle : Icons.warning_amber_rounded,
                                      size: 18,
                                      color: e.value.median <= 3000 ? context.colors.good : context.colors.warning,
                                      semanticLabel: e.value.median <= 3000 ? 'Under 3 s' : 'Over 3 s',
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
              ),
              const SizedBox(height: 12),
              SectionCard(
                title: 'AI calls · 30 days',
                child: s.logs.isEmpty
                    ? const Text('No AI calls yet.')
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final e in byTask.entries)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(switch (e.key) {
                                    AiTask.receipt => 'Receipts & pantry (Prompt A)',
                                    AiTask.dailyRecipe => 'Daily pick (Prompt B)',
                                    AiTask.spontaneousRecipe => 'Ask (Prompt C)',
                                    AiTask.nutritionEstimate => 'Macro estimates (Prompt D)',
                                    AiTask.nutritionLabel => 'Nutrition labels (Prompt E)',
                                  }, style: context.text.titleSmall),
                                  Text(
                                    '${e.value.length} calls · ${e.value.where((l) => !l.parsedOk).length} failed · '
                                    '${e.value.where((l) => l.repaired).length} repaired · '
                                    'median ${_median(e.value.map((l) => l.latencyMs).toList()) ~/ 1000} s · '
                                    '${_sum(e.value.map((l) => l.inputTokens ?? 0))} in / ${_sum(e.value.map((l) => l.outputTokens ?? 0))} out tokens',
                                    style: context.text.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
              ),
              const SizedBox(height: 12),
              if (s.logs.isNotEmpty)
                SectionCard(
                  title: 'Recent calls',
                  child: Column(
                    children: [
                      for (final l in s.logs.take(15))
                        ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          title: Text(
                            '${l.promptVersion} · ${l.model.isNotEmpty ? '${l.model} · ' : ''}${l.parsedOk ? 'ok' : 'failed'}',
                          ),
                          subtitle: Text('${l.at.toLocal()}'.substring(0, 16)),
                          children: [
                            if (l.error != null) Text(l.error!, style: TextStyle(color: context.colors.critical)),
                            if (l.validationFlags.isNotEmpty)
                              Text(l.validationFlags.join('\n'), style: context.text.bodySmall),
                            SelectableText(
                              l.rawResponse.length > 1500 ? '${l.rawResponse.substring(0, 1500)}…' : l.rawResponse,
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  static int _median(List<int> v) {
    if (v.isEmpty) return 0;
    v.sort();
    return v[v.length ~/ 2];
  }

  static int _sum(Iterable<int> v) => v.fold(0, (a, b) => a + b);
}
