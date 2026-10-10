import 'package:amiibo_network/app/configuration/query_provider.dart';
import 'package:amiibo_network/entity/amiibo_info/infrastructure/amiibo_provider.dart';
import 'package:amiibo_network/entity/amiibo_info/model/amiibo_user_collection_attributes.dart';
import 'package:amiibo_network/entity/amiibo_info/model/amiibo_info.dart';
import 'package:amiibo_network/entity/amiibo_info/model/stat.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'amiibo_user_collection_notifier.g.dart';

@riverpod
Stat? collectionStats(Ref ref) {
  final collection = ref.watch(amiiboUserCollectionProvider).value;
  if (collection == null) return null;

  final total = collection.length;
  final owned = collection
      .where((e) => e.userAttributes is OwnedUserAttributes)
      .length;
  final wished = collection
      .where((e) => e.userAttributes is WishedUserAttributes)
      .length;
  return Stat(total: total, owned: owned, wished: wished);
}

@riverpod
class AmiiboUserCollectionNotifier extends _$AmiiboUserCollectionNotifier {
  @override
  Future<List<AmiiboInfo>> build() {
    final filter = ref.watch(filterProvider);
    return ref.watch(amiibosProvider(filter: filter).future);
  }
}
