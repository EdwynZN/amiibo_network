import 'package:amiibo_network/app/configuration/preferences_provider.dart';
import 'package:amiibo_network/shared/utils/preferences_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'lock_provider.g.dart';

@riverpod
class LockNotifier extends _$LockNotifier {
  @override
  bool build() => ref.watch(preferencesProvider).getBool(sharedLock) ?? false;

  Future<void> update(bool newValue) async {
    if (newValue == state) return;
    final SharedPreferences preferences = ref.read(preferencesProvider);
    await preferences.setBool(sharedLock, newValue);
    state = newValue;
  }

  Future<void> toggle() async {
    state = !state;
    final SharedPreferences preferences = ref.read(preferencesProvider);
    await preferences.setBool(sharedLock, state);
  }
}
