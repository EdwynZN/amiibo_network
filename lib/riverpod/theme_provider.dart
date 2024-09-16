import 'dart:convert';

import 'package:amiibo_network/resources/material3_schemes.dart';
import 'package:amiibo_network/resources/theme_material3_schemes.dart';
import 'package:amiibo_network/utils/preferences_constants.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amiibo_network/repository/theme_repository.dart';
import 'package:amiibo_network/riverpod/repository_provider.dart';
import 'package:material_color_utilities/palettes/core_palette.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> updateOldTheme() async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  if (preferences.containsKey(sharedOldTheme)) {
    final String _theme = preferences.getString(sharedOldTheme) ?? 'Auto';
    await preferences.remove(sharedOldTheme);
    switch (_theme) {
      case 'Light':
        await preferences.setInt(sharedThemeMode, ThemeMode.light.index);
        break;
      case 'Dark':
        await preferences.setInt(sharedThemeMode, ThemeMode.dark.index);
        break;
      case 'Auto':
      default:
        await preferences.setInt(sharedThemeMode, ThemeMode.system.index);
        break;
    }
  }
}

final _materialYouThemeProvider = FutureProvider<Material3Schemes?>(
  (ref) async {
    ColorScheme? light;
    ColorScheme? dark;
    final CorePalette? corePalette = await DynamicColorPlugin.getCorePalette();
    if (corePalette != null) {
      light = corePalette.toColorScheme();
      dark = corePalette.toColorScheme(brightness: Brightness.dark);
    } else {
      return null;
    }

    return Material3Schemes(light: light, dark: dark);

    /* final Color? accentColor = await DynamicColorPlugin.getAccentColor();
    if (accentColor != null) {
      light = ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: Brightness.light,
      );
      dark = ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: Brightness.dark,
      );
    } */
  },
);

final customSchemesProvider = Provider<Material3Schemes?>(
  (ref) => ref.watch(_materialYouThemeProvider).valueOrNull,
);

final themeProvider = ChangeNotifierProvider<ThemeProvider>((ref) {
  final preferences = ref.watch(preferencesProvider);
  final int mode = preferences.getInt(sharedThemeMode) ?? 0;
  final int light = preferences.getInt(sharedLightTheme) ?? 0;
  final int dark = preferences.getInt(sharedDarkTheme) ?? 2;
  final String? customTheme = preferences.getString(sharedCustomTheme);
  Material3Schemes? customSchemes;
  if (customTheme != null) {
    customSchemes = Material3Schemes.fromJson(jsonDecode(customTheme));
  }
  final provider = ThemeProvider(mode, light, dark, preferences, customSchemes);
  ref.listen(
    customSchemesProvider,
    (previous, next) {
      if (next != null && previous != next && provider.useCustom) {
        provider.useCustomScheme(next);
      }
    },
    fireImmediately: true,
  );

  return provider;
});

class ThemeProvider extends ChangeNotifier {
  final AmiiboTheme _theme;
  final SharedPreferences _preferences;
  ThemeMode _preferredMode;
  int? _lightColor;
  int _darkColor;
  Material3Schemes? _customScheme;

  ThemeProvider(
    int themeMode,
    this._lightColor,
    this._darkColor,
    this._preferences,
    this._customScheme,
  )   : _preferredMode = ThemeMode.values[themeMode],
        _theme = AmiiboTheme3(
          light: _lightColor,
          dark: _darkColor,
          dynamicScheme: _customScheme,
        );

  ThemeMode get preferredMode => _preferredMode;

  int? get lightOption => _lightColor;
  int get darkOption => _darkColor;

  int get _themesLength => ThemeSchemes.styles.length;

  List<Color> get lightColors => _theme.lightColors;
  List<Color> get darkColors => _theme.darkColors;

  ThemeData? get light => _theme.light;
  ThemeData? get dark => _theme.dark;

  bool get useCustom => _customScheme != null;

  Future<void> useCustomScheme(Material3Schemes schemes) async {
    if (schemes == _customScheme) {
      return;
    }
    _customScheme = _theme.customScheme = schemes;
    _lightColor = null;
    await _preferences.setString(
      sharedCustomTheme,
      jsonEncode(schemes.toJson()),
    );
    notifyListeners();
  }

  Future<void> lightTheme(int light) async {
    light = light.clamp(0, _themesLength);
    if (light != _lightColor) {
      _lightColor = light;
      _customScheme = null;
      await _preferences.remove(sharedCustomTheme);
      await _preferences.setInt(sharedLightTheme, light);
      _theme
        ..setLight = light
        ..setDark = _darkColor;
      notifyListeners();
    }
  }

  Future<void> darkTheme(int dark) async {
    dark = dark.clamp(0, _themesLength);
    if (dark != _darkColor) {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      _darkColor = dark;
      await preferences.setInt(sharedDarkTheme, dark);
      _theme.setDark = _darkColor;
      notifyListeners();
    }
  }

  Future<void> selectMode(ThemeMode value) async {
    if (value == _preferredMode) {
      return;
    }
    _preferredMode = value;
    await _preferences.setInt(sharedThemeMode, value.index);
    notifyListeners();
  }

  Future<void> toggleThemeMode() async {
    final nextMode = switch (_preferredMode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    await selectMode(nextMode);
  }
}
