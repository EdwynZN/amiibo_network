import 'dart:collection';
import 'dart:convert';

import 'package:amiibo_network/feature/collection/domain/model/amiibo_bundle_preference_aggregate.dart';
import 'package:amiibo_network/feature/collection/domain/repository/bundle_repository.dart';
import 'package:amiibo_network/shared/data/drift_sqlite/source/drift_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/extensions/json1.dart';

class BundleDbRepository({required final AppDatabase _db})
    implements BundleRepository {
  @override
  Future<List<AmiiboBundlePreferenceAggregate>> getByIds(
    Iterable<int> ids,
  ) async {
    final amiiboIds = jsonGroupArray(_db.amiiboBundleRelation.amiiboKey);
    final amiiboBundleId = _db.amiiboBundle.id;
    final amiiboBundleBridge = _db.amiiboBundleRelation;
    final userPreferences = _db.amiiboBundleUserPreferences;
    final query =
        _db.selectOnly(_db.amiiboBundle).join([
            innerJoin(
              userPreferences,
              userPreferences.amiiboBundleId.equalsExp(amiiboBundleId),
            ),
            innerJoin(
              amiiboBundleBridge,
              amiiboBundleBridge.amiiboBundleId.equalsExp(amiiboBundleId),
            ),
          ])
          ..where(amiiboBundleId.isIn(ids))
          ..addColumns([
            amiiboBundleId,
            amiiboIds,
            userPreferences.boxed,
            userPreferences.opened,
          ])
          ..groupBy([amiiboBundleId]);

    final result = await query.get();

    return result.map((r) {
      final raw = r.rawData;
      final amiibosId = List<int>.from(jsonDecode(raw.data['c1']));
      final (int boxed, int opened) = (
        raw.read('amiiboBundleUserPreferences.boxed') ?? 0,
        raw.read('amiiboBundleUserPreferences.opened') ?? 0,
      );
      return AmiiboBundlePreferenceAggregate(
        id: raw.read('amiibo_bundle.id'),
        amiibosId: UnmodifiableListView(amiibosId),
        preferences: boxed == 0 && opened == 0
            ? null
            : .owned(boxed: boxed, opened: opened),
      );
    }).toList();
  }
}
