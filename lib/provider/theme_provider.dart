import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

MaterialAccentColor get blueGreyAccent => MaterialAccentColor(
  0xFFA5BAC4,
  <int, Color>{
    100: Color(0xFFB0C9D4),
    200: Color(0xFFA5BAC4),
    400: Color(0xFF4D6773),
    700: Color(0xFF3A5E6B),
  },
);

Future<Map<String, dynamic>> getTheme() async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final String themeMode = preferences.getString('Theme') ?? 'Auto';
  final int light = preferences.getInt('lightColor');
  final int dark = preferences.getInt('darkColor');
  return {'Theme' : themeMode, 'Light' : light, 'Dark' : dark};
}

class ThemeProvider with ChangeNotifier{
  String _savedTheme;
  ThemeMode preferredTheme;
  int _lightColor;
  int _darkColor;
  final _Theme theme;

  ThemeProvider(this._savedTheme, this._lightColor, this._darkColor) :
    preferredTheme = _switchPreferredTheme(_savedTheme),
    theme = _Theme(light: _lightColor, dark: _darkColor);

  String get savedTheme => _savedTheme;

  int get lightOption => _lightColor;

  int get darkOption => _darkColor;

  lightTheme(int light) async{
    light = light?.clamp(0, 17) ?? 0;
    if(light != _lightColor){
      final SharedPreferences preferences = await SharedPreferences.getInstance();
      _lightColor = light;
      await preferences.setInt('lightColor', light);
      theme.setLight = _lightColor;
      notifyListeners();
    }
  }

  darkTheme(int dark) async{
    dark = dark?.clamp(0, 17) ?? 0;
    if(dark != _darkColor){
      final SharedPreferences preferences = await SharedPreferences.getInstance();
      _darkColor = dark;
      await preferences.setInt('darkColor', dark);
      theme.setDark = _darkColor;
      notifyListeners();
    }
  }

  themeDB(String value) async {
    if(value != _savedTheme){
      final SharedPreferences preferences = await SharedPreferences.getInstance();
      _savedTheme = value;
      await preferences.setString('Theme', value);
      preferredTheme = _switchPreferredTheme(_savedTheme);
      notifyListeners();
    }
  }

