import 'dart:async';

import 'package:amiibo_network/app/configuration/model/search_result.dart';
import 'package:amiibo_network/app/configuration/query_provider.dart';
import 'package:amiibo_network/app/configuration/service_provider.dart';
import 'package:amiibo_network/entity/amiibo_info/model/amiibo.dart';
import 'package:amiibo_network/entity/amiibo_info/model/stat.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'amiibo_provider.g.dart';

@riverpod
int keyAmiibo(Ref ref) => throw UnimplementedError();

@riverpod
AsyncValue<Stat> statHome(Ref ref) =>
    ref.watch(amiiboHomeListProvider).whenData((value) {
      final total = value.length;
      final owned = value
          .where((e) => e.userAttributes is OwnedUserAttributes)
          .length;
      final wished = value
          .where((e) => e.userAttributes is WishedUserAttributes)
          .length;
      return Stat(total: total, owned: owned, wished: wished);
    });

@riverpod
Stream<Amiibo?> detailAmiibo(Ref ref, int key) async* {
  final service = ref.watch(serviceProvider);
  final streamController = StreamController<int>();

  void listen() => streamController.sink.add(key);

  service.addListener(listen);

  ref.onDispose(() {
    service.removeListener(listen);
    streamController.close();
  });

  yield await service.fetchOne(key);
  yield* streamController.stream.asyncMap(service.fetchOne);
}

@riverpod
Stream<List<Amiibo>> amiiboHomeList(Ref ref) async* {
  final service = ref.watch(serviceProvider);
  final streamController = StreamController<Filter>();

  void listen() => streamController.sink.add(ref.read(filterProvider));

  service.addListener(listen);

  final subscription = ref.listen(filterProvider, (previous, next) {
    if (next != previous) {
      streamController.sink.add(next);
    }
  }, fireImmediately: true);

  ref.onDispose(() {
    subscription.close();
    service.removeListener(listen);
    streamController.close();
  });

  yield* streamController.stream.asyncMap(
    (cb) => service.fetchByCategory(
      categoryAttributes: cb.categoryAttributes,
      sortBy: cb.sortBy,
      orderBy: cb.orderBy,
      hiddenCategories: cb.hiddenType,
      searchAttributes: cb.searchAttributes,
    ),
  );
}
