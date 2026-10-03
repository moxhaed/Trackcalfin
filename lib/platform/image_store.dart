import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Stores receipt/pantry photos in the app documents directory.
class ImageStore {
  ImageStore(this.dirPath, {this.compressor});

  final String dirPath;

  /// Returns a downscaled JPEG, or null to keep the original bytes.
  final Future<Uint8List?> Function(String sourcePath)? compressor;

  /// The short edge a scan photo is scaled down to (never up): a 4:3 camera photo ends at
  /// 2000 × 1500. Gemini reads images at a fixed token budget (MEDIA_RESOLUTION_HIGH) and scales
  /// bigger ones down itself, so more pixels only cost upload time and memory; 2000 px on the
  /// long edge still gives a long receipt filling the frame ~15 px letters. Scaling the short
  /// edge (not the long one) leaves tall e-receipt screenshots at their full width.
  static const shortEdge = 1500;

  /// JPEG quality: about half the bytes of 90, with no visible loss on printed text.
  static const quality = 80;

  /// The phone's compressor: one decode and one JPEG encode of the original photo. It catches
  /// running out of memory and retries at a lower decode resolution.
  static Future<Uint8List?> compressScan(String path) =>
      FlutterImageCompress.compressWithFile(path, minWidth: shortEdge, minHeight: shortEdge, quality: quality);

  Future<String> importImage(String sourcePath, String name) async {
    final dir = Directory(dirPath);
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final out = File('$dirPath/$name.jpg');
    await out.writeAsBytes(await readScaled(sourcePath), flush: true);
    return out.path;
  }

  /// The photo at [sourcePath] as it is sent to the AI: downscaled when there is a compressor.
  Future<Uint8List> readScaled(String sourcePath) async {
    Uint8List? bytes;
    if (compressor != null) {
      try {
        bytes = await compressor!(sourcePath);
      } catch (_) {
        bytes = null;
      }
    }
    // The compressor gives back nothing when every retry ran out of memory.
    if (bytes == null || bytes.isEmpty) bytes = await File(sourcePath).readAsBytes();
    return bytes;
  }

  Future<Uint8List> read(String path) => File(path).readAsBytes();

  File get _pending => File('$dirPath/.pending_capture');

  /// Notes that the camera is open for a scan of [hint], so a photo Android hands to the next
  /// launch (it may close the app while the camera is open) goes to the right queue.
  Future<void> rememberCapture(String hint) async {
    try {
      await Directory(dirPath).create(recursive: true);
      await _pending.writeAsString(hint, flush: true);
    } catch (_) {}
  }

  /// The hint of a scan whose camera was open, cleared; null when no scan was waiting for one.
  Future<String?> takeCapture() async {
    try {
      if (!_pending.existsSync()) return null;
      final hint = (await _pending.readAsString()).trim();
      await _pending.delete();
      return hint.isEmpty ? 'receipt' : hint;
    } catch (_) {
      return null;
    }
  }

  /// Deletes stored images older than [age]; returns how many were removed.
  Future<int> cleanup(Duration age) async {
    final dir = Directory(dirPath);
    if (!dir.existsSync()) return 0;
    final cutoff = DateTime.now().subtract(age);
    var n = 0;
    for (final f in dir.listSync().whereType<File>()) {
      if (f.statSync().modified.isBefore(cutoff)) {
        try {
          f.deleteSync();
          n++;
        } catch (_) {}
      }
    }
    return n;
  }
}
