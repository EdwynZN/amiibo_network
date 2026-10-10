import 'package:amiibo_network/app/configuration/model/amiibo_category_enum.dart';
import 'package:amiibo_network/app/configuration/model/hidden_types.dart';
import 'package:amiibo_network/app/configuration/model/search_result.dart';
import 'package:amiibo_network/app/configuration/model/sort_enum.dart' as s;
import 'package:amiibo_network/shared/data/drift_sqlite/model/amiibo_collection_drift_dto.dart';
import 'package:amiibo_network/shared/data/drift_sqlite/source/drift_database.dart';
import 'package:drift/drift.dart';

part 'amiibo_collection_dao.g.dart';

@DriftAccessor(include: const {'amiibo_tables.drift'})
class AmiiboCollectionDao(super.db)
    extends DatabaseAccessor<AppDatabase>
    with _$AmiiboCollectionDaoMixin, _ExpressionBuilder {
  Stream<List<AmiiboCollectionDriftDto>> fetchAllStream({
    required CategoryAttributes categoryAttributes,
    SearchAttributes? searchAttributes,
    s.OrderBy orderBy = s.OrderBy.NA,
    s.SortBy sortBy = s.SortBy.DESC,
    List<String> figures = const [],
    List<String> cards = const [],
    HiddenType? hiddenCategories,
  }) {
    return _fetchAll(
      categoryAttributes: categoryAttributes,
      searchAttributes: searchAttributes,
      orderBy: orderBy,
      sortBy: sortBy,
      figures: figures,
      cards: cards,
      hiddenCategories: hiddenCategories,
    ).map((p0) => AmiiboCollectionDriftDto.fromJson(p0.rawData.data)).watch();
  }

  Future<List<AmiiboCollectionDriftDto>> fetchAll({
    required CategoryAttributes categoryAttributes,
    SearchAttributes? searchAttributes,
    s.OrderBy orderBy = s.OrderBy.NA,
    s.SortBy sortBy = s.SortBy.DESC,
    List<String> figures = const [],
    List<String> cards = const [],
    HiddenType? hiddenCategories,
  }) async {
    return await _fetchAll(
      categoryAttributes: categoryAttributes,
      searchAttributes: searchAttributes,
      orderBy: orderBy,
      sortBy: sortBy,
      figures: figures,
      cards: cards,
      hiddenCategories: hiddenCategories,
    ).map((p0) => AmiiboCollectionDriftDto.fromJson(p0.rawData.data)).get();
  }

  JoinedSelectStatement<HasResultSet, dynamic> _fetchAll({
    required CategoryAttributes categoryAttributes,
    SearchAttributes? searchAttributes,
    s.OrderBy orderBy = s.OrderBy.NA,
    s.SortBy sortBy = s.SortBy.DESC,
    List<String> figures = const [],
    List<String> cards = const [],
    HiddenType? hiddenCategories,
  }) {
    final imagesQuery = _imageSubQuery;
    final bundleSubquery = _bundleSubquery;
    final query = select(amiibo).join([
      leftOuterJoin(
        amiiboUserPreferences,
        amiiboUserPreferences.amiiboKey.equalsExp(amiibo.key),
      ),
      leftOuterJoin(
        bundleSubquery,
        bundleSubquery
            .ref(amiiboBundleRelation.amiiboKey)
            .equalsExp(amiibo.key),
      ),
      leftOuterJoin(
        imagesQuery,
        imagesQuery.ref(amiiboImages.amiiboKey).equalsExp(amiibo.key),
      ),
    ])..orderBy(_orderExpression(orderBy, sortBy));
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

    if (whereExpression != null) query.where(whereExpression);
    return query;
  }

  Stream<AmiiboCollectionDetailDriftDto?> streamByAmiiboKey(int key) {
    final query = _queryByAmiiboKey(key);
    return query
        .map((p0) => AmiiboCollectionDetailDriftDto.fromJson(p0.data))
        .watchSingleOrNull();
  }

  Future<AmiiboCollectionDetailDriftDto?> queryByAmiiboKey(int key) async {
    final query = _queryByAmiiboKey(key);
    return await query
        .map((p0) => AmiiboCollectionDetailDriftDto.fromJson(p0.data))
        .getSingleOrNull();
  }

  Selectable<QueryRow> _queryByAmiiboKey(int key) {
    /* final amiiboIds = jsonGroupArray(amiiboBundleRelation.amiiboKey);
    final bundleSubquery = Subquery(
      selectOnly(amiiboBundleRelation).join([
          innerJoin(
            amiiboBundleUserPreferences,
            amiiboBundleUserPreferences.amiiboBundleId.equalsExp(
              amiiboBundle.id,
            ),
          ),
          innerJoin(amiiboBundle, amiiboBundle.id.equalsExp(amiiboBundle.id)),
          innerJoin(
            amiiboBundleImages,
            amiiboBundleImages.amiiboBundleId.equalsExp(amiiboBundle.id),
          ),
        ])
        ..addColumns([
          amiiboBundleRelation.amiiboKey,
          amiiboBundle.id,
          amiiboIds,
          jsonGroupArray(amiiboBundleImages.filePath),
          amiiboBundleUserPreferences.boxed,
          amiiboBundleUserPreferences.opened,
        ])
        ..orderBy([
          OrderingTerm.asc(amiiboBundle.id),
          OrderingTerm.asc(amiiboBundleImages.createAt),
        ])
        ..groupBy([amiiboBundle.id])
        ..where(amiiboBundleRelation.amiiboKey.equals(key)),
      'b',
    );

    final amiiboBundlesAlias = alias(amiiboBundleRelation, 'm');
    final bundles =
        selectOnly(amiiboBundleRelation).join([
            innerJoin(
              amiiboBundlesAlias,
              amiiboBundlesAlias.amiiboBundleId.equalsExp(
                amiiboBundleRelation.amiiboBundleId,
              ),
            ),
            innerJoin(
              amiiboBundle,
              amiiboBundle.id.equalsExp(amiiboBundleRelation.amiiboBundleId),
            ),
            leftOuterJoin(
              amiiboBundleUserPreferences,
              amiiboBundleUserPreferences.amiiboBundleId.equalsExp(
                amiiboBundle.id,
              ),
            ),
            leftOuterJoin(
              amiiboBundleImages,
              amiiboBundleImages.amiiboBundleId.equalsExp(amiiboBundle.id),
            ),
          ])
          ..addColumns([
            amiiboBundle.id,
            jsonGroupArray(amiiboBundlesAlias.amiiboKey),
            jsonGroupArray(amiiboBundleImages.filePath),
            amiiboBundleUserPreferences.boxed,
            amiiboBundleUserPreferences.opened,
          ])
          ..where(amiiboBundleRelation.amiiboKey.equals(key))
          ..orderBy([
            OrderingTerm.asc(amiiboBundle.id),
            OrderingTerm.asc(amiiboBundleImages.createAt),
          ])
          ..groupBy([amiiboBundle.id]);

    final subBundleQuery = Subquery(
      selectOnly(amiiboBundleRelation).join([
          innerJoin(
            amiiboBundlesAlias,
            amiiboBundlesAlias.amiiboBundleId.equalsExp(
              amiiboBundleRelation.amiiboBundleId,
            ),
          ),
          innerJoin(
            amiiboBundle,
            amiiboBundle.id.equalsExp(amiiboBundleRelation.amiiboBundleId),
          ),
          leftOuterJoin(
            amiiboBundleUserPreferences,
            amiiboBundleUserPreferences.amiiboBundleId.equalsExp(
              amiiboBundle.id,
            ),
          ),
          leftOuterJoin(
            amiiboBundleImages,
            amiiboBundleImages.amiiboBundleId.equalsExp(amiiboBundle.id),
          ),
        ])
        ..addColumns([
          amiiboBundle.id,
          jsonGroupArray(amiiboBundlesAlias.amiiboKey),
          jsonGroupArray(amiiboBundleImages.filePath),
          amiiboBundleUserPreferences.boxed,
          amiiboBundleUserPreferences.opened,
        ])
        ..orderBy([
          OrderingTerm.asc(amiiboBundle.id),
          OrderingTerm.asc(amiiboBundleImages.createAt),
        ])
        ..where(amiiboBundleRelation.amiiboKey.equals(key))
        ..groupBy([amiiboBundle.id]),
      'bundle',
    );

    /* final query =
        selectOnly(amiibo).join([
            leftOuterJoin(
              amiiboUserPreferences,
              amiiboUserPreferences.amiiboKey.equalsExp(amiibo.key),
            ),
            leftOuterJoin(
              amiiboImages,
              amiiboImages.amiiboKey.equalsExp(amiibo.key),
              useColumns: false,
            ),
          ])
          ..addColumns([
            ...amiibo.$columns,
            ...amiiboUserPreferences.$columns,
            jsonGroupArray(amiiboImages.filePath),
            jsonGroupArray(
              jsonGroupObject({
                const Constant('id'): subBundleQuery.ref(amiiboBundle.id),
              }),
            ),
          ])
          ..orderBy([OrderingTerm.desc(amiiboImages.createAt)])
          ..where(amiibo.key.equals(key))
          ..groupBy([amiibo.key]); */

    final object = subBundleQuery.columnsByName
        .map<Expression<String>, Expression<Object>>(
          (k, v) => MapEntry(Constant(k), v),
        );
    final query = selectOnly(amiibo)
      ..addColumns([
        ...amiibo.$columns,
        jsonGroupArray(
          jsonGroupObject(
            object,
            /* const Constant('id'): subBundleQuery.ref(amiiboBundle.id),
            const Constant('boxed'): subBundleQuery.ref(
              amiiboBundleUserPreferences.boxed,
            ),
            const Constant('opened'): subBundleQuery.ref(
              amiiboBundleUserPreferences.opened,
            ), */
          ),
        ),
      ])
      ..orderBy([OrderingTerm.desc(amiiboImages.createAt)])
      ..groupBy([amiibo.key]); */

    final query = db.customSelect('''
      SELECT
        a.key AS "amiibo.key",
        a.amiiboSeries AS "amiibo.amiiboSeries",
        a.character AS "amiibo.character",
        a.gameSeries AS "amiibo.gameSeries",
        a.name AS "amiibo.name",
        a.au AS "amiibo.au",
        a.eu AS "amiibo.eu",
        a.jp AS "amiibo.jp",
        a.na AS "amiibo.na",
        a.type AS "amiibo.type",
        a.cardNumber AS "amiibo.cardNumber",
        "amiibo_user_preferences"."boxed" AS "amiibo_user_preferences.boxed", 
        "amiibo_user_preferences"."opened" AS "amiibo_user_preferences.opened",
        "amiibo_user_preferences"."wishlist" AS "amiibo_user_preferences.wishlist",
        json_array("amiibo_images"."file_path") AS images,
        (
          SELECT json_array(
              json_object(
                'id', "amiibo_bundle"."id", 
                'amiiboIds', json_group_array("m"."amiibo_key"), 
                'images', json_array("amiibo_bundle_images"."file_path"),
                'boxed', "amiibo_bundle_user_preferences"."boxed", 
                'opened', "amiibo_bundle_user_preferences"."opened"
              )
            )
            FROM "amiibo_bundle_relation" AS e
            JOIN "amiibo_bundle_relation" AS m ON "e"."amiibo_bundle_id" = "m"."amiibo_bundle_id" 
            JOIN "amiibo_bundle" ON "amiibo_bundle"."id" = "e"."amiibo_bundle_id" 
            LEFT OUTER JOIN "amiibo_bundle_user_preferences" ON "amiibo_bundle_user_preferences"."amiibo_bundle_id" = "amiibo_bundle"."id" 
            LEFT OUTER JOIN "amiibo_bundle_images" ON "amiibo_bundle_images"."amiibo_bundle_id" = "amiibo_bundle"."id"
            WHERE "e"."amiibo_key" = a.key
            GROUP BY "amiibo_bundle"."id"
            ORDER BY "amiibo_bundle"."id" ASC, "amiibo_bundle_images"."create_at" ASC
        ) as bundles
      FROM amiibo a
      LEFT OUTER JOIN "amiibo_user_preferences" ON "amiibo_user_preferences"."amiibo_key" = "a"."key"
      LEFT OUTER JOIN "amiibo_images" ON "amiibo_images"."amiibo_key" = "a"."key"
      WHERE "a"."key" = $key
      ORDER BY "amiibo_images"."created_at" ASC;
''');

    return query;
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
      query.where(switch (searchAttributes.category) {
        .Game => amiibo.gameSeries.like(search),
        .AmiiboSeries => amiibo.amiiboSeries.like(search),
        _ => amiibo.name.like(search) | amiibo.character.like(search),
      });
    }

    final whereExpression = _updateExpression(
      categoryAttributes: categoryAttributes,
      hiddenCategories: hiddenCategories,
    );

    if (whereExpression != null) {
      query.where(whereExpression);
    }
  }

  Subquery get _imageSubQuery => Subquery(
    select(amiiboImages).join(const [])
      ..orderBy([OrderingTerm.desc(amiiboImages.createAt)])
      ..groupBy([amiiboImages.amiiboKey]),
    's',
  );

  Subquery get _bundleSubquery {
    final boxed =
        (amiiboBundleRelation.quantity * amiiboBundleUserPreferences.boxed)
            .sum();
    final opened =
        (amiiboBundleRelation.quantity * amiiboBundleUserPreferences.opened)
            .sum();
    return Subquery(
      select(amiiboBundleRelation).join([
          leftOuterJoin(
            amiiboBundle,
            amiiboBundle.id.equalsExp(amiiboBundle.id),
          ),
          leftOuterJoin(
            amiiboBundleUserPreferences,
            amiiboBundleUserPreferences.amiiboBundleId.equalsExp(
              amiiboBundle.id,
            ),
          ),
        ])
        ..addColumns([boxed, opened])
        ..groupBy([amiiboBundleRelation.amiiboKey]),
      'b',
    );
  }
}

