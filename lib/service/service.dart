import 'dart:async';
import 'package:amiibo_network/service/amiibo_api_provider.dart';
import 'package:amiibo_network/dao/SQLite/amiibo_sqlite.dart';
import '../model/amiibo.dart';
import '../model/amiibo_local_db.dart';
import 'dart:io';

class Service {
  final amiiboApiProvider = AmiiboApiProvider();
  final dao = AmiiboSQLite();
  static DateTime _lastUpdate;
  static DateTime _lastUpdateDB;

  static final Service _instance = Service._();
  factory Service() => _instance;
  Service._();

  Future<AmiiboClient> fetchAllAmiibo() => amiiboApiProvider.fetchAllAmiibo();

  Future<AmiiboLocalDB> fetchAllAmiiboDB() => dao.fetchAll();

  Future<DateTime> get lastUpdateDB async{
    return _lastUpdateDB ??= await dao.lastUpdate()
      .then((x) => x?.lastUpdated);
  }

  Future<DateTime> get lastUpdate async{
    return _lastUpdate ??= await amiiboApiProvider.fetchLastUpdate()
      .then((x) => x?.lastUpdated)
      .catchError((e) {
        return null;
    });
  }

  Future<bool> createDB() async{
    return compareLastUpdate().then((sameDate) async {
      if(sameDate == null) throw Exception("Couldn't fetch last update");
      if(!sameDate) {
        final amiiboAPI = await amiiboApiProvider.fetchAllAmiibo();
        await _updateDB(entityFromMap(amiiboAPI.toMap()));
      }
      return await Future.value(true);
    }).catchError((e) {
      if(e is SocketException) print('Failed to coneect. Check your internet connection');
      else print(e.toString());
      return false;
    });
  }

  _updateDB(AmiiboLocalDB amiiboDB) async{
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

  Future<AmiiboLocalDB> findNew() async => dao.findNew();

  Future<void> cleanNew(String name, [String search]) async {
    switch(name){
      case 'All':
        await dao.updateAll('amiibo', 'brandNew', '1');
        break;
      case 'New':
        await dao.updateAll('amiibo', 'brandNew', '1');
        break;
      case 'Owned':
        await dao.updateAll('amiibo', 'brandNew', '1', columnCategory: 'owned', category: '%1%');
        break;
      case 'Wishlist':
        await dao.updateAll('amiibo', 'brandNew', '1', columnCategory: 'wishlist', category: '%1%');
        break;
      default:
        await dao.updateAll('amiibo', 'brandNew', '1', columnCategory: search, category: '%$name%');
        break;
    }
  }

  Future<List<String>> fetchDistinct() async =>
    dao.fetchDistinct('amiibo', 'amiiboSeries');

  Future<List<String>> searchDB(String name) async =>
    dao.fetchLimit('%$name%', 10);

  Future<bool> compareLastUpdate() async{
    final dateDB = await lastUpdateDB;
    final dateAPI = await lastUpdate;

    if(dateAPI == null) return null;

    return dateDB?.isAtSameMomentAs(dateAPI) ?? false;
  }
}