import 'package:amiibo_network/dao/SQLite/amiibo_sqlite.dart';
import '../model/amiibo_local_db.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class Service {
  final dao = AmiiboSQLite();
  static Map<String, dynamic> _jsonFile;
  static DateTime _lastUpdate;
  static DateTime _lastUpdateDB;

  static final Service _instance = Service._();
  factory Service() => _instance;
  Service._();

  Future<String> getTheme() async => await dao.favoriteTheme();

  Future updateTheme(String theme) async => await dao.updateTheme(theme);

  Future<Map<String, dynamic>> get jsonFile async {
    return _jsonFile ??= jsonDecode(await rootBundle.loadString('assets/databases/amiibos.json'));
  }

  Future<AmiiboLocalDB> fetchAllAmiibo() async {
    return AmiiboLocalDB.fromJson(await jsonFile);
  }

  Future<AmiiboLocalDB> fetchAllAmiiboDB() => dao.fetchAll();

  Future<String> jsonFileDB() async {
    final AmiiboLocalDB amiibos = await dao.fetchAll();
    return jsonEncode(amiibos);
  }

  Future<DateTime> get lastUpdateDB async{
    return _lastUpdateDB ??= await dao.lastUpdate()
      .then((x) => x?.lastUpdated);
  }

  Future<DateTime> get lastUpdate async{
    return _lastUpdate ??= LastUpdateDB.fromMap(await jsonFile).lastUpdated;
  }

  Future<bool> createDB() async{
    return compareLastUpdate().then((sameDate) async {
      if(sameDate == null) throw Exception("Couldn't fetch last update");
      if(!sameDate) fetchAllAmiibo().then(_updateDB);
      return await Future.value(true);
    }).catchError((e) {
      print(e.toString());
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

  Future<void> update(AmiiboLocalDB amiibos) {
    return dao.insertImport(amiibos);
    /*return amiibos.amiibo.length == 1 ? dao.update(amiibos.amiibo[0], "amiibo")
      : dao.insertAll(amiibos, 'amiibo');*/
  }

  Future<List<String>> fetchDistinct() async =>
    dao.fetchDistinct('amiibo', 'amiiboSeries');

  Future<List<String>> searchDB(String name) async =>
    dao.fetchLimit('%$name%', 10);

  Future<bool> compareLastUpdate() async{
    final dateDB = await lastUpdateDB;
    final dateJson = await lastUpdate;

    return dateDB?.isAtSameMomentAs(dateJson) ?? false;
  }
}