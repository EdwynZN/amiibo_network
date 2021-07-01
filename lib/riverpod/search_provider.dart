import 'package:amiibo_network/riverpod/service_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:amiibo_network/enum/amiibo_category_enum.dart';
import 'package:amiibo_network/model/search_result.dart';

extension _StringParsing on AmiiboCategory {
  String get name {
    switch (this) {
      case AmiiboCategory.AmiiboSeries:
        return 'amiiboSeries';
      case AmiiboCategory.Game:
        return 'gameSeries';
      case AmiiboCategory.Name:
      case AmiiboCategory.Cards:
      case AmiiboCategory.Figures:
      case AmiiboCategory.Owned:
      case AmiiboCategory.Wishlist:
      case AmiiboCategory.CardSeries:
      case AmiiboCategory.FigureSeries:
      case AmiiboCategory.Custom:
      case AmiiboCategory.All:
      default:
        return 'name';
    }
  }

  Expression? whereExpression(String filter) {
    if (filter.isEmpty) return null;
    switch (this) {
      case AmiiboCategory.Figures:
        return InCond.inn('type', figureType);
      case AmiiboCategory.FigureSeries:
        return InCond.inn('type', figureType) &
            Cond.like('amiiboSeries', '%$filter%');
      case AmiiboCategory.CardSeries:
        return Cond.eq('type', 'Card') & Cond.like('amiiboSeries', '%$filter%');
      case AmiiboCategory.Cards:
        return Cond.eq('type', 'Card');
      case AmiiboCategory.Name:
        return Cond.like('character', '%$filter%') |
            Cond.like('name', '%$filter%');
      case AmiiboCategory.Game:
        return Cond.like('gameSeries', '%$filter%');
      case AmiiboCategory.AmiiboSeries:
        return Cond.like('amiiboSeries', '%$filter%');
      case AmiiboCategory.All:
      case AmiiboCategory.Owned:
      case AmiiboCategory.Wishlist:
      case AmiiboCategory.Custom:
      default:
        return And();
    }
  }
}

final categorySearchProvider =
    StateProvider<AmiiboCategory>((_) => AmiiboCategory.Name);

final searchProvider =
    FutureProvider.autoDispose.family<List<String>, String>((ref, search) {
  final service = ref.watch(serviceProvider.notifier);
  final category = ref.watch(categorySearchProvider).state;
  final exp = category.whereExpression(search)!;

  return service.searchDB(exp, category.name);
});
