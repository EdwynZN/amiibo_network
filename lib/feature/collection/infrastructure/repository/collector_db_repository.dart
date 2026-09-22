import 'package:amiibo_network/feature/collection/domain/model/amiibo_preference_item.dart';
import 'package:amiibo_network/feature/collection/domain/model/collector_aggregate_root.dart';
import 'package:amiibo_network/feature/collection/domain/model/user_preference_attribute.dart';
import 'package:amiibo_network/feature/collection/domain/repository/collector_repository.dart';
import 'package:amiibo_network/shared/data/drift_sqlite/source/drift_database.dart';
import 'package:drift/drift.dart';

class const CollectorDbRepository({required final AppDatabase _db})
    implements CollectorRepository {
  @override
  Future<CollectorAggregateRoot> getByUser() async {
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

    /* final bundlePreferences = _db.amiiboBundleUserPreferences;
    final bundleQuery = await _db.select(_db.amiiboBundle).join([
      innerJoin(
        bundlePreferences,
        bundlePreferences.amiiboBundleId.equalsExp(_db.amiiboBundle.id) &
            (bundlePreferences.boxed.isBiggerThanValue(0) |
                bundlePreferences.opened.isBiggerThanValue(0)),
      ),
    ]).get(); */

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

    /* Map<int, AmiiboBundlePreferenceAggregate>? bundlesOwned = {};
    for (final bundle in bundleQuery) {
      final data = bundle.rawData;
      final id = data.read<int>('amiibo.key');
      final boxed = data.read<int?>('amiibo_user_preferences.boxed') ?? 0;
      final opened = data.read<int?>('amiibo_user_preferences.opened') ?? 0;
    } */

    return CollectorAggregateRoot(
      amiibosOwned: amiibosOwned,
      amiibosWished: amiibosWished,
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
          _db.amiiboUserPreferences,
          AmiiboBundleUserPreferencesCompanion(opened: .new(0), boxed: .new(0)),
        );
      for (final query in collection.amiibosOwned.values) {
        b.update(
          _db.amiiboUserPreferences,
          AmiiboUserPreferencesCompanion(
            amiiboKey: .new(query.id),
            opened: .new(query.preferences.opened),
            boxed: .new(query.preferences.boxed),
            wishlist: .new(false),
          ),
        );
      }
      for (final query in collection.amiibosWished.values) {
        b.update(
          _db.amiiboUserPreferences,
          AmiiboUserPreferencesCompanion(
            amiiboKey: .new(query.id),
            wishlist: .new(true),
          ),
        );
      }
      for (final query in collection.bundlesOwned.values.where(
        (t) => t.preferences is OwnedUserPreferenceAttributes,
      )) {
        final attributes =
            (query.preferences! as OwnedUserPreferenceAttributes);
        final companion = AmiiboBundleUserPreferencesCompanion(
          id: .new(query.id),
          opened: .new(attributes.opened),
          boxed: .new(attributes.boxed),
        );
        b.update(_db.amiiboUserPreferences, companion);
      }
    });
  }
}
