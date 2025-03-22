import 'dart:convert';

import 'package:amiibo_network/resources/theme_material3_schemes.dart';
import 'package:amiibo_network/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'material3_schemes.freezed.dart';
part 'material3_schemes.g.dart';

@freezed
abstract class Material3Schemes with _$Material3Schemes {
  const factory Material3Schemes({
    @ColorSchemeConverter() required final ColorScheme light,
    @ColorSchemeConverter() required final ColorScheme dark,
  }) = _Material3Schemes;

  factory Material3Schemes.blend(
    Material3Schemes original,
    Material3Schemes destiny,
  ) {
    return Material3Schemes(
      light: blendScheme(original.light, destiny.light),
      dark: blendScheme(original.dark, destiny.dark),
    );
  }

  factory Material3Schemes.fromJson(Map<String, dynamic> json) =>
      _$Material3SchemesFromJson(json);
}

@Freezed(copyWith: false)
abstract class CustomScheme with _$CustomScheme {
  const CustomScheme._();

  const factory CustomScheme({
    required Brightness brightness,
    @ColorConverter() required Color primary,
    @ColorConverter() required Color onPrimary,
    @ColorOrNullConverter() Color? primaryContainer,
    @ColorOrNullConverter() Color? onPrimaryContainer,
    @ColorOrNullConverter() Color? primaryFixed,
    @ColorOrNullConverter() Color? primaryFixedDim,
    @ColorOrNullConverter() Color? onPrimaryFixed,
    @ColorOrNullConverter() Color? onPrimaryFixedVariant,
    @ColorConverter() required Color secondary,
    @ColorConverter() required Color onSecondary,
    @ColorOrNullConverter() Color? secondaryContainer,
    @ColorOrNullConverter() Color? onSecondaryContainer,
    @ColorOrNullConverter() Color? secondaryFixed,
    @ColorOrNullConverter() Color? secondaryFixedDim,
    @ColorOrNullConverter() Color? onSecondaryFixed,
    @ColorOrNullConverter() Color? onSecondaryFixedVariant,
    @ColorOrNullConverter() Color? tertiary,
    @ColorOrNullConverter() Color? onTertiary,
    @ColorOrNullConverter() Color? tertiaryContainer,
    @ColorOrNullConverter() Color? onTertiaryContainer,
    @ColorOrNullConverter() Color? tertiaryFixed,
    @ColorOrNullConverter() Color? tertiaryFixedDim,
    @ColorOrNullConverter() Color? onTertiaryFixed,
    @ColorOrNullConverter() Color? onTertiaryFixedVariant,
    @ColorConverter() required Color error,
    @ColorConverter() required Color onError,
    @ColorOrNullConverter() Color? errorContainer,
    @ColorOrNullConverter() Color? onErrorContainer,
    @ColorConverter() required Color surface,
    @ColorConverter() required Color onSurface,
    @ColorOrNullConverter() Color? surfaceDim,
    @ColorOrNullConverter() Color? surfaceBright,
    @ColorOrNullConverter() Color? surfaceContainerLowest,
    @ColorOrNullConverter() Color? surfaceContainerLow,
    @ColorOrNullConverter() Color? surfaceContainer,
    @ColorOrNullConverter() Color? surfaceContainerHigh,
    @ColorOrNullConverter() Color? surfaceContainerHighest,
    @ColorOrNullConverter() Color? onSurfaceVariant,
    @ColorOrNullConverter() Color? outline,
    @ColorOrNullConverter() Color? outlineVariant,
    @ColorOrNullConverter() Color? shadow,
    @ColorOrNullConverter() Color? scrim,
    @ColorOrNullConverter() Color? inverseSurface,
    @ColorOrNullConverter() Color? onInverseSurface,
    @ColorOrNullConverter() Color? inversePrimary,
    @ColorOrNullConverter() Color? surfaceTint,
  }) = _CustomScheme;

