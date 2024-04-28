import 'package:amiibo_network/data/common.dart';
import 'package:amiibo_network/data/sqlite/dao/SQLite/amiibo_sqlite.dart';
import 'package:amiibo_network/data/sqlite/model/expression.dart';
import 'package:amiibo_network/enum/amiibo_category_enum.dart';
import 'package:amiibo_network/enum/hidden_types.dart';
import 'package:amiibo_network/enum/sort_enum.dart';
import 'package:amiibo_network/model/search_result.dart';
import 'dart:convert';
import 'package:amiibo_network/model/amiibo.dart';
import 'package:amiibo_network/model/stat.dart';
import 'package:amiibo_network/model/update_amiibo_user_attributes.dart';

interface class Service {
  final AmiiboSQLite _dao = AmiiboSQLite();

  Future<Amiibo?> fetchOne(int key) {
    return _dao.fetchByKey(key);
  }

  Future<List<Amiibo>> fetchAllAmiibo() =>
      _dao.fetchAll();

  Future<List<Stat>> fetchStats({
    required AmiiboCategory category,
    List<String> figures = const [],
    List<String> cards = const [],
    List<String> series = const [],
    HiddenType? hiddenCategories,
    bool group = false,
  }) async {
    late Expression expression;
    switch (category) {
      case AmiiboCategory.All:
        expression = And();
        break;
      case AmiiboCategory.Custom:
        expression = Bracket(InCond.inn('type', figureType) &
                InCond.inn('amiiboSeries', figures)) |
            Bracket(
                Cond.eq('type', 'Card') & InCond.inn('amiiboSeries', cards));
        break;
      case AmiiboCategory.Figures:
        expression = InCond.inn('type', figureType);
        break;
      case AmiiboCategory.Cards:
        expression = Cond.eq('type', 'Card');
        break;
      case AmiiboCategory.AmiiboSeries:
        expression = InCond.inn('amiiboSeries', series);
        break;
      default:
        break;
    }
    if (hiddenCategories != null) {
      expression = (hiddenCategories == HiddenType.Figures
              ? InCond.notInn('type', figureType)
              : Cond.ne('type', 'Card')) &
          expression;
    }
    String? where = expression.toString();
    List<dynamic>? args = expression.args;
    if (where.isEmpty || args.isEmpty) where = args = null;
    final result = await _dao.fetchSum(where, args, group);
    return result.map<Stat>((e) => Stat.fromJson(e)).toList();
  }

  Future<List<Amiibo>> fetchByCategory({
    required CategoryAttributes categoryAttributes,
    required SearchAttributes? searchAttributes,
    OrderBy orderBy = OrderBy.NA,
    SortBy sortBy = SortBy.DESC,
    List<String> figures = const [],
    List<String> cards = const [],
    HiddenType? hiddenCategories,
  }) {
    final category = categoryAttributes.category;
    final expression = _updateExpression(
      category: category,
      search: searchAttributes?.search,
      figures: figures,
      cards: cards,
      hiddenCategories: hiddenCategories,
    );
    if (orderBy == OrderBy.CardNumber &&
        (hiddenCategories == HiddenType.Cards ||
            category == AmiiboCategory.Figures)) {
      orderBy = OrderBy.NA;
    }
    final order = _order(orderBy, sortBy);
    String? where = expression.toString();
    List<dynamic>? args = expression.args;
    if (where.isEmpty || args.isEmpty) where = args = null;
    return _dao.fetchByColumn(where, args, order);
  }

  String _order(OrderBy orderBy, SortBy sortBy) {
    final String order = orderBy.name;
    StringBuffer orderBuffer = StringBuffer();
    final String sort = sortBy.name;
    switch (orderBy) {
      case OrderBy.NA:
      case OrderBy.JP:
      case OrderBy.AU:
      case OrderBy.EU:
      case OrderBy.CardNumber:
        orderBuffer.write('$order IS NULL, $order $sort');
        break;
      case OrderBy.Type:
        orderBuffer.write('CASE WHEN type = "Figure" THEN 1 '
            'WHEN type = "Yarn" OR type = "Band" THEN 2 ELSE 3 END, amiiboSeries, key');
        break;
      case OrderBy.Owned:
      case OrderBy.Wishlist:
        final bool asc = sortBy == SortBy.ASC;
        final int _then = asc ? 1 : 0;
        final int _else = asc ? 0 : 1;
        orderBuffer.write(
            'CASE WHEN ($order IS NULL OR $order = 0) THEN $_then ELSE $_else END, key $sort');
        break;
      default:
        orderBuffer.write('$order $sort');
        break;
    }
    return orderBuffer.toString();
  }

