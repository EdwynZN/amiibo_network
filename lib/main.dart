import 'package:flutter/material.dart';
import 'package:amiibo_network/screen/home_page.dart';
import 'package:amiibo_network/screen/splash_screen.dart';
import 'package:amiibo_network/screen/detail_page.dart';
import 'package:amiibo_network/screen/settings_screen.dart';
import 'package:amiibo_network/screen/settings_detail.dart';
import 'package:amiibo_network/screen/search_screen.dart';
import 'package:amiibo_network/widget/route_transitions.dart';
import 'package:amiibo_network/service/service.dart';
import 'package:flutter/cupertino.dart';

void main() async {
  runApp(MyApp(SplashScreen()));
  //if(!(await Service().compareLastUpdate() ?? true)) runApp(MyApp(SplashScreen()));
  //else runApp(MyApp(HomePage()));
}

class MyApp extends StatelessWidget {
  final Widget firstPage;
  MyApp(this.firstPage);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textSelectionHandleColor: Colors.white70,
        brightness: Brightness.light,
        appBarTheme: AppBarTheme(color: Colors.red),
        unselectedWidgetColor: Colors.deepOrangeAccent[100],
        dividerColor: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.red,
        accentColor: Colors.redAccent,
        accentIconTheme: IconThemeData(color: Colors.white),
        iconTheme: IconThemeData(color: Colors.black),
        errorColor: Colors.redAccent,
        canvasColor: Colors.red,
        primarySwatch: Colors.red,
        primaryColor: Colors.red,
        cursorColor: Colors.black12,
        backgroundColor: Colors.white70,
        highlightColor: Colors.white54,
        cardTheme: CardTheme(
          color: Colors.white70,
          margin: EdgeInsets.only(right: 8, left: 8, top: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 8,
        ),
        textTheme: TextTheme(
          body1: TextStyle(color: Colors.black87),
          body2: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w400),
        )
      ),
      darkTheme: ThemeData(
        textSelectionHandleColor: Color.fromRGBO(207, 102, 121, 1),
        appBarTheme: AppBarTheme(
          color: Colors.grey[900],
          textTheme: TextTheme(title: TextStyle(color: Colors.white70, fontSize: 20)),
          iconTheme: IconThemeData(color: Colors.white54),
        ),
        brightness: Brightness.dark,
        unselectedWidgetColor: Colors.grey[850],
        dividerColor: Colors.white70,
        scaffoldBackgroundColor: Colors.grey[900],
        accentColor: Color.fromRGBO(207, 102, 121, 1),
        accentIconTheme: IconThemeData(color: Colors.black),
        iconTheme: IconThemeData(color: Colors.white54),
        errorColor: Color.fromRGBO(207, 102, 121, 1),
        canvasColor: Colors.grey[900],
        primarySwatch: Colors.blueGrey,
        primaryColor: Colors.blueGrey[900],
        cursorColor: Colors.white10,
        backgroundColor: Colors.grey[850],
        cardTheme: CardTheme(
          color: Colors.grey[900],
          margin: EdgeInsets.only(right: 8, left: 8, top: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 8,
        ),
        textTheme: TextTheme(
          body1: TextStyle(color: Colors.white70),
          body2: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w400),
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
        return FadeRoute(builder: (_) => HomePage());
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