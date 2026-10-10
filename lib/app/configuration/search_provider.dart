import 'package:amiibo_network/app/configuration/data_providers.dart';
import 'package:amiibo_network/app/configuration/model/amiibo_category_enum.dart';
import 'package:amiibo_network/shared/data/drift_sqlite/source/amiibo_dao.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_provider.g.dart';

@riverpod
Future<List<String>> search(Ref ref, String search) {
  final category = ref.watch(categorySearchProvider);
  final dao = AmiiboDao(ref.watch(databaseProvider));
  return dao.searchName(search: search, category: category);
}

@Riverpod(keepAlive: true)
class CategorySearch extends _$CategorySearch {
  @override
  SearchCategory build() => .Name;

  set change(SearchCategory newValue) => state = newValue;
}
