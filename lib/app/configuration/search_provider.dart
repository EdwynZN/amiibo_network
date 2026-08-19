import 'package:amiibo_network/app/configuration/model/amiibo_category_enum.dart';
import 'package:amiibo_network/app/configuration/model/search_result.dart';
import 'package:amiibo_network/app/state/preferences_provider.dart';
import 'package:amiibo_network/app/configuration/service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_provider.g.dart';

@riverpod
Future<List<String>> search(Ref ref, String search) {
  final service = ref.watch(amiiboServiceProvider);
  final category = ref.watch(categorySearchProvider);
  final hiddenCategory = ref.watch(hiddenCategoryProvider);

  return service.search(
    searchAttributes: SearchAttributes(search: search, category: category),
    hidden: hiddenCategory,
  );
}

@Riverpod(keepAlive: true)
class CategorySearch extends _$CategorySearch {
  @override
  SearchCategory build() => .Name;

  set change(SearchCategory newValue) => state = newValue;
}
