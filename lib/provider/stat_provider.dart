import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/preferences_constants.dart';
import 'package:amiibo_network/service/info_package.dart';

enum StatMode{Percentage, Ratio}

Future<bool> get getStatMode async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getBool(sharedStatMode) ?? false;
}

class StatProvider with ChangeNotifier{
  static final RegExp _regPercent = RegExp(r"^(\d+(?:\.\d*?[1-9](?=0|\b))?)\.?0*$");
  static bool get isFontFeatureEnable => InfoPackage.version >= AndroidCode.Lollipop.version; //Font feature is supported in Android 5 and above
  StatMode _preferredStat;

  StatProvider(bool stat) : _preferredStat = stat ? StatMode.Percentage : StatMode.Ratio;

  StatProvider.fromSharedPreferences(SharedPreferences preferences) :
    _preferredStat = (preferences.getBool(sharedStatMode) ?? false) ? StatMode.Percentage : StatMode.Ratio;

  bool get isPercentage => _preferredStat == StatMode.Percentage;
  StatMode get stat => _preferredStat;

  toggleStat(bool newValue) async {
    if(newValue != isPercentage){
      final SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.setBool(sharedStatMode, newValue);
      _preferredStat = isPercentage ? StatMode.Ratio : StatMode.Percentage;
      notifyListeners();
    }
  }

  String statLabel(double num, double den){
    if(isPercentage){
      if(den == 0 || num == 0) return '0%';
      final double result = num *100 / den;
      return '${_regPercent.firstMatch(result.toStringAsFixed(2))[1]}%';
    }
    return '${num.toInt()}/''${den.toInt()}';
  }
}