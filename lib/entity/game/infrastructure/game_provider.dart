import 'package:amiibo_network/entity/amiibo_info/infrastructure/amiibo_provider.dart';
import 'package:amiibo_network/entity/amiibo_info/model/amiibo.dart';
import 'package:amiibo_network/entity/game/model/game.dart';
import 'package:amiibo_network/shared/utils/urls_constants.dart' show apiUrl;
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash/stash_api.dart';
import 'package:stash_dio/stash_dio.dart';

part 'game_provider.g.dart';

@Riverpod(keepAlive: true)
Cache cache(Ref ref) => throw UnimplementedError();

@Riverpod(keepAlive: true)
Dio _dio(Ref ref) {
  final hiveCache = ref.watch(cacheProvider);
  final stashOptions = hiveCache.interceptor('amiibo');

  final dio = Dio(
    BaseOptions(baseUrl: apiUrl, connectTimeout: const Duration(seconds: 5)),
  );

  return dio..interceptors.add(stashOptions);
}

@riverpod
AmiiboDetails? _character(Ref ref, int key) {
  return ref
      .watch(detailAmiiboProvider(key))
      .maybeWhen(data: (cb) => cb?.details, orElse: () => null);
}

@riverpod
Future<NintendoPlatform> game(Ref ref, int key) async {
  final amiibo = await ref.watch(_characterProvider(key));
  if (amiibo == null) return const NintendoPlatform();
  final dio = ref.watch(_dioProvider);
  final token = CancelToken();

  ref.onDispose(token.cancel);
  final String query;

  if (amiibo.id != null) {
    final String head = amiibo.id!.substring(0, 8);
    final String tail = amiibo.id!.substring(8);
    query = 'head=$head&tail=$tail';
  } else {
    query = 'character=${amiibo.character}';
  }

  final Response<Map<String, dynamic>> result = await dio
      .get<Map<String, dynamic>>(
        'amiibo/?$query&showusage',
        cancelToken: token,
      );

  if (result.data == null) throw ArgumentError();
  final data = result.data!['amiibo'];
  if (data is! List<dynamic> || data.isEmpty) throw ArgumentError();
  final single = data.first as Map<String, dynamic>;
  final NintendoPlatform platform = NintendoPlatform.fromJson(single);
  ref.keepAlive();
  return platform;
}
