import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:amiibo_network/resources/resources.dart';

void main() {
  test('assets_icons assets test', () {
    expect(File(NetworkIcons.au).existsSync(), isTrue);
    expect(File(NetworkIcons.dsPlatform).existsSync(), isTrue);
    expect(File(NetworkIcons.eu).existsSync(), isTrue);
    expect(File(NetworkIcons.iconApp).existsSync(), isTrue);
    expect(File(NetworkIcons.jp).existsSync(), isTrue);
    expect(File(NetworkIcons.koFiIcon).existsSync(), isTrue);
    expect(File(NetworkIcons.na).existsSync(), isTrue);
    expect(File(NetworkIcons.switchPlatform).existsSync(), isTrue);
    expect(File(NetworkIcons.wiiUPlatform).existsSync(), isTrue);
    expect(File(NetworkIcons.fileExport).existsSync(), isTrue);
    expect(File(NetworkIcons.fileImport).existsSync(), isTrue);
    expect(File(NetworkIcons.github).existsSync(), isTrue);
    expect(File(NetworkIcons.jpg).existsSync(), isTrue);
    expect(File(NetworkIcons.lockedBox).existsSync(), isTrue);
    expect(File(NetworkIcons.lockedBoxSelected).existsSync(), isTrue);
    expect(File(NetworkIcons.openBox).existsSync(), isTrue);
    expect(File(NetworkIcons.openBoxSelected).existsSync(), isTrue);
  });
}
