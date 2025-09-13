import 'package:amiibo_network/repository/theme_repository.dart';
import 'package:amiibo_network/resources/material3_schemes.dart';
import 'package:amiibo_network/resources/theme_material3_schemes.dart';
import 'package:amiibo_network/utils/preferences_constants.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amiibo_network/repository/theme_mode_scheme_repository.dart';
import 'package:amiibo_network/riverpod/repository_provider.dart';
import 'package:hooks_riverpod/legacy.dart';
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

final themeRepositoryProvider = Provider<ThemeRepository>((ref) {
  final preferences = ref.watch(preferencesProvider);
  return ThemeRepository(preferences);
});

final dynamicSchemeProvider = FutureProvider<Material3Schemes?>((ref) async {
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
});

final customSchemesProvider = Provider<Material3Schemes?>(
  (ref) => ref.watch(dynamicSchemeProvider).value,
);

final themeProvider = ChangeNotifierProvider<ThemeProvider>((ref) {
  final repository = ref.watch(themeRepositoryProvider);
  final provider = ThemeProvider(repository);
  ref.listen(customSchemesProvider, (previous, next) {
    if (next != null && previous != next && provider.useCustom) {
      provider.useCustomScheme(next);
    }
  }, fireImmediately: true);

  return provider;
});

class ThemeProvider extends ChangeNotifier {
  final ThemeRepository _themeRepository;
  final AmiiboTheme _theme;
  ThemeMode _preferredMode;

  ThemeProvider(this._themeRepository)
    : _preferredMode = _themeRepository.mode,
      _theme = AmiiboTheme3(
        light: _themeRepository.lightType,
        dark: _themeRepository.darkType,
        dynamicScheme: _themeRepository.customSchemes,
      );

  ThemeMode get preferredMode => _preferredMode;

  Material3Schemes? get _customScheme => _themeRepository.customSchemes;
  bool get useCustom => _customScheme != null;

  int? get lightOption => useCustom ? null : _themeRepository.lightType;
  int get darkOption => _themeRepository.darkType;

  int get _themesLength => ThemeSchemes.styles.length;

  List<Color> get lightColors => _theme.lightColors;
  List<Color> get darkColors => _theme.darkColors;

  ThemeData? get light => _theme.light;
  ThemeData? get dark => _theme.dark;

  Future<void> useCustomScheme(Material3Schemes schemes) async {
    if (schemes == _customScheme) {
      return;
    }
    await _themeRepository.saveCustomSchemes(schemes);
    _theme.customScheme = schemes;
    notifyListeners();
  }

  Future<void> lightTheme(int light) async {
    light = light.clamp(0, _themesLength);
    if (light != lightOption) {
      await _themeRepository.deleteCustomSchemes();
      await _themeRepository.saveLightType(light);
      _theme.setLight = light;
      notifyListeners();
    }
  }

  Future<void> darkTheme(int dark) async {
    dark = dark.clamp(0, _themesLength);
    if (dark != darkOption) {
      await _themeRepository.saveDarkType(dark);
      _theme.setDark = dark;
      notifyListeners();
    }
  }

  Future<void> selectMode(ThemeMode value) async {
    if (value == _preferredMode) {
      return;
    }
    _preferredMode = value;
    await _themeRepository.saveMode(value);
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
