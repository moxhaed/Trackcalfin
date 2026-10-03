import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'integrations.dart';
import 'providers.dart';
import 'messenger.dart';
import 'theme.dart';

class TrackcalfinApp extends ConsumerStatefulWidget {
  const TrackcalfinApp({super.key, required this.router});
  final GoRouter router;

  @override
  ConsumerState<TrackcalfinApp> createState() => _TrackcalfinAppState();
}

class _TrackcalfinAppState extends ConsumerState<TrackcalfinApp> with WidgetsBindingObserver {
  late final AppIntegrations _integrations = AppIntegrations(ref, widget.router);

  // Built once: a color scheme from a seed takes a moment, and the app rebuilds on theme changes.
  final _light = AppTheme.build(Brightness.light);
  final _dark = AppTheme.build(Brightness.dark);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _integrations.start());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _integrations.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _integrations.onResume();
    if (state == AppLifecycleState.paused) _integrations.onPause();
  }

  @override
  Widget build(BuildContext context) {
    final mode = switch (ref.watch(profileProvider.select((p) => p.value?.themeMode))) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    return MaterialApp.router(
      themeMode: mode,
      title: 'Trackcalfin',
      debugShowCheckedModeBanner: false,
      theme: _light,
      darkTheme: _dark,
      scaffoldMessengerKey: appMessengerKey,
      routerConfig: widget.router,
    );
  }
}
