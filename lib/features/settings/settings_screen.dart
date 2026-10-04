import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../application/habit_scheduler.dart';
import '../../core/enums.dart';
import '../../data/isar/collections/schemas.dart';
import '../common/widgets.dart';

const dietOptions = ['vegetarian', 'vegan', 'pescatarian', 'halal', 'gluten_free', 'high_protein', 'low_carb'];
const equipmentOptions = [
  'oven',
  'air_fryer',
  'microwave',
  'rice_cooker',
  'slow_cooker',
  'pressure_cooker',
  'blender',
  'grill',
];

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(profileProvider).value;
    final money = ref.watch(moneyProvider);
    if (p == null) {
      return const Scaffold(
        appBar: TabHeader(title: 'Settings'),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final svc = ref.read(profileServiceProvider);
    Future<void> update(void Function(UserProfile p) f) async {
      await svc.update(f);
      unawaited(replanNotifications(ref));
    }

    return Scaffold(
      appBar: const TabHeader(title: 'Settings'),
      body: ListView(
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 24),
        children: [
          const GroupHeader('Goals', first: true),
          _MoneyTile(
            title: 'Monthly food budget',
            valueMinor: p.monthlyFoodBudgetMinor,
            subtitle: 'Weekly: ${money.compact((p.monthlyFoodBudgetMinor / 4.33).round())} (÷ 4.33)',
            onSave: (v) => update((x) => x.monthlyFoodBudgetMinor = v),
          ),
          _NumberTile(
            title: 'Daily calories',
            value: p.dailyKcalTarget,
            suffix: 'kcal',
            onSave: (v) => update((x) => x.dailyKcalTarget = v),
          ),
          _NumberTile(
            title: 'Daily protein',
            value: p.dailyProteinTargetG,
            suffix: 'g',
            onSave: (v) => update((x) => x.dailyProteinTargetG = v),
          ),
          _NumberTile(
            title: 'Meals per day',
            value: p.mealsPerDay.toDouble(),
            subtitle: 'Recipes target daily ÷ meals per portion',
            onSave: (v) => update((x) => x.mealsPerDay = v.round().clamp(1, 8)),
          ),
          _MoneyTile(
            title: 'Target cost per portion',
            valueMinor: p.targetCostPerPortionMinor,
            onSave: (v) => update((x) => x.targetCostPerPortionMinor = v),
          ),
          const GroupHeader('Monthly limits · other spending'),
          for (final c in [
            SpendCategory.household,
            SpendCategory.clothes,
            SpendCategory.eatingOut,
            SpendCategory.entertainment,
            SpendCategory.other,
          ])
            _MoneyTile(
              title: c.label,
              valueMinor: p.limitFor(c),
              onSave: (v) => update((x) {
                x.monthlyCategoryLimits = [
                  ...x.monthlyCategoryLimits.where((l) => l.category != c),
                  if (v > 0)
                    CategoryLimit()
                      ..category = c
                      ..limitMinor = v,
                ];
              }),
            ),
          const GroupHeader('Cooking profile'),
          _ChipsTile(
            title: 'Diet',
            options: dietOptions,
            selected: p.diet,
            onChanged: (v) => update((x) => x.diet = v),
          ),
          _TagsTile(
            title: 'Allergies',
            subtitle: 'Hard rule: recipes never include these',
            values: p.allergies,
            onChanged: (v) => update((x) => x.allergies = v),
          ),
          _TagsTile(title: 'Dislikes', values: p.dislikes, onChanged: (v) => update((x) => x.dislikes = v)),
          _TagsTile(
            title: 'Cuisines you like',
            values: p.cuisinesLiked,
            onChanged: (v) => update((x) => x.cuisinesLiked = v),
          ),
          _ChipsTile(
            title: 'Equipment',
            options: equipmentOptions,
            selected: p.equipment,
            onChanged: (v) => update((x) => x.equipment = v),
          ),
          _NumberTile(
            title: 'Max active cooking time',
            value: p.maxActiveMinutes.toDouble(),
            suffix: 'min',
            onSave: (v) => update((x) => x.maxActiveMinutes = v.round()),
          ),
          _NumberTile(
            title: 'Default portions',
            value: p.defaultPortions.toDouble(),
            subtitle: 'More than 1 = meal prep',
            onSave: (v) => update((x) => x.defaultPortions = v.round().clamp(1, 12)),
          ),
          SwitchListTile(
            title: const Text('Log the first portion when I cook'),
            subtitle: const Text('The rest goes to the fridge'),
            value: p.autoLogFirstPortion,
            onChanged: (v) => update((x) => x.autoLogFirstPortion = v),
          ),
          const GroupHeader('Rhythm'),
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Daily pick, meal-time "Ate it", weekly recap (max 3 a day)'),
            value: p.notificationsEnabled,
            onChanged: (v) => update((x) => x.notificationsEnabled = v),
          ),
          _TimeTile(
            title: 'Daily pick at',
            minute: p.dailyPickMinuteOfDay,
            onSave: (m) => update((x) => x.dailyPickMinuteOfDay = m),
          ),
          _MealTimesTile(minutes: p.mealReminderMinutes, onChanged: (v) => update((x) => x.mealReminderMinutes = v)),
          SwitchListTile(
            title: const Text('Sunday recap'),
            value: p.weeklyRecapEnabled,
            onChanged: (v) => update((x) => x.weeklyRecapEnabled = v),
          ),
          SwitchListTile(
            title: const Text('File clean receipts automatically'),
            subtitle: const Text('Only when totals match and every line is readable'),
            value: p.autoCommitCleanScans,
            onChanged: (v) => update((x) => x.autoCommitCleanScans = v),
          ),
          const GroupHeader('AI'),
          const _ApiKeyTile(),
          ListTile(
            title: const Text('Model'),
            subtitle: const Text('gemini-3.5-flash-lite (fallback: gemini-3.8-flash)'),
            trailing: const Icon(Icons.lock_outline, size: 20),
          ),
          const GroupHeader('Appearance & region'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'system', label: Text('System'), icon: Icon(Icons.brightness_auto_outlined)),
                ButtonSegment(value: 'light', label: Text('Light'), icon: Icon(Icons.light_mode_outlined)),
                ButtonSegment(value: 'dark', label: Text('Dark'), icon: Icon(Icons.dark_mode_outlined)),
              ],
              selected: {p.themeMode},
              onSelectionChanged: (v) => update((x) => x.themeMode = v.first),
            ),
          ),
          _TextTile(
            title: 'Currency (ISO code)',
            value: p.currency,
            onSave: (v) => update((x) => x.currency = v.trim().toUpperCase()),
          ),
          _TextTile(
            title: 'Country (ISO code)',
            value: p.country,
            onSave: (v) => update((x) => x.country = v.trim().toUpperCase()),
          ),
          _TextTile(
            title: 'Recipe language',
            value: p.outputLanguage,
            onSave: (v) => update((x) => x.outputLanguage = v.trim().toLowerCase()),
          ),
          _NumberTile(
            title: 'New day starts at',
            value: p.dayRolloverHour.toDouble(),
            suffix: ':00',
            subtitle: 'A late snack counts toward the previous day',
            onSave: (v) => update((x) => x.dayRolloverHour = v.round().clamp(0, 8)),
          ),
          SwitchListTile(
            title: const Text('Week starts on Sunday'),
            value: p.weekStartsOn == DateTime.sunday,
            onChanged: (v) => update((x) => x.weekStartsOn = v ? DateTime.sunday : DateTime.monday),
          ),
          const GroupHeader('Data'),
          ListTile(
            leading: const Icon(Icons.fact_check_outlined),
            title: const Text('Quick check'),
            subtitle: const Text('Verify the pantry items most likely to be wrong'),
            onTap: () => context.push('/quick-check'),
          ),
          ListTile(
            leading: const Icon(Icons.insights_outlined),
            title: const Text('Stats'),
            subtitle: const Text('Time-to-log and AI usage'),
            onTap: () => context.push('/stats'),
          ),
          ListTile(
            leading: const Icon(Icons.ios_share),
            title: const Text('Export backup'),
            subtitle: const Text('Everything as one JSON file'),
            onTap: () => _export(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Import backup'),
            subtitle: const Text('Replaces all current data'),
            onTap: () => _import(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.school_outlined),
            title: const Text('Run onboarding again'),
            onTap: () => context.push('/onboarding'),
          ),
          const SizedBox(height: 12),
          Center(child: Text('Trackcalfin 1.0', style: context.text.labelSmall)),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final json = await ref.read(backupServiceProvider).exportJson();
      final dir = await getTemporaryDirectory();
      final stamp = DateTime.now().toIso8601String().substring(0, 10);
      final file = File('${dir.path}/trackcalfin-backup-$stamp.json');
      await file.writeAsString(json);
      if (Platform.isAndroid || Platform.isIOS) {
        await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], subject: 'Trackcalfin backup'));
      } else {
        final docs = await getApplicationDocumentsDirectory();
        final out = await file.copy('${docs.path}/trackcalfin-backup-$stamp.json');
        messenger.showSnackBar(SnackBar(content: Text('Saved to ${out.path}')));
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Replace all data?'),
        content: const Text('Importing a backup deletes everything currently in the app. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Choose file')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final picked = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: const ['json']);
      final path = picked?.path;
      if (path == null) return;
      final counts = await ref.read(backupServiceProvider).importJson(await File(path).readAsString());
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Restored ${counts['ingredients']} pantry items, ${counts['transactions']} transactions, '
            '${counts['recipes']} recipes',
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Import failed: $e')));
    }
  }
}

