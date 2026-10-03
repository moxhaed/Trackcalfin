import 'dart:io';

import 'package:flutter/services.dart';

bool _loaded = false;

/// Loads Roboto and the Material icons from the Flutter SDK, so text in a test measures as on
/// an Android phone. The default test font draws every glyph as a 1 em square, about twice as
/// wide as Roboto, so layout checks with it flag text that fits on a real phone.
Future<void> loadRealFonts() async {
  if (_loaded) return;
  final root =
      Platform.environment['FLUTTER_ROOT'] ??
      // flutter_tester lives in <sdk>/bin/cache/artifacts/engine/<platform>/.
      File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.parent.path;
  final dir = Directory('$root/bin/cache/artifacts/material_fonts');
  if (!dir.existsSync()) throw StateError('No material_fonts in the Flutter SDK at $root');
  Future<ByteData> read(String file) async => ByteData.sublistView(await File('${dir.path}/$file').readAsBytes());
  final roboto = FontLoader('Roboto');
  for (final w in ['Light', 'Regular', 'Medium', 'Bold', 'Black']) {
    roboto.addFont(read('Roboto-$w.ttf'));
  }
  await roboto.load();
  await (FontLoader('MaterialIcons')..addFont(read('MaterialIcons-Regular.otf'))).load();
  _loaded = true;
}
