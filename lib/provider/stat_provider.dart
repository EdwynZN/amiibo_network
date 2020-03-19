import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum StatMode{Percentage, Ratio}

Future<bool> getStatMode() async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getBool('StatMode') ?? false;
}

class StatProvider with ChangeNotifier{
  static final RegExp regPercent = RegExp(r"^(\d+(?:\.\d*?[1-9](?=0|\b))?)\.?0*$");
  StatMode _preferredStat;

  StatProvider(bool stat) : _preferredStat = stat ? StatMode.Ratio : StatMode.Percentage;

  bool get isPercentage => _preferredStat == StatMode.Percentage;
  StatMode get stat => _preferredStat;

  toggleStat(bool newValue) async {
    if(newValue != isPercentage){
      final SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.setBool('StatMode', newValue);
      _preferredStat = isPercentage ? StatMode.Ratio : StatMode.Percentage;
      notifyListeners();
    }
  }

  String statLabel(double num, double den){
    if(isPercentage){
      if(den == 0) return '0%';
      final double x = num *100 / den;
      return '${regPercent.firstMatch(x.toStringAsFixed(2))[1]}%';
    }
    else return '${num.toInt()}/''${den.toInt()}';
  }
}