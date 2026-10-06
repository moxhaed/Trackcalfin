import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show NumberFormat;
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
    final padding = EdgeInsets.fromLTRB(
      AppSpace.screen,
      0,
      AppSpace.screen,
      MediaQuery.paddingOf(context).bottom + AppSpace.x6,
    );
    if (p == null) {
      return Scaffold(
        appBar: const TabHeader(title: 'Settings'),
        body: ListView(padding: padding, children: const [_SettingsSkeleton()]),
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
        padding: padding,
        children: [
          const GroupHeader('Goals', first: true),
          AppGroup(
            children: [
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
            ],
          ),
          const GroupHeader('Monthly limits · other spending'),
          AppGroup(
            children: [
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
            ],
          ),
          const GroupHeader('Cooking profile'),
          AppGroup(
            children: [
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
              _SwitchTile(
                title: 'Log the first portion when I cook',
                subtitle: 'The rest goes to the fridge',
                value: p.autoLogFirstPortion,
                onChanged: (v) => update((x) => x.autoLogFirstPortion = v),
              ),
            ],
          ),
          const GroupHeader('Rhythm'),
          AppGroup(
            children: [
              _SwitchTile(
                title: 'Notifications',
                subtitle: 'Daily pick, meal-time "Ate it", weekly recap (max 3 a day)',
                value: p.notificationsEnabled,
                onChanged: (v) => update((x) => x.notificationsEnabled = v),
              ),
              _TimeTile(
                title: 'Daily pick at',
                minute: p.dailyPickMinuteOfDay,
                onSave: (m) => update((x) => x.dailyPickMinuteOfDay = m),
              ),
              _MealTimesTile(
                minutes: p.mealReminderMinutes,
                onChanged: (v) => update((x) => x.mealReminderMinutes = v),
              ),
              _SwitchTile(
                title: 'Sunday recap',
                value: p.weeklyRecapEnabled,
                onChanged: (v) => update((x) => x.weeklyRecapEnabled = v),
              ),
              _SwitchTile(
                title: 'File clean receipts automatically',
                subtitle: 'Only when totals match and every line is readable',
                value: p.autoCommitCleanScans,
                onChanged: (v) => update((x) => x.autoCommitCleanScans = v),
              ),
            ],
          ),
          const GroupHeader('AI'),
          const AppGroup(
            children: [
              _ApiKeyTile(),
              AppRow(
                title: 'Model',
                subtitle: 'gemini-3.5-flash-lite (fallback: gemini-3.8-flash)',
                trailing: _LockIcon(),
              ),
            ],
          ),
          const GroupHeader('Appearance & region'),
          AppGroup(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.x4, vertical: AppSpace.x3),
                child: AppSegmented<String>(
                  segments: const {'system': 'System', 'light': 'Light', 'dark': 'Dark'},
                  selected: p.themeMode,
                  onChanged: (v) => update((x) => x.themeMode = v),
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
              _SwitchTile(
                title: 'Week starts on Sunday',
                value: p.weekStartsOn == DateTime.sunday,
                onChanged: (v) => update((x) => x.weekStartsOn = v ? DateTime.sunday : DateTime.monday),
              ),
            ],
          ),
          const GroupHeader('Data'),
          AppGroup(
            separatorIndent: AppGroup.indentIcon,
            children: [
              AppRow(
                leading: const Icon(Icons.fact_check_outlined, size: 20),
                title: 'Quick check',
                subtitle: 'Verify the pantry items most likely to be wrong',
                chevron: true,
                onTap: () => context.push('/quick-check'),
              ),
              AppRow(
                leading: const Icon(Icons.insights_outlined, size: 20),
                title: 'Stats',
                subtitle: 'Time-to-log and AI usage',
                chevron: true,
                onTap: () => context.push('/stats'),
              ),
              AppRow(
                leading: const Icon(Icons.ios_share_rounded, size: 20),
                title: 'Export backup',
                subtitle: 'Everything as one JSON file',
                chevron: true,
                onTap: () => _export(context, ref),
              ),
              AppRow(
                leading: const Icon(Icons.restore_rounded, size: 20),
                title: 'Import backup',
                subtitle: 'Replaces all current data',
                chevron: true,
                onTap: () => _import(context, ref),
              ),
              AppRow(
                leading: const Icon(Icons.school_outlined, size: 20),
                title: 'Run onboarding again',
                chevron: true,
                onTap: () => context.push('/onboarding'),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.x6),
          Center(
            child: Text(
              'Trackcalfin 1.0',
              style: context.text.labelSmall?.copyWith(color: context.colors.textTertiary),
            ),
          ),
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
          // Importing deletes everything: the confirm is the destructive (filled critical) button.
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: c.colors.critical, foregroundColor: c.scheme.onError),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Choose file'),
          ),
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

final _grouped = NumberFormat.decimalPattern();

class _NumberTile extends StatelessWidget {
  const _NumberTile({required this.title, required this.value, required this.onSave, this.suffix, this.subtitle});
  final String title;
  final double value;
  final String? suffix;
  final String? subtitle;
  final void Function(double) onSave;

  /// What the prompt starts with: the raw number, no grouping.
  String get _text => value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(1);

  /// What the row shows: "2,200 kcal", "30 min", "4:00".
  String get _shown {
    final n = value == value.roundToDouble() ? _grouped.format(value.round()) : value.toStringAsFixed(1);
    if (suffix == null) return n;
    return suffix!.startsWith(':') ? '$n$suffix' : '$n $suffix';
  }

  @override
  Widget build(BuildContext context) => AppRow(
    title: title,
    subtitle: subtitle,
    value: _shown,
    valueMuted: true,
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
    return AppRow(
      title: title,
      subtitle: subtitle,
      value: valueMinor > 0 ? money.format(valueMinor, whole: valueMinor % 100 == 0) : 'no limit',
      valueMuted: true,
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
  Widget build(BuildContext context) => AppRow(
    title: title,
    value: value,
    valueMuted: true,
    onTap: () async {
      final v = await _prompt(context, title, value);
      if (v != null) onSave(v);
    },
  );
}

/// A row with a switch. The whole row toggles, and a screen reader sees one switch.
class _SwitchTile extends StatelessWidget {
  const _SwitchTile({required this.title, required this.value, required this.onChanged, this.subtitle});
  final String title;
  final String? subtitle;
  final bool value;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: AppRow(
      title: title,
      subtitle: subtitle,
      trailing: Switch(value: value, onChanged: onChanged),
      onTap: () => onChanged(!value),
    ),
  );
}

class _LockIcon extends StatelessWidget {
  const _LockIcon();

  @override
  Widget build(BuildContext context) =>
      Icon(Icons.lock_outline_rounded, size: 20, color: context.colors.textTertiary, semanticLabel: 'Locked');
}

/// A settings cell that holds a title (and an optional hint) over a wrap of chips. The chips'
/// 48 tap targets add 6 of air above and below their 36 height, so the cell pads less.
class _ChipCell extends StatelessWidget {
  const _ChipCell({required this.title, required this.children, this.subtitle});
  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(AppSpace.x4, AppSpace.x3, AppSpace.x4, AppSpace.x1),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.text.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
        if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle!, style: context.text.bodySmall)],
        const SizedBox(height: AppSpace.x1),
        Wrap(spacing: AppSpace.x2, children: children),
      ],
    ),
  );
}

