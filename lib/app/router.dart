import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/buy/buy_screen.dart';
import '../features/buy/inbox_screen.dart';
import '../features/buy/review_screen.dart';
import '../features/cook/cook_screen.dart';
import '../features/cook/recipe_detail_screen.dart';
import '../features/cook/recipe_editor_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/dashboard/food_history_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/settings/quick_check_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/stats_screen.dart';
import 'floating_nav.dart';
import 'shell.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter buildRouter({required bool onboarded, String? initialLocation}) {
  final popups = PopupObserver();
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: onboarded ? (initialLocation ?? '/') : '/onboarding',
    observers: [popups],
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell, popupOpen: popups.open),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/', builder: (_, _) => const DashboardScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/buy',
                builder: (_, s) => BuyScreen(initialTab: s.uri.queryParameters['tab'] == 'ledger' ? 1 : 0),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/cook', builder: (_, _) => const CookScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen())],
          ),
        ],
      ),
      GoRoute(
        path: '/inbox',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const InboxScreen(),
        routes: [
          GoRoute(
            path: ':id',
            parentNavigatorKey: rootNavigatorKey,
            builder: (_, s) => ReviewScreen(jobId: int.parse(s.pathParameters['id']!)),
          ),
        ],
      ),
      GoRoute(path: '/recipe/new', parentNavigatorKey: rootNavigatorKey, builder: (_, _) => const RecipeEditorScreen()),
      GoRoute(
        path: '/recipe/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, s) => RecipeDetailScreen(id: int.parse(s.pathParameters['id']!)),
        routes: [
          GoRoute(
            path: 'edit',
            parentNavigatorKey: rootNavigatorKey,
            builder: (_, s) => RecipeEditorScreen(id: int.parse(s.pathParameters['id']!)),
          ),
        ],
      ),
      GoRoute(path: '/quick-check', parentNavigatorKey: rootNavigatorKey, builder: (_, _) => const QuickCheckScreen()),
      GoRoute(path: '/stats', parentNavigatorKey: rootNavigatorKey, builder: (_, _) => const StatsScreen()),
      GoRoute(
        path: '/food-history',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const FoodHistoryScreen(),
      ),
      GoRoute(path: '/onboarding', parentNavigatorKey: rootNavigatorKey, builder: (_, _) => const OnboardingScreen()),
    ],
  );
}
