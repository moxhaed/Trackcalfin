import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';
import 'app/providers.dart';
import 'app/router.dart';
import 'application/cook_service.dart';
import 'application/demo_seed.dart';
import 'application/migrations.dart';
import 'application/profile_service.dart';
import 'platform/background.dart';
import 'platform/image_store.dart';
import 'platform/notifications.dart';
import 'platform/secret_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isar = await openAppIsar();
  if (DemoSeed.enabled) await DemoSeed.run(isar);
  // A first run takes money, country and language from the phone's region.
  final locale = WidgetsBinding.instance.platformDispatcher.locale;
  final profile = await ProfileService(isar).load(country: locale.countryCode, language: locale.languageCode);
  await Migrations.run(isar);
  final secrets = SecureSecretStore(fallbackDir: await appSupportPath());
  final mobile = Platform.isAndroid || Platform.isIOS;
  final images = ImageStore(
    await scansPath(),
    compressor: mobile
        ? (path) => FlutterImageCompress.compressWithFile(path, minWidth: 1400, minHeight: 1400, quality: 85)
        : null,
  );

  GoRouter? router;
  await Notifications.instance.init(
    onResponse: (r) async {
      if (r.actionId == actionAte) {
        await CookService(isar).eatOldest();
        return;
      }
      final route = r.payload;
      final nav = router;
      if (nav != null && route != null && route.startsWith('/')) unawaited(nav.push(route));
    },
  );
  final launch = await Notifications.instance.launchResponse();
  router = buildRouter(onboarded: profile.onboardingDone, initialLocation: launch?.payload);
  unawaited(BackgroundScheduler.register());

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
        secretStoreProvider.overrideWithValue(secrets),
        imageStoreProvider.overrideWithValue(images),
      ],
      child: TrackcalfinApp(router: router),
    ),
  );
}