const _figureType = ['Figure', 'Yarn', 'Band'];

mixin _ExpressionBuilder on _$AmiiboCollectionDaoMixin {
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
          s.SortBy.DESC => .desc,
          s.SortBy.ASC => .asc,
        },
      ),
      if (orderBy == s.OrderBy.Owned)
        OrderingTerm(
          expression: amiiboUserPreferences.boxed,
          mode: switch (sortBy) {
            s.SortBy.DESC => .desc,
            s.SortBy.ASC => .asc,
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
    final figureFilter = amiibo.type.isIn(_figureType);
    switch (category) {
      case AmiiboCategory.Cards:
        if (hiddenCategories == HiddenType.Cards) {
          return amiibo.amiiboSeries.isIn(const []);
        }
        where = cardFilter;
        return cards.isEmpty ? where : where & amiibo.amiiboSeries.isIn(cards);
      case AmiiboCategory.Figures:
        if (hiddenCategories == .Figures) {
          return amiibo.amiiboSeries.isIn(const []);
        }
        where = figureFilter;
        return figures.isEmpty
            ? where
            : where & amiibo.amiiboSeries.isIn(figures);
      case .Owned:
        where = Expression.or([
          amiiboUserPreferences.boxed.isBiggerThanValue(0),
          amiiboUserPreferences.opened.isBiggerThanValue(0),
        ]);
        break;
      case .Wishlist:
        where = amiiboUserPreferences.wishlist.equals(true);
        break;
      case .AmiiboSeries:
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
        .Figures => cardsWhere ?? cardFilter,
        .Cards => figuresWhere ?? figureFilter,
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
