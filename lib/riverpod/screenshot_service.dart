import 'package:amiibo_network/enum/amiibo_category_enum.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/riverpod/preferences_provider.dart';
import 'package:amiibo_network/riverpod/query_provider.dart';
import 'package:amiibo_network/riverpod/theme_provider.dart';
import 'package:amiibo_network/service/notification_service.dart';
import 'package:amiibo_network/service/screenshot.dart';
import 'package:amiibo_network/service/storage.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final screenshotProvider =
    StateNotifierProvider<ScreenshotNotifier, AsyncValue<bool>>(
  (ref) {
    final localPreferences = ref.watch(personalProvider.notifier);
    final queryNotifier = ref.watch(queryProvider.notifier);
    final themeNotifier = ref.watch(themeProvider.notifier);
    return ScreenshotNotifier(
      queryProvider: queryNotifier,
      localPreferences: localPreferences,
      themeProvider: themeNotifier,
    );
  },
);

class ScreenshotNotifier extends StateNotifier<AsyncValue<bool>> {
  final Screenshot _screenshot = Screenshot();
  final NotificationService notificationService = NotificationService();
  final QueryBuilderProvider queryProvider;
  final ThemeProvider themeProvider;
  final UserPreferencessNotifier localPreferences;

  ScreenshotNotifier({
    required this.queryProvider,
    required this.localPreferences,
    required this.themeProvider,
  }) : super(const AsyncData(true));

  Future<void> saveStats(BuildContext context) async {
    if (isLoading) {
      return;
    }
    final S translate = S.current;
    _screenshot.customData(themeProvider.preferredTheme, context, localPreferences.state);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final category = queryProvider.search.category;
      final query = queryProvider.query;
      final buffer = await _screenshot.saveStats(query.where);
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
          case AmiiboCategory.Custom:
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

  Future<void> saveAmiibos(BuildContext context) async {
    if (isLoading) {
      return;
    }
    final S translate = S.current;
    _screenshot.customData(themeProvider.preferredTheme, context, localPreferences.state);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final category = queryProvider.search.category;
      final expression = queryProvider.query.where;
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
        case AmiiboCategory.Custom:
          name = 'MyCustomCollection';
          id = 8;
          break;
        case AmiiboCategory.All:
        default:
          name = 'MyAmiiboCollection';
          id = 9;
          break;
      }
      final buffer = await _screenshot.saveCollection(expression);
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
