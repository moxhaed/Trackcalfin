import 'package:intl/intl.dart';

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
