import 'dart:io';
import 'package:amiibo_network/dao/SQLite/amiibo_sqlite.dart';
import '../model/amiibo_local_db.dart';
import 'dart:convert';

class Storage{
  final dao = AmiiboSQLite();

  Future<String> writeFile(
      {String name = 'MyAmiiboList', String folder = '/Download'}) async{
    Directory dir = await Directory('/storage/emulated/0$folder').create();
    String path = '${dir.path}/MyAmiiboList_${DateTime.now().toString().substring(0,10)}.json';
    String fileSaved = 'saved';
    final File file = File(path);
    if(file.existsSync()) fileSaved = 'overwritten';
    final AmiiboLocalDB amiibos = await dao.fetchAll();
    return file.writeAsString(jsonEncode(amiibos)).then((file) => '$name has been $fileSaved');
  }

  Future<bool> readFile(String path) async{
    final file = File(path);
    String data = file.readAsStringSync();
    final Map<String, dynamic> jResult = jsonDecode(data);
    if(!jResult.containsKey('amiibo')) return false;
    final AmiiboLocalDB amiibos = AmiiboLocalDB.fromJson(jResult);
    return dao.insertImport(amiibos).then((_) => true);
  }
}