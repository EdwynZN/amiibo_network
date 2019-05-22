import 'dart:async';
import 'package:amiibo_network/service/amiibo_api_provider.dart';
import '../model/amiibo.dart';
import 'package:amiibo_network/dao/SQLite/amiibo_implement.dart';
import '../model/amiibo_local_db.dart';

class Repository {
  final amiiboApiProvider = AmiiboApiProvider();
  final dao = AmiiboImplement();
  DateTime _lastUpdate;

  Future<AmiiboClient> fetchAllAmiibo() => amiiboApiProvider.fetchAllAmiibo();

  Future<AmiiboLocalDB> fetchAllAmiiboDB() => dao.fetchAll();

  Future<DateTime> get lastUpdate async{
    if(_lastUpdate == null) {
      LastUpdate v = await amiiboApiProvider.fetchLastUpdate()
        .catchError((x) => print(x));
      _lastUpdate = v.lastUpdated;
    }
    return _lastUpdate;
  }

  Future<bool> createDB() async{
    return dao.createTables().then((_) async {
      final bool comparisonDates = await compareLastUpdate();
      if(!comparisonDates) {
        final amiiboAPI = await amiiboApiProvider.fetchAllAmiibo();
        await updateDB(entityFromMap(amiiboAPI.toMap()));
      }
      return true;
    }).catchError((e) {
      print(e.toString());
      return false;
    });
  }

  updateDB(AmiiboLocalDB amiiboDB) async{
    dao.insertAll(amiiboDB, "amiibo").then((_) async{
      await dao.updateTime(LastUpdateDB.fromDate(await lastUpdate));
    });
  }

  Future<AmiiboLocalDB> fetchByCategory(String column, String like) =>
    dao.fetchByColumn(column, like);


  Future<AmiiboDB> fetchAmiiboDBById(String id) => dao.fetchById(id);

  Future<void> update(AmiiboLocalDB amiibos) async {
    if(amiibos.amiibo.length == 1){
      return dao.update(amiibos.amiibo[0], "amiibo");
    } else{
      return dao.insertAll(amiibos, 'amiibo');
    }
  }

  Future<bool> findNew() async => dao.findNew();

  Future<void> cleanNew(String name, [bool search]) async {
    switch(name){
      case 'All':
        await dao.updateAll('amiibo', 'brandNew', '1');
        break;
      case 'Owned':
        await dao.updateAll('amiibo', 'brandNew', '1', columnCategory: 'owned', category: '%1%');
        break;
      case 'Wishlist':
        await dao.updateAll('amiibo', 'brandNew', '1', columnCategory: 'wishlist', category: '%1%');
        break;
      default:
        await dao.updateAll('amiibo', 'brandNew', '1',
          columnCategory: search ? 'name' : 'amiiboSeries', category: '%$name%');
        break;
    }
  }

  Future<List<String>> fetchDistinct() async =>
    dao.fetchDistinct('amiibo', 'amiiboSeries');

  Future<List<String>> searchDB(String name) async =>
    dao.fetchLimit('%$name%', 10);

  Future<bool> compareLastUpdate() async{
    return dao.lastUpdate().then((value) async{
      if (value != null){
        if(value.lastUpdated.isAtSameMomentAs(await lastUpdate)) return true;
      }
      return false;
    });
  }
}