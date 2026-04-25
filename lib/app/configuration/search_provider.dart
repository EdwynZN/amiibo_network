import 'package:amiibo_network/app/configuration/model/amiibo_category_enum.dart';
import 'package:amiibo_network/app/configuration/model/search_result.dart';
import 'package:amiibo_network/app/state/preferences_provider.dart';
import 'package:amiibo_network/app/configuration/service_provider.dart';
import 'package:hooks_riverpod/legacy.dart';
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
