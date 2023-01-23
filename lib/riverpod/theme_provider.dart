import 'package:amiibo_network/resources/theme_material3_schemes.dart';
import 'package:amiibo_network/utils/preferences_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amiibo_network/repository/theme_repository.dart';
import 'package:amiibo_network/riverpod/repository_provider.dart';
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

final themeProvider = ChangeNotifierProvider<ThemeProvider>((ref) {
  final preferences = ref.watch(preferencesProvider);
  final int _theme = preferences.getInt(sharedThemeMode) ?? 0;
  final int light = preferences.getInt(sharedLightTheme) ?? 0;
  final int dark = preferences.getInt(sharedDarkTheme) ?? 2;
  return ThemeProvider(_theme, light, dark, preferences);
});

class ThemeProvider extends ChangeNotifier {
  ThemeMode _preferredTheme;
  int _lightColor;
  int _darkColor;
  final AmiiboTheme _theme;
  final SharedPreferences _preferences;

  ThemeProvider(
      int themeMode, this._lightColor, this._darkColor, this._preferences)
      : _preferredTheme = ThemeMode.values[themeMode],
        _theme = AmiiboTheme3(light: _lightColor, dark: _darkColor);

  ThemeMode get preferredTheme => _preferredTheme;

  int get lightOption => _lightColor;
  int get darkOption => _darkColor;

  int get _themesLength => ThemeSchemes.styles.length;

  List<Color> get lightColors => _theme.lightColors;
  List<Color> get darkColors => _theme.darkColors;

  ThemeData? get light => _theme.light;
  ThemeData? get dark => _theme.dark;

  lightTheme(int light) async {
    light = light.clamp(0, _themesLength);
    if (light != _lightColor) {
      _lightColor = light;
      await _preferences.setInt(sharedLightTheme, light);
      _theme
        ..setLight = _lightColor
        ..setDark = _darkColor;
      notifyListeners();
    }
  }

  darkTheme(int dark) async {
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

  Future<void> themeDB(ThemeMode? value) async {
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
        _preferredTheme = ThemeMode.light;
        break;
      case ThemeMode.light:
        await themeDB(ThemeMode.dark);
        _preferredTheme = ThemeMode.dark;
        break;
      default:
        await themeDB(ThemeMode.system);
        _preferredTheme = ThemeMode.system;
        break;
    }
    notifyListeners();
  }
}
