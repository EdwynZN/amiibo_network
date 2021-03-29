import 'package:amiibo_network/utils/preferences_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amiibo_network/repository/theme_repository.dart';
import 'package:amiibo_network/riverpod/repository_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> updateOldTheme() async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  if (preferences.containsKey(sharedOldTheme)) {
    final String theme = preferences.getString(sharedOldTheme) ?? 'Auto';
    await preferences.remove(sharedOldTheme);
    switch (theme) {
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

final themeProvider = ChangeNotifierProvider<ThemeProvider>((ref) {
  final preferences = ref.watch(preferencesProvider);
  final int theme = preferences.getInt(sharedThemeMode) ?? 0;
  final int light = preferences.getInt(sharedLightTheme) ?? 0;
  final int dark = preferences.getInt(sharedDarkTheme) ?? 2;
  return ThemeProvider(theme, light, dark, preferences);
});

class ThemeProvider extends ChangeNotifier {
  ThemeMode _preferredTheme;
  int _lightColor;
  int _darkColor;
  final AmiiboTheme theme;
  final SharedPreferences _preferences;

  ThemeProvider(
      int themeMode, this._lightColor, this._darkColor, this._preferences)
      : _preferredTheme = ThemeMode.values[themeMode],
        theme = AmiiboTheme(light: _lightColor, dark: _darkColor);

  ThemeMode get preferredTheme => _preferredTheme;

  int get lightOption => _lightColor ?? 0;
  int get darkOption => _darkColor ?? 2;

  lightTheme(int light) async {
    light = light?.clamp(0, 17) ?? 0;
    if (light != _lightColor) {
      _lightColor = light;
      await _preferences.setInt(sharedLightTheme, light);
      theme
        ..setLight = _lightColor
        ..setDark = _darkColor;
      notifyListeners();
    }
  }

  darkTheme(int dark) async {
    dark = dark?.clamp(0, 17) ?? 0;
    if (dark != _darkColor) {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      _darkColor = dark;
      await preferences.setInt(sharedDarkTheme, dark);
      theme.setDark = _darkColor;
      notifyListeners();
    }
  }

  Future<void> themeDB(ThemeMode value) async {
    if (value == null) value = ThemeMode.system;
    if (value != preferredTheme) {
      _preferredTheme = value;
      await _preferences.setInt(sharedThemeMode, value.index);
      notifyListeners();
    }
  }

  Future<void> toggleThemeMode() async {
    switch (_preferredTheme) {
      case ThemeMode.system:
        await themeDB(ThemeMode.light);
        break;
      case ThemeMode.light:
        await themeDB(ThemeMode.dark);
        break;
      default:
        await themeDB(ThemeMode.system);
        break;
    }
  }
}
