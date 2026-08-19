import 'package:amiibo_network/app/configuration/query_provider.dart';
import 'package:amiibo_network/app/configuration/service_provider.dart';
import 'package:amiibo_network/entity/amiibo_info/model/amiibo.dart';
import 'package:amiibo_network/feature/amiibo/application/input/update_amiibo_user_attributes.dart';
import 'package:amiibo_network/page/home/model/title_search.dart';
import 'package:amiibo_network/shared/service/service.dart';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'select_provider.g.dart';

@riverpod
TitleSearch title(Ref ref) {
  final count = ref.watch(selectProvider);
  final query = ref.watch(queryProvider);
  final category = query.categoryAttributes.category;
  if (count.isNotEmpty) {
    return TitleSearch.count(
      title: count.length.toString(),
      category: category,
    );
  }
  final isSearch = ref.watch(isSearchProvider);
  if (isSearch) {
    return TitleSearch.search(
      title: query.searchAttributes!.search,
      searchCategory: query.searchAttributes!.category,
      category: category,
    );
  }
  return TitleSearch(
    title: switch (category) {
      .Cards when query.categoryAttributes.cards.firstOrNull != null =>
        query.categoryAttributes.cards.first,
      .Figures when query.categoryAttributes.figures.firstOrNull != null =>
        query.categoryAttributes.figures.first,
      _ => category.name,
    },
    category: category,
  );
}

@riverpod
bool canPop(Ref ref) {
  final selected = ref.watch(selectProvider);
  ref.watch(queryProvider);
  final isSearch = ref.watch(isSearchProvider);
  return !(selected.isNotEmpty || isSearch);
}

@riverpod
class SelectNotifier extends _$SelectNotifier {
  late AmiiboService _service;
  @override
  Set<int> build() {
    _service = ref.watch(serviceProvider);
    return const UnmodifiableSetView.empty();
  }

  bool addSelected(int value) {
    final newSet = Set.of(state);
    final result = newSet.add(value);
    if (result) state = UnmodifiableSetView(newSet);
    return result;
  }

  bool removeSelected(int? value) {
    final newSet = Set.of(state);
    final result = newSet.remove(value);
    if (result) state = UnmodifiableSetView(newSet);
    return result;
  }

  void updateAmiibos(UserAttributes attributes) {
    final amiibos = state
        .map((cb) => UpdateAmiiboUserAttributes(id: cb, attributes: attributes))
        .toList();
    _service.update(amiibos);
    clearSelected();
  }

  void onLongPress(int key) {
    if (!addSelected(key)) removeSelected(key);
  }

  void clearSelected() {
    if (state.isEmpty) return;
    state = const UnmodifiableSetView.empty();
  }
}