Future<String?> _prompt(
  BuildContext context,
  String title,
  String initial, {
  TextInputType? keyboard,
  String? suffix,
  String? prefix,
  bool obscure = false,
}) {
  final c = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: c,
        autofocus: true,
        obscureText: obscure,
        keyboardType: keyboard,
        decoration: InputDecoration(suffixText: suffix, prefixText: prefix),
        onSubmitted: (v) => Navigator.pop(ctx, v),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(ctx, c.text), child: const Text('Save')),
      ],
    ),
  );
}

class _NumberTile extends StatelessWidget {
  const _NumberTile({required this.title, required this.value, required this.onSave, this.suffix, this.subtitle});
  final String title;
  final double value;
  final String? suffix;
  final String? subtitle;
  final void Function(double) onSave;

  String get _text => value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(title),
    subtitle: subtitle == null ? null : Text(subtitle!),
    trailing: Text('$_text${suffix == null ? '' : ' $suffix'}', style: context.text.titleSmall),
    onTap: () async {
      final v = await _prompt(
        context,
        title,
        _text,
        keyboard: const TextInputType.numberWithOptions(decimal: true),
        suffix: suffix,
      );
      final n = double.tryParse(v?.replaceAll(',', '.') ?? '');
      if (n != null) onSave(n);
    },
  );
}

