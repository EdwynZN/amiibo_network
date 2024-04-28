import 'package:amiibo_network/data/common.dart';
import 'package:amiibo_network/data/drift_sqlite/model/drift_joined_amiibo_preferences.dart';
import 'package:amiibo_network/data/drift_sqlite/source/drift_database.dart';
import 'package:amiibo_network/enum/amiibo_category_enum.dart';
import 'package:amiibo_network/enum/hidden_types.dart';
import 'package:amiibo_network/enum/sort_enum.dart' as s;
import 'package:amiibo_network/model/amiibo.dart' hide Amiibo;
import 'package:amiibo_network/model/search_result.dart';
import 'package:amiibo_network/model/update_amiibo_user_attributes.dart';
import 'package:drift/drift.dart';

part 'amiibo_dao.g.dart';

@DriftAccessor(include: const {'amiibo_tables.drift'})
class AmiiboDao extends DatabaseAccessor<AppDatabase> with _$AmiiboDaoMixin {
  AmiiboDao(super.db);

  Future<List<AmiiboDriftModel>> fetchAll({
    required AmiiboCategory category,
    SearchAttributes? searchAttributes,
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
        if (orderBy == s.OrderBy.Owned)
          OrderingTerm(
            expression: amiiboUserPreferences.boxed,
            mode: switch (sortBy) {
              s.SortBy.DESC => OrderingMode.desc,
              s.SortBy.ASC => OrderingMode.asc,
            },
          ),
      ]);
    if (searchAttributes != null) {
      final search = '%${searchAttributes.search}%';
      query.where(
        switch (searchAttributes.category) {
          SearchCategory.Game => amiibo.gameSeries.like(search),
          SearchCategory.AmiiboSeries => amiibo.amiiboSeries.like(search),
          _ => amiibo.name.like(search) | amiibo.character.like(search),
        },
      );
    }
    if (hiddenCategories != null) {
      final typeCol = amiibo.type;
      query.where(
        switch (hiddenCategories) {
          HiddenType.Figures => typeCol.isNotIn(figureType),
          HiddenType.Cards => typeCol.isNotValue('Card'),
        },
      );
    }

    final whereExpression = _updateExpression(
      category: category,
      cards: cards,
      figures: figures,
      hiddenCategories: hiddenCategories,
    );

