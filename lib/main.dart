import 'dart:async';

import 'package:amiibo_network/firebase_options.dart';
import 'package:amiibo_network/riverpod/game_provider.dart';
import 'package:amiibo_network/riverpod/provider_observer.dart';
import 'package:amiibo_network/riverpod/router_provider.dart';
import 'package:amiibo_network/service/info_package.dart';
import 'package:amiibo_network/service/update_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:flutter/gestures.dart';
import 'package:amiibo_network/riverpod/repository_provider.dart';
import 'package:amiibo_network/riverpod/theme_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stash/stash_api.dart';
import 'package:stash_hive/stash_hive.dart';
import 'package:stash_dio/src/dio/cache_value.dart';

Future<void> main() async {
  await runZonedGuarded<Future<void>>(
    () async {
      //debugPrintGestureArenaDiagnostics = true;
      /// You must call WidgetsFlutterBinding.ensureInitialized() inside
      /// runZonedGuarded. Error handling wouldn’t work if
      /// WidgetsFlutterBinding.ensureInitialized() was called from the outside.
      WidgetsFlutterBinding.ensureInitialized();

      /// Firebase initialization
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      /// When not in debug mode:
      ///
      /// - Report crash to FirebaseCrashlytics
      ///
      /// - Change ErrorWidget to show a grey Container
      if (!kDebugMode) {
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(true);
        FlutterError.onError = (details) {
          FlutterError.presentError(details);
          unawaited(FirebaseCrashlytics.instance.recordFlutterError(details));
        };
        ErrorWidget.builder = (_) => Container(color: Colors.grey.shade300);
      } else {
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(false);
      }

      final cacheDir = await getTemporaryDirectory();
      await Hive.initFlutter();
      final UpdateService updateService = UpdateService();
      await updateService.initDB();

      /// Check Android version
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        await InfoPackage.versionCode();
      }

      final bool notUpdateRequired = await updateService.compareLastUpdate;
      final preferences = await SharedPreferences.getInstance();
      await updateOldTheme();
      final store = await newHiveDefaultCacheStore(path: cacheDir.path);
      final cache = await store.cache(
        name: 'HiveCache',
        fromEncodable: CacheValue.fromJson,
        maxEntries: 200,
        expiryPolicy: const AccessedExpiryPolicy(Duration(days: 7)),
      );
      runApp(
        ProviderScope(
          observers: [
            if (!kDebugMode) FirebaseProviderObserver(
              FirebaseCrashlytics.instance,
            ),
          ],
          overrides: [
            cacheProvider.overrideWithValue(cache),
            preferencesProvider.overrideWithValue(preferences),
            if (notUpdateRequired) initialScreen.overrideWithValue('/home'),
          ],
          child: const AmiiboNetwork(),
        ),
      );
    },
    (e, stack) {
      if (kDebugMode) {
        debugPrintStack(stackTrace: stack, label: e.toString());
        return;
      }
      unawaited(FirebaseCrashlytics.instance.recordError(e, stack));
    },
  );
}

class AmiiboNetwork extends ConsumerWidget {
  const AmiiboNetwork({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeProvider themeMode = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: themeMode.light,
      darkTheme: themeMode.dark,
      themeMode: themeMode.preferredTheme,
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      builder: (context, child) {
        final theme = AppBarTheme.of(context).systemOverlayStyle;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            systemNavigationBarColor: theme?.systemNavigationBarColor,
            systemNavigationBarContrastEnforced:
                theme?.systemNavigationBarContrastEnforced,
            systemNavigationBarDividerColor:
                theme?.systemNavigationBarDividerColor,
            systemNavigationBarIconBrightness:
                theme?.systemNavigationBarIconBrightness,
            systemStatusBarContrastEnforced:
                theme?.systemStatusBarContrastEnforced,
          ),
          child: child!,
        );
      },
    );
  }
}
