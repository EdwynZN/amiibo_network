import 'package:amiibo_network/service/info_package.dart';
import 'package:amiibo_network/utils/preferences_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amiibo_network/enum/stat_enum.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amiibo_network/riverpod/repository_provider.dart';

bool get isFontFeatureEnable => InfoPackage.version >= AndroidCode.Lollipop.version; //Font feature is supported in Android 5 and above

final statProvider = ChangeNotifierProvider<StatProvider>((ref) => StatProvider(ref.read));

class StatProvider extends ValueNotifier<StatMode> {
  static final RegExp _regPercent =
      RegExp(r"^(\d+(?:\.\d*?[1-9](?=0|\b))?)\.?0*$");
  final Reader _read;

  StatProvider(this._read)
      : super((_read(preferencesProvider).getBool(sharedStatMode) ?? false)
            ? StatMode.Percentage
            : StatMode.Ratio);

  bool get isPercentage => value == StatMode.Percentage;

  Future<void> toggleStat(bool? newValue) async {
    if (newValue != isPercentage) {
      final SharedPreferences preferences = _read(preferencesProvider);
      await preferences.setBool(sharedStatMode, newValue!);
      value = isPercentage ? StatMode.Ratio : StatMode.Percentage;
    }
  }

  String statLabel(double? num, double? den) {
    if (isPercentage) {
      if (den == 0 || num == 0) return '0%';
      final double result = num! * 100 / den!;
      return '${_regPercent.firstMatch(result.toStringAsFixed(2))![1]}%';
    }
    return '${num!.toInt()}/' '${den!.toInt()}';
  }
}
