import 'package:amiibo_network/dao/SQLite/amiibo_sqlite.dart';
import 'package:flutter/foundation.dart';
import '../model/amiibo_local_db.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

final AmiiboSQLite dao = AmiiboSQLite();

Future<void> initDB() async => await dao.initDB();

class Service{
  static Map<String, dynamic> _jsonFile;
  static DateTime _lastUpdate;
  static DateTime _lastUpdateDB;

  static final Service _instance = Service._();
  factory Service() => _instance;
  Service._();

  Future<Map<String, dynamic>> get jsonFile async {
    return _jsonFile ??= jsonDecode(await rootBundle.loadString('assets/databases/amiibos.json'));
  }

  Future<AmiiboLocalDB> fetchAllAmiibo() async => compute(entityFromMap, await jsonFile);

  Future<AmiiboLocalDB> fetchAllAmiiboDB(String orderBy) => dao.fetchAll(orderBy);

  Future<List<Map<String,dynamic>>> fetchSum({String column, List<String> args,
    bool group = false}) {
    if(column == null || args == null || args.isEmpty) column = args = null;
    return dao.fetchSum(column, args, group);
  }

  Future<String> jsonFileDB() async {
    final AmiiboLocalDB amiibos = await dao.fetchAll();
    return jsonEncode(amiibos);
  }

  Future<DateTime> get lastUpdateDB async{
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return _lastUpdateDB ??= DateTime.tryParse(preferences.getString('Date') ?? '');
  }

  Future<DateTime> get lastUpdate async{
    return _lastUpdate ??= DateTime.tryParse((await jsonFile)['lastUpdated'] ?? '');
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
      final SharedPreferences preferences = await SharedPreferences.getInstance();
      final DateTime dateTime = await lastUpdate;
      await preferences.setString('Date', dateTime?.toIso8601String());
    });
  }

  Future<AmiiboLocalDB> fetchByCategory([String column, List<String> args,
    String oderBy]) {
    if(column == null || args == null || args.isEmpty) column = args = null;
    return dao.fetchByColumn(column, args, oderBy);
  }

  Future<AmiiboDB> fetchAmiiboDBByKey(String key) => dao.fetchByKey(key);

  Future<void> update(AmiiboLocalDB amiibos) {
    return dao.insertImport(amiibos);
  }

  Future<List<String>> fetchDistinct([bool figure = true]) async =>
    dao.fetchDistinct('amiibo', 'amiiboSeries',
      figure ? 'type IS NOT' : 'type IS', ["Card"]);

  Future<List<String>> searchDB(String name) async =>
    dao.fetchLimit('%$name%', 10);

  Future<bool> compareLastUpdate() async{
    final dateDB = await lastUpdateDB;
    final dateJson = await lastUpdate;

    return dateDB?.isAtSameMomentAs(dateJson) ?? false;
  }

  Future<void> resetCollection() async{
    await dao.updateAll('amiibo', {'wishlist' : 0, 'owned' : 0});
  }
}