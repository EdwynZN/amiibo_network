import 'package:amiibo_network/dao/SQLite/amiibo_sqlite.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/preferences_constants.dart';
import 'package:amiibo_network/model/amiibo.dart';

class UpdateService{
  static Map<String, dynamic> _jsonFile;
  static DateTime _lastUpdate;
  static DateTime _lastUpdateDB;
  final AmiiboSQLite dao = AmiiboSQLite();

  static final UpdateService _instance = UpdateService._();
  factory UpdateService() => _instance;
  UpdateService._();

  Future<void> initDB() async => await dao.initDB();

  Future<Map<String, dynamic>> get jsonFile async {
    return _jsonFile ??= jsonDecode(await rootBundle.loadString('assets/databases/amiibos.json'));
  }

  Future<List<Amiibo>> fetchAllAmiibo() async => compute(entityFromMap, await jsonFile);

  Future<DateTime> get lastUpdateDB async{
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return _lastUpdateDB ??= DateTime.tryParse(preferences.getString(sharedDateDB) ?? '');
  }

  Future<DateTime> get lastUpdate async{
    return _lastUpdate ??= DateTime.tryParse((await jsonFile)['lastUpdated'] ?? '');
  }

  Future<bool> createDB() async{
    return compareLastUpdate.then((sameDate) async {
      if(sameDate == null) throw Exception("Couldn't fetch last update");
      if(!sameDate) fetchAllAmiibo().then(_updateDB);
      return await Future.value(true);
    }).catchError((e) {
      print(e.toString());
      return false;
    });
  }

  _updateDB(List<Amiibo> amiibo) async{
    dao.insertAll(amiibo, "amiibo").then((_) async{
      final SharedPreferences preferences = await SharedPreferences.getInstance();
      final DateTime dateTime = await lastUpdate;
      await preferences.setString(sharedDateDB, dateTime?.toIso8601String());
    });
  }

  Future<bool> get compareLastUpdate async{
    final dateDB = await lastUpdateDB;
    final dateJson = await lastUpdate;

    return dateDB?.isAtSameMomentAs(dateJson) ?? false;
  }
}