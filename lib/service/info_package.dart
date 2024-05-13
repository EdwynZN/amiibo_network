import 'package:flutter/services.dart';

enum AndroidCode {
  Unknown(-1),
  JellyBean(16),
  JellyBean_MR1(17),
  JellyBean_MR2(18),
  Kitkat(19),
  Kitkat_Watch(20),
  Lollipop(21),
  Lollipop_MR1(22),
  M(23),
  N(24),
  N_MR1(25),
  O(26),
  O_MR1(27),
  P(28),
  Q(29),
  R(30),
  S1(31),
  S2(32),
  T(33),
  U(34),
  New(35);

  const AndroidCode(this.code);

  final int code;

  factory AndroidCode.fromCode(int code) {
    if (code < JellyBean.code) {
      return AndroidCode.Unknown;
    } else if (code >= AndroidCode.New.code) {
      return AndroidCode.New;
    }
    return AndroidCode.values[code - JellyBean.code + 1];
  }
}

class InfoPackage {
  static const _channel =
      MethodChannel("com.dartz.amiibo_network/info_package");
  AndroidCode _version = AndroidCode.Unknown;
  AndroidCode get androidVersionCode => _version;

  InfoPackage._();
  static final InfoPackage _instance = InfoPackage._();
  static InfoPackage get instance => _instance;

  // Font feature is supported in Android 5 and above
  bool get isFontFeatureEnable =>
      androidVersionCode.code >= AndroidCode.Lollipop.code;

  // upsert feature is supported in Android API 30 (SQLite >= 3.24.0) and above
  bool get isUpsertFeatureAvailable =>
      androidVersionCode == AndroidCode.Unknown ||
      androidVersionCode.code >= AndroidCode.R.code;

  Future<void> versionCode() async {
    //TODO IOS Platform Channel
    try {
      final version = await _channel.invokeMethod<int?>('version');
      if (version != null) {
        _version = AndroidCode.fromCode(version);
      }
    } on PlatformException catch (_) {
      _version = AndroidCode.Unknown;
    }
  }
}
