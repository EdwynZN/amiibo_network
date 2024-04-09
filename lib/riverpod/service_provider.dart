import 'package:amiibo_network/enum/amiibo_category_enum.dart';
import 'package:amiibo_network/enum/hidden_types.dart';
import 'package:amiibo_network/enum/sort_enum.dart';
import 'package:amiibo_network/model/amiibo.dart';
import 'package:amiibo_network/model/stat.dart';
import 'package:amiibo_network/model/update_amiibo_user_attributes.dart';
import 'package:amiibo_network/service/service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final serviceProvider = ChangeNotifierProvider<ProxyServiceNotifier>(
  (_) => ProxyServiceNotifier(Service()),
);

class ProxyServiceNotifier extends ChangeNotifier implements Service {
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
    List<String> cards = const[],
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
  Future<Amiibo?> fetchAmiiboDBByKey(int key) =>
      service.fetchAmiiboDBByKey(key);

  Future<void> updateFromAmiibos(List<Amiibo> amiibos) async {
    await update(amiibos
        .map(
          (a) => UpdateAmiiboUserAttributes(
              id: a.key, attributes: a.userAttributes),
        )
        .toList());
  }

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
  }) => service.searchDB(
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
