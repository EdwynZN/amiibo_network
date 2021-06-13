import 'dart:async';
import 'package:amiibo_network/model/search_result.dart';
import 'package:amiibo_network/model/stat.dart';
import 'package:amiibo_network/riverpod/service_provider.dart';
import 'package:amiibo_network/service/service.dart';
import 'package:riverpod/riverpod.dart';
import 'package:amiibo_network/riverpod/query_provider.dart';
import 'package:amiibo_network/model/amiibo.dart';

final keyAmiiboProvider = ScopedProvider<int>(null);

final indexAmiiboProvider = ScopedProvider<int>((_) => throw UnsupportedError('No amiibo id selected'));

final statHomeProvider = StreamProvider.autoDispose<Stat>((ref) {
  final control = ref.watch(controlProvider.notifier);
  final streamController = StreamController<Stat>();

  final removeListener = control.addListener((state) {
    state.whenData((value) {
      final total = value.length;
      final owned = value.where((e) => e.owned).toList().length;
      final wished = value.where((e) => e.wishlist).toList().length;
      streamController.sink
          .add(Stat(total: total, owned: owned, wished: wished));
    });
  });

  ref.onDispose(() {
    removeListener();
    streamController.close();
  });

  return streamController.stream;
});

final singleAmiiboProvider =
    Provider.autoDispose.family<AsyncValue<Amiibo>, int>((ref, index) {
  return ref
      .watch(controlProvider)
      .whenData((value) => value.firstWhere((cb) => cb.key == index));
});

final detailAmiiboProvider =
    StreamProvider.autoDispose.family<Amiibo?, int>((ref, key) {
  final control = ref.watch(controlProvider.notifier);
  final service = ref.watch(serviceProvider.notifier);
  final streamController = StreamController<int>();

  final removeListener = control.addListener((state) {
    state.whenData((value) {
      streamController.sink.add(key);
    });
  });

  ref.onDispose(() {
    removeListener();
    streamController.close();
  });

  return streamController.stream.asyncMap(service.fetchAmiiboDBByKey);
});

final controlProvider =
    StateNotifierProvider.autoDispose<AmiiboProvider, AsyncValue<List<Amiibo>>>((ref) {
  final service = ref.watch(serviceProvider.notifier);
  final query = ref.watch(expressionProvider.notifier);
  final provider = AmiiboProvider(service);

  final removeListener = query.addListener(provider.update);

  ref.onDispose(() {
    removeListener();
  });

  return provider;
});

class AmiiboProvider extends StateNotifier<AsyncValue<List<Amiibo>>> {
  late QueryBuilder _queryBuilder;
  final Service _service;

  AmiiboProvider(this._service) : super(AsyncLoading());

  Expression? get where => _queryBuilder.where;

  Future<void> update([QueryBuilder? query]) async {
    if (query != null) _queryBuilder = query;
    state = await AsyncValue.guard(() => _service.fetchByCategory(
        expression: _queryBuilder.where!, orderBy: _queryBuilder.order));
  }

  Future<void> updateAmiiboDB(List<Amiibo> amiibos) async {
    await _service.update(amiibos);
    await update();
  }

  Future<void> shift(int? key) async {
    final Amiibo amiibo = state.data!.value.firstWhere((element) => element.key == key);
    final Amiibo amiiboUpdated = amiibo.copyWith(
      wishlist: amiibo.owned,
      owned: !(amiibo.wishlist ^ amiibo.owned),
    );
    updateAmiiboDB([amiiboUpdated]);
  }

  Future<void> resetCollection() async {
    await _service.resetCollection();
    await update();
  }
}
