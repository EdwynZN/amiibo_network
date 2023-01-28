import 'package:amiibo_network/enum/hidden_types.dart';
import 'package:amiibo_network/riverpod/preferences_provider.dart';
import 'package:amiibo_network/riverpod/service_provider.dart';
import 'package:amiibo_network/utils/preferences_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:amiibo_network/enum/amiibo_category_enum.dart';
import 'package:amiibo_network/enum/sort_enum.dart';
import 'package:amiibo_network/riverpod/repository_provider.dart';
import 'package:collection/collection.dart';
import 'package:amiibo_network/model/search_result.dart';

const _figures = {AmiiboCategory.FigureSeries, AmiiboCategory.Figures};
const _cards = {AmiiboCategory.CardSeries, AmiiboCategory.Cards};

final orderCategoryProvider =
    Provider.autoDispose<OrderBy>((ref) => ref.watch(queryProvider).orderBy);

final sortByProvider =
    Provider.autoDispose<SortBy>((ref) => ref.watch(queryProvider).sortBy);

final querySearchProvider = Provider.autoDispose<Search>((ref) {
  ref.watch(queryProvider);
  return ref.watch(queryProvider.notifier).search;
});

final figuresProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final service = ref.watch(serviceProvider.notifier);

  final list = await service.fetchDistinct(
    column: ['amiiboSeries'],
    expression: InCond.inn('type', figureType),
    orderBy: 'amiiboSeries',
  );

  ref.keepAlive();

  return list;
});

final cardsProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final service = ref.watch(serviceProvider.notifier);

  final list = await service.fetchDistinct(
    column: ['amiiboSeries'],
    expression: Cond.eq('type', 'Card'),
    orderBy: 'amiiboSeries',
  );

  ref.keepAlive();

  return list;
});

final queryProvider = StateNotifierProvider<QueryBuilderProvider, QueryBuilder>(
  (ref) {
    final preferences = ref.watch(preferencesProvider);
    final _customFigures =
        preferences.getStringList(sharedCustomFigures) ?? <String>[];
    final _customCards =
        preferences.getStringList(sharedCustomCards) ?? <String>[];
    final int order = (preferences.getInt(orderPreference) ?? 0)
        .clamp(0, OrderBy.values.length - 1);
    final int sort = (preferences.getInt(sortPreference) ?? 0)
        .clamp(0, SortBy.values.length - 1);

    final orderBy = OrderBy.values[order];
    final sortBy = SortBy.values[sort];
    final search = Search(
      category: _customCards.isEmpty && _customFigures.isEmpty
          ? AmiiboCategory.All
          : AmiiboCategory.Custom,
      customCards: _customCards,
      customFigures: _customFigures,
    );
    final queryBuilder = QueryBuilderProvider(
      ref,
      search,
      orderBy,
      sortBy,
    );

    ref.listen(hiddenCategoryProvider, (_, next) {
      queryBuilder._updateExpression();
    }, fireImmediately: false);

    return queryBuilder;
  },
);

class QueryBuilderProvider extends StateNotifier<QueryBuilder> {
  static final Function deepEq =
      const DeepCollectionEquality.unordered().equals;
  static bool? checkEquality(List<String>? eq1, List<String>? eq2) =>
      deepEq(eq1, eq2);

  final Ref ref;
  late Search _previousNotSearch;
  Search _query;

  QueryBuilderProvider(
    this.ref,
    this._query,
    OrderBy _orderBy,
    SortBy _sortBy,
  ) : super(
          QueryBuilder(
            where: And(),
            sortBy: _sortBy,
            orderBy: _orderBy,
          ),
        ) {
    _previousNotSearch = _query;
    if (_query.category != AmiiboCategory.All) {
      _updateExpression();
    }
  }

  Search get search => _query;
  QueryBuilder get query => state;

  bool get isSearch {
    final category = search.category;
    if (category == AmiiboCategory.Game ||
        category == AmiiboCategory.Name ||
        category == AmiiboCategory.AmiiboSeries) {
      return true;
    }
    return false;
  }

  List<String> get customFigures => List<String>.of(_query.customFigures!);
  List<String> get customCards => List<String>.of(_query.customCards!);

