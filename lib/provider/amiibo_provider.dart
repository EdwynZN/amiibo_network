import 'package:amiibo_network/service/service.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:amiibo_network/model/amiibo_local_db.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amiibo_network/utils/amiibo_category.dart';

extension _StringParsing on AmiiboCategory{
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
      case AmiiboCategory.Name:
      case AmiiboCategory.CardSeries:
      case AmiiboCategory.FigureSeries:
      case AmiiboCategory.AmiiboSeries:
      case AmiiboCategory.Game:
      case AmiiboCategory.Custom:
      default: return null;
    }
  }
}

class SingleAmiibo with ChangeNotifier{
  AmiiboDB amiibo;

  set update(AmiiboDB amiiboDB) => amiibo = amiiboDB;

  get owned => amiibo?.owned;
  get wishlist => amiibo?.wishlist;

  set owned(int value){
    if(amiibo.owned == value) return;
    if(value.isOdd) amiibo.wishlist = 0;
    amiibo.owned = value;
    notifyListeners();
  }

  set wishlist(int value){
    if(amiibo.wishlist == value) return;
    if(value.isOdd) amiibo.owned = 0;
    amiibo.wishlist = value;
    notifyListeners();
  }

  void shift(){
    final int initial = amiibo.owned + amiibo.wishlist >= 1 ? 0 : 1;
    amiibo.wishlist = amiibo.owned ^ 0;
    amiibo.owned = initial ^ 0;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}

class AmiiboProvider with ChangeNotifier{
  final _service = Service();
  String _strFilter = 'All';
  String _orderCategory;
  String _sort = 'ASC';
  AmiiboCategory _category = AmiiboCategory.All;
  Expression _where = And();
  final _amiiboList = BehaviorSubject<Map<String,dynamic>>();
  final _updateAmiiboDB = BehaviorSubject<AmiiboLocalDB>.seeded(null);

  String get orderCategory => _orderCategory;
  set orderCategory(String value){
    if(_orderCategory == value) return;
    _orderCategory = value;
    notifyListeners();
    refreshPagination();
  }
  String get sort => _sort;
  set sort(String value) {
    if(_sort == value) return;
    _sort = value;
    notifyListeners();
    refreshPagination();
  }
  String get strFilter => _category.name ?? _strFilter;
  AmiiboCategory get category => _category;
  Map<String,dynamic> get _query => <String,dynamic>{'Where' : _where, 'OrderBy' : _orderBy};

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

  Stream<AmiiboLocalDB> get amiiboList => _amiiboList.stream
    .asyncMap((map) => _service.fetchByCategory(expression: map['Where'], orderBy: map['OrderBy']));

  Stream<Map<String,dynamic>> get collectionList =>
    CombineLatestStream.combine2<void, Map<String,dynamic>, Expression>(
    _updateAmiiboDB.stream.asyncMap((amiibos) => amiibos == null ? null : _service.update(amiibos)),
    _amiiboList.stream, (_, map) => map['Where'])
    .asyncMap((exp) => _service.fetchSum(expression: exp))
    .map((map) => Map<String, dynamic>.from(map.first));

  Future<void> fetchAllAmiibosDB() async {
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
    _amiiboList.sink.add(_query);
  }

  void resetPagination(AmiiboCategory category, String search) {
    _category = category ?? _category;
    _strFilter = search ?? _strFilter;
    _updateExpression();
    _amiiboList.sink.add(_query);
    notifyListeners();
  }

  Future<void> refreshPagination() async => _amiiboList.sink.add(_query);

  void _updateExpression() {
    switch(_category){
      case AmiiboCategory.All:
        _where = And();
        break;
      case AmiiboCategory.Owned:
      case AmiiboCategory.Wishlist:
        _where = Cond.iss(_strFilter, '1');
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
        break;
      default:
        _category = AmiiboCategory.All;
        _where = And();
        break;
    }
  }

  void updateAmiiboDB({AmiiboDB amiibo, AmiiboLocalDB amiibos}) {
    amiibos ??= AmiiboLocalDB(amiibo: [amiibo]);
    _updateAmiiboDB.sink.add(amiibos);
  }

  Future<void> resetCollection() async {
    await _service.resetCollection();
    await refreshPagination();
  }

  String get _orderBy{
    StringBuffer orderBy = StringBuffer(_orderCategory);
    if(_sort?.isNotEmpty ?? false) orderBy..write(' ')..write(_sort);
    return orderBy.toString();
  }

  @override
  dispose() {
    _amiiboList?.close();
    _updateAmiiboDB?.close();
    super.dispose();
  }
}