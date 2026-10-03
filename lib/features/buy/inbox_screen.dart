import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../application/scan_service.dart';
import '../../core/currency.dart';
import '../../core/enums.dart';
import '../../data/isar/collections/schemas.dart';
import '../../domain/validation/receipt_validator.dart';
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
      appBar: AppBar(title: const Text('Inbox')),
      body: jobs.isEmpty
          ? const EmptyState(
              icon: Icons.inbox_outlined,
              title: 'All clear',
              message: 'Scans that need a look land here. Clean receipts are filed automatically.',
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (!hasKey)
                  Card(
                    color: context.scheme.tertiaryContainer,
                    child: ListTile(
                      leading: const Icon(Icons.key_outlined),
                      title: const Text('Add a Gemini API key'),
                      subtitle: const Text('Scans wait here until the AI can read them.'),
                      onTap: () => context.go('/settings'),
                    ),
                  ),
                for (final j in jobs) ...[_JobCard(job: j), const SizedBox(height: 10)],
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
    final amount = !foreign
        ? money.format(receiptTotal)
        : job.fxRate == null
        ? moneyFor(job.currency!).format(receiptTotal)
        : '${money.format(Currency.convert(receiptTotal, from: job.currency!, to: home, rate: job.fxRate!))} '
              '(${moneyFor(job.currency!).format(receiptTotal)})';
    final title = switch (job.status) {
      ScanStatus.queued => pantry ? 'Pantry photo waiting' : 'Receipt waiting',
      ScanStatus.processing => 'Reading…',
      ScanStatus.needsReview =>
        pantry ? 'Pantry photo · ${job.lines.length} items' : '${job.merchant ?? 'Receipt'} · $amount',
      ScanStatus.failed => 'Could not read this scan',
      _ => 'Scan',
    };
    final attention = job.lines.where((l) => l.needsAttention).length;
    final dateFlag = job.flags.any(ReceiptValidator.dateFlags.contains);
    final subtitle = switch (job.status) {
      ScanStatus.queued => job.lastError ?? 'Will process when online',
      ScanStatus.processing => 'The AI is extracting items',
      ScanStatus.needsReview => [
        if (job.maybeDuplicate) 'already filed?',
        if (attention > 0) '$attention to check',
        if (job.flags.contains('total_mismatch')) 'totals differ',
        if (foreign) job.fxRate == null ? 'needs an exchange rate' : 'converted from ${job.currency}',
        if (job.flags.contains('currency_uncertain')) 'check the currency',
        if (dateFlag) 'check the date',
        if (job.flags.contains('merge_proposed')) 'possible matches',
        if (attention == 0 &&
            !job.maybeDuplicate &&
            job.flags.where((f) => f != 'foreign_currency').isEmpty &&
            (!foreign || job.fxRate != null))
          'ready to file',
      ].join(' · '),
      ScanStatus.failed => job.lastError ?? '',
      _ => '',
    };
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: switch (job.status) {
              ScanStatus.processing => const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
              ScanStatus.failed => Icon(Icons.error_outline, color: context.colors.critical),
              ScanStatus.needsReview => Icon(Icons.rate_review_outlined, color: context.scheme.primary),
              _ => const Icon(Icons.schedule),
            },
            title: Text(title),
            subtitle: Text('${dayLabel(job.capturedAt, DateTime.now())} ${timeOf(job.capturedAt)} · $subtitle'),
            onTap: job.status == ScanStatus.needsReview ? () => context.push('/inbox/${job.id}') : null,
          ),
          if (job.status == ScanStatus.failed || job.status == ScanStatus.queued)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => scans.discard(job.id), child: const Text('Discard')),
                  if (job.status == ScanStatus.failed)
                    TextButton(
                      onPressed: () {
                        scans.discard(job.id);
                        startScan(context, ref, hint: pantry ? 'pantry' : 'receipt');
                      },
                      child: const Text('Retake'),
                    ),
                  FilledButton.tonal(onPressed: () => retryScan(ref, job.id), child: const Text('Try again')),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
