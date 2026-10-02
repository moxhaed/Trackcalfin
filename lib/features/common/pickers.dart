import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/region.dart';

/// Where you shop: countries by name, each with its currency. Returns the ISO code.
Future<String?> showCountryPicker(BuildContext context, {required String current}) => showDialog<String>(
  context: context,
  builder: (_) => _CountryDialog(current: current),
);

class _CountryDialog extends StatefulWidget {
  const _CountryDialog({required this.current});
  final String current;

  @override
  State<_CountryDialog> createState() => _CountryDialogState();
}

class _CountryDialogState extends State<_CountryDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final entries =
        Region.countries.entries
            .where((e) => q.isEmpty || e.value.$1.toLowerCase().contains(q) || e.key.toLowerCase() == q)
            .toList()
          ..sort((a, b) => a.value.$1.compareTo(b.value.$1));
    return AlertDialog(
      title: const Text('Where do you shop?'),
      contentPadding: const EdgeInsets.only(top: 12),
      content: SizedBox(
        width: 340,
        height: 420,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                decoration: const InputDecoration(hintText: 'Search', prefixIcon: Icon(Icons.search), isDense: true),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  for (final e in entries)
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                      title: Text(e.value.$1),
                      trailing: Text(e.value.$2, style: context.text.labelMedium),
                      selected: e.key == widget.current.toUpperCase(),
                      onTap: () => Navigator.of(context).pop(e.key),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))],
    );
  }
}

/// The language recipes and item names are written in. Returns the ISO code.
Future<String?> showLanguagePicker(BuildContext context, {required String current}) {
  final entries = Region.languages.entries.toList()..sort((a, b) => a.value.compareTo(b.value));
  return showDialog<String>(
    context: context,
    builder: (context) => SimpleDialog(
      title: const Text('Recipes and items in'),
      children: [
        for (final e in entries)
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            title: Text(e.value),
            selected: e.key == current.toLowerCase(),
            onTap: () => Navigator.of(context).pop(e.key),
          ),
      ],
    ),
  );
}

/// When a new day starts (midnight to 8 am): a snack before then counts toward the day before.
Future<int?> showDayStartPicker(BuildContext context, {required int current}) => showDialog<int>(
  context: context,
  builder: (context) => SimpleDialog(
    title: const Text('A new day starts at'),
    children: [
      for (var h = 0; h <= 8; h++)
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          title: Text(hourLabel(h)),
          selected: h == current,
          onTap: () => Navigator.of(context).pop(h),
        ),
    ],
  ),
);

/// "00:00", "04:00".
String hourLabel(int h) => '${h.toString().padLeft(2, '0')}:00';