  void _updateExpression() {
    final hiddenCategory = ref.read(hiddenCategoryProvider);
    if (hiddenCategory != null &&
        ((hiddenCategory == HiddenType.Cards &&
                _cards.contains(search.category)) ||
            (hiddenCategory == HiddenType.Figures &&
                _figures.contains(search.category)))) {
      final search = _query;
      if ((search.customCards == null || search.customCards!.isEmpty) ||
          (search.customFigures == null || search.customFigures!.isEmpty)) {
        _query = search.copyWith(category: AmiiboCategory.All, search: 'All');
      } else {
        _query =
            search.copyWith(category: AmiiboCategory.Custom, search: 'Custom');
      }
    }
    late Expression where;
    switch (_query.category) {
      case AmiiboCategory.Owned:
      case AmiiboCategory.Wishlist:
        where = Cond.iss(_query.search ?? describeEnum(_query.category), '1');
        break;
      case AmiiboCategory.Figures:
        where = InCond.inn('type', figureType);
        break;
      case AmiiboCategory.FigureSeries:
        where = InCond.inn('type', figureType) &
            Cond.eq('amiiboSeries', _query.search!);
        break;
      case AmiiboCategory.CardSeries:
        where =
            Cond.eq('type', 'Card') & Cond.eq('amiiboSeries', _query.search!);
        break;
      case AmiiboCategory.Cards:
        where = Cond.eq('type', 'Card');
        break;
      case AmiiboCategory.Game:
        where = Cond.like('gameSeries', '%${_query.search}%');
        break;
      case AmiiboCategory.Name:
        where = Cond.like('name', '%${_query.search}%') |
            Cond.like('character', '%${_query.search}%');
        break;
      case AmiiboCategory.AmiiboSeries:
        where = Cond.like('amiiboSeries', '%${_query.search}%');
        break;
      case AmiiboCategory.Custom:
        final figuresWhere = Bracket(InCond.inn('type', figureType) &
            InCond.inn('amiiboSeries', _query.customFigures!));
        final cardsWhere = Bracket(Cond.eq('type', 'Card') &
            InCond.inn('amiiboSeries', _query.customCards!));
        if (hiddenCategory != null) {
          where =
              hiddenCategory == HiddenType.Figures ? cardsWhere : figuresWhere;
        } else {
          where = figuresWhere | cardsWhere;
        }
        break;
      case AmiiboCategory.All:
      default:
        where = And();
    }
    if (_query.category != AmiiboCategory.Custom && hiddenCategory != null) {
      final figuresIgnore = InCond.notInn('type', figureType);
      final cardsIgnore = Cond.ne('type', 'Card');
      where =
          (hiddenCategory == HiddenType.Figures ? figuresIgnore : cardsIgnore) &
              (where.args.isEmpty ? where : Bracket(where));
    }
    final OrderBy orderBy = _figures.contains(_query.category) &&
            state.orderBy == OrderBy.CardNumber
        ? OrderBy.NA
        : state.orderBy;

    if (where != state.where || orderBy != state.orderBy) {
      print('diff');
      state = state.copyWith(where: where, orderBy: orderBy);
    }
  }

  void restart() {
    if (_previousNotSearch == _query) return;
    _query = _previousNotSearch;
    _updateExpression();
  }

  void updateOption(Search result) {
    if (result.category == _query.category && result.search == _query.search)
      return;
    _query = _query.copyWith(
      category: result.category,
      search: result.search,
    );
    if (!isSearch) {
      _previousNotSearch = _query;
    }
    _updateExpression();
  }

  Future<void> updateCustom(List<String>? figures, List<String>? cards) async {
    final bool equal = checkEquality(figures, _query.customFigures)! &&
        checkEquality(cards, _query.customCards)!;
    if (!equal) {
      final preferences = ref.read(preferencesProvider);
      await preferences.setStringList(sharedCustomCards, cards!);
      await preferences.setStringList(sharedCustomFigures, figures!);
      _query = _query.copyWith(customCards: cards, customFigures: figures);
      _updateExpression();
    }
  }

  Future<void> changeSortAndOrder(OrderBy? orderBy, SortBy? sortBy) async {
    QueryBuilder _state = state.copyWith();
    if (orderBy != null && orderBy != state.orderBy) {
      await ref
          .read(preferencesProvider)
          .setInt(orderPreference, orderBy.index);
      _state = _state.copyWith(orderBy: orderBy);
    }
    if (sortBy != null && sortBy != state.sortBy) {
      await ref.read(preferencesProvider).setInt(sortPreference, sortBy.index);
      _state = _state.copyWith(sortBy: sortBy);
    }
    if (_state != state) state = _state;
  }
}
