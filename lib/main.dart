import 'package:flutter/material.dart';
import 'package:amiibo_network/screen/home_page.dart';
import 'package:amiibo_network/screen/splash_screen.dart';
import 'package:amiibo_network/screen/detail_page.dart';
import 'package:amiibo_network/screen/settings_screen.dart';
import 'package:amiibo_network/screen/settings_detail.dart';
import 'package:amiibo_network/screen/search_screen.dart';
import 'package:amiibo_network/widget/route_transitions.dart';
import 'package:amiibo_network/service/service.dart';

void main() async {
  if(!(await Service().compareLastUpdate() ?? true)) runApp(MyApp(SplashScreen()));
  else runApp(MyApp(HomePage()));
}

class MyApp extends StatelessWidget {
  final Widget firstPage;
  MyApp(this.firstPage);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        unselectedWidgetColor: Colors.deepOrangeAccent[100],
        dividerColor: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.red,
        accentColor: Colors.redAccent,
        canvasColor: Colors.red,
        primarySwatch: Colors.red,
        primaryColor: Colors.red,
        cursorColor: Colors.black12,
        backgroundColor: Colors.white70,
        cardTheme: CardTheme(
          color: Colors.white70,
          margin: EdgeInsets.only(right: 8, left: 8, top: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 8,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        unselectedWidgetColor: Colors.grey[700],
        dividerColor: Colors.white70,
        scaffoldBackgroundColor: Colors.blueGrey[800],
        accentColor: Colors.blueGrey[700],
        canvasColor: Colors.blueGrey,
        primarySwatch: Colors.blueGrey,
        primaryColor: Colors.blueGrey[900],
        cursorColor: Colors.black12,
        backgroundColor: Colors.white70,
        cardTheme: CardTheme(
          color: Colors.blueGrey[900],
          margin: EdgeInsets.only(right: 8, left: 8, top: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 8,
        ),
        iconTheme: IconThemeData(color: Colors.white70),
        textTheme: TextTheme(
          body1: TextStyle(color: Colors.white),
        )
      ),
      onGenerateRoute: _getRoute,
      routes: <String, WidgetBuilder> {
        '/': (context) => firstPage,
        '/Splash': (context) => SplashScreen(),
      },
    );
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    switch(settings.name){
      case '/details':
        return materialRoute(DetailPage(amiibo: settings.arguments), settings);
      case '/home':
        return ScaleRoute(builder: (_) => HomePage());
      case '/settings':
        return SlideRoute(builder: (_) => SettingsPage());
      case '/settingsdetail':
        return SlideRoute(builder: (_) => SettingsDetail(title: settings.arguments), settings: settings);
      case '/search':
        return FadeRoute(builder: (_) => SearchScreen());
      default:
        return null;
    }
  }

}