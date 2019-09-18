import 'package:flutter/material.dart';
import 'package:amiibo_network/service/service.dart';

class ThemeProvider with ChangeNotifier{
  String _savedTheme;
  ThemeMode preferredTheme;

  ThemeProvider(this._savedTheme) : preferredTheme = _switchPreferredTheme(_savedTheme);

  String get savedTheme => _savedTheme;

  themeDB(String value) async {
    if(value != _savedTheme){
      _savedTheme = value;
      await updateTheme(value);
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