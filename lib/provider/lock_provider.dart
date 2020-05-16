import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/preferences_constants.dart';

Future<bool> get getLock async{
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getBool(sharedLock) ?? false;
}

class LockProvider extends ChangeNotifier{
  bool _lock;

  LockProvider(this._lock);

  LockProvider.fromSharedPreferences(SharedPreferences preferences)
    : _lock = preferences.getBool(sharedLock) ?? false;

  bool get lock => _lock;

  Future<void> update(bool newValue) async{
    if(newValue == _lock) return;
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    _lock = newValue;
    await preferences.setBool(sharedLock, _lock);
    notifyListeners();
  }


}