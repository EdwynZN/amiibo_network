import 'package:flutter/material.dart';

class Themes {
  static final _dark = ThemeData(
    primaryColorDark: const Color.fromRGBO(207, 102, 121, 1),
    textSelectionHandleColor: const Color.fromRGBO(207, 102, 121, 1),
    appBarTheme: AppBarTheme(
      color: Colors.grey[900],
      textTheme: TextTheme(
        title: TextStyle(color: const Color(0xFFB2B2B2), fontSize: 20),
        subtitle: TextStyle(color: const Color(0xFFB2B2B2), fontSize: 16),
      ),
      iconTheme: const IconThemeData(color: Colors.white54),
    ),
    brightness: Brightness.dark,
    unselectedWidgetColor: Colors.grey,
    dividerColor: const Color(0xFFB2B2B2),
    scaffoldBackgroundColor: Colors.black,
    accentColor: const Color.fromRGBO(207, 102, 121, 1),
    accentIconTheme: const IconThemeData(color: Colors.black),
    primaryIconTheme: const IconThemeData(color: Colors.white54),
    iconTheme: const IconThemeData(color: Colors.white54),
    errorColor: Color.fromRGBO(207, 102, 121, 1),
    primaryColorLight: Colors.grey[850],
    canvasColor: Colors.grey[850],
    primarySwatch: Colors.blueGrey,
    primaryColor: Colors.blueGrey[900],
    cursorColor: Colors.white10,
    backgroundColor: Colors.grey[900],
    selectedRowColor: const Color.fromRGBO(96, 125, 139, 0.5),
    cardTheme: CardTheme(
      color: Colors.grey[900],
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 8,
    ),
    textTheme: TextTheme(
      title: TextStyle(color: const Color(0xFFB2B2B2), fontSize: 18, fontWeight: FontWeight.w400),
      body1: TextStyle(color: const Color(0xFFB2B2B2)),
      body2: TextStyle(color: const Color(0xFFB2B2B2), fontSize: 16, fontWeight: FontWeight.w400),
      display1: TextStyle(color: const Color(0xFFB2B2B2), fontSize: 18, fontWeight: FontWeight.w600),
      subhead: TextStyle(color: const Color(0xFFB2B2B2), fontSize: 16, fontWeight: FontWeight.w400),
    ),
    bottomAppBarTheme: BottomAppBarTheme(
      color: Colors.transparent,
      elevation: 0.0
    ),
    dialogTheme: DialogTheme(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    snackBarTheme: SnackBarThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color:const Color.fromRGBO(207, 102, 121, 1))
      ),
      behavior: SnackBarBehavior.floating,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey[800],
      disabledColor: Colors.grey,
      selectedColor: const Color.fromRGBO(207, 102, 121, 1),
      secondarySelectedColor: const Color.fromRGBO(96, 125, 139, 0.5),
      labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.all(2.0),
      shape: StadiumBorder(),
      labelStyle: TextStyle(color: Colors.white70),
      secondaryLabelStyle: TextStyle(color: Colors.white70),
      brightness: Brightness.dark
    ),
    buttonTheme: ButtonThemeData(
      textTheme: ButtonTextTheme.normal,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      layoutBehavior: ButtonBarLayoutBehavior.constrained,
      buttonColor: Colors.grey[900],
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      height: 48
    ),
    toggleableActiveColor: const Color.fromRGBO(207, 102, 121, 1),
    buttonColor: Colors.grey[850],
  );
  static final _light = ThemeData(
    primaryColorDark: Colors.redAccent,
    textSelectionHandleColor: Colors.white70,
    brightness: Brightness.light,
    appBarTheme: AppBarTheme(
      color: Colors.red,
      textTheme: TextTheme(
        title: TextStyle(color: Colors.white, fontSize: 20),
        subtitle: TextStyle(color: Colors.white, fontSize: 16),
      ),
      iconTheme: IconThemeData(
        color: Colors.white
      ),
    ),
    unselectedWidgetColor: Colors.black87,
    dividerColor: Colors.blueGrey,
    scaffoldBackgroundColor: Colors.red,
    accentColor: Colors.redAccent,
    accentIconTheme: const IconThemeData(color: Colors.white),
    primaryIconTheme: const IconThemeData(color: Colors.black),
    iconTheme: const IconThemeData(color: Colors.black),
    errorColor: Colors.redAccent,
    primaryColorLight: Colors.deepOrangeAccent[100],
    canvasColor: Colors.white,
    primarySwatch: Colors.red,
    primaryColor: Colors.red,
    cursorColor: Colors.black12,
    backgroundColor: const Color(0xFFE8C2BF), //Colors.white70,
    highlightColor: Colors.white70,
    selectedRowColor: const Color.fromRGBO(100, 181, 246, 0.5),
    cardTheme: CardTheme(
      color: Colors.white70,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 8,
    ),
    textTheme: TextTheme(
      title: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w400),
      subtitle: TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w400),
      body1: TextStyle(color: Colors.black87),
      body2: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w400),
      display1: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600),
      subhead: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w400),
    ),
    bottomAppBarTheme: BottomAppBarTheme(
      color: Colors.transparent,
      elevation: 0.0
    ),
    dialogTheme: DialogTheme(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    snackBarTheme: SnackBarThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),),
      behavior: SnackBarBehavior.floating,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color.fromRGBO(211, 211, 211, 0.7),
      disabledColor: Colors.grey,
      selectedColor: Colors.redAccent,
      secondarySelectedColor: Colors.redAccent,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.all(2.0),
      shape: StadiumBorder(),
      labelStyle: TextStyle(color: Colors.black),
      secondaryLabelStyle: TextStyle(color: Colors.black),
      brightness: Brightness.light
    ),
    buttonTheme: ButtonThemeData(
      textTheme: ButtonTextTheme.normal,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      layoutBehavior: ButtonBarLayoutBehavior.constrained,
      buttonColor: const Color(0xFFE8C2BF), //Colors.white70,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      height: 48,
      highlightColor: Colors.white54
    ),
    toggleableActiveColor: Colors.redAccent,
    indicatorColor: const Color.fromRGBO(178, 218, 251, 1),
    buttonColor: const Color(0xFFE8C2BF),
  );

  static ThemeData get light => _light;
  static ThemeData get dark => _dark;
}