    if (whereExpression != null) {
      query.where(whereExpression);
    }
    final result = await query
        .map((p0) => AmiiboDriftModel.fromJson(p0.rawData.data))
        .get();
    return result;
  }

  Future<AmiiboDriftModel?> fetchByKey(int key) async {
    final query = select(amiibo).join(
      [
        leftOuterJoin(
          amiiboUserPreferences,
          amiibo.key.equalsExp(amiiboUserPreferences.amiiboKey),
        ),
      ],
    )..where(amiibo.key.equals(key));

    try {
      final result = await query
          .map((p0) => AmiiboDriftModel.fromJson(p0.rawData.data))
          .getSingle();
      return result;
    } catch (_, __) {
      return null;
    }
  }

  Future<void> insertAll({
    required List<AmiiboTable> amiibosData,
    required List<AmiiboUserPreferencesCompanion> preferences,
  }) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(amiibo, amiibosData);
      batch.insertAll(
        amiiboUserPreferences,
        preferences,
        mode: InsertMode.insertOrAbort,
      );
    });
  }

  Future<List<String>> fetchDistincts({
    required AmiiboCategory category,
    SearchAttributes? searchAttributes,
    s.OrderBy orderBy = s.OrderBy.NA,
    s.SortBy sortBy = s.SortBy.DESC,
    List<String> figures = const [],
    List<String> cards = const [],
    HiddenType? hiddenCategories,
  }) async {
    final query = selectOnly(amiibo, distinct: true)
      ..addColumns([amiibo.amiiboSeries]);
    if (searchAttributes != null) {
      final search = '%${searchAttributes.search}%';
      query.where(
        switch (searchAttributes.category) {
          SearchCategory.Game => amiibo.gameSeries.like(search),
          SearchCategory.AmiiboSeries => amiibo.amiiboSeries.like(search),
          _ => amiibo.name.like(search) | amiibo.character.like(search),
        },
      );
    }
    if (hiddenCategories != null) {
      final typeCol = amiibo.type;
      query.where(
        switch (hiddenCategories) {
          HiddenType.Figures => typeCol.isNotIn(figureType),
          HiddenType.Cards => typeCol.isNotValue('Card'),
        },
      );
    }

    final whereExpression = _updateExpression(
      category: category,
      cards: cards,
      figures: figures,
      hiddenCategories: hiddenCategories,
    );

    if (whereExpression != null) {
      query.where(whereExpression);
    }
    final result = await query.map((e) => e.read(amiibo.amiiboSeries)!).get();
    return result;
  }

  Future<List<String>> searchName({
    required SearchCategory category,
    String search = '',
    int limit = 10,
  }) async {
    if (search.isEmpty) {
      return const [];
    }
    final GeneratedColumn<String> column = switch (category) {
      SearchCategory.AmiiboSeries => amiibo.amiiboSeries,
      SearchCategory.Name => amiibo.name,
      SearchCategory.Game => amiibo.gameSeries,
    };
    final query = selectOnly(amiibo, distinct: true)
      ..addColumns([column])
      ..where(column.like('%$search%'))
      ..limit(limit);
    final result = await query.map((e) => e.read(column)!).get();
    return result;
  }

  Future<List<Map<String, dynamic>>> fetchSum({bool group = false}) async {
    final query = selectOnly(amiibo).join([
      innerJoin(
        amiiboUserPreferences,
        amiiboUserPreferences.amiiboKey.equalsExp(amiibo.key),
        useColumns: false,
      ),
    ]);
    query
      ..addColumns([
        amiibo.amiiboSeries.count(),
        amiibo.amiiboSeries.count(
          filter: amiiboUserPreferences.wishlist.equals(true),
        ),
        amiibo.amiiboSeries.count(
          filter: amiiboUserPreferences.opened.isBiggerThanValue(0) |
          amiiboUserPreferences.boxed.isBiggerThanValue(0),
        ),
      ])
      ..groupBy([amiibo.amiiboSeries]);

    final result = await query.map((e) => e.rawData.data).get();
    return result;
  }

  Future<void> clear() async {
    await update(amiiboUserPreferences).write(AmiiboUserPreferencesCompanion(
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
          const UserAttributes.wished() => const (
              opened: 0,
              boxed: 0,
              wished: true
            ),
          OwnedUserAttributes(
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
          where: (tl) => tl.amiiboKey.equals(query.id),
        );
      }
    });
  }

  Expression<bool>? _updateExpression({
    required AmiiboCategory category,
    HiddenType? hiddenCategories,
    List<String> figures = const [],
    List<String> cards = const [],
  }) {
    Expression<bool>? where;
    switch (category) {
      case AmiiboCategory.Owned:
        where = amiiboUserPreferences.boxed.isBiggerThanValue(0) |
            amiiboUserPreferences.opened.isBiggerThanValue(0);
        break;
      case AmiiboCategory.Wishlist:
        where = amiiboUserPreferences.wishlist.equals(true);
        break;
      case AmiiboCategory.Custom:
        final figuresWhere = Expression.and([
          amiibo.type.isIn(figureType),
          amiibo.amiiboSeries.isIn(figures),
        ]);
        final cardsWhere = Expression.and([
          amiibo.type.equals('Card'),
          amiibo.amiiboSeries.isIn(cards),
        ]);
        if (hiddenCategories != null) {
          where = hiddenCategories == HiddenType.Figures
              ? cardsWhere
              : figuresWhere;
        } else {
          where = figuresWhere | cardsWhere;
        }
        break;
      default:
        break;
    }
    return where;
  }
}
