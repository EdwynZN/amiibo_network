import 'dart:async';

import 'package:amiibo_network/service/service.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:amiibo_network/model/amiibo_local_db.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';

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
  String _searchFilter = 'amiiboSeries';
  String _strFilter = 'All';
  String _orderCategory;
  String _sort = 'ASC';
  Map<String,dynamic> _listOwned;

  Stream<NDEFMessage> _NFCStream;
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
  String get strFilter => _strFilter;

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

  Stream<AmiiboLocalDB> get amiiboList => _amiiboList.stream;
  Stream<Map<String,dynamic>> get collectionList => _collectionList.stream;
  //Stream<String> get NFCPayload => ZipStream2();
  Stream<String> nfcPayload;

  AmiiboProvider(bool nfcSupported){
    if(nfcSupported){
      _NFCStream = NFC.readNDEF();

      nfcPayload = amiiboList.zipWith(
        _NFCStream,
        (amiiboList, nfc) {
          print(nfc.id);
          return nfc.payload;
        }
      );
      /*
      nfcPayload = _NFCStream.zipWith(
        amiiboList,
        (nfc, amiiboList) {
          print(nfc.id);
          return nfc.payload;
        }
      );
      * */
      /*nfcPayload = ZipStream.zip2<NDEFMessage, AmiiboLocalDB, String>(
        _NFCStream, amiiboList,
        (nfc, amiiboList) => nfc.payload,
      );*/
    }
  }

  //NFC.readNDEF()

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
    //return _fetchByCategory().then((x) => notifyListeners());
  }

  Future<void> resetPagination(String name,{bool search = false}) async {
    _searchFilter = search ? 'name' : 'amiiboSeries';
    _strFilter = name;
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

  Future<void> _fetchByCategory() async{
    String column;
    List<String> args;
    final String orderBy = _orderBy;
    switch(_strFilter){
      case 'All':
        break;
      case 'Owned':
        column = 'owned'; args = ['%1%'];
        break;
      case 'Wishlist':
        column = 'wishlist'; args = ['%1%'];
        break;
      case 'Figures':
        column = 'type'; args = ['Figure', 'Yarn'];
        break;
      case 'Cards':
        column = 'type'; args = ['Card'];
        break;
      default:
        column = _searchFilter;
        args = _searchFilter == 'name' ? ['%$_strFilter%'] : ['%$_strFilter'];
        break;
    }
    final AmiiboLocalDB _amiiboListDB = await _service.fetchByCategory(column, args, orderBy);
    _listOwned = Map<String, dynamic>.from((await _service.fetchSum(column: column, args: args)).first);
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