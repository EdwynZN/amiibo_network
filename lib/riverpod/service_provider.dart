import 'dart:convert';

import 'package:amiibo_network/data/drift_sqlite/source/amiibo_dao.dart';
import 'package:amiibo_network/data/drift_sqlite/source/drift_database.dart'
    as db;
import 'package:amiibo_network/enum/amiibo_category_enum.dart';
import 'package:amiibo_network/enum/hidden_types.dart';
import 'package:amiibo_network/enum/sort_enum.dart';
import 'package:amiibo_network/model/amiibo.dart';
import 'package:amiibo_network/model/search_result.dart';
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
    required CategoryAttributes categoryAttributes,
    required SearchAttributes? searchAttributes,
    OrderBy orderBy = OrderBy.NA,
    SortBy sortBy = SortBy.DESC,
    List<String> figures = const [],
    List<String> cards = const [],
    HiddenType? hiddenCategories,
  }) =>
      service.fetchByCategory(
        categoryAttributes: categoryAttributes,
        searchAttributes: searchAttributes,
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
    required SearchAttributes? searchAttributes,
    OrderBy orderBy = OrderBy.NA,
    SortBy sortBy = SortBy.DESC,
    List<String>? figures,
    List<String>? cards,
    HiddenType? hiddenCategories,
  }) =>
      service.fetchDistinct(
        column: column,
        category: category,
        searchAttributes: searchAttributes,
        figures: figures,
        cards: cards,
        hiddenCategories: hiddenCategories,
        orderBy: orderBy,
        sortBy: sortBy,
      );

  @override
  Future<List<String>> search({
    required SearchAttributes searchAttributes,
    HiddenType? hidden,
  }) =>
      service.search(
        searchAttributes: searchAttributes,
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
  Future<List<Amiibo>> fetchAllAmiiboDB([String? orderBy]) async {
    final result = await _dao.fetchAll(category: AmiiboCategory.All);
    return result.map((e) => e.toDomain()).toList();
  }

  @override
  Future<Amiibo?> fetchOne(int key) async {
    final result = await _dao.fetchByKey(key);
    return result?.toDomain();
  }

  @override
  Future<List<Amiibo>> fetchByCategory({
    required CategoryAttributes categoryAttributes,
    required SearchAttributes? searchAttributes,
    OrderBy orderBy = OrderBy.NA,
    SortBy sortBy = SortBy.DESC,
    List<String> figures = const [],
    List<String> cards = const [],
    HiddenType? hiddenCategories,
  }) async {
    final result = await _dao.fetchAll(
      category: categoryAttributes.category,
      cards: cards,
      figures: figures,
      hiddenCategories: hiddenCategories,
      searchAttributes: searchAttributes,
      orderBy: orderBy,
      sortBy: sortBy,
    );
    return result.map((e) => e.toDomain()).toList();
  }

  @override
  Future<List<String>> fetchDistinct({
    List<String>? column,
    required AmiiboCategory category,
    required SearchAttributes? searchAttributes,
    OrderBy orderBy = OrderBy.NA,
    SortBy sortBy = SortBy.DESC,
    List<String>? figures,
    List<String>? cards,
    HiddenType? hiddenCategories,
  }) {
    return _dao.fetchDistincts(
      category: category,
      cards: cards ?? const [],
      figures: figures ?? const [],
      hiddenCategories: hiddenCategories,
      orderBy: orderBy,
      sortBy: sortBy,
      searchAttributes: searchAttributes,
    );
  }

  @override
  Future<List<Stat>> fetchStats({
    required AmiiboCategory category,
    List<String> figures = const [],
    List<String> cards = const [],
    List<String> series = const [],
    HiddenType? hiddenCategories,
    bool group = false,
  }) async {
    final result = await _dao.fetchSum(group: group);
    return result.map(Stat.fromJson).toList();
  }

  @override
  Future<String> jsonFileDB() async {
    final result = await _dao.fetchAll(category: AmiiboCategory.All);
    final List<Amiibo> amiibos = result.map((e) => e.toDomain()).toList();
    return jsonEncode(amiibos);
  }

  @override
  Future<void> resetCollection() async {
    await _dao.clear();
    notifyListeners();
  }

  @override
  Future<List<String>> search({
    required SearchAttributes searchAttributes,
    HiddenType? hidden,
  }) {
    return _dao.searchName(
      search: searchAttributes.search,
      category: searchAttributes.category,
    );
  }

  @override
  Future<void> update(List<UpdateAmiiboUserAttributes> amiibos) async {
    await _dao.updatePreferences(amiibos);
    notifyListeners();
  }
}
