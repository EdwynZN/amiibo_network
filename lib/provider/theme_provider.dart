import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const colorOwned = const MaterialAccentColor(
  0xFF2E7D32,
  <int, Color>{
    100: Color(0xFFB9F6CA),
    200: Color(0xFF2E7D32),
    400: Color(0xFF1B5E20),
    700: Color(0xFF4A5F20),
  },
);
const colorWished = const MaterialAccentColor(
  0xFFF57F17,
  <int, Color>{
    100: Color(0xFFFFE57F),
    200: Color(0xFFF57F17),
    400: Color(0xFFFF8F00),
    700: Color(0xFFFF6F00),
  },
);
const iconOwned = Icons.check_circle_outline;
const iconOwnedDark = Icons.check;
const iconWished = Icons.card_giftcard;

Future<Map<String,dynamic>> getTheme() async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  if(preferences.containsKey('Theme')){
    final String theme = preferences.getString('Theme') ?? 'Auto';
    preferences.remove('Theme');
    switch(theme){
      case 'Light':
        preferences.setInt('ThemeMode', ThemeMode.light.index);
        break;
      case 'Dark':
        preferences.setInt('ThemeMode', ThemeMode.dark.index);
        break;
      case 'Auto':
      default:
      preferences.setInt('ThemeMode', ThemeMode.system.index);
      break;
    }
  }
  final int theme = preferences.getInt('ThemeMode') ?? 0;
  final int light = preferences.getInt('lightColor') ?? 0;
  final int dark = preferences.getInt('darkColor') ?? 2;
  return <String,int>{'Theme' : theme, 'Light' : light, 'Dark' : dark};
}

class ThemeProvider with ChangeNotifier{
  ThemeMode _preferredTheme;
  int _lightColor;
  int _darkColor;
  final _Theme theme;

  ThemeProvider(int themeMode, this._lightColor, this._darkColor) :
    _preferredTheme = ThemeMode.values[themeMode],
    theme = _Theme(light: _lightColor, dark: _darkColor);

  ThemeMode get preferredTheme => _preferredTheme;

  int get lightOption => _lightColor ?? 0;

  int get darkOption => _darkColor ?? 2;

