import 'package:flutter/material.dart';

class Themes {
  static final _dark = ThemeData(
    primaryColorDark: const Color.fromRGBO(207, 102, 121, 1),
    textSelectionHandleColor: const Color.fromRGBO(207, 102, 121, 1),
    appBarTheme: AppBarTheme(
      color: Colors.grey[900],
      textTheme: TextTheme(title: TextStyle(color: Colors.white70, fontSize: 20)),
      iconTheme: IconThemeData(color: Colors.white54),
    ),
    brightness: Brightness.dark,
    unselectedWidgetColor: Colors.grey[850],
    dividerColor: Colors.white70,
    scaffoldBackgroundColor: Colors.black,
    accentColor: const Color.fromRGBO(207, 102, 121, 1),
    accentIconTheme: IconThemeData(color: Colors.black),
    iconTheme: IconThemeData(color: Colors.white54),
    errorColor: Color.fromRGBO(207, 102, 121, 1),
    canvasColor: Colors.grey[850],
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
      display1: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),
    )
  );
  static final _light = ThemeData(
    primaryColorDark: Colors.redAccent,
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
      display1: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
    )
  );

  static ThemeData get light => _light;
  static ThemeData get dark => _dark;
}