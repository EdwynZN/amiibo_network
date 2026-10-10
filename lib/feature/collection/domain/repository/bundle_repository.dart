import 'package:amiibo_network/feature/collection/domain/model/amiibo_bundle_preference_aggregate.dart';

abstract interface class BundleRepository {
  Future<List<AmiiboBundlePreferenceAggregate>> getByIds(Iterable<int> ids);
}
