import 'dart:async';
import 'package:amiibo_network/model/search_result.dart';
import 'package:amiibo_network/model/stat.dart';
import 'package:amiibo_network/riverpod/service_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:amiibo_network/riverpod/query_provider.dart';
import 'package:amiibo_network/model/amiibo.dart';

final keyAmiiboProvider = ScopedProvider<int>(null);

final indexAmiiboProvider =
    ScopedProvider<int>((_) => throw UnsupportedError('No amiibo id selected'));

final statHomeProvider = Provider.autoDispose<AsyncValue<Stat>>(
    (ref) => ref.watch(amiiboHomeListProvider).whenData((value) {
          final total = value.length;
          final owned = value.where((e) => e.owned).length;
          final wished = value.where((e) => e.wishlist).length;
          return Stat(total: total, owned: owned, wished: wished);
        }),
    name: 'Home Stats');

final detailAmiiboProvider =
    StreamProvider.autoDispose.family<Amiibo?, int>((ref, key) async* {
  final service = ref.watch(serviceProvider.notifier);
  final streamController = StreamController<int>();

  void listen() {
    streamController.sink.add(key);
  }

  service.addListener(listen);

  ref.onDispose(() {
    service.removeListener(listen);
    streamController.close();
  });

  yield await service.fetchAmiiboDBByKey(key);
  yield* streamController.stream.asyncMap(service.fetchAmiiboDBByKey);
}, name: 'Single Amiibo Details Provider');

final amiiboHomeListProvider =
    StreamProvider.autoDispose<List<Amiibo>>((ref) async* {
  final service = ref.watch(serviceProvider.notifier);
  final queryBuilder = ref.watch(queryProvider.notifier);
  final streamController = StreamController<QueryBuilder>();
  final subscription = queryBuilder.stream.listen(streamController.sink.add);

  void listen() {
    streamController.sink.add(queryBuilder.query);
  }

  service.addListener(listen);

  ref.onDispose(() {
    subscription.cancel();
    service.removeListener(listen);
    streamController.close();
  });

  yield await service.fetchByCategory(queryBuilder.query);
  yield* streamController.stream.asyncMap(service.fetchByCategory);
});
