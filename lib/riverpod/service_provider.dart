import 'dart:convert';
import 'package:amiibo_network/dao/SQLite/amiibo_sqlite.dart';
import 'package:amiibo_network/model/amiibo.dart';
import 'package:amiibo_network/model/search_result.dart';
import 'package:amiibo_network/service/service.dart';
import 'package:flutter/material.dart';
import 'package:amiibo_network/model/stat.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final serviceProvider = ChangeNotifierProvider((_) => ServiceNotifier());

class ServiceNotifier extends ChangeNotifier implements Service {
  final AmiiboSQLite dao = AmiiboSQLite();

  Future<void> shift(int key) async {
    final Amiibo? amiibo = await fetchOne(key);
    if (amiibo == null) return;
    final Amiibo amiiboUpdated = amiibo.copyWith(
      wishlist: amiibo.owned,
      owned: !(amiibo.wishlist ^ amiibo.owned),
    );
    return update([amiiboUpdated]);
  }

  @override
  Future<List<Amiibo>> fetchAllAmiiboDB([String? orderBy]) =>
      dao.fetchAll(orderBy);

  @override
  Future<List<Stat>> fetchStats(
      {required Expression expression, bool group = false}) async {
    String? where = expression.toString();
    List<dynamic>? args = expression.args;
    if (where.isEmpty || args.isEmpty) where = args = null;
    final result = await dao.fetchSum(where, args, group);
    return result.map<Stat>((e) => Stat.fromJson(e)).toList();
  }

  @override
  Future<List<Amiibo>> fetchByCategory(
      {required Expression expression, String? orderBy}) {
    String? where = expression.toString();
    List<dynamic>? args = expression.args;
    if (where.isEmpty || args.isEmpty) where = args = null;
    return dao.fetchByColumn(where, args, orderBy);
  }

  @override
  Future<String> jsonFileDB() async {
    final List<Amiibo> amiibos = await dao.fetchAll();
    return jsonEncode(amiibos);
  }

  @override
  Future<Amiibo?> fetchAmiiboDBByKey(int key) => dao.fetchByKey(key);

  @override
  Future<void> update(List<Amiibo> amiibos) async {
    await dao.insertImport(amiibos);
    notifyListeners();
  }

  @override
  Future<List<String>> fetchDistinct(
      {List<String>? column, required Expression expression, String? orderBy}) {
    String? where = expression.toString();
    List<Object>? args = expression.args;
    if (where.isEmpty || args.isEmpty) where = args = null;
    return dao.fetchDistinct('amiibo', column, where, args, orderBy);
  }

  @override
  Future<List<String>> searchDB(Expression expression, String column) {
    String? where = expression.toString();
    List<dynamic>? args = expression.args;
    if (where.isEmpty || args.isEmpty) where = args = null;
    return dao.fetchLimit(where, args, 10, column);
  }

  @override
  Future<void> resetCollection() async {
    await dao.updateAll('amiibo', {'wishlist': 0, 'owned': 0});
    notifyListeners();
  }

  @override
  Future<Amiibo?> fetchOne(int key) => dao.fetchByKey(key);
}
