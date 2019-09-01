import 'package:flutter/material.dart';
import 'package:amiibo_network/service/service.dart';

class ThemeProvider with ChangeNotifier{
  ThemeProvider._();
  static final ThemeProvider _instance = ThemeProvider._();
  factory ThemeProvider() => _instance;

  final service = Service();
  String _savedTheme;
  ThemeMode preferredTheme = ThemeMode.system;

  String get savedTheme => _savedTheme;

  Future<ThemeMode> initThemes() async {
    _savedTheme = await service.getTheme();
    preferredTheme = _switchPreferredTheme(_savedTheme);
    return preferredTheme;
  }

  themeDB(String value) async {
    if(value != _savedTheme){
      _savedTheme = value;
      await service.updateTheme(value);
      preferredTheme = _switchPreferredTheme(_savedTheme);
      notifyListeners();
    }
  }

  ThemeMode _switchPreferredTheme(String theme){
    switch(theme){
      case 'Light':
        return ThemeMode.light;
      case 'Dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}