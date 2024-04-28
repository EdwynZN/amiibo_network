import 'package:amiibo_network/riverpod/preferences_provider.dart';
import 'package:amiibo_network/riverpod/service_provider.dart';
import 'package:amiibo_network/utils/preferences_constants.dart';
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

final filterProvider = Provider.autoDispose(
  (ref) {
    final query = ref.watch(queryProvider);
    final hiddenType = ref.watch(hiddenCategoryProvider);
    return Filter(
      categoryAttributes: query.categoryAttributes,
      searchAttributes: query.searchAttributes,
      orderBy: query.orderBy,
      sortBy: query.sortBy,
      hiddenType: hiddenType,
    );
  },
);

final figuresProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final service = ref.watch(serviceProvider.notifier);

  final list = await service.fetchDistinct(
    categoryAttributes:
        const CategoryAttributes(category: AmiiboCategory.Figures),
    searchAttributes: null,
    orderBy: OrderBy.AmiiboSerie,
    sortBy: SortBy.ASC,
  );

  ref.keepAlive();

  return list;
});

final cardsProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final service = ref.watch(serviceProvider.notifier);

  final list = await service.fetchDistinct(
    searchAttributes: null,
    categoryAttributes:
        const CategoryAttributes(category: AmiiboCategory.Cards),
    orderBy: OrderBy.AmiiboSerie,
    sortBy: SortBy.ASC,
  );

  ref.keepAlive();

  return list;
});

final queryProvider = StateNotifierProvider<QueryBuilderProvider, Search>(
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
    final category = _customCards.isEmpty && _customFigures.isEmpty
        ? AmiiboCategory.All
        : AmiiboCategory.AmiiboSeries;
    final search = Search(
      categoryAttributes: CategoryAttributes(
        category: category,
        cards: _customCards,
        figures: _customFigures,
      ),
      orderBy: orderBy,
      sortBy: sortBy,
    );
    final queryBuilder = QueryBuilderProvider(
      ref: ref,
      customCards: _customCards,
      customFigures: _customFigures,
      search,
    );

    return queryBuilder;
  },
);

class QueryBuilderProvider extends StateNotifier<Search> {
  static final Function deepEq =
      const DeepCollectionEquality.unordered().equals;
  static bool? checkEquality(List<String>? eq1, List<String>? eq2) =>
      deepEq(eq1, eq2);

  final Ref ref;
  late Search _previousNotSearch;

  List<String> _customFigures;
  List<String> _customCards;

  QueryBuilderProvider(
    super.state, {
    required this.ref,
    required List<String> customFigures,
    required List<String> customCards,
  })  : _previousNotSearch = state,
        _customFigures = customFigures,
        _customCards = customCards;

  bool get isSearch => state.searchAttributes != null;

  List<String> get customFigures => List<String>.of(_customFigures);
  List<String> get customCards => List<String>.of(_customCards);

  void restart() {
    if (_previousNotSearch == state) return;
    state = _previousNotSearch;
  }

  void updateOption(SearchAttributes search) {
    if (search == state.searchAttributes) return;

    state = state.copyWith(searchAttributes: search);
    if (!isSearch) {
      _previousNotSearch = state;
    }
  }

  void updateTile(CategoryAttributes category) {
    if (category == state.categoryAttributes) {
      return;
    }

    if (category.category == AmiiboCategory.AmiiboSeries) {
      category = category.copyWith(
        cards: _customCards,
        figures: _customFigures,
      );
    }

    state =
        state.copyWith(categoryAttributes: category, searchAttributes: null);
    if (!isSearch) {
      _previousNotSearch = state;
    }
  }

  Future<void> updateCustom(List<String>? figures, List<String>? cards) async {
    final bool equal = checkEquality(figures, _customFigures)! &&
        checkEquality(cards, _customCards)!;
    if (!equal) {
      final preferences = ref.read(preferencesProvider);
      await preferences.setStringList(sharedCustomCards, cards!);
      await preferences.setStringList(sharedCustomFigures, figures!);
      _customFigures = figures;
      _customCards = cards;
      if (state.categoryAttributes.category == AmiiboCategory.AmiiboSeries) {
        state = state.copyWith.categoryAttributes(
          figures: figures,
          cards: cards,
        );
      }
    }
  }

  Future<void> changeSortAndOrder(OrderBy? orderBy, SortBy? sortBy) async {
    Search _state = state.copyWith();
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
