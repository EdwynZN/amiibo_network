import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum StatMode{Percentage, Ratio}

Future<bool> getStatMode() async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getBool('StatMode') ?? false;
}

class StatProvider with ChangeNotifier{
  static final RegExp regPercent = RegExp(r"^(\d+(?:\.\d*?[1-9](?=0|\b))?)\.?0*$");
  StatMode preferredStat;
  bool prefStat;

  StatProvider(this.prefStat) : preferredStat = _switchPreferredStat(prefStat);

  spStat(bool value) async {
    if(value != prefStat){
      final SharedPreferences preferences = await SharedPreferences.getInstance();
      prefStat = value;
      await preferences.setBool('StatMode', value);
      preferredStat = _switchPreferredStat(prefStat);
      notifyListeners();
    }
  }

  static StatMode _switchPreferredStat(bool statMode){
    if(statMode) return StatMode.Ratio;
    else return StatMode.Percentage;
  }

  String statLabel(double num, double den){
    if(prefStat){
      if(den == 0) return '0%';
      final double x = num *100 / den;
      return '${regPercent.firstMatch(x.toStringAsFixed(2))[1]}%';
    }
    else return '${num.toInt()}/''${den.toInt()}';
  }
}