class _MoneyTile extends ConsumerWidget {
  const _MoneyTile({required this.title, required this.valueMinor, required this.onSave, this.subtitle});
  final String title;
  final int valueMinor;
  final String? subtitle;
  final void Function(int) onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final money = ref.watch(moneyProvider);
    return ListTile(
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: Text(
        valueMinor > 0 ? money.format(valueMinor, whole: valueMinor % 100 == 0) : 'no limit',
        style: context.text.titleSmall,
      ),
      onTap: () async {
        final v = await _prompt(
          context,
          title,
          valueMinor > 0 ? money.toInput(valueMinor) : '',
          keyboard: const TextInputType.numberWithOptions(decimal: true),
          prefix: '${money.symbol} ',
        );
        if (v == null) return;
        onSave(v.trim().isEmpty ? 0 : (money.parse(v) ?? valueMinor));
      },
    );
  }
}

class _TextTile extends StatelessWidget {
  const _TextTile({required this.title, required this.value, required this.onSave});
  final String title;
  final String value;
  final void Function(String) onSave;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(title),
    trailing: Text(value, style: context.text.titleSmall),
    onTap: () async {
      final v = await _prompt(context, title, value);
      if (v != null) onSave(v);
    },
  );
}

class _ChipsTile extends StatelessWidget {
  const _ChipsTile({required this.title, required this.options, required this.selected, required this.onChanged});
  final String title;
  final List<String> options;
  final List<String> selected;
  final void Function(List<String>) onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.text.bodyLarge),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final o in options)
              FilterChip(
                label: Text(o.replaceAll('_', ' ')),
                selected: selected.contains(o),
                onSelected: (v) => onChanged(v ? [...selected, o] : selected.where((s) => s != o).toList()),
              ),
          ],
        ),
      ],
    ),
  );
}

