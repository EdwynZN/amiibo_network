import 'package:amiibo_network/utils/preferences_constants.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:amiibo_network/riverpod/repository_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final lockProvider = ChangeNotifierProvider<LockNotifier>((ref) => LockNotifier(ref.read));

class LockNotifier extends ValueNotifier<bool>{
  final Reader _read;

  LockNotifier(this._read)
    : super((_read(preferencesProvider).getBool(sharedLock) ?? false));

  bool get lock => value;

  Future<void> update(bool newValue) async{
    if(newValue == value) return;
    final SharedPreferences preferences = _read(preferencesProvider);
    await preferences.setBool(sharedLock, newValue);
    value = newValue;
  }

  Future<void> toggle() async{
    value = !value;
    final SharedPreferences preferences = _read(preferencesProvider);
    await preferences.setBool(sharedLock, value);
  }

}