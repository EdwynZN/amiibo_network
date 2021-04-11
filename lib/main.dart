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
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:flutter/gestures.dart';
import 'package:amiibo_network/riverpod/repository_provider.dart';
import 'package:amiibo_network/riverpod/theme_provider.dart';

Future<void> main() async {
  //debugPrintGestureArenaDiagnostics = true;
  WidgetsFlutterBinding.ensureInitialized();
  final UpdateService updateService = UpdateService();
  await updateService.initDB();
  await InfoPackage.versionCode();
  final bool splash = await updateService.compareLastUpdate;
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  await updateOldTheme();
  runApp(ProviderScope(
    overrides: [
      preferencesProvider.overrideWithValue(preferences),
    ],
    child: AmiiboNetwork(
      firstPage: splash ? const Home() : const SplashScreen(),
    ),
  ));
}

class AmiiboNetwork extends ConsumerWidget {
  
  final Widget? firstPage;
  const AmiiboNetwork({this.firstPage});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final ThemeProvider themeMode = watch(themeProvider.notifier);
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
      home: Builder(
        builder: (BuildContext context) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
                statusBarIconBrightness:
                    Theme.of(context).brightness == Brightness.light
                        ? Brightness.dark
                        : Brightness.light,
                systemNavigationBarIconBrightness:
                    Theme.of(context).brightness == Brightness.light
                        ? Brightness.dark
                        : Brightness.light,
                statusBarColor: Theme.of(context).appBarTheme.color,
                systemNavigationBarColor:
                    Theme.of(context).appBarTheme.color),
            child: firstPage!,
          );
        },
      ),
    );
  }
}