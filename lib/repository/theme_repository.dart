import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

abstract class AmiiboTheme {
  factory AmiiboTheme({int? light, int? dark}) = _Theme;

  ThemeData? get light;
  ThemeData? get dark;

  set setLight(int light);
  set setDark(int dark);
}

class _Theme implements AmiiboTheme {
  ThemeData? _lightTheme;
  ThemeData? _darkTheme;
  late MaterialAccentColor _darkAccentColor;
  TextTheme __darkAccentTextTheme = const TextTheme(
    subtitle1: TextStyle(
        color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w400),
    subtitle2: TextStyle(
        color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w400),
    bodyText1: TextStyle(
        color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w400),
    bodyText2: TextStyle(color: Colors.black87, fontSize: 14),
    headline1: TextStyle(
        color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w400),
    headline2: TextStyle(
        color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w600),
    headline3: TextStyle(
        color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w400),
    headline4: TextStyle(
        color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600),
    headline5: TextStyle(
        color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w400),
    headline6: TextStyle(
        color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600),
  );
  TextTheme __lightAccentTextTheme = const TextTheme(
    subtitle1: TextStyle(
        color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w400),
    subtitle2: TextStyle(
        color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w400),
    bodyText1: TextStyle(
        color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w400),
    bodyText2: TextStyle(color: Colors.white70, fontSize: 14),
    headline1: TextStyle(
        color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w400),
    headline2: TextStyle(
        color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
    headline3: TextStyle(
        color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w400),
    headline4: TextStyle(
        color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w600),
    headline5: TextStyle(
        color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w400),
    headline6: TextStyle(
        color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w600),
  );

  _Theme({int? light, int? dark}) {
    setLight = light;
    setDark = dark;
  }

  set setLight(int? light) {
    light ??= 0;
    MaterialColor color = Colors.primaries[light.clamp(0, 17)];
    MaterialAccentColor accentColor = Colors.accents[light.clamp(0, 15)];
    if (light >= 17)
      accentColor = const MaterialAccentColor(
        0xFF4D6773,
        <int, Color>{
          100: Color(0xFFA7C0CD),
          200: Color(0xFF78909C),
          400: Color(0xFF62727b),
          700: Color(0xFF546E7A),
        },
      );
    _darkAccentColor = accentColor;
    final Brightness _brightnessColor =
        ThemeData.estimateBrightnessForColor(color);
    final Brightness _brightnessAccentColor =
        ThemeData.estimateBrightnessForColor(accentColor);
    final Brightness _brightnessPrimaryColor =
        ThemeData.estimateBrightnessForColor(accentColor[100]!);
    final Brightness _brightnessAccentTextTheme =
        ThemeData.estimateBrightnessForColor(accentColor[700]!);
    _lightTheme = ThemeData(
      splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
      primaryColorLight: accentColor[100],
      primaryColorDark: accentColor[600],
      primaryIconTheme: const IconThemeData(color: Colors.black),
      textSelectionTheme: TextSelectionThemeData(
        selectionHandleColor: color[300],
        selectionColor: accentColor.withOpacity(0.5),
        cursorColor: Colors.black12,
      ),
      brightness: _brightnessColor,
      appBarTheme: AppBarTheme(
        elevation: 0.0,
        surfaceTintColor: color,
        backgroundColor: color,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: _brightnessColor,
          statusBarIconBrightness: _brightnessColor == Brightness.light
              ? Brightness.dark
              : Brightness.light,
          systemNavigationBarIconBrightness:
              _brightnessColor == Brightness.light
                  ? Brightness.dark
                  : Brightness.light,
          statusBarColor: color,
          systemNavigationBarColor: color,
        ),
        titleTextStyle: _brightnessColor == Brightness.light
            ? __darkAccentTextTheme.headline6!
            : __lightAccentTextTheme.headline6!.apply(color: Colors.white),
        foregroundColor: color,
        toolbarTextStyle: _brightnessColor == Brightness.light
            ? __darkAccentTextTheme.bodyText2
            : __lightAccentTextTheme.bodyText2,
        iconTheme: IconThemeData(
          color:
              _brightnessColor == Brightness.dark ? Colors.white : Colors.black,
        ),
      ),
      unselectedWidgetColor: Colors.black87,
      dividerColor: color,
      scaffoldBackgroundColor: color[50],
      iconTheme: const IconThemeData(color: Colors.black),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: const CircleBorder(),
        foregroundColor: _brightnessAccentColor == Brightness.dark
            ? Colors.white
            : Colors.black,
        backgroundColor: accentColor,
      ),
      errorColor: Colors.redAccent,
      canvasColor: color[50],
      primarySwatch: color,
      primaryColor: color,
      backgroundColor: color[100],
      highlightColor: color[200],
      selectedRowColor: color[200],
      cardColor: color[100],
      cardTheme: CardTheme(
        color: color.shade100,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        elevation: 8.0,
        surfaceTintColor: color.shade100,
      ),
      colorScheme: ColorScheme.light(
        background: Colors.white,
        error: Colors.redAccent,
        onBackground: Colors.black,
        onError: Colors.white,
        primary: color,
        onPrimary: Colors.white,
        onSecondary: _brightnessAccentTextTheme == Brightness.dark
            ? Colors.white70
            : Colors.black,
        secondary: accentColor.shade700,
        surface: Colors.white,
        onSurface: Colors.black,
        primaryContainer: color.shade700,
        secondaryContainer: accentColor.shade700,
        brightness: _brightnessColor,
        surfaceTint: color.shade100,
      ),
      textTheme: __darkAccentTextTheme,
      primaryTextTheme: _brightnessPrimaryColor == Brightness.dark
          ? __lightAccentTextTheme
          : __darkAccentTextTheme,
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accentColor,
        linearTrackColor: color.shade100,
        circularTrackColor: color.shade100,
      ),
      bottomAppBarTheme: BottomAppBarTheme(
          shape: CircularNotchedRectangle(),
          color: color,
          // color: Colors.transparent,
          elevation: 0.0),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        selectedItemColor: _brightnessAccentColor == Brightness.dark
            ? Colors.white
            : Colors.black,
        unselectedItemColor: _brightnessAccentColor == Brightness.dark
            ? color[100]!.withOpacity(0.75)
            : Colors.black38,
        showUnselectedLabels: true,
      ),
      dialogTheme: DialogTheme(
        titleTextStyle: __darkAccentTextTheme.headline6,
        contentTextStyle: __darkAccentTextTheme.subtitle1,
        backgroundColor: color[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: color[100],
        contentTextStyle: TextStyle(color: Colors.black),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: accentColor)),
        behavior: SnackBarBehavior.floating,
      ),
      splashColor: color.withOpacity(0.24),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
        mouseCursor: MaterialStateProperty.all<MouseCursor>(
            MaterialStateMouseCursor.clickable),
        //enableFeedback: false,
        shape:
            MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder()),
        side: MaterialStateProperty.all<BorderSide>(BorderSide(
          color: accentColor[700]!,
          width: 1,
        )),
        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        foregroundColor: MaterialStateProperty.all<Color?>(
            _brightnessAccentColor == Brightness.dark
                ? accentColor[700]
                : Colors.black),
      )),
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
        mouseCursor: MaterialStateProperty.all<MouseCursor>(
            MaterialStateMouseCursor.clickable),
        //enableFeedback: false,
        shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        foregroundColor: MaterialStateProperty.all<Color?>(
            _brightnessAccentColor == Brightness.dark
                ? accentColor[700]
                : Colors.black),
      )),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
              mouseCursor: MaterialStateProperty.all<MouseCursor>(
                  MaterialStateMouseCursor.clickable),
              //enableFeedback: false,
              shape: MaterialStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              elevation: MaterialStateProperty.resolveWith<double>((states) {
                if (states.contains(MaterialState.pressed)) return 0.0;
                return 8.0;
              }),
              backgroundColor: MaterialStateProperty.all<Color?>(color[100]),
              foregroundColor: MaterialStateProperty.all<Color?>(
                  __darkAccentTextTheme.headline1!.color),
              textStyle: MaterialStateProperty.all<TextStyle?>(
                  __darkAccentTextTheme.bodyText1),
              overlayColor: MaterialStateProperty.all<Color>(
                  _darkAccentColor.withOpacity(0.24)),
              visualDensity: VisualDensity(vertical: 2.5))),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ),
      chipTheme: ChipThemeData(
        checkmarkColor:
            _brightnessColor == Brightness.dark ? Colors.white : Colors.black,
        backgroundColor: Colors.black12,
        deleteIconColor: Colors.black87,
        disabledColor: Colors.black.withAlpha(0x0c),
        selectedColor: Colors.black26,
        secondarySelectedColor: color[100]!,
        labelPadding: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.all(4.0),
        labelStyle: __darkAccentTextTheme.bodyText2!,
        secondaryLabelStyle: __darkAccentTextTheme.bodyText2!.apply(
            color: _brightnessColor == Brightness.light ? null : color[500]),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        brightness: _brightnessColor,
      ),
      navigationRailTheme: NavigationRailThemeData(
        labelType: NavigationRailLabelType.selected,
        backgroundColor: color[50],
        elevation: 8.0,
        groupAlignment: 1.0,
        selectedIconTheme: IconThemeData(color: accentColor[700]),
        selectedLabelTextStyle: __lightAccentTextTheme.bodyText2!.apply(
            color: _brightnessAccentTextTheme == Brightness.dark
                ? accentColor[700]
                : Colors.black),
        unselectedIconTheme: const IconThemeData(color: Colors.black),
        unselectedLabelTextStyle: __darkAccentTextTheme.bodyText2,
      ),
      toggleableActiveColor: accentColor[700],
      indicatorColor: color[100],
      useMaterial3: true,
    );
  }

  set setDark(int? dark) {
    dark ??= 2;
    final Brightness _brightness =
        ThemeData.estimateBrightnessForColor(_darkAccentColor);
    final Color _accentColor =
        _brightness == Brightness.dark ? Colors.white : Colors.black;
    switch (dark) {
      case 0:
        _darkTheme = ThemeData(
          splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
          primaryColorLight: Colors.blueGrey[800],
          primaryColorDark: Colors.blueGrey[900],
          textSelectionTheme: TextSelectionThemeData(
            selectionHandleColor: _darkAccentColor,
            selectionColor: _darkAccentColor.withOpacity(0.5),
            cursorColor: Colors.white10,
          ),
          appBarTheme: AppBarTheme(
            elevation: 0.0,
            surfaceTintColor: Colors.blueGrey.shade900,
            backgroundColor: Colors.blueGrey.shade900,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarBrightness: Brightness.dark,
              statusBarIconBrightness: Brightness.light,
              systemNavigationBarIconBrightness: Brightness.dark,
              statusBarColor: Colors.blueGrey.shade900,
              systemNavigationBarColor: Colors.blueGrey.shade900,
            ),
            scrolledUnderElevation: 0.0,
            foregroundColor: Colors.blueGrey,
            titleTextStyle: __lightAccentTextTheme.headline6,
            toolbarTextStyle: __lightAccentTextTheme.bodyText2,
            iconTheme: const IconThemeData(color: Colors.white70),
          ),
          brightness: Brightness.dark,
          unselectedWidgetColor: Colors.white70,
          dividerColor: Colors.blueGrey[700],
          scaffoldBackgroundColor: Colors.blueGrey[900],
          primaryIconTheme: const IconThemeData(color: Colors.white70),
          iconTheme: const IconThemeData(color: Colors.white70),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            shape: const CircleBorder(),
            foregroundColor: _accentColor,
            backgroundColor: _darkAccentColor,
          ),
          errorColor: const Color.fromRGBO(207, 102, 121, 1),
          canvasColor: Colors.blueGrey[900],
          primarySwatch: Colors.blueGrey,
          primaryColor: Colors.blueGrey[900],
          backgroundColor: Colors.blueGrey[800],
          selectedRowColor: Colors.blueGrey[700],
          cardColor: Colors.blueGrey[800],
          cardTheme: CardTheme(
            surfaceTintColor: Colors.blueGrey.shade800,
            color: Colors.blueGrey[800],
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 8,
          ),
          colorScheme: ColorScheme.dark(
            background: Colors.blueGrey.shade800,
            error: const Color.fromRGBO(207, 102, 121, 1),
            onBackground: Colors.white,
            onError: Colors.white,
            primary: Colors.blueGrey,
            onPrimary: Colors.white,
            onSecondary:
                _brightness == Brightness.dark ? Colors.white70 : Colors.black,
            secondary: _darkAccentColor.shade100,
            surface: Colors.white,
            onSurface: Colors.black,
            primaryContainer: Colors.blueGrey.shade700,
            secondaryContainer: _darkAccentColor.shade700,
            brightness: Brightness.dark,
          ),
          textTheme: __lightAccentTextTheme,
          progressIndicatorTheme: ProgressIndicatorThemeData(
            color: Colors.blueGrey.shade700,
            linearTrackColor: Colors.blueGrey,
            circularTrackColor: Colors.blueGrey,
          ),
          primaryTextTheme: __lightAccentTextTheme,
          bottomAppBarTheme: BottomAppBarTheme(
            shape: CircularNotchedRectangle(),
            color: Colors.blueGrey[900],
            // color: Colors.transparent,
            elevation: 0.0,
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            selectedItemColor: _darkAccentColor,
            unselectedItemColor: Colors.blueGrey[700],
            showUnselectedLabels: true,
          ),
          dialogTheme: DialogTheme(
            titleTextStyle: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w600),
            backgroundColor: Colors.blueGrey[900],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: Colors.blueGrey[800],
            contentTextStyle: TextStyle(color: Colors.white70),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side:
                    BorderSide(color: const Color.fromRGBO(207, 102, 121, 1))),
            behavior: SnackBarBehavior.floating,
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
              style: ButtonStyle(
            mouseCursor: MaterialStateProperty.all<MouseCursor>(
                MaterialStateMouseCursor.clickable),
            //enableFeedback: false,
            shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder()),
            side: MaterialStateProperty.all<BorderSide>(BorderSide(
              color: _darkAccentColor,
              width: 1,
            )),
            backgroundColor:
                MaterialStateProperty.all<Color>(Colors.transparent),
            foregroundColor: MaterialStateProperty.all<Color>(_darkAccentColor),
          )),
          textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
            mouseCursor: MaterialStateProperty.all<MouseCursor>(
                MaterialStateMouseCursor.clickable),
            //enableFeedback: false,
            shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            backgroundColor:
                MaterialStateProperty.all<Color>(Colors.transparent),
            foregroundColor: MaterialStateProperty.all<Color>(_darkAccentColor),
            overlayColor: MaterialStateProperty.all<Color>(
                _darkAccentColor.withOpacity(0.24)),
          )),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              mouseCursor: MaterialStateProperty.all<MouseCursor>(
                  MaterialStateMouseCursor.clickable),
              //enableFeedback: false,
              shape: MaterialStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              elevation: MaterialStateProperty.resolveWith<double>((states) {
                if (states.contains(MaterialState.pressed)) return 0.0;
                return 8.0;
              }),
              backgroundColor:
                  MaterialStateProperty.all<Color?>(Colors.blueGrey[800]),
              foregroundColor: MaterialStateProperty.all<Color?>(
                  __lightAccentTextTheme.headline1!.color),
              textStyle: MaterialStateProperty.all<TextStyle?>(
                  __lightAccentTextTheme.bodyText1),
              overlayColor: MaterialStateProperty.all<Color>(
                  _darkAccentColor.withOpacity(0.24)),
              visualDensity: VisualDensity(vertical: 2.5),
            ),
          ),
          buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme.normal,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              layoutBehavior: ButtonBarLayoutBehavior.constrained,
              buttonColor: Colors.grey[900],
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              height: 48),
          bottomSheetTheme: BottomSheetThemeData(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
          ),
          chipTheme: ChipThemeData(
            checkmarkColor:
                _brightness == Brightness.dark ? Colors.white : Colors.black,
            backgroundColor: Colors.white12,
            deleteIconColor: Colors.white70,
            disabledColor: Colors.white.withAlpha(0x0C),
            selectedColor: Colors.white24,
            secondarySelectedColor: _darkAccentColor.withAlpha(0xFC),
            labelPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            padding: const EdgeInsets.all(4.0),
            labelStyle: __lightAccentTextTheme.bodyText2!,
            secondaryLabelStyle: _brightness == Brightness.dark
                ? __lightAccentTextTheme.bodyText2!
                : __darkAccentTextTheme.bodyText2!,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            brightness: _brightness,
          ),
          navigationRailTheme: NavigationRailThemeData(
              labelType: NavigationRailLabelType.selected,
              backgroundColor: Colors.blueGrey[800],
              elevation: 8.0,
              groupAlignment: 1.0,
              selectedIconTheme: IconThemeData(color: _darkAccentColor),
              selectedLabelTextStyle: __lightAccentTextTheme.bodyText2!
                  .apply(color: _darkAccentColor),
              unselectedIconTheme: const IconThemeData(color: Colors.white70),
              unselectedLabelTextStyle: __lightAccentTextTheme.bodyText2),
          toggleableActiveColor: _darkAccentColor,
          indicatorColor: Colors.blueGrey[700],
          useMaterial3: true,
        );
        break;
      case 1:
        _darkTheme = ThemeData(
          splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
          primaryColorLight: Colors.grey[850],
          primaryColorDark: Colors.grey[900],
          textSelectionTheme: TextSelectionThemeData(
            selectionHandleColor: _darkAccentColor,
            selectionColor: _darkAccentColor.withOpacity(0.5),
            cursorColor: Colors.white10,
          ),
          appBarTheme: AppBarTheme(
            elevation: 0.0,
            surfaceTintColor: Colors.grey.shade900,
            backgroundColor: Colors.grey.shade900,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarBrightness: Brightness.dark,
              statusBarIconBrightness: Brightness.light,
              systemNavigationBarIconBrightness: Brightness.dark,
              statusBarColor: Colors.grey.shade900,
              systemNavigationBarColor: Colors.grey.shade900,
            ),
            foregroundColor: Colors.blueGrey,
            titleTextStyle: __lightAccentTextTheme.headline6,
            toolbarTextStyle: __lightAccentTextTheme.bodyText2,
            iconTheme: const IconThemeData(color: Colors.white70),
          ),
          brightness: Brightness.dark,
          unselectedWidgetColor: Colors.white70,
          dividerColor: Colors.grey[800],
          scaffoldBackgroundColor: Colors.grey[900],
          primaryIconTheme: const IconThemeData(color: Colors.white70),
          iconTheme: const IconThemeData(color: Colors.white70),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            shape: const CircleBorder(),
            foregroundColor: _accentColor,
            backgroundColor: _darkAccentColor,
          ),
          errorColor: Color.fromRGBO(207, 102, 121, 1),
          canvasColor: Colors.grey[900],
          primarySwatch: Colors.grey,
          primaryColor: Colors.grey[900],
          backgroundColor: Colors.grey[850],
          selectedRowColor: Colors.grey[800],
          cardColor: Colors.grey[850],
          cardTheme: CardTheme(
            surfaceTintColor: Colors.grey[850],
            color: Colors.grey[850],
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 8,
          ),
          colorScheme: ColorScheme.dark(
            background: Colors.grey.shade800,
            error: const Color.fromRGBO(207, 102, 121, 1),
            onBackground: Colors.white,
            onError: Colors.white,
            primary: Colors.blueGrey,
            onPrimary: Colors.white,
            onSecondary:
                _brightness == Brightness.dark ? Colors.white70 : Colors.black,
            secondary: _darkAccentColor.shade100,
            surface: Colors.white,
            onSurface: Colors.black,
            primaryContainer: Colors.grey.shade700,
            secondaryContainer: _darkAccentColor.shade700,
            brightness: Brightness.dark,
          ),
          textTheme: __lightAccentTextTheme,
          primaryTextTheme: __lightAccentTextTheme,
          progressIndicatorTheme: ProgressIndicatorThemeData(
            color: Colors.grey.shade700,
            linearTrackColor: Colors.grey,
            circularTrackColor: Colors.grey,
          ),
          bottomAppBarTheme: BottomAppBarTheme(
              shape: CircularNotchedRectangle(),
              color: Colors.grey[900],
              //color: Colors.transparent,
              elevation: 0.0),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            selectedItemColor: _darkAccentColor,
            unselectedItemColor: Colors.grey[700],
            showUnselectedLabels: true,
          ),
          dialogTheme: DialogTheme(
            titleTextStyle: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w600),
            backgroundColor: Colors.grey[900],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: Colors.grey[800],
            contentTextStyle: TextStyle(color: Colors.white70),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side:
                    BorderSide(color: const Color.fromRGBO(207, 102, 121, 1))),
            behavior: SnackBarBehavior.floating,
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
              style: ButtonStyle(
            mouseCursor: MaterialStateProperty.all<MouseCursor>(
                MaterialStateMouseCursor.clickable),
            // enableFeedback: false,
            shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder()),
            side: MaterialStateProperty.all<BorderSide>(BorderSide(
              color: _darkAccentColor,
              width: 1,
            )),
            backgroundColor:
                MaterialStateProperty.all<Color>(Colors.transparent),
            foregroundColor: MaterialStateProperty.all<Color>(_darkAccentColor),
          )),
          textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
            mouseCursor: MaterialStateProperty.all<MouseCursor>(
                MaterialStateMouseCursor.clickable),
            //enableFeedback: false,
            shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            backgroundColor:
                MaterialStateProperty.all<Color>(Colors.transparent),
            foregroundColor: MaterialStateProperty.all<Color>(_darkAccentColor),
            overlayColor: MaterialStateProperty.all<Color>(
                _darkAccentColor.withOpacity(0.24)),
          )),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                  mouseCursor: MaterialStateProperty.all<MouseCursor>(
                      MaterialStateMouseCursor.clickable),
                  //enableFeedback: false,
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  elevation:
                      MaterialStateProperty.resolveWith<double>((states) {
                    if (states.contains(MaterialState.pressed)) return 0.0;
                    return 8.0;
                  }),
                  backgroundColor:
                      MaterialStateProperty.all<Color?>(Colors.grey[850]),
                  foregroundColor: MaterialStateProperty.all<Color?>(
                      __lightAccentTextTheme.headline1!.color),
                  textStyle: MaterialStateProperty.all<TextStyle?>(
                      __lightAccentTextTheme.bodyText1),
                  overlayColor: MaterialStateProperty.all<Color>(
                      _darkAccentColor.withOpacity(0.24)),
                  visualDensity: VisualDensity(vertical: 2.5))),
          buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme.normal,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              layoutBehavior: ButtonBarLayoutBehavior.constrained,
              buttonColor: Colors.grey[900],
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              height: 48),
          bottomSheetTheme: BottomSheetThemeData(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
          ),
          chipTheme: ChipThemeData(
              checkmarkColor:
                  _brightness == Brightness.dark ? Colors.white : Colors.black,
              backgroundColor: Colors.white12,
              deleteIconColor: Colors.white70,
              disabledColor: Colors.white.withAlpha(0x0C),
              selectedColor: Colors.white24,
              secondarySelectedColor: _darkAccentColor.withAlpha(0xFC),
              labelPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              padding: const EdgeInsets.all(4.0),
              labelStyle: __lightAccentTextTheme.bodyText2!,
              secondaryLabelStyle: _brightness == Brightness.dark
                  ? __lightAccentTextTheme.bodyText2!
                  : __darkAccentTextTheme.bodyText2!,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              brightness: _brightness),
          navigationRailTheme: NavigationRailThemeData(
              labelType: NavigationRailLabelType.selected,
              backgroundColor: Colors.grey[850],
              elevation: 8.0,
              groupAlignment: 1.0,
              selectedIconTheme: IconThemeData(color: _darkAccentColor),
              unselectedIconTheme: const IconThemeData(color: Colors.white70),
              selectedLabelTextStyle: __lightAccentTextTheme.bodyText2!
                  .apply(color: _darkAccentColor),
              unselectedLabelTextStyle: __lightAccentTextTheme.bodyText2),
          toggleableActiveColor: _darkAccentColor,
          indicatorColor: Colors.grey[700],
          useMaterial3: true,
        );
        break;
      case 2:
      default:
        _darkTheme = ThemeData(
          splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
          primaryColorLight: Colors.transparent,
          primaryColorDark: _darkAccentColor,
          textSelectionTheme: TextSelectionThemeData(
            selectionHandleColor: _darkAccentColor,
            selectionColor: _darkAccentColor.withOpacity(0.5),
            cursorColor: Colors.white10,
          ),
          appBarTheme: AppBarTheme(
            elevation: 0.0,
            surfaceTintColor: Colors.black,
            backgroundColor: Colors.black,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarBrightness: Brightness.dark,
              statusBarIconBrightness: Brightness.light,
              systemNavigationBarIconBrightness: Brightness.dark,
              statusBarColor: Colors.black,
              systemNavigationBarColor: Colors.black,
            ),
            foregroundColor: Colors.blueGrey,
            titleTextStyle: __lightAccentTextTheme.headline6,
            toolbarTextStyle: __lightAccentTextTheme.bodyText2,
            iconTheme: const IconThemeData(color: Colors.white70),
          ),
          brightness: Brightness.dark,
          unselectedWidgetColor: Colors.white70,
          dividerColor: Colors.grey[800],
          scaffoldBackgroundColor: Colors.black,
          primaryIconTheme: const IconThemeData(color: Colors.white70),
          iconTheme: const IconThemeData(color: Colors.white70),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            shape: const CircleBorder(),
            foregroundColor: _accentColor,
            backgroundColor: _darkAccentColor,
          ),
          errorColor: Color.fromRGBO(207, 102, 121, 1),
          canvasColor: Colors.black,
          primarySwatch: Colors.blueGrey,
          primaryColor: Colors.grey[900],
          backgroundColor: Colors.black,
          selectedRowColor: Colors.grey[900],
          cardColor: Colors.black,
          cardTheme: CardTheme(
            surfaceTintColor: Colors.black,
            color: Colors.transparent,
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[900]!, width: 2)),
            elevation: 0.0,
          ),
          colorScheme: ColorScheme.dark(
            primary: Colors.blueGrey,
            primaryContainer: Colors.blueGrey.shade700,
            onSecondary:
                _brightness == Brightness.dark ? Colors.white70 : Colors.black,
            secondary: _darkAccentColor.shade200,
            secondaryContainer: _darkAccentColor.shade700,
          ),
          textTheme: const TextTheme(
            headline6: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w400),
            subtitle2: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w400),
            bodyText2: TextStyle(color: Colors.white70),
            bodyText1: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w400),
            headline4: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w600),
            subtitle1: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w400),
          ),
          progressIndicatorTheme: ProgressIndicatorThemeData(
            color: _darkAccentColor,
            linearTrackColor: _darkAccentColor.shade100,
            circularTrackColor: _darkAccentColor.shade100,
          ),
          primaryTextTheme: __lightAccentTextTheme,
          bottomAppBarTheme: BottomAppBarTheme(
              shape: CircularNotchedRectangle(),
              color: Colors.black,
              // color: Colors.transparent,
              elevation: 0.0),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            selectedItemColor: _darkAccentColor,
            unselectedItemColor: Colors.white70,
            showUnselectedLabels: true,
          ),
          dialogTheme: DialogTheme(
            titleTextStyle: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w600),
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: _darkAccentColor)),
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: Colors.grey[900],
            contentTextStyle: TextStyle(color: Colors.white70),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: _darkAccentColor)),
            behavior: SnackBarBehavior.floating,
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
              style: ButtonStyle(
            mouseCursor: MaterialStateProperty.all<MouseCursor>(
                MaterialStateMouseCursor.clickable),
            enableFeedback: false,
            shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder()),
            side: MaterialStateProperty.all<BorderSide>(BorderSide(
              color: _darkAccentColor,
              width: 1,
            )),
            overlayColor: MaterialStateProperty.all<Color>(
                _darkAccentColor.withOpacity(0.5)),
            backgroundColor:
                MaterialStateProperty.all<Color>(Colors.transparent),
            foregroundColor: MaterialStateProperty.all<Color>(_darkAccentColor),
          )),
          textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
            mouseCursor: MaterialStateProperty.all<MouseCursor>(
                MaterialStateMouseCursor.clickable),
            //enableFeedback: false,
            shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            backgroundColor:
                MaterialStateProperty.all<Color>(Colors.transparent),
            foregroundColor: MaterialStateProperty.all<Color>(_darkAccentColor),
            overlayColor: MaterialStateProperty.all<Color>(
                _darkAccentColor.withOpacity(0.24)),
          )),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                  mouseCursor: MaterialStateProperty.all<MouseCursor>(
                      MaterialStateMouseCursor.clickable),
                  //enableFeedback: false,
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  // side: MaterialStateProperty.all<BorderSide>(BorderSide(color: Colors.grey[900], width: 2)),
                  side: MaterialStateProperty.resolveWith<BorderSide>((states) {
                    if (states.contains(MaterialState.pressed))
                      return BorderSide(color: _darkAccentColor, width: 2);
                    return BorderSide(color: Colors.grey[900]!, width: 2);
                  }),
                  elevation: MaterialStateProperty.all<double>(0.0),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.transparent),
                  foregroundColor: MaterialStateProperty.all<Color?>(
                      __lightAccentTextTheme.headline1!.color),
                  textStyle: MaterialStateProperty.all<TextStyle?>(
                      __lightAccentTextTheme.bodyText1),
                  overlayColor: MaterialStateProperty.all<Color>(
                      _darkAccentColor.withOpacity(0.24)),
                  visualDensity: VisualDensity(vertical: 2.5))),
          buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme.normal,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              layoutBehavior: ButtonBarLayoutBehavior.constrained,
              buttonColor: Colors.grey[900],
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              height: 48),
          bottomSheetTheme: BottomSheetThemeData(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
          ),
          chipTheme: ChipThemeData(
              checkmarkColor:
                  _brightness == Brightness.dark ? Colors.white : Colors.black,
              backgroundColor: Colors.white12,
              deleteIconColor: Colors.white70,
              disabledColor: Colors.white.withAlpha(0x0C),
              selectedColor: Colors.white24,
              secondarySelectedColor: _darkAccentColor.withAlpha(0xFC),
              labelPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              padding: const EdgeInsets.all(4.0),
              labelStyle: __lightAccentTextTheme.bodyText2!,
              secondaryLabelStyle: _brightness == Brightness.dark
                  ? __lightAccentTextTheme.bodyText2!
                  : __darkAccentTextTheme.bodyText2!,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              brightness: _brightness),
          navigationRailTheme: NavigationRailThemeData(
              labelType: NavigationRailLabelType.selected,
              backgroundColor: Colors.transparent,
              groupAlignment: 1.0,
              selectedIconTheme: IconThemeData(color: _darkAccentColor),
              selectedLabelTextStyle: __lightAccentTextTheme.bodyText2!
                  .apply(color: _darkAccentColor),
              unselectedIconTheme: const IconThemeData(color: Colors.white70),
              unselectedLabelTextStyle: __lightAccentTextTheme.bodyText2),
          toggleableActiveColor: _darkAccentColor,
          indicatorColor: _darkAccentColor.withOpacity(0.75),
          useMaterial3: true,
        );
        break;
    }
  }

  ThemeData? get light => _lightTheme;
  ThemeData? get dark => _darkTheme;
}
