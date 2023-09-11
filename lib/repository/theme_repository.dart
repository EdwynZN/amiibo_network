import 'package:amiibo_network/resources/theme_material3_schemes.dart';
import 'package:amiibo_network/utils/theme_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const iconOwned = Icons.bookmark_added_rounded;
const iconOwnedDark = Icons.bookmark_added_sharp;
const iconWished = Icons.favorite;

abstract class AmiiboTheme {
  factory AmiiboTheme({int? light, int? dark}) = _Theme;

  ThemeData? get light;
  set setLight(int light);

  ThemeData? get dark;
  set setDark(int dark);

  List<Color> get lightColors;
  List<Color> get darkColors;
}

class _Theme implements AmiiboTheme {
  ThemeData? _lightTheme;
  ThemeData? _darkTheme;
  late MaterialAccentColor _darkAccentColor;

  TextTheme __darkAccentTextTheme = const TextTheme(
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      color: Colors.black87,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.15,
      color: Colors.black87,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: Colors.black87,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.5,
      color: Colors.black87,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.25,
      color: Colors.black87,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.4,
      color: Colors.black87,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.25,
      color: Colors.black87,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.25,
      color: Colors.black87,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.normal,
      letterSpacing: 1.5,
      color: Colors.black87,
    ),
    displayLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w300,
      letterSpacing: -1.5,
      color: Colors.black87,
    ),
    displayMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w300,
      letterSpacing: -0.5,
      color: Colors.black87,
    ),
    displaySmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.0,
      color: Colors.black87,
    ),
    headlineLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.0,
      color: Colors.black87,
    ),
    headlineMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.25,
      color: Colors.black87,
    ),
    headlineSmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.0,
      color: Colors.black87,
    ),
  );
  TextTheme __lightAccentTextTheme = const TextTheme(
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      color: Colors.white70,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.15,
      color: Colors.white70,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: Colors.white70,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.5,
      color: Colors.white70,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.25,
      color: Colors.white70,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.4,
      color: Colors.white70,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.25,
      color: Colors.white70,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.25,
      color: Colors.white70,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.normal,
      letterSpacing: 1.5,
      color: Colors.white70,
    ),
    displayLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w300,
      letterSpacing: -1.5,
      color: Colors.white70,
    ),
    displayMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w300,
      letterSpacing: -0.5,
      color: Colors.white70,
    ),
    displaySmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.0,
      color: Colors.white70,
    ),
    headlineLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.0,
      color: Colors.white70,
    ),
    headlineMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.25,
      color: Colors.white70,
    ),
    headlineSmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.0,
      color: Colors.white70,
    ),
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
            ? __darkAccentTextTheme.titleLarge!
            : __lightAccentTextTheme.titleLarge!.apply(color: Colors.white),
        foregroundColor:
            _brightnessColor == Brightness.light ? Colors.black : Colors.white,
        toolbarTextStyle: _brightnessColor == Brightness.light
            ? __darkAccentTextTheme.bodyMedium
            : __lightAccentTextTheme.bodyMedium,
        iconTheme: IconThemeData(
          color: _brightnessColor == Brightness.light
              ? Colors.black
              : Colors.white,
        ),
      ),
      unselectedWidgetColor: Colors.black87,
      dividerColor: color,
      disabledColor: Colors.black26,
      scaffoldBackgroundColor: color[50],
      iconTheme: const IconThemeData(color: Colors.black),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: const CircleBorder(),
        foregroundColor: _brightnessAccentColor == Brightness.dark
            ? Colors.white
            : Colors.black,
        backgroundColor: accentColor,
      ),
      canvasColor: color[50],
      primarySwatch: color,
      primaryColor: color,
      highlightColor: color[200],
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
        titleTextStyle: __darkAccentTextTheme.titleLarge,
        contentTextStyle: __darkAccentTextTheme.titleMedium,
        backgroundColor: color[50],
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 4.0,
        ),
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
                  __darkAccentTextTheme.displayLarge!.color),
              textStyle: MaterialStateProperty.all<TextStyle?>(
                  __darkAccentTextTheme.bodyLarge),
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
        checkmarkColor: _brightnessPrimaryColor == Brightness.light
            ? Colors.white
            : Colors.black,
        backgroundColor: Colors.black12,
        deleteIconColor: Colors.black87,
        disabledColor: Colors.black.withAlpha(0x0c),
        selectedColor: color.shade100,
        secondarySelectedColor: color.shade100,
        labelPadding: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.all(4.0),
        labelStyle: __darkAccentTextTheme.bodyMedium!,
        secondaryLabelStyle: __darkAccentTextTheme.bodyMedium!.apply(
          color:
              _brightnessPrimaryColor == Brightness.light ? null : color[500],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
        brightness: _brightnessColor,
      ),
      navigationRailTheme: NavigationRailThemeData(
        labelType: NavigationRailLabelType.selected,
        backgroundColor: color[50],
        elevation: 8.0,
        groupAlignment: 1.0,
        selectedIconTheme: IconThemeData(color: accentColor[700]),
        selectedLabelTextStyle: __lightAccentTextTheme.bodyMedium!.apply(
            color: _brightnessAccentTextTheme == Brightness.dark
                ? accentColor[700]
                : Colors.black),
        unselectedIconTheme: const IconThemeData(color: Colors.black),
        unselectedLabelTextStyle: __darkAccentTextTheme.bodyMedium,
      ),
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
            titleTextStyle: __lightAccentTextTheme.titleLarge,
            toolbarTextStyle: __lightAccentTextTheme.bodyMedium,
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
          canvasColor: Colors.blueGrey[900],
          primarySwatch: Colors.blueGrey,
          primaryColor: Colors.blueGrey[900],
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
            titleTextStyle: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
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
                  __lightAccentTextTheme.displayLarge!.color),
              textStyle: MaterialStateProperty.all<TextStyle?>(
                  __lightAccentTextTheme.bodyLarge),
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
            labelStyle: __lightAccentTextTheme.bodyMedium!,
            secondaryLabelStyle: _brightness == Brightness.dark
                ? __lightAccentTextTheme.bodyMedium!
                : __darkAccentTextTheme.bodyMedium!,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            side: _SelectedBorder(_darkAccentColor.withOpacity(0.54)),
            brightness: _brightness,
          ),
          navigationRailTheme: NavigationRailThemeData(
            labelType: NavigationRailLabelType.selected,
            backgroundColor: Colors.blueGrey[800],
            elevation: 8.0,
            groupAlignment: 1.0,
            selectedIconTheme: IconThemeData(color: _darkAccentColor),
            selectedLabelTextStyle: __lightAccentTextTheme.bodyMedium!
                .apply(color: _darkAccentColor),
            unselectedIconTheme: const IconThemeData(color: Colors.white70),
            unselectedLabelTextStyle: __lightAccentTextTheme.bodyMedium,
          ),
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
            titleTextStyle: __lightAccentTextTheme.titleLarge,
            toolbarTextStyle: __lightAccentTextTheme.bodyMedium,
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
          canvasColor: Colors.grey[900],
          primarySwatch: Colors.grey,
          primaryColor: Colors.grey[900],
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
            titleTextStyle: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
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
                      __lightAccentTextTheme.displayLarge!.color),
                  textStyle: MaterialStateProperty.all<TextStyle?>(
                      __lightAccentTextTheme.bodyLarge),
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
            labelStyle: __lightAccentTextTheme.bodyMedium!,
            secondaryLabelStyle: _brightness == Brightness.dark
                ? __lightAccentTextTheme.bodyMedium!
                : __darkAccentTextTheme.bodyMedium!,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            side: _SelectedBorder(_darkAccentColor.withOpacity(0.54)),
            brightness: _brightness,
          ),
          navigationRailTheme: NavigationRailThemeData(
            labelType: NavigationRailLabelType.selected,
            backgroundColor: Colors.grey[850],
            elevation: 8.0,
            groupAlignment: 1.0,
            selectedIconTheme: IconThemeData(color: _darkAccentColor),
            unselectedIconTheme: const IconThemeData(color: Colors.white70),
            selectedLabelTextStyle: __lightAccentTextTheme.bodyMedium!
                .apply(color: _darkAccentColor),
            unselectedLabelTextStyle: __lightAccentTextTheme.bodyMedium,
          ),
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
            titleTextStyle: __lightAccentTextTheme.titleLarge,
            toolbarTextStyle: __lightAccentTextTheme.bodyMedium,
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
          canvasColor: Colors.black,
          primarySwatch: Colors.blueGrey,
          primaryColor: Colors.grey[900],
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
            titleLarge: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w400),
            titleSmall: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w400),
            bodyMedium: TextStyle(color: Colors.white70),
            bodySmall: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w400),
            headlineMedium: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w600),
            titleMedium: TextStyle(
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
              fontWeight: FontWeight.w600,
            ),
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
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
                      __lightAccentTextTheme.displayLarge!.color),
                  textStyle: MaterialStateProperty.all<TextStyle?>(
                      __lightAccentTextTheme.bodyLarge),
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
            labelStyle: __lightAccentTextTheme.bodyMedium!,
            secondaryLabelStyle: _brightness == Brightness.dark
                ? __lightAccentTextTheme.bodyMedium!
                : __darkAccentTextTheme.bodyMedium!,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            side: _SelectedBorder(_darkAccentColor.withOpacity(0.54)),
            brightness: _brightness,
          ),
          navigationRailTheme: NavigationRailThemeData(
            labelType: NavigationRailLabelType.selected,
            backgroundColor: Colors.transparent,
            groupAlignment: 1.0,
            selectedIconTheme: IconThemeData(color: _darkAccentColor),
            selectedLabelTextStyle: __lightAccentTextTheme.bodyMedium!
                .apply(color: _darkAccentColor),
            unselectedIconTheme: const IconThemeData(color: Colors.white70),
            unselectedLabelTextStyle: __lightAccentTextTheme.bodyMedium,
          ),
          indicatorColor: _darkAccentColor.withOpacity(0.75),
          useMaterial3: true,
        );
        break;
    }
  }

  ThemeData? get light => _lightTheme;
  ThemeData? get dark => _darkTheme;

  final List<Color> lightColors = Colors.primaries;
  final List<Color> darkColors = const [
    Colors.blueGrey,
    Colors.grey,
    Colors.black,
  ];
}

