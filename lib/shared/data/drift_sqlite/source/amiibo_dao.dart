import 'package:amiibo_network/app/configuration/model/amiibo_category_enum.dart';
import 'package:amiibo_network/app/configuration/model/hidden_types.dart';
import 'package:amiibo_network/app/configuration/model/search_result.dart';
import 'package:amiibo_network/app/configuration/model/sort_enum.dart' as s;
import 'package:amiibo_network/entity/amiibo_info/model/amiibo_user_collection_attributes.dart';
import 'package:amiibo_network/feature/amiibo/application/input/update_amiibo_user_attributes.dart';
import 'package:amiibo_network/shared/data/drift_sqlite/model/drift_joined_amiibo_preferences.dart';
import 'package:amiibo_network/shared/data/drift_sqlite/source/drift_database.dart';
import 'package:amiibo_network/shared/service/info_package.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

part 'amiibo_dao.g.dart';

const _figureType = ['Figure', 'Yarn', 'Band'];

@DriftAccessor(include: const {'amiibo_tables.drift'})
class AmiiboDao extends DatabaseAccessor<AppDatabase>
    with _$AmiiboDaoMixin, _ExpressionBuilder {
  AmiiboDao(super.db);

  Stream<List<AmiiboDriftModel>> fetchAllStream({
    required CategoryAttributes categoryAttributes,
    SearchAttributes? searchAttributes,
    s.OrderBy orderBy = s.OrderBy.NA,
    s.SortBy sortBy = s.SortBy.DESC,
    List<String> figures = const [],
    List<String> cards = const [],
    HiddenType? hiddenCategories,
  }) {
    final query = _fetchAll(
      categoryAttributes: categoryAttributes,
      searchAttributes: searchAttributes,
      orderBy: orderBy,
      sortBy: sortBy,
      figures: figures,
      cards: cards,
      hiddenCategories: hiddenCategories,
    );
    return query.map(_toModel).watch();
  }

  Future<List<AmiiboDriftModel>> fetchAll({
    required CategoryAttributes categoryAttributes,
    SearchAttributes? searchAttributes,
    s.OrderBy orderBy = s.OrderBy.NA,
    s.SortBy sortBy = s.SortBy.DESC,
    List<String> figures = const [],
    List<String> cards = const [],
    HiddenType? hiddenCategories,
  }) async {
    final query = _fetchAll(
      categoryAttributes: categoryAttributes,
      searchAttributes: searchAttributes,
      orderBy: orderBy,
      sortBy: sortBy,
      figures: figures,
      cards: cards,
      hiddenCategories: hiddenCategories,
    );

    final result = await query.map(_toModel).get();
    return result;
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

  Stream<AmiiboDetailDriftModel?> fetchByKeyStreamV2(int key) {
    final query = _fetchByKeyQueryV2(key);
    return query
        .map((s) => AmiiboDetailDriftModel.fromJson(s.data))
        .watchSingleOrNull();
  }

  Future<AmiiboDetailDriftModel?> fetchByKeyV2(int key) async {
    final query = _fetchByKeyQueryV2(key);
    final result = await query
        .map((s) => AmiiboDetailDriftModel.fromJson(s.data))
        .getSingleOrNull();
    return result;
  }

  Selectable<QueryRow> _fetchByKeyQueryV2(int key) {
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

  Stream<AmiiboDriftModel?> fetchByKeyStream(int key) {
    final query = _fetchByKeyQuery(key);
    return query.map(_toModel).watchSingleOrNull();
  }

  Future<AmiiboDriftModel?> fetchByKey(int key) async {
    final query = _fetchByKeyQuery(key);
    final result = await query.map(_toModel).getSingleOrNull();
    return result;
  }

  JoinedSelectStatement<HasResultSet, dynamic> _fetchByKeyQuery(int key) {
    final imagesQuery = _imageSubQuery;
    final bundleSubquery = _bundleSubquery;
    final query = select(amiibo).join([
      leftOuterJoin(
        amiiboUserPreferences,
        amiibo.key.equalsExp(amiiboUserPreferences.amiiboKey),
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
    ])..where(amiibo.key.equals(key));
    return query;
  }

  @visibleForTesting
  Future<TypedResult?> fetchByKeyTest(int key) async {
    final imagesQuery = _imageSubQuery;
    final bundleSubquery = _bundleSubquery;
    final query = select(amiibo).join([
      leftOuterJoin(
        amiiboUserPreferences,
        amiibo.key.equalsExp(amiiboUserPreferences.amiiboKey),
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
    ])..where(amiibo.key.equals(key));

    final result = await query.getSingleOrNull();
    return result;
  }

  Future<void> insertAll({
    required List<AmiiboTable> amiibosData,
    required List<AmiiboBundleTable> amiiboBundlesData,
    required List<AmiiboImagesCompanion> amiiboImagesData,
    required List<AmiiboBundleImagesCompanion> amiiboBundleImagesData,
    required List<AmiiboBundleUserPreferencesCompanion> amiiboBundlePreferences,
    required List<AmiiboBundleRelationCompanion> amiiboBundleRelationData,
    required List<AmiiboUserPreferencesCompanion> amiiboPreferences,
  }) async {
    await batch((batch) {
      if (InfoPackage.instance.isUpsertFeatureAvailable) {
        batch.insertAllOnConflictUpdate(amiibo, amiibosData);
        batch.insertAllOnConflictUpdate(amiiboBundle, amiiboBundlesData);
      } else {
        batch.insertAll(amiibo, amiibosData, mode: .insertOrReplace);
        batch.insertAll(
          amiiboBundle,
          amiiboBundlesData,
          mode: .insertOrReplace,
        );
      }
      batch
        ..insertAll(
          amiiboUserPreferences,
          amiiboPreferences,
          mode: .insertOrIgnore,
        )
        ..insertAll(
          amiiboBundleUserPreferences,
          amiiboBundlePreferences,
          mode: .insertOrIgnore,
        )
        ..deleteAll(amiiboBundleRelation)
        ..insertAll(
          amiiboBundleRelation,
          amiiboBundleRelationData,
          mode: .insertOrIgnore,
        )
        ..deleteAll(amiiboBundleImages)
        ..insertAll(
          amiiboBundleImages,
          amiiboBundleImagesData,
          mode: .insertOrIgnore,
        )
        ..deleteAll(amiiboImages)
        ..insertAll(amiiboImages, amiiboImagesData, mode: .insertOrIgnore);
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
      .AmiiboSeries => amiibo.amiiboSeries,
      .Name => amiibo.name,
      .Game => amiibo.gameSeries,
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
    await update(amiiboUserPreferences).write(
      AmiiboUserPreferencesCompanion(
        boxed: const Value(0),
        opened: const Value(0),
        wishlist: const Value(false),
      ),
    );
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
                wished: true,
              ),
              OwnedUserAttributes(opened: final opened, boxed: final boxed) => (
                opened: opened,
                boxed: boxed,
                wished: false,
              ),
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

  Subquery get _imageSubQuery => Subquery(
    select(amiiboImages).join([])
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

  AmiiboDriftModel _toModel(TypedResult p0) {
    /// remove suffix s from amiibo_images subquery
    final data = <String, dynamic>{
      for (final entry in p0.rawData.data.entries)
        entry.key.startsWith(r's.') ? entry.key.substring(2) : entry.key:
            entry.value,
    };

    return AmiiboDriftModel.fromJson(data);
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
