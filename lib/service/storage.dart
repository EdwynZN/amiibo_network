import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:amiibo_network/service/info_package.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:amiibo_network/generated/l10n.dart';

/// Date String in format year.month.day_hour.minute.second
String get dateTaken {
  DateTime date = DateTime.now();
  String time = date.toString().split('.')[0];
  time = time.replaceFirst(' ', '_').replaceAll(RegExp('\-|\:'), '');
  /*
  StringBuffer buffer = StringBuffer('_');
  buffer..write(date.year)..write(date.month)..write(date.day)..write('_')
    ..write(date.hour)..write(date.minute)..write(date.second);
  */
  return time;
}

/// Ask for write permission in Android 9 and below
/// If not granted and permanently denied shows a snackbar to open settings of the app
/// to unlock it
Future<bool> permissionGranted(ScaffoldMessengerState? scaffoldState) async {
  S translate = S.current;
  final versionCode = InfoPackage.androidVersionCode;
  if (versionCode == AndroidCode.Unknown)
    return false;
  else if (versionCode.code < AndroidCode.Q.code &&
    versionCode.code > AndroidCode.Lollipop_MR1.code) {
    final permissionStatus = await Permission.storage.request();
    if (!permissionStatus.isGranted) {
      if (permissionStatus.isPermanentlyDenied &&
          (scaffoldState?.mounted ?? false)) {
        scaffoldState?.hideCurrentSnackBar();
        scaffoldState?.showSnackBar(SnackBar(
          content:
              Text(translate.storagePermission(permissionStatus.name)),
          action: SnackBarAction(
            label: translate.openAppSettings,
            onPressed: () => openAppSettings(),
          ),
        ));
      }
      return false;
    }
  }
  return true;
}

Future<File> createFile(
    [String name = 'MyAmiiboNetwork', String type = 'json']) async {
  Directory dir;
  StorageDirectory storage = StorageDirectory.documents;
  if (type == 'png') storage = StorageDirectory.pictures;
  if (Platform.isAndroid)
    dir = (await getExternalStorageDirectories(type: storage))!.first;
  else
    dir = await getApplicationDocumentsDirectory();
  String path =
      '${dir.path}/${name}_${DateTime.now().toString().substring(0, 10)}.$type';
  final File file = File(path);
  return file;
}

Map<String, dynamic>? readFile(String? path) {
  try {
    final file = File(path!);
    String data = file.readAsStringSync();
    final Map<String, dynamic> jResult = jsonDecode(data);
    if (!jResult.containsKey('amiibo'))
      return null;
    else
      return jResult;
  } catch (e) {
    print(e.toString());
    return null;
  }
}

void writeFile(Map<String, dynamic> arg) => arg['file'].writeAsStringSync(
      jsonEncode(
        <String, dynamic>{
          'amiibo': arg['amiibos'],
        },
      ),
    );

void writeCollectionFile(Map<String, dynamic> arg) =>
    arg['file'].writeAsBytesSync(arg['buffer'], flush: true);
