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
    final padding = EdgeInsets.fromLTRB(
      AppSpace.screen,
      0,
      AppSpace.screen,
      MediaQuery.paddingOf(context).bottom + AppSpace.x6,
    );
    return Scaffold(
      appBar: const PageBar(title: 'Stats'),
      body: stats.when(
        loading: () => ListView(padding: padding, children: const [_StatsSkeleton()]),
        error: (e, _) => ListView(
          padding: EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.headerGap, AppSpace.screen, 0),
          children: [AppNotice(kind: NoticeKind.critical, message: "Couldn't load this.", meta: '$e')],
        ),
        data: (s) {
          final byTask = <AiTask, List<AiCallLog>>{};
          for (final l in s.logs) {
            byTask.putIfAbsent(l.task, () => []).add(l);
          }
          final secondary = context.scheme.onSurfaceVariant;
          Widget empty(String text) => Padding(
            padding: const EdgeInsets.all(AppSpace.x4),
            child: Text(text, style: context.text.bodyMedium?.copyWith(color: secondary)),
          );
          return ListView(
            padding: padding,
            children: [
              const SectionTitle('Median time to log · 30 days', first: true),
              AppGroup(
                children: [
                  if (s.medians.isEmpty)
                    empty('No logs measured yet.')
                  else
                    for (final e in s.medians.entries)
                      _MedianRow(label: _labels[e.key] ?? e.key, id: e.key, stat: e.value),
                ],
              ),
              const SectionTitle('AI calls · 30 days'),
              AppGroup(
                children: [
                  if (s.logs.isEmpty)
                    empty('No AI calls yet.')
                  else
                    for (final e in byTask.entries)
                      AppRow(
                        title: switch (e.key) {
                          AiTask.receipt => 'Receipts & pantry (Prompt A)',
                          AiTask.dailyRecipe => 'Daily pick (Prompt B)',
                          AiTask.spontaneousRecipe => 'Ask (Prompt C)',
                          AiTask.nutritionEstimate => 'Macro estimates (Prompt D)',
                          AiTask.nutritionLabel => 'Nutrition labels (Prompt E)',
                        },
                        subtitle:
                            '${e.value.length} calls · ${e.value.where((l) => !l.parsedOk).length} failed · '
                            '${e.value.where((l) => l.repaired).length} repaired · '
                            'median ${_median(e.value.map((l) => l.latencyMs).toList()) ~/ 1000} s · '
                            '${_sum(e.value.map((l) => l.inputTokens ?? 0))} in / '
                            '${_sum(e.value.map((l) => l.outputTokens ?? 0))} out tokens',
                      ),
                ],
              ),
              if (s.logs.isNotEmpty) ...[
                const SectionTitle('Recent calls'),
                AppGroup(children: [for (final l in s.logs.take(15)) _CallRow(log: l)]),
              ],
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

/// One median row: the label, how many logs it rests on, and the time with a status icon
/// (a check at 3 s or under, a warning above; "Ask" includes the AI, so it has none).
class _MedianRow extends StatelessWidget {
  const _MedianRow({required this.label, required this.id, required this.stat});
  final String label;
  final String id;
  final ({int median, int count}) stat;

  @override
  Widget build(BuildContext context) {
    final fast = stat.median <= 3000;
    return AppRow(
      title: label,
      subtitle: '${stat.count} logs',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(valueSpan(context, '${(stat.median / 1000).toStringAsFixed(1)} s', context.nums.body)),
          const SizedBox(width: AppSpace.x2),
          // A fixed 18 slot keeps the times aligned when a row has no icon.
          SizedBox.square(
            dimension: 18,
            child: id == 'ask'
                ? null
                : Icon(
                    fast ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                    size: 18,
                    color: fast ? context.colors.good : context.colors.warning,
                    semanticLabel: fast ? 'Under 3 s' : 'Over 3 s',
                  ),
          ),
        ],
      ),
    );
  }
}

/// A recent AI call: prompt, model and outcome on one line, the time under it, and the raw
/// response in a monospace panel when expanded.
class _CallRow extends StatelessWidget {
  const _CallRow({required this.log});
  final AiCallLog log;

  @override
  Widget build(BuildContext context) {
    final l = log;
    // The status says what happened in words ("failed" in the error ink); the model and the
    // time go under it.
    final meta = [if (l.model.isNotEmpty) l.model, '${l.at.toLocal()}'.substring(0, 16)].join(' · ');
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: AppSpace.x4),
      childrenPadding: const EdgeInsets.fromLTRB(AppSpace.x4, 0, AppSpace.x4, AppSpace.x4),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      title: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '${l.promptVersion} · '),
            l.parsedOk
                ? const TextSpan(text: 'ok')
                : TextSpan(
                    text: 'failed',
                    style: TextStyle(color: context.colors.criticalInk, fontWeight: FontWeight.w600),
                  ),
          ],
        ),
        style: context.text.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: SeparatedText(meta, style: context.text.bodySmall),
      children: [
        if (l.error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.x2),
            child: Text(l.error!, style: context.text.bodySmall?.copyWith(color: context.colors.criticalInk)),
          ),
        if (l.validationFlags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.x2),
            child: Text(l.validationFlags.join('\n'), style: context.text.bodySmall),
          ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpace.x3),
          decoration: BoxDecoration(color: context.colors.fill, borderRadius: BorderRadius.circular(AppRadius.input)),
          child: SelectableText(
            l.rawResponse.length > 1500 ? '${l.rawResponse.substring(0, 1500)}…' : l.rawResponse,
            style: TextStyle(
              fontFamily: 'monospace',
              fontFamilyFallback: const ['Menlo', 'Roboto Mono', 'Courier New'],
              fontSize: 11,
              height: 16 / 11,
              color: context.scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

/// The stats page while the numbers load: the real section titles over pulsing rows.
class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget row(double title, double value) => ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.x4, vertical: AppSpace.x3),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(width: title, style: context.text.bodyLarge),
                const SizedBox(height: 2),
                SkeletonLine(width: 56, style: context.text.bodySmall),
              ],
            ),
            const Spacer(),
            SkeletonLine(width: value, style: context.text.bodyLarge),
          ],
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('Median time to log · 30 days', first: true),
        AppSkeleton(child: AppGroup(children: [row(80, 40), row(120, 40), row(64, 40)])),
        const SectionTitle('AI calls · 30 days'),
        AppSkeleton(child: AppGroup(children: [row(180, 0), row(140, 0)])),
      ],
    );
  }
}
