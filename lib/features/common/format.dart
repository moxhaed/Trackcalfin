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

/// A " · "-joined line (a recipe hook, a meta line) that never leaves a separator dangling:
/// if it fits on one line at [maxWidth] it keeps its separators, otherwise each part goes on
/// its own line without them (each part kept free of orphans).
String separatedText(
  String text,
  TextStyle style,
  double maxWidth, {
  TextScaler textScaler = TextScaler.noScaling,
  TextDirection textDirection = TextDirection.ltr,
}) {
  const sep = ' · ';
  if (!text.contains(sep) || !maxWidth.isFinite) return text;
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: textDirection,
    textScaler: textScaler,
    maxLines: 1,
  )..layout();
  final fits = painter.width <= maxWidth;
  painter.dispose();
  return fits ? text : text.split(sep).map(noOrphans).join('\n');
}
