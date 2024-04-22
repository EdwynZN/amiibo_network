import 'dart:async';

import 'package:amiibo_network/data/drift_sqlite/source/amiibo_dao.dart';
import 'package:amiibo_network/data/drift_sqlite/source/drift_database.dart' as db;
import 'package:amiibo_network/data/local_file_source/model/amiibo_local_json_model.dart' as dataModel;
import 'package:amiibo_network/enum/sort_enum.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/preferences_constants.dart';
import 'package:amiibo_network/model/amiibo.dart';

final updateServiceProvider = Provider(
  (ref) => UpdateService(
    database: ref.watch(db.databaseProvider),
  ),
);

class UpdateService {
  static Map<String, dynamic>? _jsonFile;
  static DateTime? _lastUpdate;
  static DateTime? _lastUpdateDB;
  final AmiiboDao _dao;
  /* final AmiiboSQLite dao = AmiiboSQLite();

  static final UpdateService _instance = UpdateService._();
  factory UpdateService() => _instance;
  UpdateService._(); */

  UpdateService({
    required db.AppDatabase database,
  }) : _dao = database.amiiboDao;

  Future<void> updateSort(SharedPreferences preferences) async {
    late final OrderBy order;
    SortBy sort = SortBy.DESC;
    if (preferences.containsKey(sharedOldSort)) {
      final String? value = preferences.getString(sharedOldSort);
      String? _orderPreference = value?.split(' ')[0];
      order = _stringToOrderBy(_orderPreference);
      if (value?.contains('ASC') ?? false) sort = SortBy.ASC;
      preferences
        ..setInt(orderPreference, order.index)
        ..setInt(sortPreference, sort.index)
        ..remove(sharedOldSort);
    } else if (preferences.containsKey(sharedOrder) ||
        preferences.containsKey(sharedSort)) {
      String _orderPreference = preferences.getString(sharedOrder) ?? 'na';
      order = _stringToOrderBy(_orderPreference);
      String _sort = preferences.getString(sharedSort) ?? 'DESC';
      if (_sort.contains('ASC')) sort = SortBy.ASC;
      preferences
        ..setInt(orderPreference, order.index)
        ..setInt(sortPreference, sort.index)
        ..remove(sharedSort)
        ..remove(sharedOrder);
    }
  }

  OrderBy _stringToOrderBy(String? order) {
    switch (order) {
      case 'name':
        return OrderBy.Name;
      case 'owned':
        return OrderBy.Owned;
      case 'wishlist':
        return OrderBy.Wishlist;
      case 'eu':
        return OrderBy.EU;
      case 'au':
        return OrderBy.AU;
      case 'jp':
        return OrderBy.JP;
      case 'na':
      default:
        return OrderBy.NA;
    }
  }

  Future<Map<String, dynamic>?> get jsonFile async {
    return _jsonFile ??= jsonDecode(
        await rootBundle.loadString('assets/databases/amiibos.json'));
  }

  Future<List<Amiibo>> _fetchAllAmiibo() async =>
      compute(dataModel.entityFromMapToDomain, (await jsonFile)!);

  Future<DateTime?> get lastUpdateDB async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return _lastUpdateDB ??=
        DateTime.tryParse(preferences.getString(sharedDateDB) ?? '');
  }

  Future<DateTime?> get lastUpdate async {
    return _lastUpdate ??=
        DateTime.tryParse((await jsonFile)!['lastUpdated'] ?? '');
  }

  Future<bool> createDB() async {
    return upToDate.then((sameDate) async {
      //if (sameDate == null) throw Exception("Couldn't fetch last update");
      if (!sameDate) _fetchAllAmiibo().then(_updateDB);
      return await Future.value(true);
    }).catchError((e, s) {
      unawaited(
          FirebaseCrashlytics.instance.recordError(e, s, reason: 'createDB'));
      return false;
    });
  }

  _updateDB(List<Amiibo> amiibo) async {
    _dao.insertAll(amiibo).then((_) async {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final DateTime? dateTime = await lastUpdate;
      if (dateTime != null)
        await preferences.setString(sharedDateDB, dateTime.toIso8601String());
    });
  }

  Future<bool> get upToDate async {
    final dateDB = await lastUpdateDB;
    final dateJson = await lastUpdate;

    if (dateDB == null || dateJson == null) return false;
    return dateDB.isAtSameMomentAs(dateJson);
  }
}
