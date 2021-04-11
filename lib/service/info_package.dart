import 'package:flutter/services.dart';

enum AndroidCode{
  Unknown,
  JellyBean,
  JellyBean_MR1,
  JellyBean_MR2,
  Kitkat,
  Kitkat_Watch,
  Lollipop,
  Lollipop_MR1,
  M,
  N,
  N_MR1,
  O,
  O_MR1,
  P,
  Q,
  R
}

extension AndroidCodeShortcuts on AndroidCode{
  int get version => this.index + 15;
}

class InfoPackage{
  static const _channel = const MethodChannel("com.dartz.amiibo_network/info_package");
  static int get version => _version ?? -1; //returns android version code
  static int? _version;
  static AndroidCode? get androidVersionCode => _androidVersion;
  static AndroidCode? _androidVersion;

  static Future<int?> versionCode() async {
    //TODO IOS Platform Channel
    try {
      _version = await _channel.invokeMethod('version');
      _androidVersion = AndroidCode.values[_version!-15];
      return _version;
    } on PlatformException catch (e) {
      print(e);
      _version = 0;
      _androidVersion = AndroidCode.values[_version!];
      return _version;
    }
  }
}