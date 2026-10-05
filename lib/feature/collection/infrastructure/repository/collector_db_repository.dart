import 'dart:collection';
import 'dart:convert';

import 'package:amiibo_network/feature/collection/domain/model/amiibo_bundle_preference_aggregate.dart';
import 'package:amiibo_network/feature/collection/domain/model/amiibo_preference_item.dart';
import 'package:amiibo_network/feature/collection/domain/model/collector_aggregate_root.dart';
import 'package:amiibo_network/feature/collection/domain/model/user_preference_attribute.dart';
import 'package:amiibo_network/feature/collection/domain/repository/collector_repository.dart';
import 'package:amiibo_network/shared/data/drift_sqlite/source/drift_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/extensions/json1.dart';

class const CollectorDbRepository({required final AppDatabase _db})
    implements CollectorRepository {
  @override
  Future<CollectorAggregateRoot> getByUser() async {
    /// Amiibos
    final preferences = _db.amiiboUserPreferences;
    final amiiboQuery = await _db.select(_db.amiibo).join([
      innerJoin(
        preferences,
        preferences.amiiboKey.equalsExp(_db.amiibo.key) &
            (preferences.wishlist.equals(true) |
                preferences.boxed.isBiggerThanValue(0) |
                preferences.opened.isBiggerThanValue(0)),
      ),
    ]).get();
    Map<int, AmiiboPreferenceItem>? amiibosOwned = {};
    Map<int, AmiiboWishItem>? amiibosWished = {};

    for (final amiibo in amiiboQuery) {
      final data = amiibo.rawData;
      final id = data.read<int>('amiibo.key');
      final boxed = data.read<int?>('amiibo_user_preferences.boxed') ?? 0;
      final opened = data.read<int?>('amiibo_user_preferences.opened') ?? 0;
      final wished =
          data.read<bool?>('amiibo_user_preferences.wishlist') ?? false;
      if (wished) amiibosWished[id] = AmiiboWishItem(id: id);
      if (boxed > 0 || opened > 0) {
        amiibosOwned[id] = AmiiboPreferenceItem(
          id: id,
          preferences: .new(boxed: boxed, opened: opened),
        );
      }
    }

    /// Amiibo bundles
    final amiiboIds = jsonGroupArray(_db.amiiboBundleRelation.amiiboKey);
    final amiiboBundleId = _db.amiiboBundle.id;
    final amiiboBundleBridge = _db.amiiboBundleRelation;
    final userPreferences = _db.amiiboBundleUserPreferences;
    final bundlesQuery =
        _db.selectOnly(_db.amiiboBundle).join([
            innerJoin(
              userPreferences,
              userPreferences.amiiboBundleId.equalsExp(amiiboBundleId) &
                  (userPreferences.boxed.isBiggerThanValue(0) |
                      userPreferences.opened.isBiggerThanValue(0)),
            ),
            innerJoin(
              amiiboBundleBridge,
              amiiboBundleBridge.amiiboBundleId.equalsExp(amiiboBundleId),
            ),
          ])
          ..addColumns([
            amiiboBundleId,
            amiiboIds,
            userPreferences.boxed,
            userPreferences.opened,
          ])
          ..groupBy([amiiboBundleId]);

    final bundlesResult = await bundlesQuery.get();

    final bundles = bundlesResult.map((r) {
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

    final bundlesOwned = bundles
        .where((t) => t.preferences is OwnedUserPreferenceAttributes)
        .fold<Map<int, AmiiboBundlePreferenceAggregate>>(
          {},
          (map, e) => map..[e.id] = e,
        );

    return CollectorAggregateRoot(
      amiibosOwned: amiibosOwned,
      amiibosWished: amiibosWished,
      bundlesOwned: bundlesOwned,
    );
  }

  @override
  Future<void> save(CollectorAggregateRoot collection) async {
    await _db.batch((b) {
      b
        ..update(
          _db.amiiboUserPreferences,
          AmiiboUserPreferencesCompanion(
            opened: .new(0),
            boxed: .new(0),
            wishlist: .new(false),
          ),
        )
        ..update(
          _db.amiiboBundleUserPreferences,
          AmiiboBundleUserPreferencesCompanion(opened: .new(0), boxed: .new(0)),
        );
      for (final query in collection.amiibosOwned.values) {
        b.update(
          _db.amiiboUserPreferences,
          AmiiboUserPreferencesCompanion(
            opened: .new(query.preferences.opened),
            boxed: .new(query.preferences.boxed),
            wishlist: .new(false),
          ),
          where: (tl) => tl.amiiboKey.equals(query.id),
        );
      }
      for (final query in collection.amiibosWished.values) {
        b.update(
          _db.amiiboUserPreferences,
          AmiiboUserPreferencesCompanion(wishlist: .new(true)),
          where: (tl) => tl.amiiboKey.equals(query.id),
        );
      }
      for (final query in collection.bundlesOwned.values) {
        final attributes =
            (query.preferences! as OwnedUserPreferenceAttributes);
        final companion = AmiiboBundleUserPreferencesCompanion(
          opened: .new(attributes.opened),
          boxed: .new(attributes.boxed),
        );
        b.update(
          _db.amiiboBundleUserPreferences,
          companion,
          where: (tl) => tl.amiiboBundleId.equals(query.id),
        );
      }
    });
  }
}
