import 'package:amiibo_network/model/game.dart';
import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/riverpod.dart';

final _dioProvider = Provider<Dio>((_) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://www.amiiboapi.com/api/',
    ),
  );

  return dio;
});

final characterProvider = StreamProvider.autoDispose.family<String?, int>(
  (ref, key) => ref
      .watch(detailAmiiboProvider(key).stream)
      .map<String?>((cb) => cb?.character)
      .distinct(),
  name: 'Character Provider',
);

final gameProvider =
    FutureProvider.autoDispose.family<NintendoPlatform, int>((ref, key) async {
  final character = await ref.watch(characterProvider(key).last);
  if (character == null) throw ArgumentError();
  final dio = ref.watch(_dioProvider);
  final token = CancelToken();

  ref.onDispose(token.cancel);

  final result = await dio.get<Map<String, dynamic>>(
    'amiibo/?character=$character&showusage',
    cancelToken: token,
  );

  if (result.data == null) throw ArgumentError();
  final single = result.data!['amiibo'].first as Map<String, dynamic>;
  //ref.maintainState = true;
  return NintendoPlatform.fromJson(single);
}, name: 'Games Provider');