class _ChipsTile extends StatelessWidget {
  const _ChipsTile({required this.title, required this.options, required this.selected, required this.onChanged});
  final String title;
  final List<String> options;
  final List<String> selected;
  final void Function(List<String>) onChanged;

  @override
  Widget build(BuildContext context) => _ChipCell(
    title: title,
    children: [
      for (final o in options)
        AppToggleChip(
          label: o.replaceAll('_', ' '),
          selected: selected.contains(o),
          onSelected: (v) => onChanged(v ? [...selected, o] : selected.where((s) => s != o).toList()),
        ),
    ],
  );
}

class _TagsTile extends StatelessWidget {
  const _TagsTile({required this.title, required this.values, required this.onChanged, this.subtitle});
  final String title;
  final String? subtitle;
  final List<String> values;
  final void Function(List<String>) onChanged;

  @override
  Widget build(BuildContext context) => _ChipCell(
    title: title,
    subtitle: subtitle,
    children: [
      for (final v in values) AppInputChip(label: v, onDeleted: () => onChanged(values.where((x) => x != v).toList())),
      AppActionChip(
        icon: Icons.add_rounded,
        label: 'Add',
        onPressed: () async {
          final v = await _prompt(context, 'Add to ${title.toLowerCase()}', '');
          final t = v?.trim().toLowerCase();
          if (t != null && t.isNotEmpty && !values.contains(t)) onChanged([...values, t]);
        },
      ),
    ],
  );
}

