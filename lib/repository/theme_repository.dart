import 'package:amiibo_network/resources/theme_material3_schemes.dart';
import 'package:flutter/cupertino.dart';
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
  static const TextTheme _textTheme = TextTheme(
    titleLarge: TextStyle(
      color: Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
    ),
    titleMedium: TextStyle(
      color: Colors.black,
      fontSize: 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    bodyLarge: TextStyle(
      color: Colors.black,
      fontSize: 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.5,
    ),
    bodyMedium: TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.25,
    ),
    bodySmall: TextStyle(
      color: Colors.black,
      fontSize: 12,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.4,
    ),
    labelLarge: TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.25,
    ),
    labelMedium: TextStyle(
      color: Colors.black,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.25,
    ),
    labelSmall: TextStyle(
      color: Colors.black,
      fontSize: 10,
      fontWeight: FontWeight.normal,
      letterSpacing: 1.5,
    ),
    displayLarge: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.w300,
      letterSpacing: -1.5,
    ),
    displayMedium: TextStyle(
      color: Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.w300,
      letterSpacing: -0.5,
    ),
    displaySmall: TextStyle(
      color: Colors.black,
      fontSize: 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.0,
    ),
    headlineLarge: TextStyle(
      color: Colors.black,
      fontSize: 15,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.0,
    ),
    headlineMedium: TextStyle(
      color: Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.25,
    ),
    headlineSmall: TextStyle(
      color: Colors.black,
      fontSize: 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.0,
    ),
  );

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

  ThemeData _themeFromScheme(ColorScheme scheme) {
    final overlay = scheme.primary.withOpacity(0.24);
    final inverseBrightness = scheme.brightness == Brightness.light
        ? Brightness.dark
        : Brightness.light;
    return ThemeData(
      // GENERAL CONFIGURATION
      applyElevationOverlayColor: true,
      cupertinoOverrideTheme: const NoDefaultCupertinoThemeData(),
      extensions: const [],
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
        surfaceTintColor: scheme.surfaceTint,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: scheme.brightness,
          statusBarIconBrightness: inverseBrightness,
          systemNavigationBarIconBrightness: inverseBrightness,
          systemNavigationBarColor: scheme.secondaryContainer,
          statusBarColor: scheme.secondaryContainer,
        ),
        backgroundColor: scheme.background,
        titleTextStyle: _textTheme.titleMedium,
        foregroundColor: scheme.secondary,
        toolbarTextStyle: _textTheme.bodyMedium,
        iconTheme: IconThemeData(color: scheme.onBackground),
      ),
      backgroundColor: scheme.background,
      bannerTheme: MaterialBannerThemeData(
        backgroundColor: scheme.tertiary,
        contentTextStyle: _textTheme.titleMedium,
        elevation: 4.0,
      ),

      /// Deprecated in the future
      bottomAppBarColor: scheme.secondaryContainer,
      bottomAppBarTheme: BottomAppBarTheme(
        color: scheme.secondaryContainer,
        elevation: 0.0,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 0.0,
        backgroundColor: scheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
        modalBackgroundColor: scheme.primaryContainer,
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
          return scheme.primary;
        }),
      ),
      chipTheme: ChipThemeData(
        surfaceTintColor: scheme.surfaceTint,
        elevation: 0.0,
        pressElevation: 4.0,
        checkmarkColor: scheme.onPrimary,
        backgroundColor: scheme.background,
        deleteIconColor: scheme.tertiary,
        disabledColor: Colors.white.withAlpha(0x0C),
        selectedColor: scheme.primaryContainer,
        secondarySelectedColor: scheme.secondaryContainer,
        labelPadding: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.all(4.0),
        shadowColor: Colors.black12,
        selectedShadowColor: Colors.black12,
        labelStyle: _textTheme.bodySmall!.copyWith(color: scheme.onBackground),
        secondaryLabelStyle:
            _textTheme.bodySmall!.copyWith(color: scheme.onBackground),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: _SelectedBorder(scheme.primaryContainer),
        brightness: scheme.brightness,
      ),
      colorScheme: scheme,
      dataTableTheme: const DataTableThemeData(),

      /// Deprecated in the future
      dialogBackgroundColor: scheme.secondaryContainer,
      dialogTheme: DialogTheme(
        titleTextStyle: _textTheme.titleLarge,
        contentTextStyle: _textTheme.titleMedium,
        backgroundColor: scheme.secondaryContainer,
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
        space: 8.0,
        thickness: 1.0,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: scheme.surface,
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
            return 8.0;
          }),
          backgroundColor:
              MaterialStateProperty.all<Color?>(scheme.primaryContainer),
          foregroundColor: MaterialStateProperty.all<Color?>(
            scheme.onPrimaryContainer,
          ),
          textStyle: MaterialStateProperty.all<TextStyle?>(
            _textTheme.bodyText1,
          ),
          overlayColor: MaterialStateProperty.all<Color>(overlay),
          visualDensity: const VisualDensity(vertical: 2.5),
        ),
      ),

      /// Deprecated in the future
      errorColor: scheme.error,
      expansionTileTheme: ExpansionTileThemeData(
        collapsedBackgroundColor: Colors.transparent,
        backgroundColor: scheme.background,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: const CircleBorder(),
        foregroundColor: scheme.onSecondaryContainer,
        backgroundColor: scheme.secondaryContainer,
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
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.background,
        iconTheme: MaterialStateProperty.all(
            IconThemeData(color: scheme.onBackground)),
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: MaterialStateProperty.all(_textTheme.labelLarge),
      ),
      navigationRailTheme: NavigationRailThemeData(
        labelType: NavigationRailLabelType.selected,
        backgroundColor: scheme.primaryContainer,
        elevation: 8.0,
        groupAlignment: 1.0,
        selectedIconTheme: IconThemeData(color: scheme.tertiary),
        selectedLabelTextStyle: __lightAccentTextTheme.bodyText2!.apply(
          color: scheme.onTertiary,
        ),
        unselectedIconTheme: const IconThemeData(color: Colors.black),
        unselectedLabelTextStyle: __darkAccentTextTheme.bodyText2,
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
        textStyle: _textTheme.bodyText1,
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
        bodyColor: scheme.primary,
        displayColor: scheme.primary,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        refreshBackgroundColor: scheme.background,
        linearMinHeight: 4.0,
      ),

      radioTheme: const RadioThemeData(),
      scaffoldBackgroundColor: scheme.background,
      secondaryHeaderColor: scheme.secondaryContainer,

      /// Deprecated in the future
      selectedRowColor: scheme.primary.withOpacity(0.24),
      shadowColor: null, //Default color
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
      splashColor: scheme.primaryContainer.withOpacity(0.24),
      switchTheme: const SwitchThemeData(),
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
      toggleableActiveColor: scheme.secondaryContainer,
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.tertiaryContainer,
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        textStyle: _textTheme.caption,
      ),
      typography: Typography.material2021(),
      unselectedWidgetColor: scheme.onBackground,
    );
  }

  set setLight(int? light) {
    light ??= 0;
    Material3Schemes mateialScheme = ThemeSchemes.styles[light.clamp(0, 17)];
    ColorScheme lightScheme = mateialScheme.light;
    ColorScheme darkScheme = mateialScheme.dark;
    MaterialAccentColor accentColor = Colors.accents[light.clamp(0, 15)];
    _darkAccentColor = accentColor;
    _lightTheme = _themeFromScheme(lightScheme);
    //_darkTheme = _themeFromScheme(darkScheme, swatch);
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
            side: _SelectedBorder(_darkAccentColor.withOpacity(0.54)),
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
            unselectedLabelTextStyle: __lightAccentTextTheme.bodyText2,
          ),
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
            selectedLabelTextStyle: __lightAccentTextTheme.bodyText2!
                .apply(color: _darkAccentColor),
            unselectedLabelTextStyle: __lightAccentTextTheme.bodyText2,
          ),
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
            selectedLabelTextStyle: __lightAccentTextTheme.bodyText2!
                .apply(color: _darkAccentColor),
            unselectedIconTheme: const IconThemeData(color: Colors.white70),
            unselectedLabelTextStyle: __lightAccentTextTheme.bodyText2,
          ),
          toggleableActiveColor: _darkAccentColor,
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
  late ColorScheme _darkScheme;
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

  AmiiboTheme3({int? light, int? dark}) {
    setLight = light;
    setDark = dark;
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
      extensions: const [],
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
      backgroundColor: scheme.background,
      bannerTheme: MaterialBannerThemeData(
        backgroundColor: scheme.tertiary,
        contentTextStyle: _textTheme.titleMedium,
        elevation: 4.0,
      ),

      /// Deprecated in the future
      bottomAppBarColor: scheme.surface,
      bottomAppBarTheme: BottomAppBarTheme(
        color: scheme.surface,
        elevation: 0.0,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 0.0,
        backgroundColor: scheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
        modalBackgroundColor: scheme.primaryContainer,
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

      /// Deprecated in the future
      dialogBackgroundColor: scheme.surface,
      dialogTheme: DialogTheme(
        elevation: 0.0,
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
        backgroundColor: ElevationOverlay.applySurfaceTint(
          scheme.background,
          scheme.primary.withOpacity(0.12),
          2.0,
        ),
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
            _textTheme.bodyText1,
          ),
          overlayColor: MaterialStateProperty.all<Color>(overlay),
          visualDensity: const VisualDensity(vertical: 2.5),
        ),
      ),

      /// Deprecated in the future
      errorColor: scheme.error,
      expansionTileTheme: ExpansionTileThemeData(
        collapsedBackgroundColor: Colors.transparent,
        backgroundColor: scheme.background,
      ),
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
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.background,
        iconTheme: MaterialStateProperty.all(
            IconThemeData(color: scheme.onBackground)),
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: MaterialStateProperty.all(_textTheme.labelLarge),
      ),
      navigationRailTheme: NavigationRailThemeData(
        labelType: NavigationRailLabelType.selected,
        backgroundColor: scheme.primaryContainer,
        elevation: 8.0,
        groupAlignment: 1.0,
        selectedIconTheme: IconThemeData(color: scheme.tertiary),
        selectedLabelTextStyle: __lightAccentTextTheme.bodyText2!.apply(
          color: scheme.onTertiary,
        ),
        unselectedIconTheme: const IconThemeData(color: Colors.black),
        unselectedLabelTextStyle: __darkAccentTextTheme.bodyText2,
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
        textStyle: _textTheme.bodyText1,
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
        bodyColor: scheme.primary,
        displayColor: scheme.primary,
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

      /// Deprecated in the future
      selectedRowColor: scheme.primary.withOpacity(0.24),
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
              states.contains(MaterialState.pressed)) return scheme.primary;
          return scheme.primaryContainer;
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
      toggleableActiveColor: scheme.secondaryContainer,
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.tertiaryContainer,
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        textStyle: _textTheme.caption,
      ),
      typography: Typography.material2021(),
      unselectedWidgetColor: scheme.onBackground,
    );
  }

  set setLight(int? light) {
    light ??= 0;
    Material3Schemes mateialScheme = ThemeSchemes.styles[light.clamp(0, 17)];
    ColorScheme lightScheme = mateialScheme.light;
    _darkScheme = mateialScheme.dark;
    _lightTheme = _themeFromScheme(lightScheme);
  }

  set setDark(int? dark) {
    /* var bluGrey = ThemeSchemes.blueGrey.dark;

    bluGrey = ColorScheme.dark(
      primary: Colors.black,
      onPrimary: const Color(0xFFE1E2E4),
      primaryContainer: const Color(0xFF191C1E),
      onPrimaryContainer: const Color(0xFFE1E2E4),
      shadow: Colors.white24,
      surface: const Color(0xFF191C1E),
      surfaceVariant: const Color(0xFF40484C),
      background: Colors.black,
      onBackground: const Color(0xFFE1E2E4),
      secondary: const Color(0xFF4D616C),
      onSecondary: const Color(0xFFFFFFFF),
      secondaryContainer: Colors.black,
      onSecondaryContainer: const Color(0xFFE1E2E4),
    );

    final style = bluGrey.copyWith(
      /* primary: bluGrey.primary.harmonizeWith(_darkScheme.primary),
      primaryContainer:
          _darkScheme.primaryContainer.harmonizeWith(_darkScheme.primaryContainer),
      onPrimary: bluGrey.onPrimary.harmonizeWith(_darkScheme.onPrimary),
      onPrimaryContainer: bluGrey.onPrimaryContainer
          .harmonizeWith(_darkScheme.onPrimaryContainer),
      inversePrimary:
          _darkScheme.inversePrimary.harmonizeWith(_darkScheme.inversePrimary),
      background: bluGrey.background.harmonizeWith(_darkScheme.background), 
      onBackground:
          bluGrey.onBackground.harmonizeWith(_darkScheme.onBackground),*/
      error: bluGrey.error.harmonizeWith(_darkScheme.error),
      errorContainer:
          _darkScheme.errorContainer.harmonizeWith(_darkScheme.errorContainer),
      onError: bluGrey.onError.harmonizeWith(_darkScheme.onError),
      onErrorContainer:
          bluGrey.onErrorContainer.harmonizeWith(_darkScheme.onErrorContainer),
      inverseSurface:
          bluGrey.inverseSurface.harmonizeWith(_darkScheme.inverseSurface),
      onInverseSurface:
          bluGrey.onInverseSurface.harmonizeWith(_darkScheme.onInverseSurface),
      /* secondary: _darkScheme.secondary,
      secondaryContainer: _darkScheme.secondaryContainer,
      onSecondary: _darkScheme.onSecondary,
      onSecondaryContainer: _darkScheme.onSecondaryContainer, */
      tertiary: _darkScheme.tertiary,
      tertiaryContainer: _darkScheme.tertiaryContainer,
      onTertiary: _darkScheme.onTertiary,
      onTertiaryContainer: _darkScheme.onTertiaryContainer,
      onSurface: bluGrey.onSurface.harmonizeWith(_darkScheme.onSurface),
      onSurfaceVariant:
          bluGrey.onSurfaceVariant.harmonizeWith(_darkScheme.onSurfaceVariant),
      outline: bluGrey.outline.harmonizeWith(_darkScheme.outline),
      surface: bluGrey.surface.harmonizeWith(_darkScheme.surface),
      surfaceTint: bluGrey.surfaceTint.harmonizeWith(_darkScheme.surfaceTint),
      surfaceVariant:
          bluGrey.surfaceVariant.harmonizeWith(_darkScheme.surfaceVariant),
    );
     */
    final Brightness _brightness =
        ThemeData.estimateBrightnessForColor(_darkScheme.primary);
    final Color _accentColor =
        _brightness == Brightness.dark ? Colors.white : Colors.black;
    final MaterialAccentColor _darkAccentColor = MaterialAccentColor(
      _darkScheme.primary.value,
      {
        100: _darkScheme.inversePrimary,
        200: _darkScheme.primaryContainer,
        400: _darkScheme.primary,
        700: _darkScheme.primaryContainer,
      },
    );
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
          colorScheme: _darkScheme.copyWith(
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
            side: _SelectedBorder(
                _darkAccentColor.withOpacity(0.54), Colors.amber),
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
            unselectedLabelTextStyle: __lightAccentTextTheme.bodyText2,
          ),
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
          colorScheme: _darkScheme.copyWith(
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            side: _SelectedBorder(
                _darkAccentColor.withOpacity(0.54), Colors.black),
            brightness: _brightness,
          ),
          navigationRailTheme: NavigationRailThemeData(
            labelType: NavigationRailLabelType.selected,
            backgroundColor: Colors.grey[850],
            elevation: 8.0,
            groupAlignment: 1.0,
            selectedIconTheme: IconThemeData(color: _darkAccentColor),
            unselectedIconTheme: const IconThemeData(color: Colors.white70),
            selectedLabelTextStyle: __lightAccentTextTheme.bodyText2!
                .apply(color: _darkAccentColor),
            unselectedLabelTextStyle: __lightAccentTextTheme.bodyText2,
          ),
          toggleableActiveColor: _darkAccentColor,
          indicatorColor: Colors.grey[700],
          useMaterial3: true,
        );
        break;
      case 2:
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
          colorScheme: _darkScheme.copyWith(
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            side: _SelectedBorder(
                _darkAccentColor.withOpacity(0.54), Colors.black),
            brightness: _brightness,
          ),
          navigationRailTheme: NavigationRailThemeData(
            labelType: NavigationRailLabelType.selected,
            backgroundColor: Colors.transparent,
            groupAlignment: 1.0,
            selectedIconTheme: IconThemeData(color: _darkAccentColor),
            selectedLabelTextStyle: __lightAccentTextTheme.bodyText2!
                .apply(color: _darkAccentColor),
            unselectedIconTheme: const IconThemeData(color: Colors.white70),
            unselectedLabelTextStyle: __lightAccentTextTheme.bodyText2,
          ),
          toggleableActiveColor: _darkAccentColor,
          indicatorColor: _darkAccentColor.withOpacity(0.75),
          useMaterial3: true,
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
