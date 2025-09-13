import 'package:amiibo_network/enum/amiibo_category_enum.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/model/search_result.dart';
import 'package:amiibo_network/riverpod/preferences_provider.dart';
import 'package:amiibo_network/riverpod/query_provider.dart';
import 'package:amiibo_network/riverpod/service_provider.dart';
import 'package:amiibo_network/riverpod/theme_provider.dart';
import 'package:amiibo_network/service/notification_service.dart';
import 'package:amiibo_network/service/screenshot.dart';
import 'package:amiibo_network/service/storage.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';

final _screenshotServiceProvider = Provider((ref) => Screenshot());

final screenshotProvider =
    StateNotifierProvider<ScreenshotNotifier, AsyncValue<bool>>(
  (ref) {
    ref.watch(queryProvider.notifier);
    final localPreferences = ref.watch(personalProvider.notifier);
    final themeNotifier = ref.watch(themeProvider.notifier);
    final screenshotService = ref.watch(_screenshotServiceProvider);
    return ScreenshotNotifier(
      ref: ref,
      localPreferences: localPreferences,
      themeProvider: themeNotifier,
      screenshot: screenshotService,
    );
  },
);

class ScreenshotNotifier extends StateNotifier<AsyncValue<bool>> {
  final Screenshot _screenshot;
  final NotificationService notificationService = NotificationService();
  final ThemeProvider themeProvider;
  final UserPreferencessNotifier localPreferences;
  final Ref ref;

  ScreenshotNotifier({
    required this.ref,
    required this.localPreferences,
    required this.themeProvider,
    required Screenshot screenshot,
  })  : _screenshot = screenshot,
        super(const AsyncData(true));

  Future<void> saveStats(
    BuildContext context, {
    Search? search,
    bool useHidden = true,
  }) async {
    if (isLoading) {
      return;
    }
    final S translate = S.current;
    _screenshot.customData(
      themeProvider.preferredMode,
      context,
      localPreferences.state,
      ref.read(serviceProvider),
      ref.read(ownTypesCategoryProvider),
    );
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final Search query = search ?? ref.read(queryProvider);
      final hiddenTypeProvider =
          useHidden ? ref.read(hiddenCategoryProvider) : null;
      final category = query.categoryAttributes.category;
      final buffer = await _screenshot.saveStats(
        search: query,
        hiddenType: hiddenTypeProvider,
      );
      if (buffer != null) {
        String name;
        int id;
        switch (category) {
          case AmiiboCategory.Cards:
            name = 'MyCardStats';
            id = 2;
            break;
          case AmiiboCategory.Figures:
            name = 'MyFigureStats';
            id = 3;
            break;
          case AmiiboCategory.AmiiboSeries:
            name = 'MyCustomStats';
            id = 7;
            break;
          case AmiiboCategory.All:
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
          'name': '${name}_$dateTaken'
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
      themeProvider.preferredMode,
      context,
      localPreferences.state,
      ref.read(serviceProvider),
      ref.read(ownTypesCategoryProvider),
    );
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final Search query = search ?? ref.read(queryProvider);
      final hiddenTypeProvider =
          useHidden ? ref.read(hiddenCategoryProvider) : null;
      final category = query.categoryAttributes.category;
      String name;
      int id;
      switch (category) {
        case AmiiboCategory.Cards:
          name = 'MyCardCollection';
          id = 4;
          break;
        case AmiiboCategory.Figures:
          name = 'MyFigureCollection';
          id = 5;
          break;
        case AmiiboCategory.AmiiboSeries:
          name = 'MyCustomCollection';
          id = 8;
          break;
        case AmiiboCategory.All:
        default:
          name = 'MyAmiiboCollection';
          id = 9;
          break;
      }
      final buffer =
          await _screenshot.saveCollection(query, hiddenTypeProvider);
      if (buffer != null) {
        final Map<String, dynamic> notificationArgs = <String, dynamic>{
          'title': translate.notificationTitle,
          'actionTitle': translate.actionText,
          'id': id,
          'buffer': buffer,
          'name': '${name}_$dateTaken'
        };
        await NotificationService.saveImage(notificationArgs);
      }
      return false;
    });
  }

  bool get isLoading =>
      _screenshot.isRecording || state is AsyncLoading<AsyncValue<bool>>;
}
