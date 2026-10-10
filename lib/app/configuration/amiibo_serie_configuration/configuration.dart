import 'package:amiibo_network/app/configuration/data_providers.dart';
import 'package:amiibo_network/entity/amiibo_series/infrastructure/drift_amiibo_serie_query_service.dart';
import 'package:amiibo_network/entity/amiibo_series/service/amiibo_serie_query_service.dart';
import 'package:amiibo_network/shared/data/drift_sqlite/source/amiibo_dao.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'configuration.g.dart';

@riverpod
AmiiboSerieQueryService amiiboSerieQueryService(Ref ref) {
  final dao = AmiiboDao(ref.watch(databaseProvider));
  return DriftAmiiboSerieQueryService(dao);
}
