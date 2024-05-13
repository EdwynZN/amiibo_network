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
class AmiiboDao extends DatabaseAccessor<AppDatabase>
    with _$AmiiboDaoMixin, _ExpressionBuilder {
  AmiiboDao(super.db);

  Future<List<AmiiboDriftModel>> fetchAll({
    required CategoryAttributes categoryAttributes,
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
    )..orderBy(_orderExpression(orderBy, sortBy));
    _updateQueryWhere(
      query,
      categoryAttributes,
      searchAttributes,
      hiddenCategories,
      figures,
      cards,
    );

    final whereExpression = _updateExpression(
      categoryAttributes: categoryAttributes,
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

    final result = await query
        .map((p0) => AmiiboDriftModel.fromJson(p0.rawData.data))
        .getSingleOrNull();
    return result;
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
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  Future<List<String>> fetchDistincts({
    required CategoryAttributes categoryAttributes,
    SearchAttributes? searchAttributes,
    s.OrderBy orderBy = s.OrderBy.NA,
    s.SortBy sortBy = s.SortBy.DESC,
    List<String> figures = const [],
    List<String> cards = const [],
    HiddenType? hiddenCategories,
  }) async {
    final query = selectOnly(amiibo, distinct: true)
      ..addColumns([amiibo.amiiboSeries])
      ..orderBy(_orderExpression(orderBy, sortBy));
    _updateQueryWhere(
      query,
      categoryAttributes,
      searchAttributes,
      hiddenCategories,
      figures,
      cards,
    );
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

  Future<List<Map<String, dynamic>>> fetchSum({
    required CategoryAttributes categoryAttributes,
    SearchAttributes? searchAttributes,
    bool group = false,
    HiddenType? hiddenCategories,
  }) async {
    final query = selectOnly(amiibo).join([
      innerJoin(
        amiiboUserPreferences,
        amiiboUserPreferences.amiiboKey.equalsExp(amiibo.key),
        useColumns: false,
      ),
    ]);
    query
      ..addColumns([
        if (group) amiibo.amiiboSeries,
        amiibo.amiiboSeries.count(),
        CaseWhenExpression(
          cases: [
            CaseWhen(
              amiiboUserPreferences.wishlist.isValue(true),
              then: const Constant(1),
            ),
          ],
        ).count(),
        CaseWhenExpression(
          cases: [
            CaseWhen(
              amiiboUserPreferences.opened.isBiggerThanValue(0) |
                  amiiboUserPreferences.boxed.isBiggerThanValue(0),
              then: const Constant(1),
            ),
          ],
        ).count(),
        amiiboUserPreferences.opened.sum(),
        amiiboUserPreferences.boxed.sum(),
      ])
      ..orderBy([
        OrderingTerm(expression: amiibo.amiiboSeries, mode: OrderingMode.asc),
      ]);
    if (group) {
      query.groupBy([amiibo.amiiboSeries]);
    }
    _updateQueryWhere(
      query,
      categoryAttributes,
      searchAttributes,
      hiddenCategories,
    );

    final result = await query.map((e) {
      final map = e.rawData.data;
      int index = group ? 1 : 0;
      return {
        if (group) 'amiiboSeries': map['amiibo.amiiboSeries'],
        'Total': map['c${index++}'],
        'Wished': map['c${index++}'],
        'Owned': map['c${index++}'],
        'Unboxed': map['c${index++}'],
        'Boxed': map['c${index++}'],
      };
    }).get();
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

  void _updateQueryWhere(
    JoinedSelectStatement query,
    CategoryAttributes categoryAttributes,
    SearchAttributes? searchAttributes,
    HiddenType? hiddenCategories, [
    List<String> figures = const [],
    List<String> cards = const [],
  ]) {
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

    final whereExpression = _updateExpression(
      categoryAttributes: categoryAttributes,
      hiddenCategories: hiddenCategories,
    );

    if (whereExpression != null) {
      query.where(whereExpression);
    }
  }
}

mixin _ExpressionBuilder on _$AmiiboDaoMixin {
  List<OrderingTerm> _orderExpression(s.OrderBy orderBy, s.SortBy sortBy) {
    return [
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
          s.OrderBy.AmiiboSerie => amiibo.amiiboSeries,
          s.OrderBy.Game => amiibo.gameSeries,
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
    ];
  }

  Expression<bool>? _updateExpression({
    required CategoryAttributes categoryAttributes,
    HiddenType? hiddenCategories,
  }) {
    Expression<bool>? where;
    final cards = categoryAttributes.cards;
    final figures = categoryAttributes.figures;
    final category = categoryAttributes.category;
    final cardFilter = amiibo.type.equals('Card');
    final figureFilter = amiibo.type.isIn(figureType);
    switch (category) {
      case AmiiboCategory.Cards:
        if (hiddenCategories == HiddenType.Cards) {
          return amiibo.amiiboSeries.isIn(const []);
        }
        where = cardFilter;
        return cards.isEmpty ? where : where & amiibo.amiiboSeries.isIn(cards);
      case AmiiboCategory.Figures:
        if (hiddenCategories == HiddenType.Figures) {
          return amiibo.amiiboSeries.isIn(const []);
        }
        where = figureFilter;
        return figures.isEmpty
            ? where
            : where & amiibo.amiiboSeries.isIn(figures);
      case AmiiboCategory.Owned:
        where = Expression.or([
          amiiboUserPreferences.boxed.isBiggerThanValue(0),
          amiiboUserPreferences.opened.isBiggerThanValue(0),
        ]);
        break;
      case AmiiboCategory.Wishlist:
        where = amiiboUserPreferences.wishlist.equals(true);
        break;
      case AmiiboCategory.AmiiboSeries:
        if (figures.isEmpty && cards.isEmpty) {
          return amiibo.amiiboSeries.isIn(const []);
        }
        break;
      default:
        break;
    }
    Expression<bool>? figuresWhere;
    Expression<bool>? cardsWhere;
    if (figures.isNotEmpty) {
      figuresWhere = Expression.and([
        figureFilter,
        amiibo.amiiboSeries.isIn(figures),
      ]);
    }
    if (cards.isNotEmpty) {
      cardsWhere = Expression.and([
        cardFilter,
        amiibo.amiiboSeries.isIn(cards),
      ]);
    }

    final Expression<bool>? seriesExpression;
    if (hiddenCategories != null) {
      seriesExpression = switch (hiddenCategories) {
        HiddenType.Figures => cardsWhere ?? cardFilter,
        HiddenType.Cards => figuresWhere ?? figureFilter,
      };
    } else {
      final noFigures = figuresWhere == null;
      final noCards = cardsWhere == null;
      seriesExpression = (noFigures ^ noCards) || (noCards && noFigures)
          ? (figuresWhere ?? cardsWhere)
          : figuresWhere! | cardsWhere!;
    }

    where = where == null
        ? seriesExpression
        : seriesExpression == null
            ? where
            : where & seriesExpression;
    return where;
  }
}