  lightTheme(int light) async{
    light = light?.clamp(0, 17) ?? 0;
    if(light != _lightColor){
      final SharedPreferences preferences = await SharedPreferences.getInstance();
      _lightColor = light;
      await preferences.setInt('lightColor', light);
      theme..setLight = _lightColor..setDark = _darkColor;
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

  Future<void> themeDB(ThemeMode value) async {
    if(value == null) value = ThemeMode.system;
    if(value != preferredTheme){
      final SharedPreferences preferences = await SharedPreferences.getInstance();
      _preferredTheme = value;
      await preferences.setInt('ThemeMode', value.index);
      notifyListeners();
    }
  }
}

class _Theme{
  ThemeData _lightTheme;
  ThemeData _darkTheme;
  Color _darkAccentColor = const Color.fromRGBO(207, 102, 121, 1);
  TextTheme __darkAccentTextTheme = const TextTheme(
    headline6: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w400),
    subtitle2: TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w400),
    bodyText2: TextStyle(color: Colors.black87, fontSize: 14),
    bodyText1: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w400),
    headline4: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600),
    subtitle1: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w400),
  );
  TextTheme __lightAccentTextTheme = const TextTheme(
    headline6: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w400),
    subtitle2: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w400),
    bodyText2: TextStyle(color: Colors.white70, fontSize: 14),
    bodyText1: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w400),
    headline4: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w600),
    subtitle1: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w400),
  );

  _Theme({int light, int dark}){
    setLight = light;
    setDark = dark;
  }

  set setLight(int light){
    light ??= 0;
    MaterialColor color = Colors.primaries[light.clamp(0, 17)];
    MaterialAccentColor accentColor = Colors.accents[light.clamp(0, 15)];
    if(light >= 17) accentColor = const MaterialAccentColor(
      0xFF4D6773,
      <int, Color>{
        100: Color(0xFFA7C0CD),
        200: Color(0xFF78909C),
        400: Color(0xFF62727b),
        700: Color(0xFF546E7A),
      },
    );
    _darkAccentColor = accentColor[200];
    final Brightness _brightnessColor = ThemeData.estimateBrightnessForColor(color);
    final Brightness _brightnessAccentColor = ThemeData.estimateBrightnessForColor(accentColor);
    final Brightness _brightnessAccentTextTheme = ThemeData.estimateBrightnessForColor(accentColor[700]);
    _lightTheme = ThemeData(
      splashFactory: InkRipple.splashFactory,
      primaryColorDark: accentColor[100],
      textSelectionHandleColor: color[300],
      textSelectionColor: accentColor.withOpacity(0.5),
      brightness: Brightness.light,
      appBarTheme: AppBarTheme(
        elevation: 0.0,
        color: color,
        textTheme: _brightnessColor == Brightness.light ?
          __darkAccentTextTheme.apply(fontSizeFactor: 1.15, fontSizeDelta: 1.0) :
          __lightAccentTextTheme.apply(fontSizeFactor: 1.15, fontSizeDelta: 1.0, bodyColor: Colors.white, displayColor: Colors.white),
        /*textTheme: TextTheme(
          headline6: TextStyle(color: Colors.white, fontSize: 20),
          subtitle2: TextStyle(color: Colors.white, fontSize: 16),
        ),*/
        iconTheme: IconThemeData(
          color: _brightnessColor == Brightness.dark ? Colors.white : Colors.black,
        ),
      ),
      unselectedWidgetColor: Colors.black87,
      dividerColor: color,
      scaffoldBackgroundColor: color[50],
      accentColor: accentColor[700],
      accentIconTheme: IconThemeData(
        color: ThemeData.estimateBrightnessForColor(accentColor[100]) == Brightness.dark ? Colors.white : Colors.black
      ),
      accentColorBrightness: _brightnessAccentColor,
      primaryIconTheme: const IconThemeData(color: Colors.black),
      iconTheme: const IconThemeData(color: Colors.black),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: _brightnessAccentColor == Brightness.dark ? Colors.white : Colors.black,//Colors.white,
        backgroundColor: accentColor
      ),
      errorColor: Colors.redAccent,
      primaryColorLight: accentColor[100],
      canvasColor: color[50],
      primarySwatch: color,
      primaryColor: color,
      cursorColor: Colors.black12,
      backgroundColor: color[100],
      highlightColor: color[200],
      selectedRowColor: color[200],
      cardColor: color[100],
      cardTheme: CardTheme(
        color: color[100],
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 8,
      ),
      textTheme: const TextTheme(
        headline6: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w400),
        subtitle2: TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w400),
        bodyText2: TextStyle(color: Colors.black87),
        bodyText1: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w400),
        headline4: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600),
        subtitle1: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w400),
      ),
      accentTextTheme: _brightnessAccentTextTheme == Brightness.dark ? __lightAccentTextTheme : __darkAccentTextTheme,
      bottomAppBarTheme: BottomAppBarTheme(
          color: Colors.transparent,
          elevation: 0.0
      ),
      dialogTheme: DialogTheme(
        titleTextStyle: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600),
        backgroundColor: color[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: color[100],
        contentTextStyle: TextStyle(
            color: Colors.black
        ),
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
        buttonColor: color[100],
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        height: 48,
        highlightColor: color[200],
      ),
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
      ),
      toggleableActiveColor: accentColor[700],
      indicatorColor: color[100],
      buttonColor: color[100],
    );
  }

  set setDark(int dark){
    dark ??= 2;
    final Brightness _brightness = ThemeData.estimateBrightnessForColor(_darkAccentColor);
    switch(dark){
      case 0:
        _darkTheme = ThemeData(
          splashFactory: InkRipple.splashFactory,
          primaryColorDark: _darkAccentColor,
          textSelectionHandleColor: _darkAccentColor,
          textSelectionColor: _darkAccentColor.withOpacity(0.5),
          appBarTheme: AppBarTheme(
            elevation: 0.0,
            color: Colors.blueGrey[900],
            textTheme: __lightAccentTextTheme.apply(fontSizeFactor: 1.15, fontSizeDelta: 1.0),
            /*textTheme: TextTheme(
              headline6: TextStyle(color: Colors.white70, fontSize: 20),
              subtitle2: TextStyle(color: Colors.white70, fontSize: 16),
            ),*/
            iconTheme: const IconThemeData(color: Colors.white70),
          ),
          brightness: Brightness.dark,
          unselectedWidgetColor: Colors.white70,
          dividerColor: Colors.blueGrey[700],
          scaffoldBackgroundColor: Colors.blueGrey[900],
          accentColor: _darkAccentColor,
          accentIconTheme: const IconThemeData(color: Colors.black),
          accentColorBrightness: _brightness,
          primaryIconTheme: const IconThemeData(color: Colors.white70),
          iconTheme: const IconThemeData(color: Colors.white70),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            foregroundColor: _brightness == Brightness.dark ? Colors.white : Colors.black,//Colors.white,
            backgroundColor: _darkAccentColor,
          ),
          errorColor: Color.fromRGBO(207, 102, 121, 1),
          primaryColorLight: Colors.blueGrey[800],
          canvasColor: Colors.blueGrey[900],
          primarySwatch: Colors.blueGrey,
          primaryColor: Colors.blueGrey[900],
          cursorColor: Colors.white10,
          backgroundColor: Colors.blueGrey[800],
          selectedRowColor: Colors.blueGrey[700],
          cardColor: Colors.blueGrey[800],
          cardTheme: CardTheme(
            color: Colors.blueGrey[800],
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 8,
          ),
          textTheme: const TextTheme(
            headline6: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w400),
            subtitle2: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w400),
            bodyText2: TextStyle(color: Colors.white70),
            bodyText1: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w400),
            headline4: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w600),
            subtitle1: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w400),
          ),
          accentTextTheme: _brightness == Brightness.dark ? __lightAccentTextTheme : __darkAccentTextTheme,
          bottomAppBarTheme: BottomAppBarTheme(
            color: Colors.transparent,
            elevation: 0.0
          ),
          dialogTheme: DialogTheme(
            titleTextStyle: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w600),
            backgroundColor: Colors.blueGrey[900],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: Colors.blueGrey[800],
            contentTextStyle: TextStyle(
                color: Colors.white70
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
          toggleableActiveColor: _darkAccentColor,
          indicatorColor: Colors.blueGrey[700],
          buttonColor: Colors.blueGrey[800],
        );
        break;
      case 1:
        _darkTheme = ThemeData(
          splashFactory: InkRipple.splashFactory,
          primaryColorDark: _darkAccentColor,
          textSelectionHandleColor: _darkAccentColor,
          textSelectionColor: _darkAccentColor.withOpacity(0.5),
          appBarTheme: AppBarTheme(
            elevation: 0.0,
            color: Colors.grey[900],
            textTheme: __lightAccentTextTheme.apply(fontSizeFactor: 1.15, fontSizeDelta: 1.0),
            /*textTheme: TextTheme(
              headline6: TextStyle(color: Colors.white70, fontSize: 20),
              subtitle2: TextStyle(color: Colors.white70, fontSize: 16),
            ),*/
            iconTheme: const IconThemeData(color: Colors.white70),
          ),
          brightness: Brightness.dark,
          unselectedWidgetColor: Colors.white70,
          dividerColor: Colors.grey[800],
          scaffoldBackgroundColor: Colors.grey[900],
          accentColor: _darkAccentColor,
          accentIconTheme: const IconThemeData(color: Colors.black),
          accentColorBrightness: _brightness,
          primaryIconTheme: const IconThemeData(color: Colors.white70),
          iconTheme: const IconThemeData(color: Colors.white70),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            foregroundColor: _brightness == Brightness.dark ? Colors.white : Colors.black,//Colors.white,
            backgroundColor: _darkAccentColor,
          ),
          errorColor: Color.fromRGBO(207, 102, 121, 1),
          primaryColorLight: Colors.grey[850],
          canvasColor: Colors.grey[900],
          primarySwatch: Colors.grey,
          primaryColor: Colors.grey[900],
          cursorColor: Colors.white10,
          backgroundColor: Colors.grey[850],
          selectedRowColor: Colors.grey[800],
          cardColor: Colors.grey[850],
          cardTheme: CardTheme(
            color: Colors.grey[850],
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 8,
          ),
          textTheme: const TextTheme(
            subtitle1: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w400),
            subtitle2: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w400),
            bodyText1: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w400),
            bodyText2: TextStyle(color: Colors.white70),
            headline4: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w600),
            headline6: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w400),
          ),
          accentTextTheme: _brightness == Brightness.dark ? __lightAccentTextTheme : __darkAccentTextTheme,
          bottomAppBarTheme: BottomAppBarTheme(
              color: Colors.transparent,
              elevation: 0.0
          ),
          dialogTheme: DialogTheme(
            titleTextStyle: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w600),
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: Colors.grey[800],
            contentTextStyle: TextStyle(
                color: Colors.white70
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
          toggleableActiveColor: _darkAccentColor,
          indicatorColor: Colors.grey[700],
          buttonColor: Colors.grey[850],
        );
        break;
      case 2:
      default:
        _darkTheme = ThemeData(
          splashFactory: InkRipple.splashFactory,
          primaryColorDark: _darkAccentColor,
          textSelectionHandleColor: _darkAccentColor,
          textSelectionColor: _darkAccentColor.withOpacity(0.5),
          appBarTheme: AppBarTheme(
            elevation: 0.0,
            color: Colors.black,
            textTheme: __lightAccentTextTheme.apply(fontSizeFactor: 1.15, fontSizeDelta: 1.0),
            /*textTheme: TextTheme(
              headline6: TextStyle(color: Colors.white70, fontSize: 20),
              subtitle2: TextStyle(color: Colors.white70, fontSize: 16),
            ),*/
            iconTheme: const IconThemeData(color: Colors.white70),
          ),
          brightness: Brightness.dark,
          unselectedWidgetColor: Colors.white70,
          dividerColor: Colors.grey[800],
          scaffoldBackgroundColor: Colors.black,
          accentColor: _darkAccentColor,
          accentIconTheme: const IconThemeData(color: Colors.black),
          accentColorBrightness: _brightness,
          primaryIconTheme: const IconThemeData(color: Colors.white70),
          iconTheme: const IconThemeData(color: Colors.white70),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            foregroundColor: _brightness == Brightness.dark ? Colors.white : Colors.black,
            backgroundColor: _darkAccentColor,
          ),
          errorColor: Color.fromRGBO(207, 102, 121, 1),
          primaryColorLight: Colors.transparent,
          canvasColor: Colors.black,
          primarySwatch: Colors.blueGrey,
          primaryColor: Colors.grey[900],
          cursorColor: Colors.white10,
          backgroundColor: Colors.black,
          selectedRowColor: Colors.grey[900],
          cardColor: Colors.black,
          cardTheme: CardTheme(
            color: Colors.transparent,
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[900], width: 2)
            ),
            elevation: 0,
          ),
          textTheme: const TextTheme(
            headline6: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w400),
            subtitle2: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w400),
            bodyText2: TextStyle(color: Colors.white70),
            bodyText1: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w400),
            headline4: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w600),
            subtitle1: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w400),
          ),
          accentTextTheme: _brightness == Brightness.dark ? __lightAccentTextTheme : __darkAccentTextTheme,
          bottomAppBarTheme: BottomAppBarTheme(
              color: Colors.transparent,
              elevation: 0.0
          ),
          dialogTheme: DialogTheme(
            titleTextStyle: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w600),
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: _darkAccentColor)
            ),
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: Colors.grey[900],
            contentTextStyle: TextStyle(color: Colors.white70),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: _darkAccentColor)
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
          toggleableActiveColor: _darkAccentColor,
          buttonColor: Colors.grey[900],
        );
        break;
    }
  }

  ThemeData get light => _lightTheme;
  ThemeData get dark => _darkTheme;
}