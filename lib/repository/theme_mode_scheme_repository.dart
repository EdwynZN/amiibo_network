import 'package:amiibo_network/resources/material3_schemes.dart';
import 'package:amiibo_network/resources/theme_material3_schemes.dart';
import 'package:amiibo_network/utils/theme_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const iconOwned = Icons.bookmark_added_rounded;
const iconOwnedDark = Icons.bookmark_added_sharp;
const iconWished = Icons.favorite;

abstract class AmiiboTheme {
  factory AmiiboTheme({int? light, int? dark}) = AmiiboTheme3;

  set customScheme(Material3Schemes scheme);

  ThemeData? get light;
  set setLight(int light);

  ThemeData? get dark;
  set setDark(int dark);

  List<Color> get lightColors;
  List<Color> get darkColors;
}

class AmiiboTheme3 implements AmiiboTheme {
  ThemeData? _lightTheme;
  ThemeData? _darkTheme;
  late Material3Schemes _materialScheme;
  ColorScheme get _darkScheme => _materialScheme.dark;
  int? _dark;
  final _greyScheme = const ColorScheme(
    error: Color(0xFFCF6679),
    onError: Color(0xFF690005),
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

  AmiiboTheme3({int? light, int? dark, Material3Schemes? dynamicScheme}) {
    if (dynamicScheme != null) {
      customScheme = dynamicScheme;
    } else {
      setLight = light ?? 0;
      setDark = dark ?? 0;
    }
  }

  ThemeData _themeFromScheme(ColorScheme scheme,
      [bool useSurfaceElevation = true]) {
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
        thumbColor: WidgetStatePropertyAll(scheme.secondary),
      ),
      splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
      useMaterial3: true,
      visualDensity: const VisualDensity(),
      // COLOR CONFIGURATION
      appBarTheme: AppBarTheme(
        elevation: !useSurfaceElevation ? 0 : 2.0,
        shadowColor: scheme.shadow,
        surfaceTintColor: scheme.surfaceTint,
        scrolledUnderElevation: 8.0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: inverseBrightness,
          statusBarIconBrightness: inverseBrightness,
          systemNavigationBarIconBrightness: inverseBrightness,
          systemNavigationBarColor: ElevationOverlay.applySurfaceTint(
            scheme.surface,
            scheme.surfaceTint,
            2.0,
          ),
          systemNavigationBarDividerColor: ElevationOverlay.applySurfaceTint(
            scheme.surface,
            scheme.surfaceTint,
            6.0,
          ),
          systemStatusBarContrastEnforced: false,
          statusBarColor: Colors.transparent,
        ),
        backgroundColor: scheme.surface,
        titleTextStyle:
            _textTheme.titleMedium?.copyWith(color: scheme.onSurface),
        toolbarTextStyle:
            _textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
        foregroundColor: scheme.onSurface,
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      badgeTheme: const BadgeThemeData(),
      bannerTheme: MaterialBannerThemeData(
        backgroundColor: scheme.tertiary,
        contentTextStyle: _textTheme.titleMedium,
        elevation: !useSurfaceElevation ? 0 : 4.0,
      ),
      bottomAppBarTheme: BottomAppBarTheme(
        color: scheme.surface,
        elevation: !useSurfaceElevation ? 0 : 0.0,
        height: kBottomNavigationBarHeight,
        padding: EdgeInsets.zero,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        elevation: !useSurfaceElevation ? 0 : 0.0,
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
        elevation: !useSurfaceElevation ? 0 : 8.0,
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
        elevation: !useSurfaceElevation ? 0 : 4.0,
        shadowColor: scheme.surface.withOpacity(0.12),
        surfaceTintColor: scheme.surfaceTint,
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.disabled)) return null;
          return scheme.onPrimary;
        }),
        fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.disabled)) return null;
          if (states.contains(WidgetState.focused) ||
              states.contains(WidgetState.pressed)) return scheme.secondary;
          return scheme.tertiaryContainer;
        }),
      ),
      chipTheme: ChipThemeData(
        surfaceTintColor: scheme.surfaceTint,
        elevation: !useSurfaceElevation ? 0 : 4.0,
        pressElevation: 6.0,
        checkmarkColor: scheme.onPrimary,
        backgroundColor: scheme.surface,
        deleteIconColor: scheme.tertiary,
        disabledColor: Colors.white.withAlpha(0x0C),
        selectedColor: scheme.primaryContainer,
        secondarySelectedColor: scheme.secondaryContainer,
        labelPadding: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.all(4.0),
        shadowColor: Colors.black12,
        selectedShadowColor: Colors.black38,
        labelStyle: _textTheme.bodySmall!.copyWith(color: scheme.onSurface),
        secondaryLabelStyle:
            _textTheme.bodySmall!.copyWith(color: scheme.onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: _SelectedBorder(scheme.primary, scheme.primary),
        brightness: scheme.brightness,
      ),
      colorScheme: scheme,
      dataTableTheme: const DataTableThemeData(),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(_darkScheme.surface),
        ),
      ),

      /// Deprecated in the future
      dialogBackgroundColor: scheme.surface,
      dialogTheme: DialogTheme(
        elevation: !useSurfaceElevation ? 0 : 2.0,
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
        elevation: !useSurfaceElevation ? 0 : 4.0,
        shadowColor: scheme.shadow,
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surfaceTint,
        shape: const RoundedRectangleBorder(),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          mouseCursor: WidgetStateProperty.all<MouseCursor>(
              WidgetStateMouseCursor.clickable),
          //enableFeedback: false,
          surfaceTintColor: WidgetStateProperty.all(scheme.surfaceTint),
          shape: WidgetStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          elevation: WidgetStateProperty.resolveWith<double>((states) {
            if (states.contains(WidgetState.pressed)) return 0.0;
            return !useSurfaceElevation ? 0 : 4.0;
          }),
          backgroundColor:
              WidgetStateProperty.all<Color?>(scheme.secondaryContainer),
          foregroundColor: WidgetStateProperty.all<Color?>(
            scheme.onSecondaryContainer,
          ),
          textStyle: WidgetStateProperty.all<TextStyle?>(
            _textTheme.bodyLarge,
          ),
          overlayColor: WidgetStateProperty.all<Color>(overlay),
          visualDensity: const VisualDensity(vertical: 0),
        ),
      ),

      expansionTileTheme: ExpansionTileThemeData(
        collapsedBackgroundColor: Colors.transparent,
        backgroundColor: scheme.surface,
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
      iconTheme: IconThemeData(color: scheme.onSurface),

      /// Deprecated in the future
      indicatorColor: scheme.primaryContainer,
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurface,
        selectedTileColor: scheme.secondaryContainer,
        selectedColor: scheme.onSecondaryContainer,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
      ),
      menuBarTheme: const MenuBarThemeData(),
      menuButtonTheme: const MenuButtonThemeData(),
      menuTheme: const MenuThemeData(),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        iconTheme:
            WidgetStateProperty.all(IconThemeData(color: scheme.onSurface)),
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.all(_textTheme.labelLarge),
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        elevation: !useSurfaceElevation ? 0 : 4.0,
        shadowColor: scheme.shadow,
        backgroundColor: scheme.surface,
      ),
      navigationRailTheme: NavigationRailThemeData(
        labelType: NavigationRailLabelType.selected,
        backgroundColor: scheme.primaryContainer,
        elevation: !useSurfaceElevation ? 0 : 8.0,
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
          mouseCursor: WidgetStateProperty.all<MouseCursor>(
            WidgetStateMouseCursor.clickable,
          ),
          //enableFeedback: false,
          shape: WidgetStateProperty.all<OutlinedBorder>(
            const RoundedRectangleBorder(),
          ),
          side: WidgetStateProperty.all<BorderSide>(BorderSide(
            color: scheme.primary,
            width: 1,
          )),
          backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
          foregroundColor: WidgetStateProperty.all<Color?>(scheme.primary),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        textStyle: _textTheme.bodyLarge,
        color: scheme.primaryContainer,
        elevation: !useSurfaceElevation ? 0 : 8.0,
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
        refreshBackgroundColor: scheme.surface,
        linearMinHeight: 4.0,
      ),

      radioTheme: const RadioThemeData(),
      scaffoldBackgroundColor: scheme.surface,
      secondaryHeaderColor: scheme.secondaryContainer,
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.disabled))
              return null;
            else if (states.contains(WidgetState.selected))
              return scheme.primary;
            else if (states.contains(WidgetState.focused) ||
                states.contains(WidgetState.pressed))
              return scheme.primaryContainer;
            return scheme.surface;
          }),
          iconSize: WidgetStatePropertyAll(16.0),
          iconColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.disabled))
              return null;
            else if (states.contains(WidgetState.selected))
              return scheme.onPrimary;
            else if (states.contains(WidgetState.focused) ||
                states.contains(WidgetState.pressed))
              return scheme.onPrimaryContainer;
            return scheme.onSurface;
          }),
          textStyle: WidgetStatePropertyAll(_textTheme.labelLarge),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.disabled))
              return null;
            else if (states.contains(WidgetState.selected))
              return scheme.onPrimary;
            else if (states.contains(WidgetState.focused) ||
                states.contains(WidgetState.pressed))
              return scheme.onPrimaryContainer;
            return scheme.onSurface;
          }),
          elevation: WidgetStatePropertyAll(0.0),
          side: WidgetStatePropertyAll(
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
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          } else if (states.contains(WidgetState.focused) ||
              states.contains(WidgetState.pressed)) {
            return scheme.primaryContainer;
          } else if (states.contains(WidgetState.selected)) {
            return scheme.primary;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          } else if (states.contains(WidgetState.focused) ||
              states.contains(WidgetState.pressed)) {
            return scheme.onPrimaryContainer.withOpacity(0.24);
          } else if (states.contains(WidgetState.selected)) {
            return scheme.primary.withOpacity(0.24);
          }
          return null;
        }),
        trackOutlineWidth: WidgetStatePropertyAll(2.0),
      ),
      tabBarTheme: const TabBarTheme(),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          mouseCursor: WidgetStateProperty.all<MouseCursor>(
              WidgetStateMouseCursor.clickable),
          //enableFeedback: false,
          shape: WidgetStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
          foregroundColor: WidgetStateProperty.all<Color>(scheme.onSurface),
          overlayColor: WidgetStateProperty.all<Color>(overlay),
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
      unselectedWidgetColor: scheme.onSurface,
    );
  }

  @override
  set setLight(int light) {
    final length = lightColors.length;
    light = light.clamp(0, length - 1);
    _materialScheme = ThemeSchemes.styles[light];
    ColorScheme lightScheme = _materialScheme.light;
    _lightTheme = _themeFromScheme(lightScheme);
    _setDark();
  }

  @override
  set setDark(int? dark) {
    _dark = dark;
    _setDark();
  }

  void _setDark() {
    switch (_dark) {
      case 0:
        final darkBlueGrey = ThemeSchemes.blueGrey.dark;
        final theme = blendScheme(darkBlueGrey, _darkScheme, 0.25);
        _darkTheme = _themeFromScheme(theme);
        break;
      case 1:
        final theme = blendScheme(_greyScheme, _darkScheme, 0.35);
        _darkTheme = _themeFromScheme(theme);
        break;
      case 2:
        final scheme = blendScheme(_darkScheme, _greyScheme, 0.75);
        final theme = _themeFromScheme(scheme, false);
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
          colorScheme: theme.colorScheme.copyWith(surface: Colors.black),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            shape: const CircleBorder(),
            foregroundColor: _darkScheme.onSecondaryContainer,
            backgroundColor: _darkScheme.secondaryContainer,
          ),
          bottomSheetTheme: BottomSheetThemeData(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            modalBackgroundColor: Colors.transparent,
            constraints: const BoxConstraints(maxWidth: 400.0),
            shape: shape,
            surfaceTintColor: _darkScheme.surfaceTint,
          ),
          canvasColor: Colors.black,
          cardColor: Colors.black,
          cardTheme: CardTheme(
            surfaceTintColor: null,
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
            elevation: 0.0,
          ),
          drawerTheme: DrawerThemeData(
            elevation: 0.0,
            shadowColor: _darkScheme.shadow,
            surfaceTintColor: _darkScheme.surfaceTint,
            backgroundColor: Colors.black,
            shape: const RoundedRectangleBorder(),
          ),
          listTileTheme: ListTileThemeData(
            iconColor: _darkScheme.onSurface,
            selectedTileColor: _darkScheme.secondaryContainer,
            selectedColor: _darkScheme.onSecondaryContainer,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
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

  @override
  ThemeData? get light => _lightTheme;

  @override
  ThemeData? get dark => _darkTheme;

  @override
  set customScheme(Material3Schemes scheme) {
    _materialScheme = scheme;
    _lightTheme = _themeFromScheme(_materialScheme.light);
    _materialScheme = _materialScheme;
    _setDark();;
  }

  @override
  final List<Color> lightColors =
      ThemeSchemes.styles.map((e) => e.light.primaryContainer).toList();

  @override
  List<Color> get darkColors => [
        Colors.blueGrey,
        Colors.grey,
        Colors.black,
        _darkScheme.primary,
      ];
}

class _SelectedBorder extends BorderSide implements WidgetStateBorderSide {
  final Color? selectedColor;
  final Color regularColor;

  const _SelectedBorder(
    this.selectedColor, [
    Color? regularColor,
  ]) : regularColor = regularColor ?? Colors.white54;

  @override
  BorderSide? resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return const BorderSide(color: Colors.white12);
    }
    if (selectedColor != null && states.contains(WidgetState.selected)) {
      return BorderSide(color: selectedColor!);
    }
    return BorderSide(color: regularColor);
  }
}
