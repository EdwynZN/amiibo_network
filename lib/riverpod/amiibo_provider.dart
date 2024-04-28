import 'dart:async';
import 'package:amiibo_network/model/search_result.dart';
import 'package:amiibo_network/model/stat.dart';
import 'package:amiibo_network/riverpod/service_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:amiibo_network/riverpod/query_provider.dart';
import 'package:amiibo_network/model/amiibo.dart';

final keyAmiiboProvider = Provider<int>((_) => throw UnimplementedError());

final indexAmiiboProvider =
    Provider<int>((_) => throw UnsupportedError('No amiibo id selected'));

final statHomeProvider = Provider.autoDispose<AsyncValue<Stat>>(
    (ref) => ref.watch(amiiboHomeListProvider).whenData((value) {
          final total = value.length;
          final owned = value
              .where((e) => e.userAttributes is OwnedUserAttributes)
              .length;
          final wished = value
              .where((e) => e.userAttributes is WishedUserAttributes)
              .length;
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

  yield await service.fetchOne(key);
  yield* streamController.stream.asyncMap(service.fetchOne);
}, name: 'Single Amiibo Details Provider');

final amiiboHomeListProvider =
    StreamProvider.autoDispose<List<Amiibo>>((ref) async* {
  final service = ref.watch(serviceProvider.notifier);
  final streamController = StreamController<Filter>();

  void listen() {
    streamController.sink.add(ref.read(filterProvider));
  }

  service.addListener(listen);

  final subscription = ref.listen(
    filterProvider,
    (previous, next) {
      if (next != previous) {
        streamController.sink.add(next);
      }
    },
    fireImmediately: true,
  );

  ref.onDispose(() {
    subscription.close();
    service.removeListener(listen);
    streamController.close();
  });
  /* 
  yield await service.fetchByCategory(
    queryBuilder.query,
    queryBuilder.query.order,
  ); */
  yield* streamController.stream.asyncMap((cb) => service.fetchByCategory(
        categoryAttributes: cb.categoryAttributes,
        sortBy: cb.sortBy,
        orderBy: cb.orderBy,
        cards: cb.customCards,
        figures: cb.customFigures,
        hiddenCategories: cb.hiddenType,
        searchAttributes: cb.searchAttributes,
      ));
});
