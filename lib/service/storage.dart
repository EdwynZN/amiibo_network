import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:amiibo_network/dao/SQLite/amiibo_sqlite.dart';
import '../model/amiibo_local_db.dart';
import 'dart:convert';

enum AppDirectory{ EXTERNAL, TEMPORAL, LOCAL }

class Storage{
  final dao = AmiiboSQLite();
  Future get externalDirectory async => await getExternalStorageDirectory();
  Future get tempDirectory async => await getTemporaryDirectory();
  Future get localPath async => await getApplicationDocumentsDirectory();

  Future<String> writeFile(AppDirectory kDir,
      {String name = 'MyAmiiboList', String folder = '/Download'}) async{
    Directory dir;
    String path;
    String fileSaved = 'saved';
    switch(kDir){
      case AppDirectory.EXTERNAL:
        dir = await externalDirectory;
        dir = await Directory('${dir.path}$folder').create();
        break;
      case AppDirectory.TEMPORAL:
        dir = await tempDirectory;
        dir = await Directory(dir.path).create();
        break;
      case AppDirectory.LOCAL:
        dir = await localPath;
        dir = await Directory(dir.path).create();
        break;
    }
    path = '${dir.path}/MyAmiiboList_${DateTime.now().toString().substring(0,10)}.json';
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