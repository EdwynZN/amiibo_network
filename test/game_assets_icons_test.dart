import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:amiibo_network/resources/resources.dart';

void main() {
  test('game_assets_icons assets test', () {
    expect(File(GameIcons.nintendoSwitch).existsSync(), isTrue);
    expect(File(GameIcons.pacmanGhost).existsSync(), isTrue);
    expect(File(GameIcons.pacman).existsSync(), isTrue);
    expect(File(GameIcons.pokeball).existsSync(), isTrue);
    expect(File(GameIcons.pokemon).existsSync(), isTrue);
    expect(File(GameIcons.superMario).existsSync(), isTrue);
    expect(File(GameIcons.superMarioToad).existsSync(), isTrue);
    expect(File(GameIcons.tlozSword).existsSync(), isTrue);
  });
}
