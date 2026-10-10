import 'dart:async';

import 'package:amiibo_network/app/configuration/data_providers.dart';
import 'package:amiibo_network/app/configuration/model/search_result.dart';
import 'package:amiibo_network/entity/amiibo_info/infrastructure/amiibo_collection_drift_service.dart';
import 'package:amiibo_network/entity/amiibo_info/model/amiibo_detail_info.dart';
import 'package:amiibo_network/entity/amiibo_info/model/amiibo_info.dart';
import 'package:amiibo_network/entity/amiibo_info/service/amiibo_collection_query_service.dart';
import 'package:amiibo_network/shared/data/drift_sqlite/source/amiibo_collection_dao.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'configuration.g.dart';

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
Stream<AmiiboDetailInfo?> detailAmiibo(Ref ref, int key) async* {
  final service = ref.watch(amiiboColletcionQueryServiceProvider);
  yield* service.fetchStreamDetail(amiiboId: key);
}