class AmiiboTheme3 implements AmiiboTheme {
  ThemeData? _lightTheme;
  ThemeData? _darkTheme;
  late Material3Schemes _materialScheme;
  ColorScheme get _darkScheme => _materialScheme.dark;
  final _greyScheme = const ColorScheme(
    background: Color(0xFF212121),
    error: Color(0xFFCF6679),
    onError: Color(0xFF690005),
    onBackground: Color(0xFFE1E2E4),
    brightness: Brightness.dark,
    primary: Color(0xFF424242),
    onPrimary: Colors.white,
    surface: const Color(0xFF191C1E),
    onSurface: const Color(0xFFE1E2E4),
    primaryContainer: Color(0xFF757575),
    secondary: Color(0xFFC0B4B4),
    onSecondary: Color(0xFF1F333C),
    secondaryContainer: Color(0x2B45443B),
    onSecondaryContainer: Color(0xFFE7F0F5),
  );
  static const TextTheme _textTheme = TextTheme(
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.25,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.4,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.25,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.25,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.normal,
      letterSpacing: 1.5,
    ),
    displayLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w300,
      letterSpacing: -1.5,
    ),
    displayMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w300,
      letterSpacing: -0.5,
    ),
    displaySmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.0,
    ),
    headlineLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.0,
    ),
    headlineMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.25,
    ),
    headlineSmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.0,
    ),
  );

  TextTheme __darkAccentTextTheme = const TextTheme(
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      color: Colors.black87,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.15,
      color: Colors.black87,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: Colors.black87,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.5,
      color: Colors.black87,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.25,
      color: Colors.black87,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.4,
      color: Colors.black87,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.25,
      color: Colors.black87,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.25,
      color: Colors.black87,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.normal,
      letterSpacing: 1.5,
      color: Colors.black87,
    ),
    displayLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w300,
      letterSpacing: -1.5,
      color: Colors.black87,
    ),
    displayMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w300,
      letterSpacing: -0.5,
      color: Colors.black87,
    ),
    displaySmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.0,
      color: Colors.black87,
    ),
    headlineLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.0,
      color: Colors.black87,
    ),
    headlineMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.25,
      color: Colors.black87,
    ),
    headlineSmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.0,
      color: Colors.black87,
    ),
  );
  TextTheme __lightAccentTextTheme = const TextTheme(
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      color: Colors.white70,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.15,
      color: Colors.white70,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: Colors.white70,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.5,
      color: Colors.white70,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.25,
      color: Colors.white70,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.4,
      color: Colors.white70,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.25,
      color: Colors.white70,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.25,
      color: Colors.white70,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.normal,
      letterSpacing: 1.5,
      color: Colors.white70,
    ),
    displayLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w300,
      letterSpacing: -1.5,
      color: Colors.white70,
    ),
    displayMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w300,
      letterSpacing: -0.5,
      color: Colors.white70,
    ),
    displaySmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.0,
      color: Colors.white70,
    ),
    headlineLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.0,
      color: Colors.white70,
    ),
    headlineMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.25,
      color: Colors.white70,
    ),
    headlineSmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.0,
      color: Colors.white70,
    ),
  );

  AmiiboTheme3({int? light, int? dark}) {
    setLight = light ?? 0;
    setDark = dark ?? 0;
  }

  ThemeData _themeFromScheme(ColorScheme scheme) {
    final overlay = scheme.primary.withOpacity(0.24);
    final inverseBrightness = scheme.brightness == Brightness.light
        ? Brightness.dark
        : Brightness.light;
    return ThemeData(
      // GENERAL CONFIGURATION
      applyElevationOverlayColor: true,
      cupertinoOverrideTheme: const NoDefaultCupertinoThemeData(),
      extensions: [
        PreferencesExtension.brigthness(scheme.brightness),
      ],
      inputDecorationTheme: const InputDecorationTheme(),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      pageTransitionsTheme: const PageTransitionsTheme(),
      platform: null,
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: MaterialStatePropertyAll(scheme.secondary),
      ),
      splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
      useMaterial3: true,
      visualDensity: const VisualDensity(),
      // COLOR CONFIGURATION
      appBarTheme: AppBarTheme(
        elevation: 2.0,
        shadowColor: scheme.shadow,
        surfaceTintColor: scheme.surfaceTint,
        scrolledUnderElevation: 8.0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: inverseBrightness,
          statusBarIconBrightness: inverseBrightness,
          systemNavigationBarIconBrightness: inverseBrightness,
          systemNavigationBarColor: scheme.surface,
          systemStatusBarContrastEnforced: false,
          statusBarColor: Colors.transparent,
        ),
        backgroundColor: scheme.background,
        titleTextStyle:
            _textTheme.titleMedium?.copyWith(color: scheme.onBackground),
        toolbarTextStyle:
            _textTheme.bodyMedium?.copyWith(color: scheme.onBackground),
        foregroundColor: scheme.onBackground,
        iconTheme: IconThemeData(color: scheme.onBackground),
      ),
      badgeTheme: const BadgeThemeData(),
      bannerTheme: MaterialBannerThemeData(
        backgroundColor: scheme.tertiary,
        contentTextStyle: _textTheme.titleMedium,
        elevation: 4.0,
      ),
      bottomAppBarTheme: BottomAppBarTheme(
        color: scheme.surface,
        elevation: 0.0,
        height: kBottomNavigationBarHeight,
        padding: EdgeInsets.zero,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        constraints: const BoxConstraints(maxWidth: 400.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
        modalBackgroundColor: Colors.transparent,
        modalElevation: 0.0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.secondaryContainer,
        elevation: 8.0,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: const IconThemeData(),
        selectedItemColor: scheme.onSecondaryContainer,
        selectedLabelStyle: _textTheme.titleSmall!.copyWith(
          color: scheme.onSecondaryContainer,
        ),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        unselectedIconTheme: const IconThemeData(),
        unselectedItemColor: scheme.outline,
        unselectedLabelStyle: _textTheme.titleSmall,
        landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
      ),

      /// Deprecated in the future
      brightness: scheme.brightness,
      buttonBarTheme: const ButtonBarThemeData(),
      buttonTheme: ButtonThemeData(
        // Deprecated: Used in old RaisedButton/FlatButton
        textTheme: ButtonTextTheme.normal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        layoutBehavior: ButtonBarLayoutBehavior.constrained,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        height: 48,
      ),
      canvasColor: scheme.secondaryContainer,
      cardColor: scheme.secondaryContainer,
      cardTheme: CardTheme(
        color: scheme.secondaryContainer,
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        elevation: 4.0,
        shadowColor: scheme.surface.withOpacity(0.12),
        surfaceTintColor: scheme.surfaceTint,
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: MaterialStateProperty.resolveWith<Color?>((states) {
          if (states.contains(MaterialState.disabled)) return null;
          return scheme.onPrimary;
        }),
        fillColor: MaterialStateProperty.resolveWith<Color?>((states) {
          if (states.contains(MaterialState.disabled)) return null;
          if (states.contains(MaterialState.focused) ||
              states.contains(MaterialState.pressed)) return scheme.secondary;
          return scheme.tertiaryContainer;
        }),
      ),
      chipTheme: ChipThemeData(
        surfaceTintColor: scheme.surfaceTint,
        elevation: 4.0,
        pressElevation: 6.0,
        checkmarkColor: scheme.onPrimary,
        backgroundColor: scheme.background,
        deleteIconColor: scheme.tertiary,
        disabledColor: Colors.white.withAlpha(0x0C),
        selectedColor: scheme.primaryContainer,
        secondarySelectedColor: scheme.secondaryContainer,
        labelPadding: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.all(4.0),
        shadowColor: Colors.black12,
        selectedShadowColor: Colors.black38,
        labelStyle: _textTheme.bodySmall!.copyWith(color: scheme.onBackground),
        secondaryLabelStyle:
            _textTheme.bodySmall!.copyWith(color: scheme.onBackground),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: _SelectedBorder(scheme.primary, scheme.primary),
        brightness: scheme.brightness,
      ),
      colorScheme: scheme,
      dataTableTheme: const DataTableThemeData(),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: MaterialStatePropertyAll(_darkScheme.background),
        ),
      ),

      /// Deprecated in the future
      dialogBackgroundColor: scheme.surface,
      dialogTheme: DialogTheme(
        elevation: 2.0,
        titleTextStyle:
            _textTheme.titleLarge!.copyWith(color: scheme.onSurface),
        contentTextStyle:
            _textTheme.titleMedium!.copyWith(color: scheme.onSurface),
        backgroundColor: scheme.surface,
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 4.0,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      disabledColor: Colors.grey, // Defaults grey
      dividerColor: scheme.outline,
      dividerTheme: DividerThemeData(
        color: scheme.outline,
        space: 16.0,
        thickness: 0.75,
      ),
      drawerTheme: DrawerThemeData(
        elevation: 4.0,
        shadowColor: scheme.shadow,
        backgroundColor: scheme.background,
        shape: const RoundedRectangleBorder(),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          mouseCursor: MaterialStateProperty.all<MouseCursor>(
              MaterialStateMouseCursor.clickable),
          //enableFeedback: false,
          surfaceTintColor: MaterialStateProperty.all(scheme.surfaceTint),
          shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          elevation: MaterialStateProperty.resolveWith<double>((states) {
            if (states.contains(MaterialState.pressed)) return 0.0;
            return 4.0;
          }),
          backgroundColor:
              MaterialStateProperty.all<Color?>(scheme.secondaryContainer),
          foregroundColor: MaterialStateProperty.all<Color?>(
            scheme.onSecondaryContainer,
          ),
          textStyle: MaterialStateProperty.all<TextStyle?>(
            _textTheme.bodyLarge,
          ),
          overlayColor: MaterialStateProperty.all<Color>(overlay),
          visualDensity: const VisualDensity(vertical: 2.5),
        ),
      ),

      expansionTileTheme: ExpansionTileThemeData(
        collapsedBackgroundColor: Colors.transparent,
        backgroundColor: scheme.background,
      ),
      filledButtonTheme: const FilledButtonThemeData(),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: const CircleBorder(),
        foregroundColor: scheme.onTertiaryContainer,
        backgroundColor: scheme.tertiaryContainer,
      ),
      focusColor: scheme.inversePrimary,
      fontFamily: null,
      highlightColor: scheme.primaryContainer.withOpacity(0.38),
      hintColor: Colors.black38,
      hoverColor: scheme.primaryContainer,
      iconTheme: IconThemeData(color: scheme.onBackground),

      /// Deprecated in the future
      indicatorColor: scheme.primaryContainer,
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onBackground,
        selectedTileColor: scheme.secondaryContainer,
        selectedColor: scheme.onSecondaryContainer,
      ),
      menuBarTheme: const MenuBarThemeData(),
      menuButtonTheme: const MenuButtonThemeData(),
      menuTheme: const MenuThemeData(),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.background,
        iconTheme: MaterialStateProperty.all(
            IconThemeData(color: scheme.onBackground)),
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: MaterialStateProperty.all(_textTheme.labelLarge),
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        elevation: 4.0,
        shadowColor: scheme.shadow,
        backgroundColor: scheme.background,
      ),
      navigationRailTheme: NavigationRailThemeData(
        labelType: NavigationRailLabelType.selected,
        backgroundColor: scheme.primaryContainer,
        elevation: 8.0,
        groupAlignment: 1.0,
        selectedIconTheme: IconThemeData(color: scheme.tertiary),
        selectedLabelTextStyle: __lightAccentTextTheme.bodyMedium!.apply(
          color: scheme.onTertiary,
        ),
        unselectedIconTheme: const IconThemeData(color: Colors.black),
        unselectedLabelTextStyle: __darkAccentTextTheme.bodyMedium,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          mouseCursor: MaterialStateProperty.all<MouseCursor>(
            MaterialStateMouseCursor.clickable,
          ),
          //enableFeedback: false,
          shape: MaterialStateProperty.all<OutlinedBorder>(
            const RoundedRectangleBorder(),
          ),
          side: MaterialStateProperty.all<BorderSide>(BorderSide(
            color: scheme.primary,
            width: 1,
          )),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
          foregroundColor: MaterialStateProperty.all<Color?>(scheme.primary),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        textStyle: _textTheme.bodyLarge,
        color: scheme.primaryContainer,
        elevation: 8.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
          side: BorderSide(color: scheme.secondaryContainer),
        ),
      ),
      primaryColor: scheme.primary,
      primaryColorDark: scheme.secondary,
      primaryColorLight: scheme.primaryContainer,
      primaryIconTheme: IconThemeData(color: scheme.primary),
      primaryTextTheme: _textTheme.apply(
        bodyColor: scheme.onPrimary,
        displayColor: scheme.onPrimary,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        circularTrackColor: scheme.primaryContainer,
        linearTrackColor: scheme.primaryContainer,
        color: scheme.primary,
        refreshBackgroundColor: scheme.background,
        linearMinHeight: 4.0,
      ),

      radioTheme: const RadioThemeData(),
      scaffoldBackgroundColor: scheme.background,
      secondaryHeaderColor: scheme.secondaryContainer,
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
            if (states.contains(MaterialState.disabled))
              return null;
            else if (states.contains(MaterialState.selected))
              return scheme.primary;
            else if (states.contains(MaterialState.focused) ||
                states.contains(MaterialState.pressed))
              return scheme.primaryContainer;
            return scheme.background;
          }),
          iconSize: MaterialStatePropertyAll(16.0),
          iconColor: MaterialStateProperty.resolveWith<Color?>((states) {
            if (states.contains(MaterialState.disabled))
              return null;
            else if (states.contains(MaterialState.selected))
              return scheme.onPrimary;
            else if (states.contains(MaterialState.focused) ||
                states.contains(MaterialState.pressed))
              return scheme.onPrimaryContainer;
            return scheme.onBackground;
          }),
          textStyle: MaterialStatePropertyAll(_textTheme.labelLarge),
          foregroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
            if (states.contains(MaterialState.disabled))
              return null;
            else if (states.contains(MaterialState.selected))
              return scheme.onPrimary;
            else if (states.contains(MaterialState.focused) ||
                states.contains(MaterialState.pressed))
              return scheme.onPrimaryContainer;
            return scheme.onBackground;
          }),
          elevation: MaterialStatePropertyAll(0.0),
          side: MaterialStatePropertyAll(
              BorderSide(color: scheme.primaryContainer)),
        ),
      ),
      shadowColor: scheme.shadow, //Default color
      sliderTheme: const SliderThemeData(),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.tertiaryContainer,
        contentTextStyle: TextStyle(color: scheme.onTertiaryContainer),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: scheme.tertiary,
          ),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      splashColor: scheme.tertiaryContainer.withOpacity(0.24),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color?>((states) {
          if (states.contains(MaterialState.disabled)) return null;
          if (states.contains(MaterialState.focused) ||
              states.contains(MaterialState.pressed))
            return scheme.primaryContainer;
          return scheme.primary;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color?>((states) {
          if (states.contains(MaterialState.disabled)) return null;
          if (states.contains(MaterialState.focused) ||
              states.contains(MaterialState.pressed)) return scheme.primary;
          return scheme.primaryContainer;
        }),
      ),
      tabBarTheme: const TabBarTheme(),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          mouseCursor: MaterialStateProperty.all<MouseCursor>(
              MaterialStateMouseCursor.clickable),
          //enableFeedback: false,
          shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
          foregroundColor:
              MaterialStateProperty.all<Color>(scheme.onBackground),
          overlayColor: MaterialStateProperty.all<Color>(overlay),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        selectionHandleColor: scheme.secondary,
        selectionColor: scheme.secondaryContainer,
        cursorColor: scheme.onSecondaryContainer,
      ),
      textTheme: _textTheme,
      timePickerTheme: const TimePickerThemeData(),
      toggleButtonsTheme: const ToggleButtonsThemeData(),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.tertiaryContainer,
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        textStyle: _textTheme.bodySmall,
      ),
      typography: Typography.material2021(),
      unselectedWidgetColor: scheme.onBackground,
    );
  }

  set setLight(int light) {
    final length = lightColors.length;
    light = light.clamp(0, length - 1);
    _materialScheme = ThemeSchemes.styles[light];
    ColorScheme lightScheme = _materialScheme.light;
    _lightTheme = _themeFromScheme(lightScheme);
  }

  set setDark(int? dark) {
    switch (dark) {
      case 0:
        final darkBlueGrey = ThemeSchemes.blueGrey.dark;
        final theme = blendScheme(darkBlueGrey, _darkScheme);
        _darkTheme = _themeFromScheme(theme);
        Colors.grey;
        break;
      case 1:
        final theme = blendScheme(_greyScheme, _darkScheme);
        _darkTheme = _themeFromScheme(theme);
        break;
      case 2:
        final scheme = blendScheme(_greyScheme, _darkScheme, 0.15);
        final theme = _themeFromScheme(scheme);
        final shape = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: _darkScheme.primary),
        );
        _darkTheme = theme.copyWith(
          primaryColorLight: Colors.transparent,
          primaryColorDark: _darkScheme.primary,
          appBarTheme: theme.appBarTheme.copyWith(
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
            iconTheme: const IconThemeData(color: Colors.white70),
          ),
          scaffoldBackgroundColor: Colors.black,
          colorScheme: theme.colorScheme.copyWith(background: Colors.black),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            shape: const CircleBorder(),
            foregroundColor: _darkScheme.onPrimaryContainer,
            backgroundColor: _darkScheme.primaryContainer,
          ),
          bottomSheetTheme: BottomSheetThemeData(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            modalBackgroundColor: Colors.transparent,
            constraints: const BoxConstraints(maxWidth: 400.0),
            shape: shape,
            surfaceTintColor: _darkScheme.background,
          ),
          canvasColor: Colors.black,
          cardColor: Colors.black,
          cardTheme: CardTheme(
            surfaceTintColor: _darkScheme.primaryContainer,
            color: Colors.black,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: _darkScheme.secondaryContainer,
                width: 1.0,
              ),
            ),
            elevation: 0.0,
          ),
          dialogTheme: theme.dialogTheme.copyWith(
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            shape: shape,
            surfaceTintColor: _darkScheme.surfaceTint,
            backgroundColor: Colors.black,
            elevation: 2.0,
          ),
          drawerTheme: DrawerThemeData(
            elevation: 3.0,
            shadowColor: _darkScheme.shadow,
            surfaceTintColor: _darkScheme.surfaceTint,
            backgroundColor: Colors.black,
            shape: const RoundedRectangleBorder(),
          ),
          listTileTheme: ListTileThemeData(
            iconColor: _darkScheme.onBackground,
            selectedTileColor: _darkScheme.secondaryContainer,
            selectedColor: _darkScheme.onSecondaryContainer,
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: const Color(0xFF212121),
            contentTextStyle: const TextStyle(color: Colors.white70),
            shape: shape,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 3:
      default:
        _darkTheme = _themeFromScheme(_darkScheme);
        break;
    }
  }

  ThemeData? get light => _lightTheme;
  ThemeData? get dark => _darkTheme;

  final List<Color> lightColors =
      ThemeSchemes.styles.map((e) => e.light.primaryContainer).toList();

  List<Color> get darkColors => [
        Colors.blueGrey,
        Colors.grey,
        Colors.black,
        _darkScheme.primary,
      ];
}

class _SelectedBorder extends BorderSide implements MaterialStateBorderSide {
  final Color? selectedColor;
  final Color regularColor;

  const _SelectedBorder(
    this.selectedColor, [
    Color? regularColor,
  ]) : regularColor = regularColor ?? Colors.white54;

  @override
  BorderSide? resolve(Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) {
      return const BorderSide(color: Colors.white12);
    }
    if (selectedColor != null && states.contains(MaterialState.selected)) {
      return BorderSide(color: selectedColor!);
    }
    return BorderSide(color: regularColor);
  }
}
