import 'package:amiibo_network/dao/SQLite/amiibo_sqlite.dart';
import 'package:amiibo_network/model/search_result.dart';
import 'dart:convert';
import 'package:amiibo_network/model/amiibo.dart';
import 'package:amiibo_network/model/stat.dart';

class Service {
  final AmiiboSQLite dao = AmiiboSQLite();

  Future<Amiibo?> fetchOne(int key) {
    return dao.fetchByKey(key);
  }

  Future<List<Amiibo>> fetchAllAmiiboDB([String? orderBy]) =>
      dao.fetchAll(orderBy);

  Future<List<Stat>> fetchStats(
      {required Expression expression, bool group = false}) async {
    String? where = expression.toString();
    List<dynamic>? args = expression.args;
    if (where.isEmpty || args.isEmpty) where = args = null;
    final result = await dao.fetchSum(where, args, group);
    return result.map<Stat>((e) => Stat.fromJson(e)).toList();
  }

  Future<List<Amiibo>> fetchByCategory(QueryBuilder builder) {
    String? where = builder.where.toString();
    List<dynamic>? args = builder.where.args;
    if (where.isEmpty || args.isEmpty) where = args = null;
    return dao.fetchByColumn(where, args, builder.order, builder.sortBy);
  }

  Future<String> jsonFileDB() async {
    final List<Amiibo> amiibos = await dao.fetchAll();
    return jsonEncode(amiibos);
  }

  Future<Amiibo?> fetchAmiiboDBByKey(int key) => dao.fetchByKey(key);

  Future<void> update(List<Amiibo> amiibos) => dao.insertImport(amiibos);

  Future<List<String>> fetchDistinct(
      {List<String>? column, required Expression expression, String? orderBy}) {
    String? where = expression.toString();
    List<Object>? args = expression.args;
    if (where.isEmpty || args.isEmpty) where = args = null;
    return dao.fetchDistinct('amiibo', column, where, args, orderBy);
  }

  Future<List<String>> searchDB(Expression expression, String column) {
    String? where = expression.toString();
    List<dynamic>? args = expression.args;
    if (where.isEmpty || args.isEmpty) where = args = null;
    return dao.fetchLimit(where, args, 10, column);
  }

  Future<void> resetCollection() async {
    await dao.updateAll('amiibo', {'wishlist': 0, 'owned': 0});
  }
}
