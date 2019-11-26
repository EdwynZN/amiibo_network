import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> getTheme() async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getString('Theme') ?? 'Auto';
}

class ThemeProvider with ChangeNotifier{
  String _savedTheme;
  ThemeMode preferredTheme;

  ThemeProvider(this._savedTheme) : preferredTheme = _switchPreferredTheme(_savedTheme);

  String get savedTheme => _savedTheme;

  themeDB(String value) async {
    if(value != _savedTheme){
      final SharedPreferences preferences = await SharedPreferences.getInstance();
      _savedTheme = value;
      await preferences.setString('Theme', value);
      preferredTheme = _switchPreferredTheme(_savedTheme);
      notifyListeners();
    }
  }

  static ThemeMode _switchPreferredTheme(String theme){
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