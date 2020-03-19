import '../generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amiibo_network/provider/search_provider.dart';
import 'package:amiibo_network/widget/route_transitions.dart';
import 'package:amiibo_network/provider/theme_provider.dart';
import 'package:amiibo_network/provider/amiibo_provider.dart';
import 'package:flutter/services.dart';
import 'package:amiibo_network/provider/stat_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MyApp extends StatelessWidget {
  final Widget firstPage;
  final Map<String,dynamic> theme;
  final bool statMode;
  MyApp({this.firstPage, this.theme, this.statMode});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(
              theme['Theme'], theme['Light'], theme['Dark']
          ),
        ),
        ChangeNotifierProvider<StatProvider>(
          create: (context) => StatProvider(statMode),
        ),
        Provider<SearchProvider>(
          create: (_) => SearchProvider(),
          dispose: (_, search) => search.dispose(),
        ),
        ChangeNotifierProvider<AmiiboProvider>(
          create: (_) => AmiiboProvider(),
        ),
        Consumer<ThemeProvider>(
          builder: (context, themeMode, child) => MaterialApp(
            localizationsDelegates: [S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            /*localeResolutionCallback: (deviceLocale, supportedLocales){
              if(S.delegate.isSupported(deviceLocale)) return deviceLocale;
              return supportedLocales.first;
            },*/
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
          ),
        ),
      ],
      child: firstPage,
    );
  }
}