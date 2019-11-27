import 'dart:io';
import '../model/amiibo_local_db.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

Map<String, dynamic> checkPermission(PermissionStatus permission) {
  Map<String, dynamic> response = Map<String, dynamic>();
  switch(permission){
    case(PermissionStatus.granted):
      response['permission'] = true;
      response['message'] = 'Storage permission granted';
      break;
    case(PermissionStatus.denied):
      response['permission'] = false;
      response['message'] = 'Storage permission denied';
      break;
    case(PermissionStatus.disabled):
      response['permission'] = false;
      response['message'] = 'Storage permission disabled';
      break;
    case(PermissionStatus.restricted):
      response['permission'] = false;
      response['message'] = 'Storage permission restricted';
      break;
    case(PermissionStatus.unknown):
      response['permission'] = false;
      response['message'] = 'Unknown Error';
      break;
  }
  return response;
}

Future<Map<String,dynamic>> readFile(String path) async{
  print(path);
  final file = File(path);
  String data = file.readAsStringSync();
  final Map<String, dynamic> jResult = jsonDecode(data);
  if(!jResult.containsKey('amiibo')) return null;
  else return jResult;
}

Future<String> writeFile(AmiiboLocalDB amiibos) async{
  String name = 'MyAmiiboList'; String folder = '/Download';
  Directory dir = await Directory('/storage/emulated/0$folder').create();
  String path = '${dir.path}/MyAmiiboList_${DateTime.now().toString().substring(0,10)}.json';
  String fileSaved = 'saved';
  final File file = File(path);
  if(file.existsSync()) fileSaved = 'overwritten';
  return file.writeAsString(jsonEncode(amiibos)).then((file) => '$name has been $fileSaved');
}

void writeCollectionFile(Map<String, dynamic> map) async{
  final File file = File(map['path']);
  file.writeAsBytes(map['buffer']);
  //return file.writeAsString(jsonEncode(amiibos)).then((file) => '$name has been $fileSaved');
}