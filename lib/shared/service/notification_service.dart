import 'dart:convert';
import 'dart:io';

import 'package:amiibo_network/shared/data/local_file_source/model/amiibo_local_read_json_model.dart';
import 'package:amiibo_network/entity/amiibo_info/model/amiibo.dart';
import 'package:amiibo_network/shared/service/storage.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract interface class _NotificationService {
  Future<bool> sendNotification(Map<String, dynamic> args);

  Future<bool> saveImage(Map<String, dynamic> args);

  Future<bool> saveJsonFile({
    required String title,
    required String actionNotificationTitle,
    required String name,
    required List<Amiibo> amiibos,
  });
}

/// No-op implementation
class _NoNotificationService implements _NotificationService {
  const _NoNotificationService();

  @override
  Future<bool> sendNotification(Map<String, dynamic> args) =>
      Future.value(false);

  @override
  Future<bool> saveImage(Map<String, dynamic> args) => Future.value(false);

  @override
  Future<bool> saveJsonFile({
    required String title,
    required String actionNotificationTitle,
    required String name,
    required List<Amiibo> amiibos,
  }) => Future.value(false);
}

class _PlatformNotificationService implements _NotificationService {
  const _PlatformNotificationService();
  static const _channel = const MethodChannel(
    "com.dartz.amiibo_network/notification",
  );

  @override
  Future<bool> sendNotification(Map<String, dynamic> args) async {
    try {
      final bool? result = await _channel.invokeMethod('notification', args);
      return result ?? false;
    } on PlatformException catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      return false;
    }
  }

  @override
  Future<bool> saveImage(Map<String, dynamic> args) async {
    try {
      final bool? result = await _channel.invokeMethod('saveImage', args);
      return result ?? false;
    } on PlatformException catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      return false;
    }
  }

  @override
  Future<bool> saveJsonFile({
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
    try {
      final bool? result = await _channel.invokeMethod('saveJson', args);
      return result ?? false;
    } on PlatformException catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      return false;
    }
  }
}

List<int> _convertToString(List<Amiibo> amiibos) {
  final List<AmiiboLocalReadJsonModel> localReadJson = amiibos
      .map(AmiiboLocalReadJsonModel.fromAmiibo)
      .toList();
  final encoder = JsonUtf8Encoder();
  return encoder.convert(localReadJson);
}

class NotificationService {
  const NotificationService._(this._service);
  factory NotificationService() =>
      _instance ??= NotificationService._(
        Platform.isAndroid
            ? _PlatformNotificationService()
            : _NoNotificationService(),
      );

  final _NotificationService _service;

  static NotificationService? _instance;

  static Future<bool> sendNotification(Map<String, dynamic> args) async {
    final instance = NotificationService();
    return instance._service.sendNotification(args);
  }

  static Future<bool> saveImage(Map<String, dynamic> args) async {
    final instance = NotificationService();
    return instance._service.saveImage(args);
  }

  static Future<bool> saveJsonFile({
    required String title,
    required String actionNotificationTitle,
    required String name,
    required List<Amiibo> amiibos,
  }) async {
    final instance = NotificationService();
    return instance._service.saveJsonFile(
      title: title,
      actionNotificationTitle: actionNotificationTitle,
      name: name,
      amiibos: amiibos,
    );
  }
}
