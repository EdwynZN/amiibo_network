import 'package:amiibo_network/service/service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:amiibo_network/utils/amiibo_category.dart';
import '../model/query_builder.dart';

extension _StringParsing on AmiiboCategory{
  String get name {
    switch(this){
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
      default: return 'name';
    }
  }
}

class SearchProvider{
  final _service = Service();
  final _searchFetcher = BehaviorSubject<String>.seeded('');
  final _categoryStream = BehaviorSubject<AmiiboCategory>.seeded(_category);
  static AmiiboCategory _category = AmiiboCategory.Name;
  AmiiboCategory get category => _category;
  set category(AmiiboCategory newCategory) {
    if(newCategory == null) {
      _category = AmiiboCategory.All;
      return;
    }
    _category = newCategory;
    _categoryStream.sink.add(newCategory);
  }

  Stream<List<String>> get search => CombineLatestStream.combine2<String, AmiiboCategory, Expression>(
    _searchFetcher.stream.debounceTime(const Duration(milliseconds: 500)).map((string) => string.trim()),
    _categoryStream.stream, (text, category) => whereExpression(text),
  ).asyncMap((exp) => exp == null ? null : _service.searchDB(exp, _category.name));

  Expression whereExpression(String filter){
    if(filter.isEmpty) return null;
    switch(_category){
      case AmiiboCategory.Figures:
        return InCond.inn('type', ['Figure', 'Yarn']);
      case AmiiboCategory.FigureSeries:
        return InCond.inn('type', ['Figure', 'Yarn']) & Cond.like('amiiboSeries', '%$filter%');
      case AmiiboCategory.CardSeries:
        return Cond.eq('type', 'Card') & Cond.like('amiiboSeries', '%$filter%');
      case AmiiboCategory.Cards:
        return Cond.eq('type', 'Card');
      case AmiiboCategory.Name:
        return Cond.like('character', '%$filter%') | Cond.like('name', '%$filter%');
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

  searchValue(String s) => _searchFetcher.sink.add(s);

  dispose() {
    _categoryStream?.close();
    _searchFetcher?.close();
  }
}