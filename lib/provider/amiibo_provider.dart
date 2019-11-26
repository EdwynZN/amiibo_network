import 'package:amiibo_network/service/service.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:amiibo_network/model/amiibo_local_db.dart';

class SelectProvider with ChangeNotifier{
  final Set<ValueKey<int>> set = Set<ValueKey<int>>();

  bool get multipleSelected => set.isNotEmpty;
  int get selected => set.length;
  bool addSelected(ValueKey<int> value) => set.add(value);
  bool removeSelected(ValueKey<int> value) => set.remove(value);
  bool isSelected(ValueKey<int> value) => set.contains(value);

  void clearSelected() {
    set.clear();
    notifyListeners();
  }

  void notifyWidgets() => notifyListeners();
}

class AmiiboProvider with ChangeNotifier{
  static final _service = Service();
  String _searchFilter = 'amiiboSeries';
  String _strFilter = 'All';
  String _order = 'na DESC';
  Map<String,dynamic> _listOwned;
  AmiiboLocalDB _amiiboListDB;

  final _collectionList = PublishSubject<Map<String,dynamic>>();
  final _updateAmiiboDB = PublishSubject<AmiiboLocalDB>()
    ..listen((amiibos) async => await _service.update(amiibos));

  AmiiboLocalDB get amiibosDB => _amiiboListDB;
  Map<String,dynamic> get listCollection => _listOwned;
  String get orderBy => _order;
  String get strFilter => _strFilter;
  set strOrderBy(String sort) => _order = sort;
  set setFilter(String value) => _strFilter = value;

  void notifyWidgets() => notifyListeners();

  Observable<Map<String,dynamic>> get collectionList => _collectionList.stream;

  Future<void> fetchAllAmiibosDB() => _fetchByCategory().then((x) => notifyListeners());

  resetPagination(String name,{bool search = false}) {
    _searchFilter = search ? 'name' : 'amiiboSeries';
    _strFilter = name;
    _fetchByCategory().then((x) => notifyListeners());
  }

  refreshPagination() => _fetchByCategory().then((x) => notifyListeners());

  set removeFromList(String position) => --_listOwned[position];
  set countOwned(int counter) => counter.isOdd ? ++_listOwned['Owned'] : --_listOwned['Owned'];
  set countWished(int counter) => counter.isOdd ? ++_listOwned['Wished'] : --_listOwned['Wished'];

  updateList() => _collectionList.sink.add(_listOwned);

  Future<void> _fetchByCategory() async{
    /*_amiiboListDB = await _service.fetchByCategory(_strFilter, _args, _order);
    _listOwned = Map<String, dynamic>.from(
        (await _service.fetchSum(column: _strFilter, args: _args)).first);
    */
    switch(_strFilter){
      case 'All':
        _amiiboListDB = await _service.fetchByCategory(null, null, _order);
        _listOwned = Map<String, dynamic>.from((await _service.fetchSum()).first);
       /* _amiiboListDB = await _service.fetchAllAmiiboDB(_order);
        _listOwned = Map<String, dynamic>.from(
            (await _service.fetchSum()).first);*/
        break;
      case 'Owned':
        _amiiboListDB = await _service.fetchByCategory('owned', ['%1%'], _order);
        _listOwned = Map<String, dynamic>.from(
          (await _service.fetchSum(column: 'owned', args: ['%1%'])).first);
        break;
      case 'Wishlist':
        _amiiboListDB = await _service.fetchByCategory('wishlist', ['%1%'], _order);
        _listOwned = Map<String, dynamic>.from(
            (await _service.fetchSum(column: 'wishlist', args: ['%1%'])).first);
        break;
      default:
        _amiiboListDB = await _service.fetchByCategory(_searchFilter,
          [_searchFilter == 'name' ? '%$_strFilter%' : '%$_strFilter'], _order);
        _listOwned = Map<String, dynamic>.from(
          (await _service.fetchSum(column: _searchFilter,
            args: [_searchFilter == 'name' ? '%$_strFilter%' : '%$_strFilter'])).first);
        break;
    }
    _collectionList.sink.add(_listOwned);
  }

