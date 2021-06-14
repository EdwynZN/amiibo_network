import 'dart:async';
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
    StreamProvider.autoDispose.family<Amiibo?, int>((ref, key) {
  final service = ref.watch(serviceProvider.notifier);
  final streamController = StreamController<int>()..sink.add(key);

  void listen() {
    streamController.sink.add(key);
  }

  service.addListener(listen);

  ref.onDispose(() {
    service.removeListener(listen);
    streamController.close();
  });

  return streamController.stream.asyncMap(service.fetchAmiiboDBByKey);
});

final amiiboHomeListProvider =
    StreamProvider.autoDispose<List<Amiibo>>((ref) async* {
  final service = ref.watch(serviceProvider.notifier);
  final query = ref.watch(queryProvider.notifier);

  yield await service.fetchByCategory(expression: query.state.where, orderBy: query.state.order);
  yield* query.stream.asyncMap((query) =>
      service.fetchByCategory(expression: query.where, orderBy: query.order));
});
