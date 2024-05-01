import 'package:amiibo_network/enum/amiibo_category_enum.dart';
import 'package:amiibo_network/model/search_result.dart';
import 'package:amiibo_network/riverpod/preferences_provider.dart';
import 'package:amiibo_network/riverpod/service_provider.dart';
import 'package:riverpod/riverpod.dart';

final categorySearchProvider =
    StateProvider<SearchCategory>((_) => SearchCategory.Name);

final searchProvider =
    FutureProvider.autoDispose.family<List<String>, String>((ref, search) {
  final service = ref.watch(serviceProvider.notifier);
  final category = ref.watch(categorySearchProvider);
  final hiddenCategory = ref.watch(hiddenCategoryProvider);

  return service.search(
    searchAttributes: SearchAttributes(search: search, category: category),
    hidden: hiddenCategory,
  );
});
