import 'package:amiibo_network/feature/collection/domain/model/collector_aggregate_root.dart';

abstract interface class CollectorRepository {
  Future<CollectorAggregateRoot> getByUser();

  Future<void> save(CollectorAggregateRoot collection);

}
