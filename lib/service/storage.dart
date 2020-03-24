import 'dart:io';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

bool checkPermission(PermissionStatus permission) {
  switch(permission){
    case(PermissionStatus.granted):
    case(PermissionStatus.unknown):
      return true;
    case(PermissionStatus.denied):
    case(PermissionStatus.neverAskAgain):
    case(PermissionStatus.restricted):
    default:
      return false;
  }
}

Future<File> createFile([String name = 'MyAmiiboNetwork', String type = 'json']) async{
  Directory dir;
  if(Platform.isAndroid) dir = await getExternalStorageDirectory();
  else dir = await getApplicationDocumentsDirectory();
  String path = '${dir.path}/${name}_${DateTime.now().toString().substring(0,10)}.$type';
  final File file = File(path);
  return file;
}

Future<File> createCacheFile(String path) async{
  final File file = File(path);
  final Directory dir = await getTemporaryDirectory();
  final File copyFile = await file.copy('${dir.path}/cacheAmiibo.json');
  return copyFile;
}

Map<String,dynamic> readFile1(File file) {
  String data = file.readAsStringSync();
  final Map<String, dynamic> jResult = jsonDecode(data);
  if(!jResult.containsKey('amiibo')) return null;
  else return jResult;
}

Map<String,dynamic> readFile(String path) {
  final file = File(path);
  String data = file.readAsStringSync();
  final Map<String, dynamic> jResult = jsonDecode(data);
  if(!jResult.containsKey('amiibo')) return null;
  else return jResult;
}

void writeFile(Map<String,dynamic> arg) =>
  arg['file'].writeAsStringSync(jsonEncode(arg['amiibos']));

void writeCollectionFile(Map<String, dynamic> arg) =>
  arg['file'].writeAsBytesSync(arg['buffer'], flush: true);