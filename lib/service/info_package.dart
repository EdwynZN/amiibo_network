import 'package:flutter/services.dart';

enum AndroidCode {
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
  R,
  S,
  T,
}

extension AndroidCodeShortcuts on AndroidCode {
  int get version => this.index + 15;
}

class InfoPackage {
  static const _channel =
      const MethodChannel("com.dartz.amiibo_network/info_package");
  static int get version => _version ?? 0; //returns android version code
  static int? _version;
  static AndroidCode get androidVersionCode {
    if (version < 0 || version >= AndroidCode.values.length) {
      return AndroidCode.Unknown;
    }
    return AndroidCode.values[version];
  }

  static Future<int> versionCode() async {
    //TODO IOS Platform Channel
    try {
      _version = await _channel.invokeMethod('version');
      if (_version != null) {
        _version = _version! - 15;
      }
      return version;
    } on PlatformException catch (_) {
      _version = 0;
      return version;
    }
  }
}
