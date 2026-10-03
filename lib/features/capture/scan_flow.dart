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
/// Returns whether a photo was queued.
///
/// Everything is read from [ref] before the camera opens: the calling widget may be gone when
/// it closes (the Inbox card a Retake came from, or the whole app if Android closed it, in which
/// case [recoverLostScans] picks the photo up on the next start).
Future<bool> startScan(BuildContext context, WidgetRef ref, {required String hint, bool camera = true}) async {
  final timer = LogTimer();
  final scans = ref.read(scanServiceProvider);
  final images = ref.read(imageStoreProvider);
  final metrics = ref.read(metricsServiceProvider);
  final ai = ref.read(aiGatewayProvider);
  final run = _queueRunner(ref);
  List<String> paths;
  try {
    await images.rememberCapture(hint);
    paths = await PhotoCapture.pick(camera: camera);
  } catch (e) {
    notifyApp('Could not open the camera: $e');
    return false;
  } finally {
    await images.takeCapture();
  }
  if (paths.isEmpty) return false;
  try {
    await scans.enqueue(paths, hint: hint);
  } catch (e) {
    notifyApp('Could not save the photo: $e');
    return false;
  }
  celebrate();
  unawaited(metrics.record('scan', timer.elapsed));
  final hasKey = await ai.hasKey;
  notifyApp(
    hasKey
        ? (hint == 'pantry' ? 'Pantry photo queued. Review it in the Inbox soon.' : 'Receipt queued. We\'ll sort it.')
        : 'Saved. Add a Gemini API key in Settings to process it.',
  );
  unawaited(run());
  return true;
}

/// A photo taken for a scan just before Android closed the app (the camera needed the memory)
/// is handed to this launch: queue it as the scan it was meant to be.
Future<void> recoverLostScans(WidgetRef ref) async {
  final scans = ref.read(scanServiceProvider);
  final images = ref.read(imageStoreProvider);
  final run = _queueRunner(ref);
  final List<String> paths;
  try {
    paths = await PhotoCapture.recoverLost();
  } catch (e) {
    if (await images.takeCapture() != null) notifyApp('The photo from the camera was lost: $e');
    return;
  }
  // No scan was waiting for a photo (a label photo, say): leave it.
  final hint = await images.takeCapture();
  if (paths.isEmpty || hint == null) return;
  try {
    await scans.enqueue(paths, hint: hint);
  } catch (e) {
    notifyApp('Could not save the photo: $e');
    return;
  }
  notifyApp(hint == 'pantry' ? 'Pantry photo saved. Reading it now.' : 'Receipt photo saved. Reading it now.');
  unawaited(run());
}

/// Runs the scan queue and reports results.
Future<void> processScansInBackground(WidgetRef ref) => _queueRunner(ref)();

/// Inbox "Try again": back in the queue, read now.
Future<void> retryScan(WidgetRef ref, int jobId) async {
  final scans = ref.read(scanServiceProvider);
  final run = _queueRunner(ref);
  await scans.retry(jobId);
  await run();
}

/// Reads what it needs from [ref] now, so it can run after the caller is gone.
Future<void> Function() _queueRunner(WidgetRef ref) {
  final scans = ref.read(scanServiceProvider);
  final prices = ref.read(priceServiceProvider);
  final nutrition = ref.read(nutritionServiceProvider);
  final fmt = ref.read(moneyProvider).format;
  Future<void> run() async {
    final results = await scans.processQueue();
    for (final r in results) {
      // A receipt filed on its own still says where its items were cheaper.
      final tx = r.autoCommitted ? r.transactionId : null;
      final tips = tx == null ? const <PriceTip>[] : await prices.tipsFor(tx);
      reportScan(
        r,
        fmt,
        tips: tips,
        retry: () async {
          await scans.retry(r.job.id);
          await run();
        },
      );
    }
    // Pantry photos can add items without a nutrition profile.
    if (results.any((r) => !r.waiting)) unawaited(nutrition.fillMissing());
  }

  return run;
}

void reportScan(ScanResult r, String Function(int) fmt, {List<PriceTip> tips = const [], VoidCallback? retry}) {
  final job = r.job;
  final what = job.kind == ScanKind.pantry || job.userHint == 'pantry' ? 'pantry photo' : 'receipt';
  String msg;
  if (r.autoCommitted) {
    final items = job.lines.where((l) => l.ingredientKey != null).length;
    final total = r.filedMinor ?? job.lines.where((l) => l.include).fold<int>(0, (a, l) => a + l.totalMinor);
    // An older receipt is filed on its own day: say which.
    final when = job.purchasedAt == null ? '' : dayNote(job.purchasedAt!, DateTime.now());
    msg = '${job.merchant ?? 'Receipt'} ${fmt(total)}$when · ${itemCount(items)} stocked';
  } else if (job.status == ScanStatus.needsReview) {
    msg = job.kind == ScanKind.pantry ? 'Pantry photo ready to review' : 'Receipt needs a quick look';
  } else if (job.status == ScanStatus.failed || r.waiting) {
    // Never silent: the scan waits in the Inbox with the reason, and one tap tries again.
    final why = job.lastError ?? 'unknown error';
    msg = r.waiting ? 'Could not read the $what yet: $why. It waits in the Inbox.' : 'Scan failed: $why';
    notifyApp(
      msg,
      actionLabel: retry == null ? null : 'Try again',
      onAction: retry,
      duration: const Duration(seconds: 8),
    );
    if (!r.waiting) unawaited(Notifications.instance.showScanResult(msg));
    return;
  } else {
    return;
  }
  notifyFiled(msg, tips);
  unawaited(Notifications.instance.showScanResult(tips.isEmpty ? msg : '$msg ${tipLine(tips)}'));
}
