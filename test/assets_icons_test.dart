import 'dart:io';

import 'package:amiibo_network/resources/resources.dart';
import 'package:test/test.dart';

void main() {
  test('assets_icons assets test', () {
    expect(true, File(NetworkIcons.au).existsSync());
    expect(true, File(NetworkIcons.dsPlatform).existsSync());
    expect(true, File(NetworkIcons.eu).existsSync());
    expect(true, File(NetworkIcons.iconApp).existsSync());
    expect(true, File(NetworkIcons.jp).existsSync());
    expect(true, File(NetworkIcons.koFiIcon).existsSync());
    expect(true, File(NetworkIcons.na).existsSync());
    expect(true, File(NetworkIcons.switchPlatform).existsSync());
    expect(true, File(NetworkIcons.wiiUPlatform).existsSync());
  });
}
