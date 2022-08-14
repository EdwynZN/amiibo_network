import 'package:flutter/material.dart';

Color? colorOnThemeMode(ThemeMode mode, Brightness brightness) {
  switch (mode) {
    case ThemeMode.light:
      return null;
    case ThemeMode.dark:
      return Colors.white54;
    case ThemeMode.system:
    default:
      return brightness == Brightness.dark ? Colors.white54 : null;
  }
}