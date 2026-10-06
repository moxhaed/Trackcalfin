import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../application/scan_service.dart';
import '../../core/currency.dart';
import '../../core/enums.dart';
import '../../data/isar/collections/schemas.dart';
import '../capture/scan_flow.dart';
import '../common/format.dart';
import '../common/widgets.dart';
import 'fx_widgets.dart';

/// Scans that need attention: review by exception (rule R5).
class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(scanJobsProvider).value ?? const [];
    final hasKey = ref.watch(hasApiKeyProvider).value ?? false;
    return Scaffold(
      appBar: const PageBar(title: 'Inbox'),
      body: jobs.isEmpty
          ? const EmptyState(
              icon: Icons.inbox_outlined,
              title: 'All clear',
              message: 'Scans that need a look land here. Clean receipts are filed automatically.',
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(
                AppSpace.screen,
                AppSpace.headerGap,
                AppSpace.screen,
                MediaQuery.paddingOf(context).bottom + AppSpace.x6,
              ),
              children: [
                if (!hasKey) ...[
                  AppNotice(
                    icon: Icons.key_outlined,
                    title: 'Add a Gemini API key',
                    message: 'Scans wait here until the AI can read them.',
                    onTap: () => context.go('/settings'),
                  ),
                  const SizedBox(height: AppSpace.x3),
                ],
                AppGroup(
                  separatorIndent: AppGroup.indentIcon,
                  children: [for (final j in jobs) _JobCard(job: j)],
                ),
              ],
            ),
    );
  }
}

class _JobCard extends ConsumerWidget {
  const _JobCard({required this.job});
  final ScanJob job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final money = ref.watch(moneyProvider);
    final scans = ref.read(scanServiceProvider);
    final pantry = job.kind == ScanKind.pantry || job.userHint == 'pantry';
    final home = ref.watch(profileProvider).value?.currency ?? 'EUR';
    final foreign = ScanService.isForeign(job, home);
    final receiptTotal = job.lines.where((l) => l.include).fold(0, (a, l) => a + l.totalMinor);
    // The amount sits in the trailing slot, like the Ledger: in the home currency over the
    // receipt's own "(CHF 23.10)"; without a rate only the receipt's currency is known.
    final original = foreign ? moneyFor(job.currency!).format(receiptTotal) : null;
    final amount = !foreign
        ? money.format(receiptTotal)
        : job.fxRate == null
        ? original!
        : money.format(Currency.convert(receiptTotal, from: job.currency!, to: home, rate: job.fxRate!));
    final amountCaption = foreign && job.fxRate != null ? '($original)' : null;
    final title = switch (job.status) {
      ScanStatus.queued => pantry ? 'Pantry photo waiting' : 'Receipt waiting',
      ScanStatus.processing => 'Reading…',
      ScanStatus.needsReview => pantry ? 'Pantry photo · ${job.lines.length} items' : job.merchant ?? 'Receipt',
      ScanStatus.failed => 'Could not read this scan',
      _ => 'Scan',
    };
    final attention = job.lines.where((l) => l.needsAttention).length;
    final subtitle = switch (job.status) {
      ScanStatus.queued => job.lastError ?? 'Will process when online',
      ScanStatus.processing => 'The AI is extracting items',
      ScanStatus.needsReview => [
        if (attention > 0) '$attention to check',
        if (job.flags.contains('total_mismatch')) 'totals differ',
        // With a rate, the "(CHF 23.10)" under the amount already says it was converted.
        if (foreign && job.fxRate == null) 'needs an exchange rate',
        if (job.flags.contains('currency_uncertain')) 'check the currency',
        if (job.flags.contains('merge_proposed')) 'possible duplicates',
        if (attention == 0 &&
            job.flags.where((f) => f != 'foreign_currency').isEmpty &&
            (!foreign || job.fxRate != null))
          'ready to file',
      ].join(' · '),
      ScanStatus.failed => job.lastError ?? '',
      _ => '',
    };
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppRow(
          leading: switch (job.status) {
            ScanStatus.processing => const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            ScanStatus.failed => Icon(Icons.error_outline_rounded, size: 20, color: c.critical),
            ScanStatus.needsReview => Icon(Icons.rate_review_outlined, size: 20, color: context.scheme.primary),
            _ => const Icon(Icons.schedule_rounded, size: 20),
          },
          title: title,
          subtitle: '${dayLabel(job.capturedAt, DateTime.now())} ${timeOf(job.capturedAt)} · $subtitle',
          value: job.status == ScanStatus.needsReview && !pantry ? amount : null,
          valueCaption: job.status == ScanStatus.needsReview && !pantry ? amountCaption : null,
          chevron: job.status == ScanStatus.needsReview,
          onTap: job.status == ScanStatus.needsReview ? () => context.push('/inbox/${job.id}') : null,
        ),
        if (job.status == ScanStatus.failed || job.status == ScanStatus.queued)
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.x4, 0, AppSpace.x4, AppSpace.x3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: c.criticalInk),
                  onPressed: () => scans.discard(job.id),
                  child: const Text('Discard'),
                ),
                if (job.status == ScanStatus.failed)
                  TextButton(
                    onPressed: () {
                      scans.discard(job.id);
                      startScan(context, ref, hint: pantry ? 'pantry' : 'receipt');
                    },
                    child: const Text('Retake'),
                  ),
                const SizedBox(width: AppSpace.x2),
                FilledButton.tonal(
                  style: AppTheme.tonalButton(context, small: true),
                  onPressed: () async {
                    await scans.retry(job.id);
                    await processScansInBackground(ref);
                  },
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
