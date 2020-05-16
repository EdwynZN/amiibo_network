import 'package:amiibo_network/dao/SQLite/amiibo_sqlite.dart';
import '../model/amiibo_local_db.dart';
import '../model/query_builder.dart';
import 'dart:convert';

class Service{
  final AmiiboSQLite dao = AmiiboSQLite();

  Future<AmiiboLocalDB> fetchAllAmiiboDB([String orderBy]) => dao.fetchAll(orderBy);

  Future<List<Map<String,dynamic>>> fetchSum({Expression expression,
    bool group = false}) {
    String where = expression.toString();
    List<dynamic> args = expression.args;
    if(where.isEmpty | args.isEmpty) where = args = null;
    return dao.fetchSum(where, args, group);
  }

  Future<AmiiboLocalDB> fetchByCategory({Expression expression, String orderBy}) {
    String where = expression.toString();
    List<dynamic> args = expression.args;
    if(where.isEmpty | args.isEmpty) where = args = null;
    return dao.fetchByColumn(where, args, orderBy);
  }

  Future<String> jsonFileDB() async {
    final AmiiboLocalDB amiibos = await dao.fetchAll();
    return jsonEncode(amiibos);
  }

  Future<AmiiboDB> fetchAmiiboDBByKey(String key) => dao.fetchByKey(key);

  Future<void> update(AmiiboLocalDB amiibos) => dao.insertImport(amiibos);

  Future<List<String>> fetchDistinct({List<String> column, Expression expression, String orderBy}) {
    String where = expression.toString();
    List<dynamic> args = expression.args;
    if(where.isEmpty | args.isEmpty) where = args = null;
    return dao.fetchDistinct('amiibo', column, where, args, orderBy);
  }

  Future<List<String>> searchDB(Expression expression, String column) {
    String where = expression.toString();
    List<dynamic> args = expression.args;
    if(where.isEmpty | args.isEmpty) where = args = null;
    return dao.fetchLimit(where, args, 10, column);
  }

  Future<void> resetCollection() async{
    await dao.updateAll('amiibo', {'wishlist' : 0, 'owned' : 0});
  }
}