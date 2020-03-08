import 'package:amiibo_network/dao/SQLite/amiibo_sqlite.dart';
import '../model/amiibo_local_db.dart';
import 'dart:convert';

class Service{
  final AmiiboSQLite dao = AmiiboSQLite();

  Future<AmiiboLocalDB> fetchAllAmiiboDB([String orderBy]) => dao.fetchAll(orderBy);

  Future<List<Map<String,dynamic>>> fetchSum({String column, List<String> args,
    bool group = false}) {
    if(column == null || args == null || args.isEmpty) column = args = null;
    return dao.fetchSum(column, args, group);
  }

  Future<String> jsonFileDB() async {
    final AmiiboLocalDB amiibos = await dao.fetchAll();
    return jsonEncode(amiibos);
  }

  Future<AmiiboLocalDB> fetchByCategory([String column, List<String> args,
    String orderBy]) {
    if(column == null || (args?.isEmpty ?? true)) column = args = null;
    return dao.fetchByColumn(column, args, orderBy);
  }

  Future<AmiiboDB> fetchAmiiboDBByKey(String key) => dao.fetchByKey(key);

  Future<void> update(AmiiboLocalDB amiibos) => dao.insertImport(amiibos);

  Future<List<String>> fetchDistinct([bool figure = true]) async =>
    dao.fetchDistinct('amiibo', 'amiiboSeries',
      figure ? 'type IS NOT' : 'type IS', ["Card"]);

  Future<List<String>> searchDB(String name) async => dao.fetchLimit('%$name%', 10);

  Future<void> resetCollection() async{
    await dao.updateAll('amiibo', {'wishlist' : 0, 'owned' : 0});
  }
}