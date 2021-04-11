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
    StateNotifierProvider<OrderProvider, OrderBy>((ref) {
  final preferences = ref.watch(preferencesProvider);
  final int order = preferences.getInt(orderPreference) ?? 0;
  return OrderProvider(ref.read, order);
});

final sortByProvider = StateNotifierProvider<SortProvider, SortBy>((ref) {
    final preferences = ref.watch(preferencesProvider);
    final int sort = preferences.getInt(sortPreference) ?? 0;
    return SortProvider(ref.read, sort);
  },
);

final queryProvider = StateNotifierProvider<QueryProvider, Search>(
  (ref) {
    final preferences = ref.watch(preferencesProvider);
    final _customFigures =
        preferences.getStringList(sharedCustomFigures) ?? <String>[];
    final _customCards =
        preferences.getStringList(sharedCustomCards) ?? <String>[];
    return QueryProvider(ref.read, _customFigures, _customCards);
  },
);

final expressionProvider = StateNotifierProvider.autoDispose<
    StateController<QueryBuilder>, QueryBuilder>((ref) {
  final StateController<QueryBuilder> controller =
      StateController<QueryBuilder>(QueryBuilder());
  final provider = ref.watch(queryProvider.notifier);
  final order = ref.watch(orderCategoryProvider.notifier);
  final sort = ref.watch(sortByProvider.notifier);

  final removeListener = provider.addListener((query) {
    Expression where;
    switch (query.category) {
      case AmiiboCategory.Owned:
      case AmiiboCategory.Wishlist:
        where = Cond.iss(query.search ?? describeEnum(query.category), '1');
        break;
      case AmiiboCategory.Figures:
        where = InCond.inn('type', ['Figure', 'Yarn']);
        break;
      case AmiiboCategory.FigureSeries:
        where = InCond.inn('type', ['Figure', 'Yarn']) &
            Cond.eq('amiiboSeries', query.search!);
        break;
      case AmiiboCategory.CardSeries:
        where =
            Cond.eq('type', 'Card') & Cond.eq('amiiboSeries', query.search!);
        break;
      case AmiiboCategory.Cards:
        where = Cond.eq('type', 'Card');
        break;
      case AmiiboCategory.Game:
        where = Cond.like('gameSeries', '%${query.search}%');
        break;
      case AmiiboCategory.Name:
        where = Cond.like('name', '%${query.search}%') |
            Cond.like('character', '%${query.search}%');
        break;
      case AmiiboCategory.AmiiboSeries:
        where = Cond.like('amiiboSeries', '%${query.search}%');
        break;
      case AmiiboCategory.Custom:
        where = Bracket(InCond.inn('type', ['Figure', 'Yarn']) &
                InCond.inn('amiiboSeries', query.customFigures!)) |
            Bracket(Cond.eq('type', 'Card') &
                InCond.inn('amiiboSeries', query.customCards!));
        break;
      case AmiiboCategory.All:
      default:
        where = And();
    }
    controller.state = controller.state.copyWith(where: where);
  });

  final removeOrderListener = order.addListener((order) {
    controller.state = controller.state.copyWith(orderBy: describeEnum(order));
  });

  final removeSortListener = sort.addListener((sort) {
    controller.state = controller.state.copyWith(sortBy: describeEnum(sort));
  });

  ref.onDispose(() {
    removeListener();
    removeOrderListener();
    removeSortListener();
  });

  return controller;
});

final AutoDisposeFutureProvider<List<String>>? figuresProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final service = ref.watch(serviceProvider);

  final list = await service.fetchDistinct(
    column: ['amiiboSeries'],
    expression: InCond.inn('type', ['Figure', 'Yarn']),
    orderBy: 'amiiboSeries',
  );

  ref.maintainState = true;

  return list;
});

final AutoDisposeFutureProvider<List<String>>? cardsProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final service = ref.watch(serviceProvider);

  final list = await service.fetchDistinct(
    column: ['amiiboSeries'],
    expression: Cond.eq('type', 'Card'),
    orderBy: 'amiiboSeries',
  );

  ref.maintainState = true;

  return list;
});

class SortProvider extends StateNotifier<SortBy> {
  SortProvider(this._read, int mode) : super(SortBy.values[mode]);

  final Reader _read;

  Future<void> changeState(SortBy? mode) async {
    if (mode != null && mode != state) {
      await _read(preferencesProvider).setInt(sortPreference, mode.index);
      state = mode;
    }
  }
}

class OrderProvider extends StateNotifier<OrderBy> {
  OrderProvider(this._read, int mode) : super(OrderBy.values[mode]);

  final Reader _read;

  Future<void> changeState(OrderBy? mode) async {
    if (mode != null && mode != state) {
      await _read(preferencesProvider).setInt(orderPreference, mode.index);
      state = mode;
    }
  }
}

class QueryProvider extends StateNotifier<Search> {
  static final Function deepEq =
      const DeepCollectionEquality.unordered().equals;
  static bool? checkEquality(List<String>? eq1, List<String>? eq2) =>
      deepEq(eq1, eq2);
  final Reader _read;
  QueryProvider(this._read, List<String> figures, List<String> cards)
      : super(Search(
            category: AmiiboCategory.All,
            customFigures: figures,
            customCards: cards));

  void updateQuery(Query query) {
    if (query != state) state = query as Search;
  }

  void updateOption(Search result) {
    if (result.category != state.category || result.search != state.search)
      state = state.copyWith(
        category: result.category,
        search: result.search,
      );
  }

  Future<void> updateCustom(List<String>? figures, List<String>? cards) async {
    final bool equal = checkEquality(figures, state.customFigures)! &&
        checkEquality(cards, state.customCards)!;
    if (!equal) {
      final preferences = _read(preferencesProvider);
      await preferences.setStringList(sharedCustomCards, cards!);
      await preferences.setStringList(sharedCustomFigures, figures!);
      state = state.copyWith(
        customCards: cards,
        customFigures: figures,
      );
    }
  }
}
