import 'package:amiibo_network/model/preferences.dart';
import 'package:amiibo_network/riverpod/repository_provider.dart';
import 'package:amiibo_network/utils/preferences_constants.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final personalProvider =
    StateNotifierProvider<UserPreferencessNotifier, Preferences>(
  (ref) {
    final shraedProvider = ref.watch(preferencesProvider);
    final percent = shraedProvider.getBool(sharedStatMode) ?? false;
    final grid = shraedProvider.getBool(sharedGridMode) ?? true;
    //final percent = shraedProvider.getBool(sharedIgnored) ?? false;
    final initial = Preferences(
      usePercentage: percent,
      useGrid: grid,
      ignored: [],
    );
    return UserPreferencessNotifier(initial, ref);
  },
  name: 'PreferencesProvider',
);

class UserPreferencessNotifier extends StateNotifier<Preferences> {
  final Ref ref;
  
  UserPreferencessNotifier(super._state, this.ref);

  bool get isPercentage => state.usePercentage;

  Future<void> toggleStat(bool newValue) async {
    if (newValue != isPercentage) {
      final SharedPreferences preferences = ref.read(preferencesProvider);
      await preferences.setBool(sharedStatMode, newValue);
      state = state.copyWith(usePercentage: newValue);
    }
  }

  Future<void> toggleVisualList(bool newValue) async {
    if (newValue != state.useGrid) {
      final SharedPreferences preferences = ref.read(preferencesProvider);
      await preferences.setBool(sharedGridMode, newValue);
      state = state.copyWith(useGrid: newValue);
    }
  }

  Future<void> updateIgnoredList(bool newValue) async {
    if (newValue != isPercentage) {
      final SharedPreferences preferences = ref.read(preferencesProvider);
      await preferences.setBool(sharedStatMode, newValue);
      state = state.copyWith(usePercentage: newValue);
    }
  }
}