import 'package:amiibo_network/data/drift_sqlite/source/drift_database.dart';
import 'package:amiibo_network/enum/amiibo_category_enum.dart';
import 'package:amiibo_network/enum/hidden_types.dart';
import 'package:amiibo_network/enum/sort_enum.dart' as s;
import 'package:amiibo_network/model/amiibo.dart' as domain;
import 'package:amiibo_network/model/amiibo_sqlite_model.dart';
import 'package:amiibo_network/model/update_amiibo_user_attributes.dart';
import 'package:drift/drift.dart';

part 'amiibo_dao.g.dart';

@DriftAccessor(include: const {'amiibo_tables.drift'})
class AmiiboDao extends DatabaseAccessor<AppDatabase> with _$AmiiboDaoMixin {
  AmiiboDao(super.db);

  Future<List<domain.Amiibo>> fetchAll({
    required AmiiboCategory category,
    String? search,
    s.OrderBy orderBy = s.OrderBy.NA,
    s.SortBy sortBy = s.SortBy.DESC,
    List<String> figures = const [],
    List<String> cards = const [],
    HiddenType? hiddenCategories,
  }) async {
    final query = select(amiibo).join(
      [
        leftOuterJoin(
          amiiboUserPreferences,
          amiiboUserPreferences.amiiboKey.equalsExp(amiibo.key),
        ),
      ],
    )..orderBy([
        OrderingTerm(
          expression: switch (orderBy) {
            s.OrderBy.NA => amiibo.na,
            s.OrderBy.EU => amiibo.eu,
            s.OrderBy.JP => amiibo.jp,
            s.OrderBy.AU => amiibo.au,
            s.OrderBy.Name => amiibo.name,
            s.OrderBy.Owned => amiiboUserPreferences.opened,
            s.OrderBy.Wishlist => amiiboUserPreferences.wishlist,
            s.OrderBy.CardNumber => amiibo.cardNumber,
            s.OrderBy.Type => amiibo.type,
          },
          mode: switch (sortBy) {
            s.SortBy.DESC => OrderingMode.desc,
            s.SortBy.ASC => OrderingMode.asc,
          },
        ),
      ]);
    if (search != null) {
      query.where(amiibo.name.like('%$search%'));
    }

    final result = await query.get();
    print(result);
    return result
        .map(
          (e) => AmiiboSqlite.fromJson(e.rawData.data).toDomain(),
        )
        .toList();
  }

  Future<domain.Amiibo> fetchByKey(int key) async {
    final query = select(amiibo).join(
      [
        leftOuterJoin(
          amiiboUserPreferences,
          amiibo.key.equalsExp(amiiboUserPreferences.amiiboKey),
        ),
      ],
    )..where(amiibo.key.equals(key));

    final result = await query.getSingle();
    return AmiiboSqlite.fromJson(result.rawData.data).toDomain();
  }

  Future<void> insertAll(List<domain.Amiibo> amiibos) async {
    final List<AmiiboData> amiibosData = [];
    final List<AmiiboUserPreference> preferences = [];
    for (final a in amiibos) {
      amiibosData.add(AmiiboData.fromJson(a.toJson()));
      preferences.add(AmiiboUserPreference.fromJson(a.toJson()));
    }
    await batch((batch) async {
      batch.insertAllOnConflictUpdate(amiibo, amiibosData);
      batch.insertAllOnConflictUpdate(amiiboUserPreferences, preferences);
    });
  }

  Future<List<String>> searchName({String search = '', int limit = 10}) async {
    final query = select(amiibo)
      ..where((tbl) => tbl.name.like('%$search%'))
      ..limit(limit);
    final result = await query.get();
    return result.map((e) => e.name).toList();
  }

  /* Future<List<Map<String, dynamic>>> fetchSum({bool group = false}) async {
    final sum = amiibo.amiiboSeries.length.sum();
    final query = select(amiibo)..addColumns([sum]);
    if (group) {
      query..groupBy([amiibo.amiiboSeries]);
    }
    final result = await query.get();
    return result.map((e) => e.name).toList();
  } */

  Future<void> clear() async {
    await update(amiiboUserPreferences)
        .write(AmiiboUserPreferencesCompanion(
      boxed: const Value(0),
      opened: const Value(0),
      wishlist: const Value(false),
    ));
  }

  Future<void> updatePreferences(
    List<UpdateAmiiboUserAttributes> amiibos,
  ) async {
    await batch((batch) async {
      for (final query in amiibos) {
        final ({int boxed, int opened, bool wished}) args =
            switch (query.attributes) {
          const domain.UserAttributes.wished() => const (
              opened: 0,
              boxed: 0,
              wished: true
            ),
          domain.OwnedUserAttributes(
            opened: final opened,
            boxed: final boxed,
          ) =>
            (opened: opened, boxed: boxed, wished: false),
          _ => const (opened: 0, boxed: 0, wished: false),
        };
        batch.update(
          amiiboUserPreferences,
          AmiiboUserPreferencesCompanion(
            amiiboKey: Value(query.id),
            opened: Value(args.opened),
            boxed: Value(args.boxed),
            wishlist: Value(args.wished),
          ),
        );
      }
    });
  }
}
