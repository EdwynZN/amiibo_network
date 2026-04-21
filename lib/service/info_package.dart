import 'package:flutter/services.dart';

abstract class AndroidSdkCode {
  const AndroidSdkCode._();

  static const AndroidCode JellyBean = AndroidCode._(16);
  static const AndroidCode JellyBean_MR1 = AndroidCode._(17);
  static const AndroidCode JellyBean_MR2 = AndroidCode._(18);
  static const AndroidCode Kitkat = AndroidCode._(19);
  static const AndroidCode Kitkat_Watch = AndroidCode._(20);
  static const AndroidCode Lollipop = AndroidCode._(21);
  static const AndroidCode Lollipop_MR1 = AndroidCode._(22);
  static const AndroidCode M = AndroidCode._(23);
  static const AndroidCode N = AndroidCode._(24);
  static const AndroidCode N_MR1 = AndroidCode._(25);
  static const AndroidCode O = AndroidCode._(26);
  static const AndroidCode O_MNR1 = AndroidCode._(27);
  static const AndroidCode P = AndroidCode._(28);
  static const AndroidCode Q = AndroidCode._(29);
  static const AndroidCode R = AndroidCode._(30);
  static const AndroidCode S1 = AndroidCode._(31);
  static const AndroidCode S2 = AndroidCode._(32);
  static const AndroidCode T = AndroidCode._(33);
  static const AndroidCode U = AndroidCode._(34);
  static const AndroidCode V = AndroidCode._(35);
  static const AndroidCode A16 = AndroidCode._(36);
  static const AndroidCode A17 = AndroidCode._(37);
}

extension type const AndroidCode._(int code) {
  static const unknown = AndroidCode._(-1);

  factory AndroidCode.fromCode(int code) {
    return switch (code) {
      < 16 => unknown,
      _ => AndroidCode._(code),
    };
  }

  operator <(AndroidCode other) => code < other.code;
  operator <=(AndroidCode other) => code <= other.code;
  operator >(AndroidCode other) => code > other.code;
  operator >=(AndroidCode other) => code >= other.code;

  bool get isUnknown => this == unknown;
}

class InfoPackage {
  static const _channel = MethodChannel(
    "com.dartz.amiibo_network/info_package",
  );
  AndroidCode _version = AndroidCode.unknown;
  AndroidCode get androidVersionCode => _version;

  InfoPackage._();
  static final InfoPackage _instance = InfoPackage._();
  static InfoPackage get instance => _instance;

  // Font feature is supported in Android 5 and above
  bool get isFontFeatureEnable =>
      androidVersionCode >= AndroidSdkCode.Lollipop;

  // upsert feature is supported in Android API 30 (SQLite >= 3.24.0) and above
  bool get isUpsertFeatureAvailable =>
      androidVersionCode >= AndroidSdkCode.R;

  Future<void> versionCode() async {
    //TODO IOS Platform Channel
    try {
      final version = await _channel.invokeMethod<int?>('version');
      if (version != null) {
        _version = AndroidCode.fromCode(version);
      }
    } on PlatformException catch (_) {
      _version = AndroidCode.unknown;
    }
  }
}
