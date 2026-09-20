import 'package:material_ui/material_ui.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'theme_state.freezed.dart';

@freezed
class ThemeState with _$ThemeState {
  const ThemeState({
    required this.light,
    required this.dark,
    required this.lightColors,
    required this.darkColors,
    required this.isCustom,
  });

  final ThemeData? light;
  final ThemeData? dark;
  final bool isCustom;
  final List<Color> lightColors;
  final List<Color> darkColors;
}
