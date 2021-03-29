import 'dart:async';

import 'package:amiibo_network/model/search_result.dart';
import 'package:amiibo_network/model/stat.dart';
import 'package:amiibo_network/service/service.dart';
import 'package:riverpod/riverpod.dart';
import 'package:amiibo_network/riverpod/query_provider.dart';
import 'package:amiibo_network/riverpod/repository_provider.dart';
import 'package:amiibo_network/model/amiibo.dart';

final indexAmiiboProvider = ScopedProvider<int>(null);

final statHomeProvider = StreamProvider.autoDispose<Stat>((ref) async* {
  final control = ref.watch(controlProvider);
  final streamController = StreamController<Stat>();

  final removeListener = control.addListener((state) {
    state.whenData((value) {
      final total = value.length.toDouble();
      final owned = value.where((e) => e.owned).toList().length.toDouble();
      final wished = value.where((e) => e.wishlist).toList().length.toDouble();
      streamController.sink
          .add(Stat(total: total, owned: owned, wished: wished));
    });
  });

  ref.onDispose(() {
    removeListener();
    streamController.close();
  });
  yield* streamController.stream;
});

final singleAmiiboProvider =
    Provider.autoDispose.family<AsyncValue<Amiibo>, int>((ref, index) {
  return ref
      .watch(controlProvider.state)
      .whenData((value) => value?.firstWhere((cb) => cb.key == index));
});

final detailAmiiboProvider =
    Provider.autoDispose.family<AsyncValue<Amiibo>, int>((ref, index) {
  return ref
      .watch(controlProvider.state)
      .whenData((value) => value?.firstWhere((cb) => cb.key == index));
});

final controlProvider =
    StateNotifierProvider.autoDispose<AmiiboProvider>((ref) {
  final service = ref.watch(serviceProvider);
  final query = ref.watch(expressionProvider);
  final provider = AmiiboProvider(service);

  final removeListener = query.addListener(provider.update);

  ref.onDispose(() {
    removeListener();
  });

  return provider;
});

class AmiiboProvider extends StateNotifier<AsyncValue<List<Amiibo>>> {
  QueryBuilder _queryBuilder;
  final Service _service;

  AmiiboProvider(this._service) : super(AsyncLoading());

  Expression get where => _queryBuilder.where;

  Future<void> update([QueryBuilder query]) async {
    if (query != null) _queryBuilder = query;
    state = await AsyncValue.guard(() => _service.fetchByCategory(
        expression: _queryBuilder.where, orderBy: _queryBuilder.order));
  }

  Future<void> updateAmiiboDB({Amiibo amiibo, List<Amiibo> amiibos}) async {
    amiibos ??= [amiibo];
    await _service.update(amiibos);
    await update();
  }

  Future<void> shift(int key) async {
    final amiibo = state.data.value.firstWhere((element) => element.key == key);
    final amiiboUpdated = amiibo.copyWith(
      wishlist: amiibo.owned,
      owned: !(amiibo.wishlist ^ amiibo.owned),
    );
    updateAmiiboDB(amiibo: amiiboUpdated);
  }

  Future<void> resetCollection() async {
    await _service.resetCollection();
    await update();
  }
}
