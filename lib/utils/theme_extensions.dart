import 'package:amiibo_network/resources/theme_material3_schemes.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class PreferencesExtension extends ThemeExtension<PreferencesExtension>
    with EquatableMixin {
  final TonalColor ownPalette;
  final TonalColor wishPalette;
  final Brightness brightness;

  const PreferencesExtension._({
    required this.ownPalette,
    required this.wishPalette,
    required this.brightness,
  });

  factory PreferencesExtension.brigthness(Brightness brightness) {
    const ownPalette = const TonalColor(
      0xFF2E7D32,
      <int, Color>{
        0: Colors.black,
        10: Color(0XFF002203),
        20: Color(0XFF003909),
        30: Color(0XFF085314),
        40: Color(0XFF286C2A),
        50: Color(0XFF428541),
        60: Color(0XFF5BA058),
        70: Color(0XFF75BC70),
        80: Color(0XFF90D899),
        90: Color(0XFFABF5A3),
        95: Color(0XFFC8FFBF),
        98: Color(0xFFEcFFE4),
        99: Color(0xFFF6FFF0),
        100: Colors.white,
      },
    );
    const wishPalette = const TonalColor(
      0xFF8F4E00,
      <int, Color>{
        0: Colors.black,
        10: Color(0XFF1E1D00),
        20: Color(0XFF343200),
        30: Color(0XFF4B4900),
        40: Color(0XFF646100),
        50: Color(0XFF7E7A00),
        60: Color(0XFF999500),
        70: Color(0XFFB5B000),
        80: Color(0XFFD1CC1F),
        90: Color(0XFFEEE83F),
        95: Color(0XFFFDF74D),
        98: Color(0xFFFFFBF5),
        99: Color(0xFFFFFBFF),
        100: Colors.white,
      },
    );
    return PreferencesExtension._(
      ownPalette: ownPalette,
      wishPalette: wishPalette,
      brightness: brightness,
    );
  }

  bool get _isDark => brightness == Brightness.dark;

  Color get ownPrimary => _isDark ? ownPalette.shade80 : ownPalette.shade40;
  Color get onOwnPrimary => _isDark ? ownPalette.shade20 : ownPalette.shade100;
  Color get ownContainer => _isDark ? ownPalette.shade30 : ownPalette.shade90;
  Color get onOwnContainer => _isDark ? ownPalette.shade90 : ownPalette.shade10;

  Color get wishPrimary => _isDark ? wishPalette.shade80 : wishPalette.shade40;
  Color get onWishPrimary => _isDark ? wishPalette.shade20 : wishPalette.shade100;
  Color get wishContainer => _isDark ? wishPalette.shade30 : wishPalette.shade90;
  Color get onWishContainer => _isDark ? wishPalette.shade90 : wishPalette.shade10;

  @override
  ThemeExtension<PreferencesExtension> copyWith({
    TonalColor? ownPalette,
    TonalColor? wishPalette,
    Brightness? brightness,
  }) {
    return PreferencesExtension._(
      ownPalette: ownPalette ?? this.ownPalette,
      wishPalette: wishPalette ?? this.wishPalette,
      brightness: brightness ?? this.brightness,
    );
  }

  @override
  ThemeExtension<PreferencesExtension> lerp(
    covariant ThemeExtension<PreferencesExtension>? other,
    double t,
  ) {
    if (other is! PreferencesExtension) {
      return this;
    }
    return PreferencesExtension._(
      ownPalette: TonalColor.lerp(this.ownPalette, other.ownPalette, t)!,
      wishPalette: TonalColor.lerp(this.wishPalette, other.wishPalette, t)!,
      brightness: t < 0.5 ? brightness : other.brightness,
    );
  }

  @override
  final bool stringify = true;

  @override
  List<Object?> get props => [ownPalette];
}

/// Possible use in Future
/* @immutable
class TonalExtension extends ThemeExtension<TonalExtension> with EquatableMixin {
  final TonalColor tonalPalette;

  TonalExtension({required this.tonalPalette});
  
  @override
  ThemeExtension<TonalExtension> copyWith({TonalColor? tonalPalette}) {
    return TonalExtension(tonalPalette: tonalPalette ?? this.tonalPalette);
  }
  
  @override
  ThemeExtension<TonalExtension> lerp(
    covariant ThemeExtension<TonalExtension>? other,
    double t,
  ) {
    if (other is! TonalExtension) {
      return this;
    }
    return TonalExtension(
      tonalPalette: TonalColor.lerp(this.tonalPalette, other.tonalPalette, t)!,
    );
  }
  
  @override
  final bool stringify = true;

  @override
  List<Object?> get props => [tonalPalette];
} */