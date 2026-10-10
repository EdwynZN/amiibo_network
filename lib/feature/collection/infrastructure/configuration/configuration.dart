import 'package:amiibo_network/app/configuration/data_providers.dart';
import 'package:amiibo_network/feature/collection/application/use_case/update_collection_use_case.dart';
import 'package:amiibo_network/feature/collection/infrastructure/repository/bundle_db_repository.dart';
import 'package:amiibo_network/feature/collection/infrastructure/repository/collector_db_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'configuration.g.dart';

@riverpod
UpdateCollectionUseCase updateCollectionUseCase(Ref ref) {
  final db = ref.watch(databaseProvider);
  final collectionRepository = CollectorDbRepository(db: db);
  final bundleRepository = BundleDbRepository(db: db);
  return UpdateCollectionUseCase(
    repository: collectionRepository,
    bundleRepo: bundleRepository,
  );
}