  updateAmiiboDB({AmiiboDB amiibo, AmiiboLocalDB amiibos}) async{
    amiibos ??= AmiiboLocalDB(amiibo: [amiibo]);
    _updateAmiiboDB.sink.add(amiibos);
  }

  Future<void> resetCollection() async {
    await _service.resetCollection();
    await refreshPagination();
  }

  @override
  dispose() {
    _collectionList.close();
    _updateAmiiboDB.close();
    super.dispose();
  }
}

/*
class AmiiboProvider with ChangeNotifier{
  static final _service = Service();
  String _searchFilter = 'amiiboSeries';
  String _strFilter = 'All';
  String _order = 'na DESC';
  Map<String,String> exOrderBy = {'serie' : 'ASC', 'na' : 'DESC'};
  Map<String,dynamic> _listOwned;
  AmiiboLocalDB _amiiboListDB;

  final _collectionList = PublishSubject<Map<String,dynamic>>();
  final _updateAmiiboDB = PublishSubject<AmiiboLocalDB>()
    ..listen((amiibos) async => await _service.update(amiibos));

  AmiiboLocalDB get amiibosDB => _amiiboListDB;
  Map<String,dynamic> get listCollection => _listOwned;
  String get orderBy => _order;
  String get strFilter => _strFilter;
  set strOrderBy(String sort) => _order = sort;
  set setFilter(String value) => _strFilter = value;

  void notifyWidgets() => notifyListeners();

  Observable<Map<String,dynamic>> get collectionList => _collectionList.stream;

  Future<void> fetchAllAmiibosDB() =>
    _fetchByCategory(_strFilter).then((x) => notifyListeners());

  resetPagination(String name,{bool search = false}) {
    _searchFilter = search ? 'name' : 'amiiboSeries';
    _strFilter = name;
    _fetchByCategory(name).then((x) => notifyListeners());
  }

  refreshPagination() =>
    _fetchByCategory(_strFilter).then((x) => notifyListeners());

  set removeFromList(String position) => --_listOwned[position];
  set countOwned(int counter) => counter.isOdd ? ++_listOwned['Owned'] : --_listOwned['Owned'];
  set countWished(int counter) => counter.isOdd ? ++_listOwned['Wished'] : --_listOwned['Wished'];

  updateList() => _collectionList.sink.add(_listOwned);

  Future<void> _fetchByCategory(String name) async{
    switch(name){
      case 'All':
        _amiiboListDB = await _service.fetchAllAmiiboDB(_order);
        _listOwned = Map<String, dynamic>.from(
          (await _service.fetchSum()).first);
        break;
      case 'Owned':
        _amiiboListDB = await _service.fetchByCategory('owned', ['%1%'], _order);
        _listOwned = Map<String, dynamic>.from(
          (await _service.fetchSum(column: 'owned', args: ['%1%'])).first);
        break;
      case 'Wishlist':
        _amiiboListDB = await _service.fetchByCategory('wishlist', ['%1%'], _order);
        _listOwned = Map<String, dynamic>.from(
            (await _service.fetchSum(column: 'wishlist', args: ['%1%'])).first);
        break;
      default:
        _amiiboListDB = await _service.fetchByCategory(_searchFilter,
            [_searchFilter == 'name' ? '%$name%' : '%$name'], _order);
        _listOwned = Map<String, dynamic>.from(
          (await _service.fetchSum(column: _searchFilter,
            args: _searchFilter == 'name' ? ['%$name%'] : ['%$name'])).first);
        break;
    }
    _collectionList.sink.add(_listOwned);
  }

  updateAmiiboDB({AmiiboDB amiibo, AmiiboLocalDB amiibos}) async{
    amiibos ??= AmiiboLocalDB(amiibo: [amiibo]);
    _updateAmiiboDB.sink.add(amiibos);
  }

  Future<void> resetCollection() async {
    await _service.resetCollection();
    await refreshPagination();
  }

  @override
  dispose() {
    _collectionList.close();
    _updateAmiiboDB.close();
    super.dispose();
  }
}
*/