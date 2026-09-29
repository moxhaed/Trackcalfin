import 'dart:io';

import 'package:image_picker/image_picker.dart';

/// Camera on phones, file picker on desktop.
class PhotoCapture {
  const PhotoCapture._();

  static bool get hasCamera => Platform.isAndroid || Platform.isIOS;

  static Future<List<String>> pick({required bool camera}) async {
    final picker = ImagePicker();
    if (camera && hasCamera) {
      final x = await picker.pickImage(source: ImageSource.camera, imageQuality: 90, maxWidth: 2400, maxHeight: 2400);
      return x == null ? const [] : [x.path];
    }
    final xs = await picker.pickMultiImage(imageQuality: 90, maxWidth: 2400, maxHeight: 2400, limit: 4);
    return xs.map((x) => x.path).toList();
  }
}
