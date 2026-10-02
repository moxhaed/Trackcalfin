import 'dart:io';

import 'package:flutter/material.dart';

import 'widgets.dart';

/// The photos still kept of [paths] (photos are deleted after 30 days).
List<File> keptPhotos(List<String> paths) => [
  for (final p in paths)
    if (File(p).existsSync()) File(p),
];

/// The photos a scan was read from, full screen: pinch to zoom, swipe between pages.
Future<void> showPhotos(BuildContext context, List<String> paths) async {
  final files = keptPhotos(paths);
  if (files.isEmpty) {
    showInfo(context, 'The photo is no longer on this phone. Photos are kept for 30 days.');
    return;
  }
  await Navigator.of(
    context,
    rootNavigator: true,
  ).push(MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => _PhotoPage(files)));
}

class _PhotoPage extends StatefulWidget {
  const _PhotoPage(this.files);
  final List<File> files;

  @override
  State<_PhotoPage> createState() => _PhotoPageState();
}

class _PhotoPageState extends State<_PhotoPage> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final n = widget.files.length;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(n > 1 ? 'Photo ${_page + 1} of $n' : 'Photo'),
      ),
      body: PageView(
        onPageChanged: (i) => setState(() => _page = i),
        children: [
          for (final f in widget.files)
            InteractiveViewer(
              maxScale: 6,
              child: Center(child: Image.file(f, fit: BoxFit.contain)),
            ),
        ],
      ),
    );
  }
}
