import 'package:amiibo_network/service/service.dart';
import 'package:amiibo_network/utils/preferences_constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amiibo_network/utils/amiibo_category.dart';
import '../model/query_builder.dart';
import 'package:collection/collection.dart';

extension _StringParsing on AmiiboCategory{
  //describeEnum(AmiiboCategory.All);
  String get name {
    switch(this){
      case AmiiboCategory.All:
        return 'All';
      case AmiiboCategory.Owned:
        return 'Owned';
      case AmiiboCategory.Wishlist:
        return 'Wishlist';
      case AmiiboCategory.Figures:
        return 'Figures';
      case AmiiboCategory.Cards:
        return 'Cards';
      case AmiiboCategory.Custom:
        return 'Custom';
      case AmiiboCategory.Name:
      case AmiiboCategory.CardSeries:
      case AmiiboCategory.FigureSeries:
      case AmiiboCategory.AmiiboSeries:
      case AmiiboCategory.Game:
      default: return null;
    }
  }
}

class QueryProvider with ChangeNotifier{
  final _service = Service();
  static final Function deepEq = const DeepCollectionEquality.unordered().equals;
  String _strFilter = 'All';
  String _orderCategory;
  String _sort = 'ASC';
  AmiiboCategory _category = AmiiboCategory.All;
  Expression _where = And();
  List<String> _customFigures = <String>[];
  List<String> _customCards = <String>[];

  QueryProvider();

  QueryProvider.fromSharedPreferences(SharedPreferences preferences){
    _customFigures = preferences.getStringList(sharedCustomFigures) ?? <String>[];
    _customCards = preferences.getStringList(sharedCustomCards) ?? <String>[];
  }

  List<String> get customFigures => List<String>.of(_customFigures);
  List<String> get customCards => List<String>.of(_customCards);
  Expression get where => _where;
  String get orderCategory => _orderCategory;
  set orderCategory(String value){
    if(_orderCategory == value) return;
    _orderCategory = value;
    notifyListeners();
  }
  String get sort => _sort;
  set sort(String value) {
    if(_sort == value) return;
    _sort = value;
    notifyListeners();
  }
  String get strFilter => _category.name ?? _strFilter;
  AmiiboCategory get category => _category;
  void get retryQuery => notifyListeners();

  Future<void> updateCustom(List<String> figures, List<String> cards) async{
    final bool equal = checkEquality(figures, _customFigures) && checkEquality(cards, _customCards);
    if(!equal){
      final SharedPreferences preferences = await SharedPreferences.getInstance();
      _customFigures = List<String>.of(figures);
      _customCards = List<String>.of(cards);
      await preferences.setStringList(sharedCustomCards, _customCards);
      await preferences.setStringList(sharedCustomFigures, _customFigures);
    }
    if(!equal && _category == AmiiboCategory.Custom) _updateExpression;
  }

  static bool checkEquality(List<String> eq1, List<String> eq2) => deepEq(eq1, eq2);

  Future<void> fetchAllAmiibosDB() async{
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    if(preferences.containsKey('Sort')){
      final String value = preferences.getString('Sort');
      _orderCategory = value?.split(' ')[0] ?? 'na';
      if(value?.contains('DESC') ?? false) _sort = 'DESC';
      preferences..setString('OrderCategory', _orderCategory)
        ..setString('SortBy', _sort)
        ..remove('Sort');
    }else{
      _orderCategory = preferences.getString('OrderCategory') ?? 'na';
      _sort = preferences.getString('SortBy') ?? 'DESC';
    }
    notifyListeners();
  }

  void resetPagination(AmiiboCategory category, String search){
    _category = category ?? _category;
    _strFilter = search ?? _strFilter;
    _updateExpression;
  }

  static Expression updateExpression(AmiiboCategory category, [String filter]){
    String strFilter = filter ?? category.name ?? '';
    switch(category){
      case AmiiboCategory.Owned:
      case AmiiboCategory.Wishlist:
        return Cond.iss(strFilter, '1');
        break;
      case AmiiboCategory.Figures:
        return InCond.inn('type', ['Figure', 'Yarn']);
        break;
      case AmiiboCategory.FigureSeries:
        return InCond.inn('type', ['Figure', 'Yarn'])
        & Cond.eq('amiiboSeries', strFilter);
        break;
      case AmiiboCategory.CardSeries:
        return Cond.eq('type', 'Card')
        & Cond.eq('amiiboSeries', strFilter);
        break;
      case AmiiboCategory.Cards:
        return Cond.eq('type', 'Card');
        break;
      case AmiiboCategory.Game:
        return Cond.like('gameSeries', '%$strFilter%');
        break;
      case AmiiboCategory.Name:
        return Cond.like('name', '%$strFilter%')
        | Cond.like('character', '%$strFilter%');
        break;
      case AmiiboCategory.AmiiboSeries:
        return Cond.like('amiiboSeries', '%$strFilter%');
        break;
      case AmiiboCategory.Custom:
        return Bracket(InCond.inn('type', ['Figure', 'Yarn']) & InCond.inn('amiiboSeries', null))
        | Bracket(Cond.eq('type', 'Card') & InCond.inn('amiiboSeries', null));
        break;
      case AmiiboCategory.All:
      default:
        return And();
        break;
    }
  }

  void get _updateExpression{
    switch(_category){
      case AmiiboCategory.Owned:
      case AmiiboCategory.Wishlist:
        _where = Cond.iss(_strFilter ?? _category.name, '1');
        break;
      case AmiiboCategory.Figures:
        _where = InCond.inn('type', ['Figure', 'Yarn']);
        break;
      case AmiiboCategory.FigureSeries:
        _where = InCond.inn('type', ['Figure', 'Yarn'])
        & Cond.eq('amiiboSeries', _strFilter);
        break;
      case AmiiboCategory.CardSeries:
        _where = Cond.eq('type', 'Card')
        & Cond.eq('amiiboSeries', _strFilter);
        break;
      case AmiiboCategory.Cards:
        _where = Cond.eq('type', 'Card');
        break;
      case AmiiboCategory.Game:
        _where = Cond.like('gameSeries', '%$_strFilter%');
        break;
      case AmiiboCategory.Name:
        _where = Cond.like('name', '%$_strFilter%')
        | Cond.like('character', '%$_strFilter%');
        break;
      case AmiiboCategory.AmiiboSeries:
        _where = Cond.like('amiiboSeries', '%$_strFilter%');
        break;
      case AmiiboCategory.Custom:
        _where =
          Bracket(InCond.inn('type', ['Figure', 'Yarn']) & InCond.inn('amiiboSeries', _customFigures))
          | Bracket(Cond.eq('type', 'Card') & InCond.inn('amiiboSeries', _customCards));
        break;
      case AmiiboCategory.All:
      default:
        _category = AmiiboCategory.All;
        _where = And();
        break;
    }
    notifyListeners();
  }

  Future<void> resetCollection() async {
    await _service.resetCollection();
    notifyListeners();
  }
}