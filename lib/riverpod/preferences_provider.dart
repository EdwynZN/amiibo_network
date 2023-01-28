import 'package:amiibo_network/enum/hidden_types.dart';
import 'package:amiibo_network/model/preferences.dart';
import 'package:amiibo_network/riverpod/repository_provider.dart';
import 'package:amiibo_network/utils/preferences_constants.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final hiddenCategoryProvider = Provider<HiddenTypes?>(
  (ref) => ref.watch(personalProvider).ignored,
  name: 'hiddenCategoriesProvider',
);

final personalProvider =
    StateNotifierProvider<UserPreferencessNotifier, Preferences>(
  (ref) {
    final sharedProvider = ref.watch(preferencesProvider);
    final percent = sharedProvider.getBool(sharedStatMode) ?? false;
    final grid = sharedProvider.getBool(sharedGridMode) ?? true;
    final ignored = sharedProvider.getInt(sharedIgnored) ?? 0;
    final HiddenTypes? categoryIgnored;
    switch (ignored) {
      case 1:
        categoryIgnored = HiddenTypes.Figures;
        break;
      case 2:
        categoryIgnored = HiddenTypes.Cards;
        break;
      default:
        categoryIgnored = null;
        break;
    }
    //final percent = shraedProvider.getBool(sharedIgnored) ?? false;
    final initial = Preferences(
      usePercentage: percent,
      useGrid: grid,
      ignored: categoryIgnored,
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

  Future<void> updateIgnoredList(HiddenTypes? category) async {
    if (category != state.ignored) {
      final SharedPreferences preferences = ref.read(preferencesProvider);
      final int value;
      switch (category) {
        case HiddenTypes.Figures:
          value = 1;
          break;
        case HiddenTypes.Cards:
          value = 2;
          break;
        default:
          value = 0;
          break;
      }
      await preferences.setInt(sharedIgnored, value);
      state = state.copyWith(ignored: category);
    }
  }
}
