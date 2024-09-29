import 'dart:async';

import 'package:amiibo_network/data/drift_sqlite/model/map_converter.dart';
import 'package:amiibo_network/data/drift_sqlite/source/affiliation_link_dao.dart';
import 'package:amiibo_network/data/drift_sqlite/source/amiibo_dao.dart';
import 'package:amiibo_network/data/drift_sqlite/source/drift_database.dart'
    as db;
import 'package:amiibo_network/data/drift_sqlite/source/drift_database.dart'
    show AmiiboUserPreferencesCompanion;
import 'package:amiibo_network/data/local_file_source/model/amiibo_local_json_model.dart'
    as dataModel;
import 'package:amiibo_network/data/local_file_source/model/country_local_file_model.dart';
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
  static List<Map<String, dynamic>>? _affiliationJsonFile;
  static DateTime? _lastUpdate;
  static DateTime? _lastUpdateDB;
  final AmiiboDao _dao;
  final AffiliationLinkDao _affiliationLinkDao;
  /* final AmiiboSQLite dao = AmiiboSQLite();

  static final UpdateService _instance = UpdateService._();
  factory UpdateService() => _instance;
  UpdateService._(); */

  UpdateService({
    required db.AppDatabase database,
  })  : _dao = database.amiiboDao,
        _affiliationLinkDao = database.affiliationLinkDao;

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

  Future<List<Map<String, dynamic>>> get _countryJsonFile async {
    return _affiliationJsonFile ??= (jsonDecode(
      await rootBundle.loadString('assets/databases/affiliation.json'),
    ) as List).cast<Map<String, dynamic>>();
  }

  Future<List<CountryLocalFileModel>> _modelCountries() async =>
      compute(fileCountryToModel, await _countryJsonFile);

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
      if (!sameDate) {
        await _updateDB();
      }
      return await Future.value(true);
    }).catchError((e, s) {
      unawaited(
          FirebaseCrashlytics.instance.recordError(e, s, reason: 'createDB'));
      return false;
    });
  }

  _updateDB() async {
    final amiibos = await _fetchAllAmiibo();
    final List<db.AmiiboTable> amiibosData = [];
    final List<AmiiboUserPreferencesCompanion> preferences = [];
    for (final a in amiibos) {
      amiibosData.add(dataFromDomain(a));
      preferences.add(
        AmiiboUserPreferencesCompanion.insert(amiiboKey: a.key),
      );
    }
    await _dao.insertAll(amiibosData: amiibosData, preferences: preferences);
    final countries = await _modelCountries();
    final List<db.CountryTable> contryTableList = [];
    final List<db.AffiliationLinkCompanion> links = [];
    for (final c in countries) {
      contryTableList.add(
        db.CountryTable(
          code: c.countryCode,
          en: c.translation.en,
          es: c.translation.es,
          fr: c.translation.fr,
        ),
      );
      links.add(
        db.AffiliationLinkCompanion.insert(
          countryCode: c.countryCode,
          amazon: c.amazonLink,
        ),
      );
    }
    await _affiliationLinkDao.saveCountries(countries: contryTableList);
    await _affiliationLinkDao.saveLinks(links: links);
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    final DateTime? dateTime = await lastUpdate;
    if (dateTime != null) {
      await sharedPref.setString(sharedDateDB, dateTime.toIso8601String());
    }
  }

  Future<bool> get upToDate async {
    final dateDB = await lastUpdateDB;
    final dateJson = await lastUpdate;

    if (dateDB == null || dateJson == null) return false;
    return dateDB.isAtSameMomentAs(dateJson);
  }
}
