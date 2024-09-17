import 'dart:async';
import 'dart:convert';

import 'package:amiibo_network/resources/material3_schemes.dart';
import 'package:amiibo_network/utils/preferences_constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ThemeRepository {
  factory ThemeRepository(SharedPreferences preferences) =
      _LocalThemeRepository;

  ThemeMode get mode;

  Future<void> saveMode(ThemeMode mode);

  int get lightType;

  Future<void> saveLightType(int type);

  int get darkType;

  Future<void> saveDarkType(int type);

  Material3Schemes? get customSchemes;

  Future<void> saveCustomSchemes(Material3Schemes scheme);

  Future<void> deleteCustomSchemes();
}

class _LocalThemeRepository implements ThemeRepository {
  final SharedPreferences _preferences;

  const _LocalThemeRepository(this._preferences);

  @override
  Material3Schemes? get customSchemes {
    final String? customTheme = _preferences.getString(sharedCustomTheme);
    Material3Schemes? customSchemes;
    if (customTheme != null) {
      customSchemes = Material3Schemes.fromJson(jsonDecode(customTheme));
    }
    return customSchemes;
  }

  @override
  Future<void> saveCustomSchemes(Material3Schemes scheme) async {
    await _preferences.setString(
      sharedCustomTheme,
      jsonEncode(scheme.toJson()),
    );
  }

  @override
  Future<void> deleteCustomSchemes() async {
    await _preferences.remove(sharedCustomTheme);
  }

  @override
  int get darkType => _preferences.getInt(sharedDarkTheme) ?? 2;

  @override
  Future<void> saveDarkType(int type) async {
    await _preferences.setInt(sharedDarkTheme, type);
  }

  @override
  int get lightType => _preferences.getInt(sharedLightTheme) ?? 0;

  @override
  Future<void> saveLightType(int type) async {
    await _preferences.setInt(sharedLightTheme, type);
  }

  @override
  ThemeMode get mode {
    final value = _preferences.getInt(sharedThemeMode) ?? 0;
    return ThemeMode.values[value];
  }

  @override
  Future<void> saveMode(ThemeMode mode) async {
    await _preferences.setInt(sharedThemeMode, mode.index);
  }
}
