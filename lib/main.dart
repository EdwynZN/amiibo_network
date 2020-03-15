import 'package:amiibo_network/provider/search_provider.dart';
import 'package:amiibo_network/service/update_service.dart';
import 'package:flutter/material.dart';
import 'package:amiibo_network/screen/home_page.dart';
import 'package:amiibo_network/screen/splash_screen.dart';
import 'package:amiibo_network/widget/route_transitions.dart';
import 'package:amiibo_network/provider/theme_provider.dart';
import 'package:amiibo_network/provider/amiibo_provider.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:amiibo_network/provider/stat_provider.dart';
//import 'package:flutter/gestures.dart';

void main() async {
  //debugPrintGestureArenaDiagnostics = true;
  WidgetsFlutterBinding.ensureInitialized();
  final UpdateService updateService = UpdateService();
  await updateService.initDB();
  final bool splash = await updateService.compareLastUpdate();
  final Map<String,dynamic> savedTheme = await getTheme();
  final bool stat = await getStatMode();
  runApp(
    AmiiboNetwork(
      firstPage: splash ? Home() : SplashScreen(),
      theme: savedTheme,
      statMode: stat,
    )
  );
}

class AmiiboNetwork extends StatelessWidget {
  final Widget firstPage;
  final Map<String,dynamic> theme;
  final bool statMode;
  AmiiboNetwork({this.firstPage, this.theme, this.statMode});

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