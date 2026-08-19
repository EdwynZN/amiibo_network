import 'dart:async';
import 'dart:convert';

import 'package:amiibo_network/app/configuration/model/sort_enum.dart';
import 'package:amiibo_network/entity/amiibo_info/model/amiibo.dart';
import 'package:amiibo_network/shared/data/drift_sqlite/model/map_converter.dart';
import 'package:amiibo_network/shared/data/drift_sqlite/source/affiliation_link_dao.dart';
import 'package:amiibo_network/shared/data/drift_sqlite/source/amiibo_dao.dart';
import 'package:amiibo_network/shared/data/drift_sqlite/source/drift_database.dart'
    as db;
import 'package:amiibo_network/shared/data/local_file_source/model/amiibo_local_json_model.dart'
    as dataModel;
import 'package:amiibo_network/shared/data/local_file_source/model/country_local_file_model.dart';
import 'package:amiibo_network/shared/utils/preferences_constants.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'update_service.g.dart';

@riverpod
UpdateService updateService(Ref ref) =>
    UpdateService(database: ref.watch(db.databaseProvider));

typedef _Images = ({
  List<db.AmiiboImagesCompanion> images,
  List<db.AmiiboBundleImagesCompanion> bundles,
});

_Images _imagesFromJson(Map<String, dynamic> amiibo) {
  final images = amiibo["amiibos"] as List;
  final bundles = amiibo["bundles"] as List;
  return (
    images: images.map((e) {
      final map = e as Map<String, dynamic>;
      return db.AmiiboImagesCompanion.insert(
        amiiboKey: map['amiibo_key'] as int,
        filePath: map['file_path'] as String,
        createAt: map['created_at'] as int,
      );
    }).toList(),
    bundles: bundles.map((e) {
      final map = e as Map<String, dynamic>;
      return db.AmiiboBundleImagesCompanion.insert(
        amiiboBundleId: map['amiibo_bundle_id'] as int,
        filePath: map['file_path'] as String,
        createAt: map['created_at'] as int,
      );
    }).toList(),
  );
}

class UpdateService {
  static Map<String, dynamic>? _jsonFile;
  static Map<String, dynamic>? _imagesJsonFile;
  static List<Map<String, dynamic>>? _affiliationJsonFile;
  static DateTime? _lastUpdate;
  static DateTime? _lastUpdateDB;
  final AmiiboDao _dao;
  final AffiliationLinkDao _affiliationLinkDao;

  UpdateService({required db.AppDatabase database})
    : _dao = database.amiiboDao,
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
    return switch (order) {
      'name' => .Name,
      'owned' => .Owned,
      'wishlist' => .Wishlist,
      'eu' => .EU,
      'au' => .AU,
      'jp' => .JP,
      _ => .NA,
    };
  }

  Future<Map<String, dynamic>> get jsonFile async {
    return _jsonFile ??= jsonDecode(
      await rootBundle.loadString('assets/databases/amiibos.json'),
    );
  }

  Future<List<Amiibo>> _fetchAllAmiibo() async =>
      compute(dataModel.entityFromMapToDomain, await jsonFile);

  Future<_Images> _fetchAmiiboImages() async =>
      compute(_imagesFromJson, await _amiiboImagesJsonFile);

  Future<Map<String, dynamic>> get _amiiboImagesJsonFile async {
    return _imagesJsonFile ??= jsonDecode(
      await rootBundle.loadString('assets/databases/amiibo_images.json'),
    );
  }

  Future<List<Map<String, dynamic>>> get _countryJsonFile async {
    return _affiliationJsonFile ??=
        (jsonDecode(
                  await rootBundle.loadString(
                    'assets/databases/affiliation.json',
                  ),
                )
                as List)
            .cast<Map<String, dynamic>>();
  }

  Future<List<CountryLocalFileModel>> _modelCountries() async =>
      compute(fileCountryToModel, await _countryJsonFile);

  Future<DateTime?> get lastUpdateDB async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return _lastUpdateDB ??= DateTime.tryParse(
      preferences.getString(sharedDateDB) ?? '',
    );
  }

  Future<DateTime?> get lastUpdate async {
    final map = await jsonFile;
    return _lastUpdate ??= DateTime.tryParse(map['lastUpdated'] ?? '');
  }

  Future<bool> createDB() async {
    return upToDate
        .then((sameDate) async {
          if (!sameDate) await _updateDB();
          return await Future.value(true);
        })
        .catchError((e, s) {
          unawaited(
            FirebaseCrashlytics.instance.recordError(e, s, reason: 'createDB'),
          );
          return false;
        });
  }

  Future<void> _updateDB() async {
    await _updateAmiibosDb();

    await _updateAffiliations();

    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    final DateTime? dateTime = await lastUpdate;
    if (dateTime != null) {
      await sharedPref.setString(sharedDateDB, dateTime.toIso8601String());
    }
  }

  Future<void> _updateAmiibosDb() async {
    final amiibos = await _fetchAllAmiibo();
    final images = await _fetchAmiiboImages();
    final List<db.AmiiboTable> amiibosData = [];
    final List<db.AmiiboUserPreferencesCompanion> preferences = [];
    for (final a in amiibos) {
      final id = a.key;
      amiibosData.add(dataFromDomain(a));
      preferences.add(db.AmiiboUserPreferencesCompanion.insert(amiiboKey: id));
    }
    await _dao.insertAll(
      amiibosData: amiibosData,
      preferences: preferences,
      amiiboImagesData: images.images,
      amiiboBundleImagesData: images.bundles,
    );
  }

  Future<void> _updateAffiliations() async {
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
  }

  Future<bool> get upToDate async {
    final dateDB = await lastUpdateDB;
    final dateJson = await lastUpdate;

    if (dateDB == null || dateJson == null) return false;
    return dateDB.isAtSameMomentAs(dateJson);
  }
}
