import 'dart:io';

import 'package:image_picker/image_picker.dart';

/// Camera on phones, file picker on desktop.
///
/// Photos come back at full size: the app scales them down itself ([ImageStore.compressScan]).
/// Asking image_picker to resize makes it decode the whole photo on Android (a 50 MP photo is a
/// 200 MB bitmap) without handling running out of memory, which takes the app down.
class PhotoCapture {
  const PhotoCapture._();

  static bool get hasCamera => Platform.isAndroid || Platform.isIOS;

  static Future<List<String>> pick({required bool camera}) async {
    final picker = ImagePicker();
    if (camera && hasCamera) {
      final x = await picker.pickImage(source: ImageSource.camera);
      return x == null ? const [] : [x.path];
    }
    final xs = await picker.pickMultiImage(limit: 4);
    return xs.map((x) => x.path).toList();
  }

  /// Android can close the app while the camera app is open. The photo taken then is handed to
  /// the next launch: this returns it (empty when there is none). Throws if it was lost.
  static Future<List<String>> recoverLost() async {
    if (!Platform.isAndroid) return const [];
    final r = await ImagePicker().retrieveLostData();
    if (r.isEmpty) return const [];
    if (r.exception != null) throw r.exception!;
    return [for (final f in r.files ?? const <XFile>[]) f.path];
  }
}
