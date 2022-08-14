import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:amiibo_network/resources/resources.dart';

void main() {
  test('assets_icons assets test', () {
    expect(File(NetworkIcons.au).existsSync(), true);
    expect(File(NetworkIcons.dsPlatform).existsSync(), true);
    expect(File(NetworkIcons.eu).existsSync(), true);
    expect(File(NetworkIcons.iconApp).existsSync(), true);
    expect(File(NetworkIcons.jp).existsSync(), true);
    expect(File(NetworkIcons.koFiIcon).existsSync(), true);
    expect(File(NetworkIcons.na).existsSync(), true);
    expect(File(NetworkIcons.switchPlatform).existsSync(), true);
    expect(File(NetworkIcons.wiiUPlatform).existsSync(), true);
  });
}