String _hm(int minute) => '${(minute ~/ 60).toString().padLeft(2, '0')}:${(minute % 60).toString().padLeft(2, '0')}';

class _TimeTile extends StatelessWidget {
  const _TimeTile({required this.title, required this.minute, required this.onSave});
  final String title;
  final int minute;
  final void Function(int) onSave;

  @override
  Widget build(BuildContext context) => AppRow(
    title: title,
    value: _hm(minute),
    valueMuted: true,
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
  Widget build(BuildContext context) => _ChipCell(
    title: 'Meal reminders',
    subtitle: 'Only when prepped portions are in the fridge',
    children: [
      for (final m in minutes)
        AppInputChip(label: _hm(m), onDeleted: () => onChanged(minutes.where((x) => x != m).toList())),
      if (minutes.length < 4)
        AppActionChip(
          icon: Icons.add_rounded,
          label: 'Add',
          onPressed: () async {
            final t = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 12, minute: 30));
            if (t != null) onChanged(({...minutes, t.hour * 60 + t.minute}.toList())..sort());
          },
        ),
    ],
  );
}

class _ApiKeyTile extends ConsumerWidget {
  const _ApiKeyTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final has = ref.watch(hasApiKeyProvider).value ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppRow(
          leading: Icon(
            has ? Icons.key_rounded : Icons.key_off_outlined,
            size: 20,
            color: has ? context.colors.good : null,
          ),
          title: 'Gemini API key',
          subtitle: has ? 'Stored in the device keystore' : 'Needed for scanning and recipes',
          value: has ? 'Change' : 'Add',
          valueMuted: true,
          chevron: true,
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
          // Small text actions under the row's text: 16 + 24 + 12 = 52, less the buttons' own 12.
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 0, AppSpace.x4, AppSpace.x2),
            child: Row(
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(minimumSize: const Size(48, 36)),
                  icon: const Icon(Icons.network_check_rounded, size: 18),
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
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48, 36),
                    foregroundColor: context.colors.criticalInk,
                  ),
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

/// The settings page before the profile loads: the real group titles over pulsing rows.
class _SettingsSkeleton extends StatelessWidget {
  const _SettingsSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget row(double title, double value) => ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 52),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.x4, vertical: AppSpace.x3),
        child: Row(
          children: [
            SkeletonLine(width: title, style: context.text.bodyLarge),
            const Spacer(),
            SkeletonLine(width: value, style: context.text.bodyLarge),
          ],
        ),
      ),
    );
    Widget group(String title, List<(double, double)> rows, {bool first = false}) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GroupHeader(title, first: first),
        AppSkeleton(child: AppGroup(children: [for (final (t, v) in rows) row(t, v)])),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        group('Goals', const [(150, 56), (120, 72), (110, 48), (96, 24), (170, 48)], first: true),
        group('Cooking profile', const [(80, 160), (110, 120), (140, 40), (130, 56)]),
        group('Rhythm', const [(112, 40), (130, 56), (150, 24)]),
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
