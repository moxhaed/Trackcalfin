import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:isar_community/isar.dart';

import '../application/ai_gateway.dart';
import '../application/ask_service.dart';
import '../application/backup_service.dart';
import '../application/cook_service.dart';
import '../application/daily_pick_service.dart';
import '../application/fx_service.dart';
import '../application/ledger_service.dart';
import '../application/metrics_service.dart';
import '../application/nutrition_service.dart';
import '../application/pantry_service.dart';
import '../application/price_service.dart';
import '../application/profile_service.dart';
import '../application/quick_log_service.dart';
import '../application/recipe_service.dart';
import '../application/scan_service.dart';
import '../core/day_clock.dart';
import '../core/enums.dart';
import '../core/money.dart';
import '../data/ai/gemini_client.dart';
import '../data/ai/prompt_repository.dart';
import '../data/fx/fx_rate_client.dart';
import '../data/isar/collections/schemas.dart';
import '../domain/dashboard.dart';
import '../domain/food_history.dart';
import '../domain/price_book.dart';
import '../domain/quick_check.dart';
import '../domain/streak.dart';
import '../domain/vibe.dart';
import '../platform/image_store.dart';
import '../platform/secret_store.dart';

// ---------------------------------------------------------------------------
// Infrastructure (overridden in main)

final isarProvider = Provider<Isar>((ref) => throw UnimplementedError('isarProvider not overridden'));
final secretStoreProvider = Provider<SecretStore>((ref) => MemorySecretStore());
final imageStoreProvider = Provider<ImageStore>((ref) => throw UnimplementedError('imageStoreProvider'));
final nowProvider = Provider<DateTime Function()>((ref) => DateTime.now);
final promptRepositoryProvider = Provider((ref) => PromptRepository(rootBundle.loadString));

// ---------------------------------------------------------------------------
// Services

final profileServiceProvider = Provider((ref) => ProfileService(ref.watch(isarProvider)));
final ledgerServiceProvider = Provider((ref) => LedgerService(ref.watch(isarProvider), now: ref.watch(nowProvider)));
final pantryServiceProvider = Provider((ref) => PantryService(ref.watch(isarProvider), now: ref.watch(nowProvider)));
final cookServiceProvider = Provider((ref) => CookService(ref.watch(isarProvider), now: ref.watch(nowProvider)));
final recipeServiceProvider = Provider((ref) => RecipeService(ref.watch(isarProvider), now: ref.watch(nowProvider)));
final metricsServiceProvider = Provider((ref) => MetricsService(ref.watch(isarProvider)));
final backupServiceProvider = Provider((ref) => BackupService(ref.watch(isarProvider)));
final priceServiceProvider = Provider((ref) => PriceService(ref.watch(isarProvider), now: ref.watch(nowProvider)));

/// `--dart-define=GEMINI_BASE_URL=http://127.0.0.1:8765/v1beta` points the app at a local
/// stand-in for Gemini, to check AI screens on the desktop without a key or quota.
const _geminiBaseUrl = String.fromEnvironment('GEMINI_BASE_URL', defaultValue: GeminiClient.defaultBaseUrl);

final aiGatewayProvider = Provider(
  (ref) => AiGateway(
    isar: ref.watch(isarProvider),
    secrets: ref.watch(secretStoreProvider),
    prompts: ref.watch(promptRepositoryProvider),
    baseUrl: _geminiBaseUrl,
  ),
);
final fxServiceProvider = Provider(
  (ref) => FxService(ref.watch(isarProvider), client: FxRateClient(http.Client()), now: ref.watch(nowProvider)),
);
final scanServiceProvider = Provider(
  (ref) => ScanService(
    isar: ref.watch(isarProvider),
    images: ref.watch(imageStoreProvider),
    ai: ref.watch(aiGatewayProvider),
    fx: ref.watch(fxServiceProvider),
    now: ref.watch(nowProvider),
  ),
);
final nutritionServiceProvider = Provider(
  (ref) =>
      NutritionService(isar: ref.watch(isarProvider), ai: ref.watch(aiGatewayProvider), now: ref.watch(nowProvider)),
);
final dailyPickServiceProvider = Provider(
  (ref) =>
      DailyPickService(isar: ref.watch(isarProvider), ai: ref.watch(aiGatewayProvider), now: ref.watch(nowProvider)),
);
final askServiceProvider = Provider(
  (ref) => AskService(isar: ref.watch(isarProvider), ai: ref.watch(aiGatewayProvider), now: ref.watch(nowProvider)),
);
final quickLogServiceProvider = Provider(
  (ref) =>
      QuickLogService(isar: ref.watch(isarProvider), ai: ref.watch(aiGatewayProvider), now: ref.watch(nowProvider)),
);

// ---------------------------------------------------------------------------
// Live data

final profileProvider = StreamProvider<UserProfile>((ref) {
  final isar = ref.watch(isarProvider);
  return isar.userProfiles.watchObject(1, fireImmediately: true).map((p) => p ?? ProfileService.defaults());
});

