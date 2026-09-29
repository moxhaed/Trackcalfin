import 'dart:io';
import 'dart:typed_data';

/// Stores receipt/pantry photos in the app documents directory.
class ImageStore {
  ImageStore(this.dirPath, {this.compressor});

  final String dirPath;

  /// Returns a downscaled JPEG, or null to keep the original bytes.
  final Future<Uint8List?> Function(String sourcePath)? compressor;

  Future<String> importImage(String sourcePath, String name) async {
    final dir = Directory(dirPath);
    if (!dir.existsSync()) dir.createSync(recursive: true);
    Uint8List? bytes;
    if (compressor != null) {
      try {
        bytes = await compressor!(sourcePath);
      } catch (_) {
        bytes = null;
      }
    }
    bytes ??= await File(sourcePath).readAsBytes();
    final out = File('$dirPath/$name.jpg');
    await out.writeAsBytes(bytes, flush: true);
    return out.path;
  }

  Future<Uint8List> read(String path) => File(path).readAsBytes();

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
