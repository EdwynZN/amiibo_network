import 'package:amiibo_network/service/service.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:amiibo_network/model/amiibo_local_db.dart';
import '../model/query_builder.dart';

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
}

class AmiiboProvider{
  final _service = Service();
  QueryBuilder _queryBuilder = QueryBuilder(And());
  final _amiiboList = BehaviorSubject<QueryBuilder>();
  final _updateAmiiboDB = BehaviorSubject<AmiiboLocalDB>.seeded(null);

  void update(Expression where, [String orderBy, String asc]){
    _queryBuilder = QueryBuilder(where, orderBy, asc);
    _amiiboList.sink.add(_queryBuilder);
  }

  Stream<AmiiboLocalDB> get amiiboList => _amiiboList.stream
    .asyncMap((query) => _service.fetchByCategory(expression: query.where, orderBy: query.order));

  Stream<Map<String,dynamic>> get collectionList =>
    CombineLatestStream.combine2<void, QueryBuilder, Expression>(
        _updateAmiiboDB.stream.asyncMap((amiibos) => amiibos == null ? null : _service.update(amiibos)),
        _amiiboList.stream, (_, query) => query.where)
      .asyncMap((exp) => _service.fetchSum(expression: exp))
      .map((map) => Map<String, dynamic>.from(map.first));


  void updateAmiiboDB({AmiiboDB amiibo, AmiiboLocalDB amiibos}) {
    amiibos ??= AmiiboLocalDB(amiibo: [amiibo]);
    _updateAmiiboDB.sink.add(amiibos);
  }

  void get refreshAmiibos => _amiiboList.sink.add(_queryBuilder);

  dispose() {
    _amiiboList?.close();
    _updateAmiiboDB?.close();
  }
}