class _TagsTile extends StatelessWidget {
  const _TagsTile({required this.title, required this.values, required this.onChanged, this.subtitle});
  final String title;
  final String? subtitle;
  final List<String> values;
  final void Function(List<String>) onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.text.bodyLarge),
        if (subtitle != null) Text(subtitle!, style: context.text.bodySmall),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final v in values)
              InputChip(label: Text(v), onDeleted: () => onChanged(values.where((x) => x != v).toList())),
            ActionChip(
              avatar: const Icon(Icons.add, size: 16),
              label: const Text('Add'),
              onPressed: () async {
                final v = await _prompt(context, 'Add to ${title.toLowerCase()}', '');
                final t = v?.trim().toLowerCase();
                if (t != null && t.isNotEmpty && !values.contains(t)) onChanged([...values, t]);
              },
            ),
          ],
        ),
      ],
    ),
  );
}

String _hm(int minute) => '${(minute ~/ 60).toString().padLeft(2, '0')}:${(minute % 60).toString().padLeft(2, '0')}';

class _TimeTile extends StatelessWidget {
  const _TimeTile({required this.title, required this.minute, required this.onSave});
  final String title;
  final int minute;
  final void Function(int) onSave;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(title),
    trailing: Text(_hm(minute), style: context.text.titleSmall),
    onTap: () async {
      final t = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: minute ~/ 60, minute: minute % 60),
      );
      if (t != null) onSave(t.hour * 60 + t.minute);
    },
  );
}

class _MealTimesTile extends StatelessWidget {
  const _MealTimesTile({required this.minutes, required this.onChanged});
  final List<int> minutes;
  final void Function(List<int>) onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Meal reminders', style: context.text.bodyLarge),
        Text('Only when prepped portions are in the fridge', style: context.text.bodySmall),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          children: [
            for (final m in minutes)
              InputChip(label: Text(_hm(m)), onDeleted: () => onChanged(minutes.where((x) => x != m).toList())),
            if (minutes.length < 4)
              ActionChip(
                avatar: const Icon(Icons.add, size: 16),
                label: const Text('Add'),
                onPressed: () async {
                  final t = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 12, minute: 30));
                  if (t != null) onChanged(({...minutes, t.hour * 60 + t.minute}.toList())..sort());
                },
              ),
          ],
        ),
      ],
    ),
  );
}

class _ApiKeyTile extends ConsumerWidget {
  const _ApiKeyTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final has = ref.watch(hasApiKeyProvider).value ?? false;
    return Column(
      children: [
        ListTile(
          leading: Icon(has ? Icons.key : Icons.key_off_outlined, color: has ? context.colors.good : null),
          title: const Text('Gemini API key'),
          subtitle: Text(has ? 'Stored in the device keystore' : 'Needed for scanning and recipes'),
          trailing: Text(has ? 'Change' : 'Add'),
          onTap: () async {
            final v = await _prompt(context, 'Gemini API key', '', obscure: true);
            if (v == null) return;
            await ref.read(secretStoreProvider).writeApiKey(v.trim().isEmpty ? null : v.trim());
            ref.invalidate(hasApiKeyProvider);
            if (v.trim().isNotEmpty) {
              unawaited(ref.read(scanServiceProvider).processQueue());
              unawaited(ref.read(nutritionServiceProvider).fillMissing());
              unawaited(ref.read(todayPickProvider.notifier).refresh());
            }
          },
        ),
        if (has)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.network_check, size: 18),
                  label: const Text('Test connection'),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final err = await ref.read(aiGatewayProvider).testConnection();
                    messenger.showSnackBar(
                      SnackBar(content: Text(err == null ? 'Gemini is reachable' : 'Failed: $err')),
                    );
                  },
                ),
                TextButton(
                  onPressed: () async {
                    await ref.read(secretStoreProvider).writeApiKey(null);
                    ref.invalidate(hasApiKeyProvider);
                  },
                  child: const Text('Remove'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Re-plans notifications after rhythm changes.
Future<void> replanNotifications(WidgetRef ref) async {
  final scheduler = HabitScheduler(isar: ref.read(isarProvider), picks: ref.read(dailyPickServiceProvider));
  await scheduler.refreshMealReminders();
  await scheduler.scheduleWeeklyRecap();
}
