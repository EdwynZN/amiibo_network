import 'package:amiibo_network/shared/data/drift_sqlite/source/amiibo_dao.dart';
import 'package:amiibo_network/shared/data/drift_sqlite/source/drift_database.dart'
    as db;
import 'package:amiibo_network/app/configuration/model/amiibo_category_enum.dart';
import 'package:amiibo_network/app/configuration/model/hidden_types.dart';
import 'package:amiibo_network/app/configuration/model/sort_enum.dart';
import 'package:amiibo_network/entity/amiibo_info/model/amiibo.dart';
import 'package:amiibo_network/app/configuration/model/search_result.dart';
import 'package:amiibo_network/entity/amiibo_info/model/stat.dart';
import 'package:amiibo_network/feature/amiibo/application/input/update_amiibo_user_attributes.dart';
import 'package:amiibo_network/shared/service/service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/legacy.dart';

final serviceProvider = ChangeNotifierProvider<AmiiboServiceNotifer>(
  (ref) => DriftServiceNotifier(database: ref.watch(db.databaseProvider)),
);

abstract class AmiiboServiceNotifer extends ChangeNotifier
    implements AmiiboService {
  Future<void> updateFromAmiibos(List<Amiibo> amiibos) async {
    await update(
      amiibos
          .map(
            (a) => UpdateAmiiboUserAttributes(
              id: a.key,
              attributes: a.userAttributes,
            ),
          )
          .toList(),
    );
  }
}

class DriftServiceNotifier extends AmiiboServiceNotifer {
  final AmiiboDao _dao;

  DriftServiceNotifier({required db.AppDatabase database})
    : _dao = database.amiiboDao;

  @override
  Future<List<Amiibo>> fetchAllAmiibo() async {
    final result = await _dao.fetchAll(
      categoryAttributes: const CategoryAttributes(
        category: AmiiboCategory.All,
      ),
    );
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
      categoryAttributes: categoryAttributes,
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
    required CategoryAttributes categoryAttributes,
    required SearchAttributes? searchAttributes,
    OrderBy orderBy = OrderBy.NA,
    SortBy sortBy = SortBy.DESC,
    HiddenType? hiddenCategories,
  }) {
    return _dao.fetchDistincts(
      categoryAttributes: categoryAttributes,
      hiddenCategories: hiddenCategories,
      orderBy: orderBy,
      sortBy: sortBy,
      searchAttributes: searchAttributes,
    );
  }

  @override
  Future<List<Stat>> fetchStats({
    required CategoryAttributes categoryAttributes,
    required SearchAttributes? searchAttributes,
    List<String> figures = const [],
    List<String> cards = const [],
    List<String> series = const [],
    HiddenType? hiddenCategories,
    bool group = false,
  }) async {
    final result = await _dao.fetchSum(
      categoryAttributes: categoryAttributes,
      searchAttributes: searchAttributes,
      hiddenCategories: hiddenCategories,
      group: group,
    );
    return result.map(Stat.fromJson).toList();
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
