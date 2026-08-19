import 'package:amiibo_network/app/configuration/model/search_result.dart';
import 'package:amiibo_network/app/configuration/query_provider.dart';
import 'package:amiibo_network/app/configuration/service_provider.dart';
import 'package:amiibo_network/app/state/preferences_provider.dart';
import 'package:amiibo_network/app/state/theme/theme_provider.dart';
import 'package:amiibo_network/shared/generated/l10n.dart';
import 'package:amiibo_network/shared/service/notification_service.dart';
import 'package:amiibo_network/shared/service/screenshot.dart';
import 'package:amiibo_network/shared/service/storage.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'screenshot_service.g.dart';

@riverpod
Screenshot _screenshotService(Ref ref) => Screenshot();

@Riverpod(keepAlive: true)
class ScreenshotNotifier extends _$ScreenshotNotifier {
  late Screenshot _screenshot;
  late ThemeModeNotifier _themeMode;
  late UserPreferencessNotifier _localPreferences;

  @override
  Future<bool> build() async {
    ref.watch(queryProvider.notifier);
    _localPreferences = ref.watch(personalProvider.notifier);
    _themeMode = ref.watch(themeModeProvider.notifier);
    _screenshot = ref.watch(_screenshotServiceProvider);

    return true;
  }

  Future<void> saveStats(
    BuildContext context, {
    Search? search,
    bool useHidden = true,
  }) async {
    if (isLoading) return;
    final S translate = S.current;
    _screenshot.customData(
      _themeMode.preferredMode,
      context,
      _localPreferences.value,
      ref.read(serviceProvider),
      ref.read(ownTypesCategoryProvider),
    );
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final Search query = search ?? ref.read(queryProvider);
      final hiddenTypeProvider = useHidden
          ? ref.read(hiddenCategoryProvider)
          : null;
      final category = query.categoryAttributes.category;
      final buffer = await _screenshot.saveStats(
        search: query,
        hiddenType: hiddenTypeProvider,
      );
      if (buffer != null) {
        String name;
        int id;
        switch (category) {
          case .Cards:
            name = 'MyCardStats';
            id = 2;
            break;
          case .Figures:
            name = 'MyFigureStats';
            id = 3;
            break;
          case .AmiiboSeries:
            name = 'MyCustomStats';
            id = 7;
            break;
          case .All:
          default:
            name = 'MyAmiiboStats';
            id = 1;
            break;
        }
        final Map<String, dynamic> notificationArgs = <String, dynamic>{
          'title': translate.notificationTitle,
          'actionTitle': translate.actionText,
          'id': id,
          'buffer': buffer,
          'name': '${name}_$dateTaken',
        };
        return await NotificationService.saveImage(notificationArgs);
      }
      return false;
    });
  }

  Future<void> saveAmiibos(
    BuildContext context, {
    Search? search,
    bool useHidden = true,
  }) async {
    if (isLoading) {
      return;
    }
    final S translate = S.current;
    _screenshot.customData(
      _themeMode.preferredMode,
      context,
      _localPreferences.value,
      ref.read(serviceProvider),
      ref.read(ownTypesCategoryProvider),
    );
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final Search query = search ?? ref.read(queryProvider);
      final hiddenTypeProvider = useHidden
          ? ref.read(hiddenCategoryProvider)
          : null;
      final category = query.categoryAttributes.category;
      String name;
      int id;
      switch (category) {
        case .Cards:
          name = 'MyCardCollection';
          id = 4;
          break;
        case .Figures:
          name = 'MyFigureCollection';
          id = 5;
          break;
        case .AmiiboSeries:
          name = 'MyCustomCollection';
          id = 8;
          break;
        case .All:
        default:
          name = 'MyAmiiboCollection';
          id = 9;
          break;
      }
      final buffer = await _screenshot.saveCollection(
        query,
        hiddenTypeProvider,
      );
      if (buffer != null) {
        final Map<String, dynamic> notificationArgs = <String, dynamic>{
          'title': translate.notificationTitle,
          'actionTitle': translate.actionText,
          'id': id,
          'buffer': buffer,
          'name': '${name}_$dateTaken',
        };
        await NotificationService.saveImage(notificationArgs);
      }
      return false;
    });
  }

  bool get isLoading => _screenshot.isRecording || state.isLoading;
}
