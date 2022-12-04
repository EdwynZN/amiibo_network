import 'package:amiibo_network/utils/preferences_constants.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:amiibo_network/riverpod/repository_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final lockProvider = ChangeNotifierProvider<LockNotifier>((ref) => LockNotifier(ref));

class LockNotifier extends ValueNotifier<bool>{
  final Ref ref;

  LockNotifier(this.ref)
    : super((ref.read(preferencesProvider).getBool(sharedLock) ?? false));

  bool get lock => value;

  Future<void> update(bool newValue) async{
    if(newValue == value) return;
    final SharedPreferences preferences = ref.read(preferencesProvider);
    await preferences.setBool(sharedLock, newValue);
    value = newValue;
  }

  Future<void> toggle() async{
    value = !value;
    final SharedPreferences preferences = ref.read(preferencesProvider);
    await preferences.setBool(sharedLock, value);
  }

}