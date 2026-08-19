import 'package:amiibo_network/app/configuration/model/amiibo_category_enum.dart';
import 'package:amiibo_network/app/configuration/model/search_result.dart';
import 'package:amiibo_network/app/configuration/model/sort_enum.dart';
import 'package:amiibo_network/app/configuration/preferences_provider.dart';
import 'package:amiibo_network/app/configuration/service_provider.dart';
import 'package:amiibo_network/app/state/preferences_provider.dart';
import 'package:amiibo_network/shared/utils/preferences_constants.dart';
import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'query_provider.g.dart';

@riverpod
OrderBy orderCategory(Ref ref) => ref.watch(queryProvider).orderBy;

@riverpod
SortBy sortBy(Ref ref) => ref.watch(queryProvider).sortBy;

@riverpod
Filter filter(Ref ref) {
  final query = ref.watch(queryProvider);
  final hiddenType = ref.watch(hiddenCategoryProvider);
  return Filter(
    categoryAttributes: query.categoryAttributes,
    searchAttributes: query.searchAttributes,
    orderBy: query.orderBy,
    sortBy: query.sortBy,
    hiddenType: hiddenType,
  );
}

@riverpod
FutureOr<List<String>> figures(Ref ref) async {
  final service = ref.watch(serviceProvider.notifier);
  final list = await service.fetchDistinct(
    categoryAttributes: const CategoryAttributes(category: .Figures),
    searchAttributes: null,
    orderBy: .AmiiboSerie,
    sortBy: .ASC,
  );
  ref.keepAlive();
  return list;
}

@riverpod
FutureOr<List<String>> cards(Ref ref) async {
  final service = ref.watch(serviceProvider.notifier);
  final list = await service.fetchDistinct(
    searchAttributes: null,
    categoryAttributes: const CategoryAttributes(category: .Cards),
    orderBy: .AmiiboSerie,
    sortBy: .ASC,
  );
  ref.keepAlive();
  return list;
}

@riverpod
bool isSearch(Ref ref) =>
    ref.watch(queryProvider.select((state) => state.searchAttributes != null));

@riverpod
class QueryNotifier extends _$QueryNotifier {
  static final Function deepEq =
      const DeepCollectionEquality.unordered().equals;
  static bool checkEquality(List<String>? eq1, List<String>? eq2) =>
      deepEq(eq1, eq2);

  late Search _previousNotSearch;

  late List<String> _customFigures;
  late List<String> _customCards;

  @override
  Search build() {
    final preferences = ref.watch(preferencesProvider);
    _customFigures =
        preferences.getStringList(sharedCustomFigures) ?? <String>[];
    _customCards = preferences.getStringList(sharedCustomCards) ?? <String>[];
    final int order = (preferences.getInt(orderPreference) ?? 0).clamp(
      0,
      OrderBy.values.length - 1,
    );
    final int sort = (preferences.getInt(sortPreference) ?? 0).clamp(
      0,
      SortBy.values.length - 1,
    );

    final orderBy = OrderBy.values[order];
    final sortBy = SortBy.values[sort];
    final category = _customCards.isEmpty && _customFigures.isEmpty
        ? AmiiboCategory.All
        : AmiiboCategory.AmiiboSeries;
    return Search(
      categoryAttributes: CategoryAttributes(
        category: category,
        cards: _customCards,
        figures: _customFigures,
      ),
      orderBy: orderBy,
      sortBy: sortBy,
    );
  }

  bool get _isSearch => state.searchAttributes != null;

  List<String> get customFigures => UnmodifiableListView(_customFigures);
  List<String> get customCards => UnmodifiableListView(_customCards);

  void restart() {
    if (_previousNotSearch == state) return;
    state = _previousNotSearch;
  }

  void updateOption(SearchAttributes search) {
    if (search == state.searchAttributes) return;

    state = state.copyWith(searchAttributes: search);
    if (!_isSearch) _previousNotSearch = state;
  }

  void updateTile(CategoryAttributes category) {
    if (category == state.categoryAttributes) return;

    if (category.category == .AmiiboSeries) {
      category = category.copyWith(
        cards: _customCards,
        figures: _customFigures,
      );
    }

    state = state.copyWith(
      categoryAttributes: category,
      searchAttributes: null,
    );
    if (!_isSearch) _previousNotSearch = state;
  }

  Future<void> updateCustom(List<String> figures, List<String> cards) async {
    final bool equal =
        checkEquality(figures, _customFigures) &&
        checkEquality(cards, _customCards);
    if (!equal) {
      final preferences = ref.read(preferencesProvider);
      await preferences.setStringList(sharedCustomCards, cards);
      await preferences.setStringList(sharedCustomFigures, figures);
      _customFigures = figures;
      _customCards = cards;
      if (state.categoryAttributes.category == .AmiiboSeries) {
        state = state.copyWith.categoryAttributes(
          figures: figures,
          cards: cards,
        );
      }
    }
  }

  Future<void> changeSortAndOrder(OrderBy orderBy, SortBy sortBy) async {
    Search _state = state.copyWith();
    if (orderBy != state.orderBy) {
      await ref
          .read(preferencesProvider)
          .setInt(orderPreference, orderBy.index);
      _state = _state.copyWith(orderBy: orderBy);
    }
    if (sortBy != state.sortBy) {
      await ref.read(preferencesProvider).setInt(sortPreference, sortBy.index);
      _state = _state.copyWith(sortBy: sortBy);
    }
    if (_state != state) state = _state;
  }
}
