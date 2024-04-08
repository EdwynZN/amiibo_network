import 'dart:convert';
import 'dart:io';

import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/model/amiibo.dart';
import 'package:amiibo_network/service/info_package.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

sealed class AmiiboFile {
  const AmiiboFile();
}

class AmiiboFileData extends AmiiboFile {
  final List<Amiibo> amiibos;

  const AmiiboFileData(this.amiibos);
}

class AmiiboFileError extends AmiiboFile {
  final Object error;
  final StackTrace stackTrace;

  const AmiiboFileError(this.error, this.stackTrace);
}

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
          content: Text(translate.storagePermission(permissionStatus.name)),
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

AmiiboFile readFile(String path) {
  try {
    final file = File(path);
    String data = file.readAsStringSync();
    final jResult = jsonDecode(data);
    if (jResult is Map && jResult.containsKey('amiibo')) {
      final data = entityFromMap(jResult as Map<String, dynamic>);
      return AmiiboFileData(data);
    } else if (jResult is List<dynamic>) {
      final data = entityFromMap({'amiibo': jResult});
      return AmiiboFileData(data);
    }
    return AmiiboFileError(
      Exception('wrong format: ${jResult.runtimeType}'),
      StackTrace.current,
    );
  } catch (e, s) {
    return AmiiboFileError(e, s);
  }
}

void writeCollectionFile(Map<String, dynamic> arg) =>
    arg['file'].writeAsBytesSync(arg['buffer'], flush: true);