  ColorScheme toColorScheme() => ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        primaryFixed: primaryFixed,
        primaryFixedDim: primaryFixedDim,
        onPrimaryFixed: onPrimaryFixed,
        onPrimaryFixedVariant: onPrimaryFixedVariant,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        secondaryFixed: secondaryFixed,
        secondaryFixedDim: secondaryFixedDim,
        onSecondaryFixed: onSecondaryFixed,
        onSecondaryFixedVariant: onSecondaryFixedVariant,
        tertiary: tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        tertiaryFixed: tertiaryFixed,
        tertiaryFixedDim: tertiaryFixedDim,
        onTertiaryFixed: onTertiaryFixed,
        onTertiaryFixedVariant: onTertiaryFixedVariant,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
        surface: surface,
        onSurface: onSurface,
        surfaceDim: surfaceDim,
        surfaceBright: surfaceBright,
        surfaceContainerLowest: surfaceContainerLowest,
        surfaceContainerLow: surfaceContainerLow,
        surfaceContainer: surfaceContainer,
        surfaceContainerHigh: surfaceContainerHigh,
        surfaceContainerHighest: surfaceContainerHighest,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
        shadow: shadow,
        scrim: scrim,
        inverseSurface: inverseSurface,
        onInverseSurface: onInverseSurface,
        inversePrimary: inversePrimary,
        surfaceTint: surfaceTint,
      );

  factory CustomScheme.fromColorScheme(ColorScheme colorScheme) => CustomScheme(
        brightness: colorScheme.brightness,
        primary: colorScheme.primary,
        onPrimary: colorScheme.onPrimary,
        primaryContainer: colorScheme.primaryContainer,
        onPrimaryContainer: colorScheme.onPrimaryContainer,
        primaryFixed: colorScheme.primaryFixed,
        primaryFixedDim: colorScheme.primaryFixedDim,
        onPrimaryFixed: colorScheme.onPrimaryFixed,
        onPrimaryFixedVariant: colorScheme.onPrimaryFixedVariant,
        secondary: colorScheme.secondary,
        onSecondary: colorScheme.onSecondary,
        secondaryContainer: colorScheme.secondaryContainer,
        onSecondaryContainer: colorScheme.onSecondaryContainer,
        secondaryFixed: colorScheme.secondaryFixed,
        secondaryFixedDim: colorScheme.secondaryFixedDim,
        onSecondaryFixed: colorScheme.onSecondaryFixed,
        onSecondaryFixedVariant: colorScheme.onSecondaryFixedVariant,
        tertiary: colorScheme.tertiary,
        onTertiary: colorScheme.onTertiary,
        tertiaryContainer: colorScheme.tertiaryContainer,
        onTertiaryContainer: colorScheme.onTertiaryContainer,
        tertiaryFixed: colorScheme.tertiaryFixed,
        tertiaryFixedDim: colorScheme.tertiaryFixedDim,
        onTertiaryFixed: colorScheme.onTertiaryFixed,
        onTertiaryFixedVariant: colorScheme.onTertiaryFixedVariant,
        error: colorScheme.error,
        onError: colorScheme.onError,
        errorContainer: colorScheme.errorContainer,
        onErrorContainer: colorScheme.onErrorContainer,
        surface: colorScheme.surface,
        onSurface: colorScheme.onSurface,
        surfaceDim: colorScheme.surfaceDim,
        surfaceBright: colorScheme.surfaceBright,
        surfaceContainerLowest: colorScheme.surfaceContainerLowest,
        surfaceContainerLow: colorScheme.surfaceContainerLow,
        surfaceContainer: colorScheme.surfaceContainer,
        surfaceContainerHigh: colorScheme.surfaceContainerHigh,
        surfaceContainerHighest: colorScheme.surfaceContainerHighest,
        onSurfaceVariant: colorScheme.onSurfaceVariant,
        outline: colorScheme.outline,
        outlineVariant: colorScheme.outlineVariant,
        shadow: colorScheme.shadow,
        scrim: colorScheme.scrim,
        inverseSurface: colorScheme.inverseSurface,
        onInverseSurface: colorScheme.onInverseSurface,
        inversePrimary: colorScheme.inversePrimary,
        surfaceTint: colorScheme.surfaceTint,
      );

  factory CustomScheme.fromJson(Map<String, dynamic> json) =>
      _$CustomSchemeFromJson(json);
}

class ColorConverter extends JsonConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromJson(int color) => Color(color);

  @override
  int toJson(Color color) {
    return color.colorValue;
  }
}

class ColorOrNullConverter extends JsonConverter<Color?, int?> {
  const ColorOrNullConverter();

  @override
  Color? fromJson(int? color) => color == null ? null : Color(color);

  @override
  int? toJson(Color? color) {
    return color == null ? null : color.colorValue;
  }
}

class ColorSchemeConverter extends JsonConverter<ColorScheme, String> {
  const ColorSchemeConverter();

  @override
  ColorScheme fromJson(String json) {
    final Map<String, dynamic> decodeJson = jsonDecode(json);
    return CustomScheme.fromJson(decodeJson).toColorScheme();
  }

  @override
  String toJson(ColorScheme object) {
    return jsonEncode(CustomScheme.fromColorScheme(object).toJson());
  }
}