UserProfile _profileOf(Ref ref) => ref.watch(profileProvider).value ?? ProfileService.defaults();

final moneyProvider = Provider<MoneyFormat>((ref) => ProfileService.moneyFor(_profileOf(ref)));
final dayClockProvider = Provider<DayClock>((ref) => ProfileService.clockFor(_profileOf(ref)));

final hasApiKeyProvider = FutureProvider<bool>((ref) => ref.watch(aiGatewayProvider).hasKey);

final ingredientsProvider = StreamProvider<List<Ingredient>>((ref) {
  final isar = ref.watch(isarProvider);
  return isar.ingredients.where().sortByName().watch(fireImmediately: true);
});

final transactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final isar = ref.watch(isarProvider);
  return isar.transactions.where(sort: Sort.desc).anyOccurredAt().limit(500).watch(fireImmediately: true);
});

final recipesProvider = StreamProvider<List<Recipe>>((ref) {
  final isar = ref.watch(isarProvider);
  return isar.recipes.where().watch(fireImmediately: true);
});

final fridgeProvider = StreamProvider<List<CookSession>>((ref) {
  final isar = ref.watch(isarProvider);
  return isar.cookSessions.where().statusEqualTo(CookStatus.active).sortByCookedAt().watch(fireImmediately: true);
});

final scanJobsProvider = StreamProvider<List<ScanJob>>((ref) {
  final isar = ref.watch(isarProvider);
  return isar.scanJobs
      .filter()
      .not()
      .statusEqualTo(ScanStatus.committed)
      .and()
      .not()
      .statusEqualTo(ScanStatus.discarded)
      .sortByCapturedAtDesc()
      .watch(fireImmediately: true);
});

final inboxCountProvider = Provider<int>((ref) {
  final jobs = ref.watch(scanJobsProvider).value ?? const [];
  return jobs.where((j) => j.status == ScanStatus.needsReview || j.status == ScanStatus.failed).length;
});

final todayLogProvider = StreamProvider<DailyLog?>((ref) {
  final isar = ref.watch(isarProvider);
  final key = ref.watch(dayClockProvider).dateKey(ref.watch(nowProvider)());
  return isar.dailyLogs.where().dateKeyEqualTo(key).watch(fireImmediately: true).map((l) => l.firstOrNull);
});

/// Each store's latest price per item, from the ledger (the last 500 transactions are months
/// of shopping), in the units the items use now.
final priceBookProvider = Provider<PriceBook>((ref) {
  final txs = ref.watch(transactionsProvider).value ?? const [];
  final items = ref.watch(ingredientsProvider).value ?? const <Ingredient>[];
  return PriceBook.from(txs, now: ref.watch(nowProvider)(), units: {for (final i in items) i.key: i.baseUnit});
});

final quickCheckProvider = Provider<List<Ingredient>>((ref) {
  final items = ref.watch(ingredientsProvider).value ?? const [];
  return QuickCheck.candidates(items, ref.watch(nowProvider)());
});

// ---------------------------------------------------------------------------
// Today's pick

class TodayPickNotifier extends AsyncNotifier<PickOutcome> {
  @override
  Future<PickOutcome> build() async {
    ref.watch(hasApiKeyProvider);
    return ref.read(dailyPickServiceProvider).ensure();
  }

  Future<void> refresh({bool force = false}) async {
    if (force) state = const AsyncLoading<PickOutcome>();
    state = await AsyncValue.guard(() => ref.read(dailyPickServiceProvider).ensure(force: force));
  }

  Future<String?> swap() async {
    state = const AsyncLoading<PickOutcome>();
    final res = await ref.read(dailyPickServiceProvider).swap();
    state = AsyncData(res);
    return res.error;
  }
}

final todayPickProvider = AsyncNotifierProvider<TodayPickNotifier, PickOutcome>(TodayPickNotifier.new);

// ---------------------------------------------------------------------------
// Dashboard

class DashboardView {
  DashboardView(this.state, this.vibe, this.profile, this.streak);
  final DashboardState state;
  final VibeResult vibe;
  final UserProfile profile;
  final StreakResult streak;
}

