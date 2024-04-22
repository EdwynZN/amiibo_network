import 'dart:convert';

import 'package:amiibo_network/data/drift_sqlite/source/amiibo_dao.dart';
import 'package:amiibo_network/data/drift_sqlite/source/drift_database.dart'
    as db;
import 'package:amiibo_network/enum/amiibo_category_enum.dart';
import 'package:amiibo_network/enum/hidden_types.dart';
import 'package:amiibo_network/enum/sort_enum.dart';
import 'package:amiibo_network/model/amiibo.dart';
import 'package:amiibo_network/model/stat.dart';
import 'package:amiibo_network/model/update_amiibo_user_attributes.dart';
import 'package:amiibo_network/service/service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final serviceProvider = ChangeNotifierProvider<ServiceNotifer>(
  (ref) => DriftServiceNotifier(database: ref.watch(db.databaseProvider)),
);

abstract class ServiceNotifer extends ChangeNotifier implements Service {
  Future<void> updateFromAmiibos(List<Amiibo> amiibos) async {
    await update(amiibos
        .map(
          (a) => UpdateAmiiboUserAttributes(
              id: a.key, attributes: a.userAttributes),
        )
        .toList());
  }
}

class ProxyServiceNotifier extends ServiceNotifer {
  final Service service;
  ProxyServiceNotifier(this.service);

  Future<void> shift(int key) async {
    final Amiibo? amiibo = await fetchOne(key);
    if (amiibo == null) return;
    final amiiboUpdated = switch (amiibo.userAttributes) {
      OwnedUserAttributes() => const WishedUserAttributes(),
      const WishedUserAttributes() => const EmptyUserAttributes(),
      _ => UserAttributes.owned(),
    };
    return update([
      UpdateAmiiboUserAttributes(id: amiibo.key, attributes: amiiboUpdated),
    ]);
  }

  @override
  Future<List<Amiibo>> fetchAllAmiiboDB([String? orderBy]) =>
      service.fetchAllAmiiboDB(orderBy);

  @override
  Future<List<Stat>> fetchStats({
    required AmiiboCategory category,
    List<String> figures = const [],
    List<String> cards = const [],
    List<String> series = const [],
    HiddenType? hiddenCategories,
    bool group = false,
  }) =>
      service.fetchStats(
        category: category,
        cards: cards,
        figures: figures,
        hiddenCategories: hiddenCategories,
        series: series,
        group: group,
      );

  @override
  Future<List<Amiibo>> fetchByCategory({
    required AmiiboCategory category,
    String? search,
    OrderBy orderBy = OrderBy.NA,
    SortBy sortBy = SortBy.DESC,
    List<String> figures = const [],
    List<String> cards = const [],
    HiddenType? hiddenCategories,
  }) =>
      service.fetchByCategory(
        category: category,
        search: search,
        orderBy: orderBy,
        sortBy: sortBy,
        figures: figures,
        cards: cards,
        hiddenCategories: hiddenCategories,
      );

  @override
  Future<String> jsonFileDB() => service.jsonFileDB();

  @override
  Future<void> update(List<UpdateAmiiboUserAttributes> amiibos) async {
    await service.update(amiibos);
    notifyListeners();
  }

  @override
  Future<List<String>> fetchDistinct({
    List<String>? column,
    required AmiiboCategory category,
    String? search,
    OrderBy orderBy = OrderBy.NA,
    SortBy sortBy = SortBy.DESC,
    List<String>? figures,
    List<String>? cards,
    HiddenType? hiddenCategories,
  }) =>
      service.fetchDistinct(
        column: column,
        category: category,
        search: search,
        figures: figures,
        cards: cards,
        hiddenCategories: hiddenCategories,
        orderBy: orderBy,
        sortBy: sortBy,
      );

  @override
  Future<List<String>> searchDB({
    required String filter,
    required AmiiboCategory category,
    HiddenType? hidden,
  }) =>
      service.searchDB(
        filter: filter,
        category: category,
        hidden: hidden,
      );

  @override
  Future<void> resetCollection() async {
    await service.resetCollection();
    notifyListeners();
  }

  @override
  Future<Amiibo?> fetchOne(int key) => service.fetchOne(key);
}

class DriftServiceNotifier extends ServiceNotifer {
  final AmiiboDao _dao;

  DriftServiceNotifier({
    required db.AppDatabase database,
  }) : _dao = database.amiiboDao;

  @override
  Future<List<Amiibo>> fetchAllAmiiboDB([String? orderBy]) {
    return _dao.fetchAll(category: AmiiboCategory.All);
  }

  @override
  Future<Amiibo?> fetchOne(int key) {
    return _dao.fetchByKey(key);
  }

  @override
  Future<List<Amiibo>> fetchByCategory(
      {required AmiiboCategory category,
      String? search,
      OrderBy orderBy = OrderBy.NA,
      SortBy sortBy = SortBy.DESC,
      List<String> figures = const [],
      List<String> cards = const [],
      HiddenType? hiddenCategories}) {
    return _dao.fetchAll(category: AmiiboCategory.All);
  }

  @override
  Future<List<String>> fetchDistinct({
    List<String>? column,
    required AmiiboCategory category,
    String? search,
    OrderBy orderBy = OrderBy.NA,
    SortBy sortBy = SortBy.DESC,
    List<String>? figures,
    List<String>? cards,
    HiddenType? hiddenCategories,
  }) {
    return _dao.searchName(search: search ?? '');
  }

  @override
  Future<List<Stat>> fetchStats(
      {required AmiiboCategory category,
      List<String> figures = const [],
      List<String> cards = const [],
      List<String> series = const [],
      HiddenType? hiddenCategories,
      bool group = false}) {
    // TODO: implement fetchStats
    throw UnimplementedError();
  }

  @override
  Future<String> jsonFileDB() async {
    final List<Amiibo> amiibos = await _dao.fetchAll(category: AmiiboCategory.All);
    return jsonEncode(amiibos);
  }

  @override
  Future<void> resetCollection() => _dao.clear();

  @override
  Future<List<String>> searchDB({
    required String filter,
    required AmiiboCategory category,
    HiddenType? hidden,
  }) {
    return _dao.searchName(search: filter);
  }

  @override
  Future<void> update(List<UpdateAmiiboUserAttributes> amiibos) {
    return _dao.updatePreferences(amiibos);
  }
}
