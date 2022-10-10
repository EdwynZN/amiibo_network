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

  ref.maintainState = true;

  return list;
});

final cardsProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final service = ref.watch(serviceProvider.notifier);

  final list = await service.fetchDistinct(
    column: ['amiiboSeries'],
    expression: Cond.eq('type', 'Card'),
    orderBy: 'amiiboSeries',
  );

  ref.maintainState = true;

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
    return QueryBuilderProvider(
      ref.read,
      search,
      orderBy,
      sortBy,
    );
  },
);

class QueryBuilderProvider extends StateNotifier<QueryBuilder> {
  static final Function deepEq =
      const DeepCollectionEquality.unordered().equals;
  static bool? checkEquality(List<String>? eq1, List<String>? eq2) =>
      deepEq(eq1, eq2);

  static const Set<AmiiboCategory> figuresCategories = {
    AmiiboCategory.FigureSeries,
    AmiiboCategory.Figures,
  };

  final Reader _read;
  Search _query;

  QueryBuilderProvider(
    this._read,
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
        if (_query.category != AmiiboCategory.All) {
          _updateExpression();
        }
      }

  Search get search => _query;
  QueryBuilder get query => state;

  List<String> get customFigures => List<String>.of(_query.customFigures!);
  List<String> get customCards => List<String>.of(_query.customCards!);

  void _updateExpression() {
    late final Expression where;
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
        where = Bracket(InCond.inn('type', figureType) &
                InCond.inn('amiiboSeries', _query.customFigures!)) |
            Bracket(Cond.eq('type', 'Card') &
                InCond.inn('amiiboSeries', _query.customCards!));
        break;
      case AmiiboCategory.All:
      default:
        where = And();
    }
    final OrderBy orderBy = figuresCategories.contains(_query.category) &&
            state.orderBy == OrderBy.CardNumber
        ? OrderBy.NA
        : state.orderBy;

    if (where != state.where || orderBy != state.orderBy) {
      state = state.copyWith(where: where, orderBy: orderBy);
    }
  }

  void updateOption(Search result) {
    if (result.category == _query.category && result.search == _query.search)
      return;
    _query = _query.copyWith(
      category: result.category,
      search: result.search,
    );
    _updateExpression();
  }

  Future<void> updateCustom(List<String>? figures, List<String>? cards) async {
    final bool equal = checkEquality(figures, _query.customFigures)! &&
        checkEquality(cards, _query.customCards)!;
    if (!equal) {
      final preferences = _read(preferencesProvider);
      await preferences.setStringList(sharedCustomCards, cards!);
      await preferences.setStringList(sharedCustomFigures, figures!);
      _query = _query.copyWith(customCards: cards, customFigures: figures);
      _updateExpression();
    }
  }

  Future<void> changeSortAndOrder(OrderBy? orderBy, SortBy? sortBy) async {
    QueryBuilder _state = state.copyWith();
    if (orderBy != null && orderBy != state.orderBy) {
      await _read(preferencesProvider).setInt(orderPreference, orderBy.index);
      _state = _state.copyWith(orderBy: orderBy);
    }
    if (sortBy != null && sortBy != state.sortBy) {
      await _read(preferencesProvider).setInt(sortPreference, sortBy.index);
      _state = _state.copyWith(sortBy: sortBy);
    }
    if (_state != state) state = _state;
  }
}
