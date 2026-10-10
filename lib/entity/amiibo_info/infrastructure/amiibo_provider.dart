import 'dart:async';

import 'package:amiibo_network/app/configuration/data_providers.dart';
import 'package:amiibo_network/app/configuration/model/search_result.dart';
import 'package:amiibo_network/entity/amiibo_info/infrastructure/amiibo_collection_drift_service.dart';
import 'package:amiibo_network/entity/amiibo_info/model/amiibo.dart';
import 'package:amiibo_network/entity/amiibo_info/model/amiibo_detail_info.dart';
import 'package:amiibo_network/entity/amiibo_info/model/amiibo_info.dart';
import 'package:amiibo_network/entity/amiibo_info/service/amiibo_collection_query_service.dart';
import 'package:amiibo_network/shared/data/drift_sqlite/source/amiibo_collection_dao.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'amiibo_provider.g.dart';

@riverpod
AmiiboCollectionQueryService amiiboColletcionQueryService(Ref ref) {
  final dao = AmiiboCollectionDao(ref.watch(databaseProvider));
  return DriftAmiiboCollectionQueryService(dao);
}

@riverpod
Stream<List<AmiiboInfo>> amiibos(Ref ref, {required Filter filter}) {
  final service = ref.watch(amiiboColletcionQueryServiceProvider);
  return service.fetchStreamCollection(filter: filter);
}

@riverpod
int keyAmiibo(Ref ref) => throw UnimplementedError();

@riverpod
Stream<Amiibo?> detailAmiibo(Ref ref, int key) async* {
  final service = ref.watch(amiiboColletcionQueryServiceProvider);
  yield* service.fetchStreamDetail(amiiboId: key).map((e) {
    if (e == null) return null;
    UserAttributes userAttributes = const .none();
    if (e.details.userAttributes case WishedUserCollectionAttributes()) {
      userAttributes = .wished();
    }
    if (e.details.userAttributes case OwnedUserCollectionAttributes(
      :final opened,
      :final boxed,
    )) {
      final (allBoxed, allOpened) = e.bundles.fold((boxed, opened), (r, m) {
        if (m.userAttributes case OwnedUserCollectionAttributes(
          :final opened,
          :final boxed,
        )) {
          return (r.$1 + boxed, r.$2 + opened);
        }
        return (r.$1, r.$2);
      });
      userAttributes = .owned(boxed: allBoxed, opened: allOpened);
    }
    return Amiibo(
      key: key,
      details: .new(
        amiiboSeries: e.details.amiiboSeries,
        character: e.details.character,
        gameSeries: e.details.gameSeries,
        name: e.details.name,
        type: e.details.type,
        au: e.details.au,
        eu: e.details.eu,
        image: e.details.images.isEmpty ? null : e.details.images.first,
        jp: e.details.jp,
        na: e.details.na,
      ),
      userAttributes: userAttributes,
    );
  });

  /* final service = ref.watch(amiiboServiceProvider);
  final streamController = StreamController<int>();

  void listen() => streamController.sink.add(key);

  service.addListener(listen);

  ref.onDispose(() {
    service.removeListener(listen);
    streamController.close();
  });

  yield await service.fetchOne(key);
  yield* streamController.stream.asyncMap(service.fetchOne); */
}