  static ThemeMode _switchPreferredTheme(String theme){
    switch(theme){
      case 'Light':
        return ThemeMode.light;
      case 'Dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

class _Theme{
  ThemeData _lightTheme;
  ThemeData _darkTheme;

  _Theme({int light, int dark}){
    setLight = light;
    setDark = dark;
  }

  set setLight(int light){
    MaterialColor color = Colors.primaries[light?.clamp(0, 17) ?? 0];
    MaterialAccentColor accentColor = Colors.accents[light?.clamp(0, 15) ?? 0];
    if(light == 17) accentColor = blueGreyAccent;
    _lightTheme = ThemeData(
      primaryColorDark: accentColor[100],
      textSelectionHandleColor: color[300],
      brightness: Brightness.light,
      appBarTheme: AppBarTheme(
        color: color,
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
      scaffoldBackgroundColor: color,
      accentColor: accentColor,
      accentIconTheme: const IconThemeData(color: Colors.white),
      primaryIconTheme: const IconThemeData(color: Colors.black),
      iconTheme: const IconThemeData(color: Colors.black),
      errorColor: Colors.redAccent,
      primaryColorLight: accentColor[100],
      canvasColor: Colors.white,
      primarySwatch: color,
      primaryColor: color,
      cursorColor: Colors.black12,
      backgroundColor: color[100],
      highlightColor: Colors.white70,
      selectedRowColor: color[200],
      cardTheme: CardTheme(
        color: color[100],
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
        backgroundColor: color[100],//Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: color[100], //const Color(0xFFE8C2BF),
        contentTextStyle: TextStyle(
            color: Colors.black
        ),
        //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: accentColor)
        ),
        behavior: SnackBarBehavior.floating,
      ),
      buttonTheme: ButtonThemeData(
        textTheme: ButtonTextTheme.normal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        layoutBehavior: ButtonBarLayoutBehavior.constrained,
        buttonColor: color[100], //const Color(0xFFE8C2BF), //Colors.white70,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        height: 48,
        highlightColor: Colors.white70,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
      ),
      toggleableActiveColor: accentColor,
      indicatorColor: color[100],
      buttonColor: color[100],
    );
  }

  set setDark(int dark){
    //MaterialColor color = Colors.primaries[dark?.clamp(0, 2) ?? 0];
    //MaterialAccentColor accentColor = Colors.accents[dark?.clamp(0, 2) ?? 0];
    dark ??= 0;
    switch(dark){
      case 0:
        _darkTheme = ThemeData(
          primaryColorDark: const Color.fromRGBO(207, 102, 121, 1),
          textSelectionHandleColor: const Color.fromRGBO(207, 102, 121, 1),
          appBarTheme: AppBarTheme(
            color: Colors.blueGrey[900],
            textTheme: TextTheme(
              title: TextStyle(color: const Color(0xFFB2B2B2), fontSize: 20),
              subtitle: TextStyle(color: const Color(0xFFB2B2B2), fontSize: 16),
            ),
            iconTheme: const IconThemeData(color: Colors.white54),
          ),
          brightness: Brightness.dark,
          unselectedWidgetColor: Colors.white54,
          dividerColor: const Color(0xFFB2B2B2),
          scaffoldBackgroundColor: Colors.blueGrey[900],
          accentColor: const Color.fromRGBO(207, 102, 121, 1),
          accentIconTheme: const IconThemeData(color: Colors.black),
          primaryIconTheme: const IconThemeData(color: Colors.white54),
          iconTheme: const IconThemeData(color: Colors.white54),
          errorColor: Color.fromRGBO(207, 102, 121, 1),
          primaryColorLight: Colors.blueGrey[800],
          canvasColor: Colors.blueGrey[800],
          primarySwatch: Colors.blueGrey,
          primaryColor: Colors.blueGrey[900],
          cursorColor: Colors.white10,
          backgroundColor: Colors.blueGrey[800],
          selectedRowColor: const Color.fromRGBO(96, 125, 139, 0.5),
          cardTheme: CardTheme(
            color: Colors.blueGrey[800],
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
            backgroundColor: Colors.blueGrey[900],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: Colors.blueGrey[800],
            contentTextStyle: TextStyle(
                color: const Color(0xFFB2B2B2)
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color:const Color.fromRGBO(207, 102, 121, 1))
            ),
            behavior: SnackBarBehavior.floating,
          ),
          buttonTheme: ButtonThemeData(
            textTheme: ButtonTextTheme.normal,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            layoutBehavior: ButtonBarLayoutBehavior.constrained,
            buttonColor: Colors.grey[900],
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            height: 48
          ),
          bottomSheetTheme: BottomSheetThemeData(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
          ),
          toggleableActiveColor: const Color.fromRGBO(207, 102, 121, 1),
          buttonColor: Colors.blueGrey[800],
        );
        break;
      case 1:
        _darkTheme = ThemeData(
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
          unselectedWidgetColor: Colors.white54,
          dividerColor: const Color(0xFFB2B2B2),
          scaffoldBackgroundColor: Colors.grey[900],
          accentColor: const Color.fromRGBO(207, 102, 121, 1),
          accentIconTheme: const IconThemeData(color: Colors.black),
          primaryIconTheme: const IconThemeData(color: Colors.white54),
          iconTheme: const IconThemeData(color: Colors.white54),
          errorColor: Color.fromRGBO(207, 102, 121, 1),
          primaryColorLight: Colors.grey[800],
          canvasColor: Colors.grey[800],
          primarySwatch: Colors.grey,
          primaryColor: Colors.grey[900],
          cursorColor: Colors.white10,
          backgroundColor: Colors.grey[800],
          selectedRowColor: const Color.fromRGBO(96, 125, 139, 0.5),
          cardTheme: CardTheme(
            color: Colors.grey[800],
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
            backgroundColor: Colors.grey[800],
            contentTextStyle: TextStyle(
                color: const Color(0xFFB2B2B2)
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color:const Color.fromRGBO(207, 102, 121, 1))
            ),
            behavior: SnackBarBehavior.floating,
          ),
          buttonTheme: ButtonThemeData(
            textTheme: ButtonTextTheme.normal,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            layoutBehavior: ButtonBarLayoutBehavior.constrained,
            buttonColor: Colors.grey[900],
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            height: 48
          ),
          bottomSheetTheme: BottomSheetThemeData(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
          ),
          toggleableActiveColor: const Color.fromRGBO(207, 102, 121, 1),
          buttonColor: Colors.grey[800],
        );
        break;
      case 2:
        _darkTheme = ThemeData(
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
          unselectedWidgetColor: Colors.white54,
          dividerColor: const Color(0xFFB2B2B2),
          scaffoldBackgroundColor: Colors.black,
          accentColor: const Color.fromRGBO(207, 102, 121, 1),
          accentIconTheme: const IconThemeData(color: Colors.black),
          primaryIconTheme: const IconThemeData(color: Colors.white54),
          iconTheme: const IconThemeData(color: Colors.white54),
          errorColor: Color.fromRGBO(207, 102, 121, 1),
          primaryColorLight: Colors.grey[850],
          canvasColor: Colors.grey[900],
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
            backgroundColor: Colors.grey[900],
            contentTextStyle: TextStyle(
                color: const Color(0xFFB2B2B2)
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color:const Color.fromRGBO(207, 102, 121, 1))
            ),
            behavior: SnackBarBehavior.floating,
          ),
          buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme.normal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              layoutBehavior: ButtonBarLayoutBehavior.constrained,
              buttonColor: Colors.grey[900],
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              height: 48
          ),
          bottomSheetTheme: BottomSheetThemeData(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
          ),
          toggleableActiveColor: const Color.fromRGBO(207, 102, 121, 1),
          buttonColor: Colors.grey[900],
        );
        break;
      default:
        _darkTheme = ThemeData(
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
          unselectedWidgetColor: Colors.white54,
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
            backgroundColor: Colors.grey[900],
            contentTextStyle: TextStyle(
                color: const Color(0xFFB2B2B2)
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color:const Color.fromRGBO(207, 102, 121, 1))
            ),
            behavior: SnackBarBehavior.floating,
          ),
          buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme.normal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              layoutBehavior: ButtonBarLayoutBehavior.constrained,
              buttonColor: Colors.grey[900],
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              height: 48
          ),
          bottomSheetTheme: BottomSheetThemeData(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
          ),
          toggleableActiveColor: const Color.fromRGBO(207, 102, 121, 1),
          buttonColor: Colors.grey[850],
        );
        break;
    }
  }

  ThemeData get light => _lightTheme;
  ThemeData get dark => _darkTheme;
}