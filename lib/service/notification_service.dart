import 'dart:convert';

import 'package:amiibo_network/data/local_file_source/model/amiibo_local_read_json_model.dart';
import 'package:amiibo_network/model/amiibo.dart';
import 'package:amiibo_network/service/storage.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

List<int> _convertToString(List<Amiibo> amiibos) {
  final List<AmiiboLocalReadJsonModel> localReadJson = amiibos
    .map(AmiiboLocalReadJsonModel.fromAmiibo)
    .toList();
  final encoder = JsonUtf8Encoder();
  return encoder.convert(localReadJson);
}

class NotificationService {
  static const _channel =
      const MethodChannel("com.dartz.amiibo_network/notification");

  static Future<bool> sendNotification(Map<String, dynamic> args) async {
    //TODO IOS Platform Channel
    try {
      final bool? result = await _channel.invokeMethod('notification', args);
      return result ?? false;
    } on PlatformException catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> saveImage(Map<String, dynamic> args) async {
    //TODO IOS Platform Channel
    try {
      final bool? result = await _channel.invokeMethod('saveImage', args);
      return result ?? false;
    } on PlatformException catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> saveJsonFile({
    required String title,
    required String actionNotificationTitle,
    required String name,
    required List<Amiibo> amiibos,
  }) async {
    final buffer = await compute(_convertToString, amiibos);
    final Map<String, dynamic> args = <String, dynamic>{
      'title': title,
      'actionTitle': actionNotificationTitle,
      'id': 9,
      'buffer': buffer, // Uint8List.fromList(map.codeUnits),
      'name': '${name}_$dateTaken',
    };
    //TODO IOS Platform Channel
    try {
      final bool? result = await _channel.invokeMethod('saveJson', args);
      return result ?? false;
    } on PlatformException catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      return false;
    }
  }
}