  Expression _updateExpression({
    required AmiiboCategory category,
    String? search,
    List<String> figures = const [],
    List<String> cards = const [],
    HiddenType? hiddenCategories,
  }) {
    if (hiddenCategories != null &&
        ((hiddenCategories == HiddenType.Cards &&
                category == AmiiboCategory.Cards) ||
            (hiddenCategories == HiddenType.Figures &&
                category == AmiiboCategory.Figures))) {
      category = cards.isEmpty || figures.isEmpty
          ? AmiiboCategory.All
          : AmiiboCategory.Custom;
    }
    late Expression where;
    switch (category) {
      case AmiiboCategory.Owned:
      case AmiiboCategory.Wishlist:
        where = Cond.iss(search ?? category.name, '1');
        break;
      case AmiiboCategory.Figures:
        where = InCond.inn('type', figureType);
        if (search != null) {
          where &= Cond.eq('amiiboSeries', search);
        }
        break;
      case AmiiboCategory.Cards:
        where = Cond.eq('type', 'Card');
        if (search != null) {
          where &= Cond.eq('amiiboSeries', search);
        }
        break;
      /* case AmiiboCategory.Game:
        where = Cond.like('gameSeries', '%$search%');
        break;
      case AmiiboCategory.Name:
        where = Cond.like('name', '%$search%') |
            Cond.like('character', '%$search%');
        break; */
      case AmiiboCategory.AmiiboSeries:
        where = Cond.like('amiiboSeries', '%$search%');
        break;
      case AmiiboCategory.Custom:
        final figuresWhere = Bracket(InCond.inn('type', figureType) &
            InCond.inn('amiiboSeries', figures));
        final cardsWhere = Bracket(
            Cond.eq('type', 'Card') & InCond.inn('amiiboSeries', cards));
        if (hiddenCategories != null) {
          where = hiddenCategories == HiddenType.Figures
              ? cardsWhere
              : figuresWhere;
        } else {
          where = figuresWhere | cardsWhere;
        }
        break;
      case AmiiboCategory.All:
      default:
        where = And();
    }
    if (category != AmiiboCategory.Custom && hiddenCategories != null) {
      final figuresIgnore = InCond.notInn('type', figureType);
      final cardsIgnore = Cond.ne('type', 'Card');
      where = (hiddenCategories == HiddenType.Figures
              ? figuresIgnore
              : cardsIgnore) &
          (where.args.isEmpty ? where : Bracket(where));
    }
    return where;
  }

  /* Future<List<Amiibo>> fetchByCategory(QueryBuilder builder, [String? orderBy]) {
    String? where = builder.where.toString();
    List<dynamic>? args = builder.where.args;
    if (where.isEmpty || args.isEmpty) where = args = null;
    return dao.fetchByColumn(where, args, orderBy);
  } */

  Future<String> jsonFileDB() async {
    final List<Amiibo> amiibos = await _dao.fetchAll();
    return jsonEncode(amiibos);
  }

  Future<void> update(List<UpdateAmiiboUserAttributes> amiibos) =>
      _dao.insertImport(amiibos);

  Future<List<String>> fetchDistinct({
    required CategoryAttributes categoryAttributes,
    required SearchAttributes? searchAttributes,
    OrderBy orderBy = OrderBy.NA,
    SortBy sortBy = SortBy.DESC,
    List<String>? figures,
    List<String>? cards,
    HiddenType? hiddenCategories,
  }) {
    final category = categoryAttributes.category;
    final expression = _updateExpression(
      category: category,
      search: searchAttributes?.search,
      figures: figures ?? const [],
      cards: cards ?? const [],
      hiddenCategories: hiddenCategories,
    );
    if (orderBy == OrderBy.CardNumber &&
        (hiddenCategories == HiddenType.Cards ||
            category == AmiiboCategory.Figures)) {
      orderBy = OrderBy.NA;
    }
    final order = _order(orderBy, sortBy);
    String? where = expression.toString();
    List<Object>? args = expression.args;
    if (where.isEmpty || args.isEmpty) where = args = null;
    return _dao.fetchDistinct('amiibo', where, args, order);
  }

  Future<List<String>> search({
    required SearchAttributes searchAttributes,
    HiddenType? hidden,
  }) async {
    Expression? exp = _whereExpression(
      searchAttributes.category,
      searchAttributes.search,
    );
    if (exp == null) return const [];
    if (hidden != null) {
      exp = (hidden == HiddenType.Cards
              ? Cond.ne('type', 'Card')
              : InCond.notInn('type', figureType)) &
          Bracket(exp);
    }
    String? where = exp.toString();
    List<dynamic>? args = exp.args;
    if (where.isEmpty || args.isEmpty) where = args = null;
    return _dao.fetchLimit(where, args, 10, searchAttributes.category.name);
  }

  Expression? _whereExpression(SearchCategory category, String filter) {
    if (filter.isEmpty) return null;
    switch (category) {
      case SearchCategory.Name:
        return Cond.like('character', '%$filter%') |
            Cond.like('name', '%$filter%');
      case SearchCategory.Game:
        return Cond.like('gameSeries', '%$filter%');
      case SearchCategory.AmiiboSeries:
        return Cond.like('amiiboSeries', '%$filter%');
      default:
        return And();
    }
  }

  Future<void> resetCollection() async {
    await _dao.updateAll('amiibo', {'wishlist': 0, 'owned': 0});
  }
}