Future<DashboardView> loadDashboard(Isar isar, DateTime now, {Recipe? pick}) async {
  final profile = await isar.userProfiles.get(1) ?? ProfileService.defaults();
  final clock = ProfileService.clockFor(profile);
  final money = ProfileService.moneyFor(profile);
  final monthStart = clock.monthStart(now);
  final trailingStart = clock.dayStart(DayClock.addDays(now, -28));
  final from = monthStart.isBefore(trailingStart) ? monthStart : trailingStart;
  final txs = await isar.transactions.where().occurredAtBetween(from, now.add(const Duration(minutes: 1))).findAll();
  final first = await isar.transactions.where().anyOccurredAt().findFirst();
  final weekStartKey = clock.dateKey(clock.weekStart(now));
  // Last week (macro fallback), this month and the trailing 28 days (what was eaten).
  final logsFrom = [
    DayClock.addDaysToKey(weekStartKey, -7),
    clock.dateKey(monthStart),
    clock.dateKey(trailingStart),
  ].reduce((a, b) => a < b ? a : b);
  final logs = await isar.dailyLogs.where().dateKeyBetween(logsFrom, DayClock.addDaysToKey(weekStartKey, 7)).findAll();
  final firstMeal = await isar.dailyLogs.where().anyDateKey().filter().mealsCountGreaterThan(0).findFirst();
  final uses = await isar.foodUses.where().toGreaterThan(clock.startOfKey(logsFrom)).findAll();
  final firstUse = await isar.foodUses.where().sortByFrom().findFirst();
  final firstEaten = _earliest([if (firstMeal != null) DayClock.dateOfKey(firstMeal.dateKey), ?firstUse?.from]);
  final outTx = await isar.transactions
      .where()
      .occurredAtGreaterThan(now.subtract(const Duration(days: 90)))
      .filter()
      .primaryCategoryEqualTo(SpendCategory.eatingOut)
      .findAll();
  final state = DashboardAggregator.compute(
    DashboardInput(
      now: now,
      clock: clock,
      profile: profile,
      transactions: txs,
      logs: logs,
      firstTransactionAt: first?.occurredAt,
      firstMealAt: firstEaten,
      uses: uses,
      eatingOutAvgMinor: outTx.length >= 3 ? (outTx.fold(0, (a, t) => a + t.totalMinor) / outTx.length).round() : null,
    ),
  );
  final vibe = VibeScorer.score(state, profile, money, pickTitle: pick?.title, pickProtein: pick?.perPortion.proteinG);
  final todayKey = clock.dateKey(now);
  final since = DayClock.addDaysToKey(todayKey, -120);
  final loggedDays = <int>{
    ...(await isar.dailyLogs.where().dateKeyGreaterThan(since).filter().mealsCountGreaterThan(0).findAll()).map(
      (l) => l.dateKey,
    ),
    ...(await isar.transactions.where().occurredAtGreaterThan(DayClock.dateOfKey(since)).findAll()).map(
      (t) => clock.dateKey(t.occurredAt),
    ),
  };
  final streak = StreakCalculator.compute(loggedDays, todayKey, weekStartsOn: profile.weekStartsOn);
  return DashboardView(state, vibe, profile, streak);
}

DateTime? _earliest(Iterable<DateTime> times) => times.isEmpty ? null : times.reduce((a, b) => a.isBefore(b) ? a : b);

final dashboardProvider = StreamProvider<DashboardView>((ref) {
  final isar = ref.watch(isarProvider);
  final now = ref.watch(nowProvider);
  final pick = ref.watch(todayPickProvider).value?.recipe;
  final triggers = StreamGroup.merge<void>([
    isar.transactions.watchLazy(fireImmediately: true),
    isar.dailyLogs.watchLazy(),
    isar.foodUses.watchLazy(),
    isar.userProfiles.watchLazy(),
    Stream<void>.periodic(const Duration(minutes: 10)),
  ]);
  return triggers.asyncMap((_) => loadDashboard(isar, now(), pick: pick));
});

// ---------------------------------------------------------------------------
// Food history

class FoodHistoryView {
  FoodHistoryView(this.months, this.profile);

  /// Budget months, oldest first; the last one is the current month.
  final List<FoodPeriod> months;
  final UserProfile profile;
}

Future<FoodHistoryView> loadFoodHistory(Isar isar, DateTime now) async {
  final profile = await isar.userProfiles.get(1) ?? ProfileService.defaults();
  final clock = ProfileService.clockFor(profile);
  final from = FoodHistory.oldestStart(now, clock);
  final txs = await isar.transactions.where().occurredAtBetween(from, now.add(const Duration(minutes: 1))).findAll();
  final logs = await isar.dailyLogs.where().dateKeyBetween(clock.dateKey(from), clock.dateKey(now)).findAll();
  final uses = await isar.foodUses.where().toGreaterThan(from, include: true).findAll();
  final firstTx = await isar.transactions.where().anyOccurredAt().findFirst();
  final firstMeal = await isar.dailyLogs.where().anyDateKey().filter().mealsCountGreaterThan(0).findFirst();
  final firstUse = await isar.foodUses.where().sortByFrom().findFirst();
  final months = FoodHistory.months(
    now: now,
    clock: clock,
    transactions: txs,
    logs: logs,
    uses: uses,
    firstData: _earliest([
      ?firstTx?.occurredAt,
      if (firstMeal != null) clock.startOfKey(firstMeal.dateKey),
      ?firstUse?.from,
    ]),
  );
  return FoodHistoryView(months, profile);
}

final foodHistoryProvider = StreamProvider.autoDispose<FoodHistoryView>((ref) {
  final isar = ref.watch(isarProvider);
  final now = ref.watch(nowProvider);
  final triggers = StreamGroup.merge<void>([
    isar.transactions.watchLazy(fireImmediately: true),
    isar.dailyLogs.watchLazy(),
    isar.foodUses.watchLazy(),
    isar.userProfiles.watchLazy(),
  ]);
  return triggers.asyncMap((_) => loadFoodHistory(isar, now()));
});
