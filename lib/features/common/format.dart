import 'package:flutter/painting.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../core/enums.dart';
import '../../domain/units.dart';

String qty(double v, BaseUnit u) => UnitConverter.format(v, u);

String dayLabel(DateTime d, DateTime now) {
  final a = DateTime(d.year, d.month, d.day);
  final b = DateTime(now.year, now.month, now.day);
  final diff = b.difference(a).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  if (diff < 7 && diff > 0) return DateFormat.EEEE().format(d);
  return DateFormat('EEE d MMM').format(d);
}

String shortDate(DateTime d) => DateFormat('EEE d MMM').format(d);
String timeOf(DateTime d) => DateFormat.Hm().format(d);

String daysLeftLabel(int? days) {
  if (days == null) return '';
  if (days <= 0) return 'use today';
  if (days == 1) return '1 day';
  return '$days days';
}

String kcal(double v) => '${NumberFormat.decimalPattern().format(v.round())} kcal';
String grams(double v) => '${v.round()} g';

String minutesLabel(int m) {
  if (m <= 0) return '';
  if (m < 60) return '$m min';
  final h = m ~/ 60;
  final r = m % 60;
  return r == 0 ? '$h h' : '$h h $r';
}

/// Prose for display without dangling words: a number stays with its unit ("51 g") and the
/// last two words stay together, so a line never ends with a lone word on the next one.
/// Uses no-break spaces, so only apply it to text that tests or code don't match literally.
String noOrphans(String s) {
  var t = s.trim().replaceAllMapped(
    RegExp(r'(\d) (g|kg|ml|l|pc|min|h|d|kcal|%)(?=$|[\s.,;:)])'),
    (m) => '${m[1]}\u00A0${m[2]}',
  );
  final last = t.lastIndexOf(' ');
  if (last > 0 && t.length - last <= 16) t = '${t.substring(0, last)}\u00A0${t.substring(last + 1)}';
  return t;
}

/// A separator-joined line (a recipe hook, a meta line, a comma summary) packed greedily:
/// as many parts per line as fit in [maxWidth], breaking only between parts and never inside
/// one. With the default " · " the separator is dropped at a break, so no line starts or ends
/// with "·"; with [keepSeparator] (", ") it stays at the line end ("Pasta, Gruyère," /
/// "Chicken sandwich, Sunscreen"). A part wider than a line goes on its own line and wraps
/// by itself (kept free of orphans for " · " lines). Text that fits on one line, or has no
/// separator, comes back unchanged.
String separatedText(
  String text,
  TextStyle style,
  double maxWidth, {
  String separator = ' · ',
  bool keepSeparator = false,
  TextScaler textScaler = TextScaler.noScaling,
  TextDirection textDirection = TextDirection.ltr,
}) {
  if (!text.contains(separator) || !maxWidth.isFinite) return text;
  final painter = TextPainter(textDirection: textDirection, textScaler: textScaler, maxLines: 1);
  try {
    double width(String s) {
      painter.text = TextSpan(text: s, style: style);
      painter.layout();
      return painter.width;
    }

    if (width(text) <= maxWidth) return text;
    final trimmed = separator.trimRight();
    final raw = text.split(separator);
    final parts = [
      for (var i = 0; i < raw.length; i++)
        keepSeparator ? (i < raw.length - 1 ? '${raw[i]}$trimmed' : raw[i]) : noOrphans(raw[i]),
    ];
    final glue = keepSeparator ? ' ' : separator;
    final lines = <String>[];
    var line = '';
    for (final part in parts) {
      final next = line.isEmpty ? part : '$line$glue$part';
      if (line.isNotEmpty && width(next) > maxWidth) {
        lines.add(line);
        line = part;
      } else {
        line = next;
      }
    }
    if (line.isNotEmpty) lines.add(line);
    return lines.join('\n');
  } finally {
    painter.dispose();
  }
}
