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

/// "Sat 26 Sep", with the year when it isn't this year: "3 Mar 2025".
String dateLabel(DateTime d, DateTime now) => d.year == now.year ? shortDate(d) : DateFormat('d MMM yyyy').format(d);

/// For a message about something filed on [d]: "" when that's today, else " · yesterday",
/// " · Wednesday" or " · Wed 23 Sep".
String dayNote(DateTime d, DateTime now) => switch (dayLabel(d, now)) {
  'Today' => '',
  'Yesterday' => ' · yesterday',
  final day => ' · $day',
};

/// "today", "yesterday", "6 days ago".
String daysAgoLabel(int days) => switch (days) {
  <= 0 => 'today',
  1 => 'yesterday',
  _ => '$days days ago',
};

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

/// 1st, 2nd, 3rd, 4th, 11th, 21st.
String ordinal(int n) {
  final teen = n % 100 >= 11 && n % 100 <= 13;
  final suffix = teen
      ? 'th'
      : switch (n % 10) {
          1 => 'st',
          2 => 'nd',
          3 => 'rd',
          _ => 'th',
        };
  return '$n$suffix';
}

/// "the 1st (calendar months)", "the 17th".
String monthStartLabel(int day) => day <= 1 ? 'the 1st (calendar months)' : 'the ${ordinal(day)}';
