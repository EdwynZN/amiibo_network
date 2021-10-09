import 'package:amiibo_network/riverpod/game_provider.dart';
import 'package:amiibo_network/service/info_package.dart';
import 'package:amiibo_network/service/update_service.dart';
import 'package:flutter/material.dart';
import 'package:amiibo_network/screen/home_page.dart';
import 'package:amiibo_network/screen/splash_screen.dart';
import 'package:amiibo_network/widget/route_transitions.dart';
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
  //debugPrintGestureArenaDiagnostics = true;
  WidgetsFlutterBinding.ensureInitialized();
  final cacheDir = await getTemporaryDirectory();
  await Hive.initFlutter();
  final UpdateService updateService = UpdateService();
  await updateService.initDB();
  await InfoPackage.versionCode();
  final bool splash = await updateService.compareLastUpdate;
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  await updateOldTheme();
  runApp(
    ProviderScope(
      overrides: [
        cacheProvider.overrideWithValue(
          newHiveCache(
            cacheDir.path,
            cacheName: 'HiveCache',
            fromEncodable: (cb) => CacheValue.fromJson(cb),
            maxEntries: 200,
            expiryPolicy: AccessedExpiryPolicy(const Duration(days: 7)),
          ),
        ),
        preferencesProvider.overrideWithValue(preferences),
      ],
      child: AmiiboNetwork(
        firstPage: splash ? const Home() : const SplashScreen(),
      ),
    ),
  );
}

class AmiiboNetwork extends ConsumerWidget {
  final Widget firstPage;
  const AmiiboNetwork({Key? key, required this.firstPage}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final ThemeProvider themeMode = watch(themeProvider);
    return MaterialApp(
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: themeMode.theme.light,
      darkTheme: themeMode.theme.dark,
      onGenerateRoute: Routes.getRoute,
      themeMode: themeMode.preferredTheme,
      builder: (context, child) {
        final theme = Theme.of(context);
        final Brightness brightness = theme == Brightness.light ? Brightness.dark : Brightness.light;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarIconBrightness: brightness,
            systemNavigationBarIconBrightness: brightness,
            statusBarColor: theme.appBarTheme.color,
            systemNavigationBarColor: theme.appBarTheme.color,
          ),
          child: child!,
        );
      },
      home: firstPage,
    );
  }
}
