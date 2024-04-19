import 'dart:convert';

import 'package:amiibo_network/model/amiibo.dart';
import 'package:amiibo_network/service/storage.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';

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
    final encoder = JsonUtf8Encoder();
    final Map<String, dynamic> args = <String, dynamic>{
      'title': title,
      'actionTitle': actionNotificationTitle,
      'id': 9,
      'buffer': encoder.convert(amiibos),// Uint8List.fromList(map.codeUnits),
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
