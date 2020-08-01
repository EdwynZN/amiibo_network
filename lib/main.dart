import 'package:amiibo_network/service/info_package.dart';
import 'package:amiibo_network/service/update_service.dart';
import 'package:flutter/material.dart';
import 'package:amiibo_network/screen/home_page.dart';
import 'package:amiibo_network/screen/splash_screen.dart';
import 'package:amiibo_network/widget/route_transitions.dart';
import 'package:amiibo_network/provider/theme_provider.dart';
import 'package:amiibo_network/provider/stat_provider.dart';
import 'package:amiibo_network/provider/lock_provider.dart';
import 'package:amiibo_network/provider/search_provider.dart';
import 'package:amiibo_network/provider/query_provider.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:flutter/gestures.dart';

Future<void> main() async {
  //debugPrintGestureArenaDiagnostics = true;
  WidgetsFlutterBinding.ensureInitialized();
  final UpdateService updateService = UpdateService();
  await updateService.initDB();
  await InfoPackage.versionCode();
  final bool splash = await updateService.compareLastUpdate;
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final Map<String,int> savedTheme = await getTheme;
  runApp(
    AmiiboNetwork(
      firstPage: splash ? Home() : SplashScreen(),
      preferences: preferences,
      theme: savedTheme,
    )
  );
}

class AmiiboNetwork extends StatelessWidget {
  final SharedPreferences preferences;
  final Widget firstPage;
  final Map<String,dynamic> theme;
  AmiiboNetwork({this.firstPage, this.theme, this.preferences});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<QueryProvider>(
          create: (_) => QueryProvider.fromSharedPreferences(preferences),
        ),
        ChangeNotifierProvider<LockProvider>(
          create: (context) => LockProvider.fromSharedPreferences(preferences)
        ),
        ChangeNotifierProvider<StatProvider>(
          create: (context) => StatProvider.fromSharedPreferences(preferences)
        ),
        Provider<SearchProvider>(
          create: (_) => SearchProvider(),
          dispose: (_, search) => search.dispose(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(
              theme['Theme'], theme['Light'], theme['Dark']
          ),
          builder: (context, child) {
            final ThemeProvider themeMode = context.watch<ThemeProvider>();
            return MaterialApp(
                localizationsDelegates: [S.delegate,
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
                    builder: (BuildContext context){
                      return AnnotatedRegion<SystemUiOverlayStyle>(
                        value: SystemUiOverlayStyle(
                            statusBarColor: Theme.of(context).appBarTheme.color,
                            systemNavigationBarColor: Theme.of(context).appBarTheme.color
                        ),
                        child: child,
                      );
                    }
                )
            );
          },
        ),
      ],
      child: firstPage,
    );
  }
}