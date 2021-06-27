import 'package:amiibo_network/model/amiibo.dart';
import 'package:amiibo_network/model/game.dart';
import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/riverpod.dart';

const apiUrl = 'https://www.amiiboapi.com/api/';

final _dioProvider = Provider<Dio>((_) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiUrl,
      connectTimeout: 5000,
    ),
  );

  return dio;
});

final _characterProvider = StreamProvider.autoDispose.family<Amiibo?, int>(
  (ref, key) => ref
      .watch(detailAmiiboProvider(key).stream)
      .map<Amiibo?>((cb) => cb?.copyWith(owned: false, wishlist: false))
      .distinct(),
  name: 'Character Provider',
);

final gameProvider =
    FutureProvider.autoDispose.family<NintendoPlatform, int>((ref, key) async {
  final amiibo = await ref.watch(_characterProvider(key).last);
  if (amiibo == null) throw ArgumentError();
  final dio = ref.watch(_dioProvider);
  final token = CancelToken();

  ref.onDispose(token.cancel);
  late final Response<Map<String, dynamic>> result;

  if (amiibo.id != null) {
    final String head = amiibo.id!.substring(0, 8);
    final String tail = amiibo.id!.substring(8);

    result = await dio.get<Map<String, dynamic>>(
      'amiibo/?head=$head&tail=$tail&showusage',
      cancelToken: token,
    );
  } else
    result = await dio.get<Map<String, dynamic>>(
      'amiibo/?character=${amiibo.character}&showusage',
      cancelToken: token,
    );

  if (result.data == null) throw ArgumentError();
  final data = result.data!['amiibo'];
  if (data is! List<dynamic> || data.length > 1) throw ArgumentError();
  final single = data.first as Map<String, dynamic>;
  final NintendoPlatform platform = NintendoPlatform.fromJson(single);
  ref.maintainState = true;
  return platform;
}, name: 'Games Provider');
