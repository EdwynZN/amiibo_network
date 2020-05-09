import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

Future<File> createFile([String name = 'MyAmiiboNetwork', String type = 'json']) async{
  Directory dir;
  StorageDirectory storage = StorageDirectory.documents;
  if(type == 'png') storage = StorageDirectory.pictures;
  if(Platform.isAndroid) dir = (await getExternalStorageDirectories(type: storage)).first;
  else dir = await getApplicationDocumentsDirectory();
  String path = '${dir.path}/${name}_${DateTime.now().toString().substring(0,10)}.$type';
  final File file = File(path);
  return file;
}

Map<String,dynamic> readFile(File file) {
  try{
    String data = file.readAsStringSync();
    final Map<String, dynamic> jResult = jsonDecode(data);
    if(!jResult.containsKey('amiibo')) return null;
    else return jResult;
  }catch(e){
    print(e.toString());
    return null;
  }
}

void writeFile(Map<String,dynamic> arg) =>
  arg['file'].writeAsStringSync(jsonEncode(arg['amiibos']));

void writeCollectionFile(Map<String, dynamic> arg) =>
  arg['file'].writeAsBytesSync(arg['buffer'], flush: true);