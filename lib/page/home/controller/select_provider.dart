import 'package:amiibo_network/app/configuration/query_provider.dart';
import 'package:amiibo_network/entity/amiibo_info/model/amiibo_user_collection_attributes.dart';
import 'package:amiibo_network/feature/collection/application/input/update_collection_input.dart';
import 'package:amiibo_network/feature/collection/application/use_case/update_collection_use_case.dart';
import 'package:amiibo_network/feature/collection/infrastructure/configuration/configuration.dart';
import 'package:amiibo_network/page/home/model/title_search.dart';
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
  late UpdateCollectionUseCase _service;
  @override
  Set<int> build() {
    _service = ref.watch(updateCollectionUseCaseProvider);
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
    final CollectionAttributes collection = switch (attributes) {
      OwnedUserAttributes(:final boxed, :final opened) => .owned(
        boxed: boxed,
        opened: opened,
      ),
      WishedUserAttributes() => const .wished(),
      EmptyUserAttributes() => const .none(),
    };
    final input = UpdateCollectionInput(
      amiibos: state
          .map((cb) => CollectionAmiibo(id: cb, attributes: collection))
          .toList(),
      bundles: const [],
    );
    _service(input);
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
