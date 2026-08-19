import 'dart:async';

import 'package:amiibo_network/app/configuration/preferences_provider.dart';
import 'package:amiibo_network/app/state/model/theme_state.dart';
import 'package:amiibo_network/app/state/theme/service/theme_mode_scheme_repository.dart';
import 'package:amiibo_network/app/state/theme/service/theme_repository.dart';
import 'package:amiibo_network/shared/resources/material3_schemes.dart';
import 'package:amiibo_network/shared/resources/theme_material3_schemes.dart';
import 'package:amiibo_network/shared/utils/corepalette_to_color_scheme.dart';
import 'package:amiibo_network/shared/utils/preferences_constants.dart';
import 'package:collection/collection.dart';
import 'package:dynamic_color/dynamic_color.dart' hide CorePaletteToColorScheme;
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

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

@riverpod
ThemeRepository themeRepository(Ref ref) {
  final preferences = ref.watch(preferencesProvider);
  return ThemeRepository(preferences);
}

@riverpod
Future<Material3Schemes?> dynamicScheme(Ref ref) async {
  final corePalette = await DynamicColorPlugin.getCorePalette();
  if (corePalette == null) return null;

  final light = corePalette.toColorScheme();
  final dark = corePalette.toColorScheme(brightness: .dark);
  return Material3Schemes(light: light, dark: dark);
}

@riverpod
Material3Schemes? customSchemes(Ref ref) =>
    ref.watch(dynamicSchemeProvider).value;

@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    final repo = ref.watch(themeRepositoryProvider);
    listenSelf((previous, next) {
      if (next == previous) return;
      unawaited(repo.saveMode(next));
    });
    return repo.mode;
  }

  ThemeMode get preferredMode => state;

  Future<void> selectMode(ThemeMode value) async {
    if (value == state) return;
    state = value;
  }

  Future<void> toggleThemeMode() async {
    final ThemeMode nextMode = switch (state) {
      .system => .light,
      .light => .dark,
      .dark => .system,
    };
    await selectMode(nextMode);
  }
}

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  late ThemeRepository _themeRepository;
  late AmiiboTheme _theme;

  ThemeState _fromTheme() {
    return ThemeState(
      light: _theme.light,
      dark: _theme.dark,
      lightColors: UnmodifiableListView(_theme.lightColors),
      darkColors: UnmodifiableListView(_theme.darkColors),
      isCustom: useCustom,
    );
  }

  @override
  ThemeState build() {
    _themeRepository = ref.watch(themeRepositoryProvider);
    _theme = AmiiboTheme3(
      light: _themeRepository.lightType,
      dark: _themeRepository.darkType,
      dynamicScheme: _themeRepository.customSchemes,
    );
    ref.listen(customSchemesProvider, (previous, next) {
      if (next != null && previous != next && useCustom) _useCustomScheme(next);
    }, fireImmediately: true);

    return _fromTheme();
  }

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
    if (schemes == _customScheme) return;
    await _useCustomScheme(schemes);
    state = _fromTheme();
  }

  Future<void> _useCustomScheme(Material3Schemes schemes) async {
    await _themeRepository.saveCustomSchemes(schemes);
    _theme.customScheme = schemes;
  }

  Future<void> lightTheme(int light) async {
    light = light.clamp(0, _themesLength);
    if (light != lightOption) {
      await _themeRepository.deleteCustomSchemes();
      await _themeRepository.saveLightType(light);
      _theme.setLight = light;
      state = _fromTheme();
    }
  }

  Future<void> darkTheme(int dark) async {
    dark = dark.clamp(0, _themesLength);
    if (dark != darkOption) {
      await _themeRepository.saveDarkType(dark);
      _theme.setDark = dark;
      state = _fromTheme();
    }
  }
}
