import 'dart:ui';

import 'package:amiibo_network/app/configuration/model/hidden_types.dart';
import 'package:amiibo_network/app/configuration/query_provider.dart';
import 'package:amiibo_network/entity/preferences/model/preferences.dart';
import 'package:amiibo_network/app/configuration/preferences_provider.dart';
import 'package:amiibo_network/app/configuration/stat_ui_remote_config_provider.dart';
import 'package:amiibo_network/shared/utils/preferences_constants.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'preferences_provider.g.dart';

@Riverpod(keepAlive: true)
HiddenType? hiddenCategory(Ref ref) => ref.watch(personalProvider).ignored;

@Riverpod(keepAlive: true)
bool ownTypesCategory(Ref ref) {
  final ownedCategories = ref.watch(remoteOwnedCategoryProvider);
  return ownedCategories &&
      ref.watch(personalProvider.select((value) => value.ownTypes));
}

@Riverpod(keepAlive: true)
Locale? locale(Ref ref) {
  final languageCode = ref.watch(
    personalProvider.select((value) => value.languageCode),
  );
  if (languageCode == null || languageCode.isEmpty) return null;
  return Locale.fromSubtags(languageCode: languageCode);
}

@riverpod
bool canSortCard(Ref ref) {
  final isCardsHidden = ref.watch(
    hiddenCategoryProvider.select((h) => h == .Cards),
  );
  if (isCardsHidden) return false;
  return ref.watch(
    queryProvider.select(
      (value) => value.categoryAttributes.category == .Figures,
    ),
  );
}

@Riverpod(keepAlive: true, name: 'personalProvider')
class UserPreferencesNotifier extends _$UserPreferencesNotifier {
  @override
  Preferences build() {
    final sharedProvider = ref.watch(preferencesProvider);
    final percent = sharedProvider.getBool(sharedStatMode) ?? false;
    final grid = sharedProvider.getBool(sharedGridMode) ?? true;
    final ignored = sharedProvider.getInt(sharedIgnored) ?? 0;
    final languageCode = sharedProvider.getString(sharedLanguageCode);
    final ownType = sharedProvider.getBool(sharedOwnType) ?? false;
    final HiddenType? categoryIgnored = switch (ignored) {
      1 => .Figures,
      2 => .Cards,
      _ => null,
    };
    final inAppBrowser = sharedProvider.getBool(sharedInAppBrowser) ?? false;
    final amazonCountryCode = sharedProvider.getString(
      sharedAmazonCountryCode,
    );

    return Preferences(
      usePercentage: percent,
      useGrid: grid,
      ownTypes: ownType,
      ignored: categoryIgnored,
      languageCode: languageCode,
      inAppBrowser: inAppBrowser,
      amazonCountryCode: amazonCountryCode,
    );
  }

  Preferences get value => state;

  Future<void> forceLocale(String? newLanguageCode) async {
    if (newLanguageCode != state.languageCode) {
      final SharedPreferences preferences = ref.read(preferencesProvider);
      if (newLanguageCode == null) {
        await preferences.remove(sharedLanguageCode);
      } else {
        await preferences.setString(sharedLanguageCode, newLanguageCode);
      }
      state = state.copyWith(languageCode: newLanguageCode);
    }
  }

  Future<void> toggleOwnType(bool newValue) async {
    if (newValue != state.ownTypes) {
      final SharedPreferences preferences = ref.read(preferencesProvider);
      await preferences.setBool(sharedOwnType, newValue);
      state = state.copyWith(ownTypes: newValue);
    }
  }

  Future<void> toggleStat(bool newValue) async {
    if (newValue != state.usePercentage) {
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

  Future<void> updateIgnoredList(HiddenType? category) async {
    if (category != state.ignored) {
      final SharedPreferences preferences = ref.read(preferencesProvider);
      final int value;
      switch (category) {
        case HiddenType.Figures:
          value = 1;
          break;
        case HiddenType.Cards:
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

  Future<void> toogleInAppBrowser(bool newValue) async {
    if (newValue != state.inAppBrowser) {
      final SharedPreferences preferences = ref.read(preferencesProvider);
      await preferences.setBool(sharedInAppBrowser, newValue);
      state = state.copyWith(inAppBrowser: newValue);
    }
  }

  Future<void> changeAmazonCountryCode(String? newValue) async {
    if (newValue != state.amazonCountryCode) {
      final SharedPreferences preferences = ref.read(preferencesProvider);
      if (newValue == null) {
        await preferences.remove(sharedAmazonCountryCode);
      } else {
        await preferences.setString(sharedAmazonCountryCode, newValue);
      }
      state = state.copyWith(amazonCountryCode: newValue);
    }
  }
}
