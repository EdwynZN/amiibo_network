import 'package:flutter/services.dart';

class NotificationService {
  static const _channel = const MethodChannel("com.dartz.amiibo_network/notification");

  static Future<bool> sendNotification(Map<String,dynamic> args) async {
    //TODO IOS Platform Channel
    try {
      final bool result = await _channel.invokeMethod('notification', args);
      return result;
    } on PlatformException catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> saveImage(Map<String,dynamic> args) async {
    //TODO IOS Platform Channel
    try {
      final bool result = await _channel.invokeMethod('saveImage', args);
      return result;
    } on PlatformException catch (e) {
      print(e);
      return false;
    }
  }

}