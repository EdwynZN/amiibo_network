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
  static final _service = Service();
  String _strFilter = 'All';
  String _orderCategory;
  String _sort = 'ASC';
  Map<String,dynamic> _listOwned;
  AmiiboCategory _category = AmiiboCategory.All;
  Expression _where = And();

  final _amiiboList = BehaviorSubject<AmiiboLocalDB>();
  final _collectionList = BehaviorSubject<Map<String,dynamic>>();
  final _updateAmiiboDB = PublishSubject<AmiiboLocalDB>()
    ..listen((amiibos) async => await _service.update(amiibos));

  Map<String,dynamic> get listCollection => _listOwned;
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

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

  Stream<AmiiboLocalDB> get amiiboList => _amiiboList.stream;
  Stream<Map<String,dynamic>> get collectionList => _collectionList.stream;

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
    await _fetchByCategory();
  }

  Future<void> resetPagination(AmiiboCategory category, String search) async {
    _category = category ?? _category;
    _strFilter = search ?? _strFilter;
    _updateExpression();
    await _fetchByCategory();
    notifyListeners();
  }

  Future<void> refreshPagination() => _fetchByCategory();

  void updateOwned(int owned, int wished){
    if(owned.isOdd){
      if(wished.isOdd) --_listOwned['Wished'];
      ++_listOwned['Owned'];
    }
    else --_listOwned['Owned'];
    _collectionList.sink.add(_listOwned);
  }

  void updateWished(int wished, int owned){
    if(wished.isOdd){
      if(owned.isOdd) --_listOwned['Owned'];
      ++_listOwned['Wished'];
    }
    else --_listOwned['Wished'];
    _collectionList.sink.add(_listOwned);
  }

  void shiftStat(int owned, int wished){
    final int initial = owned + wished >= 1 ? 0 : 1;
    final int oldOwned = owned, oldWished = wished;
    wished = owned ^ 0; owned = initial ^ 0;

    if(oldOwned != owned) oldOwned.isEven ? ++_listOwned['Owned'] : --_listOwned['Owned'];
    if(oldWished != wished) oldWished.isEven ? ++_listOwned['Wished'] : --_listOwned['Wished'];
    _collectionList.sink.add(_listOwned);
  }

  void _updateExpression() {
    switch(_category){
      case AmiiboCategory.All:
        _where = And();
        break;
      case AmiiboCategory.Owned:
      case AmiiboCategory.Wishlist:
        _where = Cond.like(_strFilter, '%1%');
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

  Future<void> _fetchByCategory() async{
    final AmiiboLocalDB _amiiboListDB = await _service.fetchByCategory(expression: _where, orderBy: _orderBy);
    _listOwned = Map<String, dynamic>.from((await _service.fetchSum(expression: _where,)).first);
    _amiiboList.sink.add(_amiiboListDB);
    _collectionList.sink.add(_listOwned);
  }

  updateAmiiboDB({AmiiboDB amiibo, AmiiboLocalDB amiibos}) {
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
    _collectionList?.close();
    _updateAmiiboDB?.close();
    super.dispose();
  }
}