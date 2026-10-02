import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/messenger.dart';
import '../../app/providers.dart';
import '../../application/scan_service.dart';
import '../../core/enums.dart';
import '../../domain/price_book.dart';
import '../../platform/notifications.dart';
import '../../platform/photo_capture.dart';
import '../common/format.dart';
import '../common/store_prices.dart';
import '../common/widgets.dart';

/// Snap → queue → back to what you were doing. The AI runs in the background.
Future<void> startScan(BuildContext context, WidgetRef ref, {required String hint, bool camera = true}) async {
  final timer = LogTimer();
  List<String> paths;
  try {
    paths = await PhotoCapture.pick(camera: camera);
  } catch (e) {
    if (context.mounted) showInfo(context, 'Could not open the camera: $e');
    return;
  }
  if (paths.isEmpty) return;
  final scans = ref.read(scanServiceProvider);
  await scans.enqueue(paths, hint: hint);
  celebrate();
  unawaited(ref.read(metricsServiceProvider).record('scan', timer.elapsed));
  final hasKey = await ref.read(aiGatewayProvider).hasKey;
  notifyApp(
    hasKey
        ? (hint == 'pantry' ? 'Pantry photo queued. Review it in the Inbox soon.' : 'Receipt queued. We\'ll sort it.')
        : 'Saved. Add a Gemini API key in Settings to process it.',
  );
  unawaited(processScansInBackground(ref));
}

/// Runs the scan queue and reports results.
Future<void> processScansInBackground(WidgetRef ref) async {
  final scans = ref.read(scanServiceProvider);
  final prices = ref.read(priceServiceProvider);
  final money = ref.read(moneyProvider);
  final results = await scans.processQueue();
  for (final r in results) {
    // A receipt filed on its own still says where its items were cheaper.
    final tx = r.autoCommitted ? r.transactionId : null;
    reportScan(r, money.format, tips: tx == null ? const [] : await prices.tipsFor(tx));
  }
  // Pantry photos can add items without a nutrition profile.
  if (results.isNotEmpty) unawaited(ref.read(nutritionServiceProvider).fillMissing());
}

void reportScan(ScanResult r, String Function(int) fmt, {List<PriceTip> tips = const []}) {
  final job = r.job;
  String msg;
  if (r.autoCommitted) {
    final items = job.lines.where((l) => l.ingredientKey != null).length;
    final total = job.lines.where((l) => l.include).fold(0, (a, l) => a + l.totalMinor);
    // An older receipt is filed on its own day: say which.
    final when = job.purchasedAt == null ? '' : dayNote(job.purchasedAt!, DateTime.now());
    msg = '${job.merchant ?? 'Receipt'} ${fmt(total)}$when · ${itemCount(items)} stocked';
  } else if (job.status == ScanStatus.needsReview) {
    msg = job.kind == ScanKind.pantry ? 'Pantry photo ready to review' : 'Receipt needs a quick look';
  } else if (job.status == ScanStatus.failed) {
    msg = 'Scan failed: ${job.lastError ?? 'unknown error'}';
  } else {
    return;
  }
  notifyFiled(msg, tips);
  unawaited(Notifications.instance.showScanResult(tips.isEmpty ? msg : '$msg ${tipLine(tips)}'));
}
