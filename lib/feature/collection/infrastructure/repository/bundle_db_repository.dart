import 'package:amiibo_network/feature/collection/domain/model/amiibo_bundle_preference_aggregate.dart';
import 'package:amiibo_network/feature/collection/domain/repository/bundle_repository.dart';
import 'package:amiibo_network/shared/data/drift_sqlite/source/drift_database.dart';
import 'package:drift/drift.dart';

class BundleDbRepository({required final AppDatabase _db})
    implements BundleRepository {
  @override
  Future<List<AmiiboBundlePreferenceAggregate>> getByIds(
    Iterable<int> ids,
  ) async {
    final query = _db.select(_db.amiiboBundle).join([
      leftOuterJoin(
        _db.amiiboBundleUserPreferences,
        _db.amiiboBundleUserPreferences.id.equalsExp(_db.amiiboBundle.id),
      ),
      leftOuterJoin(
        _db.amiiboBundleRelation,
        _db.amiiboBundleRelation.id.equalsExp(_db.amiiboBundle.id),
      ),
    ])..where(_db.amiiboBundle.id.isIn(ids));

    final result = await query.get();

    return result.map((r) {
      final data = r.rawData;
      return AmiiboBundlePreferenceAggregate(
        id: data.read('amiiboBundle.id'),
        amiibosId: data.read('amiiboBundleRelation.id'),
        preferences: data.read('amiiboBundleUserPreferences.id'),
      );
    }).toList();
  }
}
