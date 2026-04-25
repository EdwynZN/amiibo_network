import 'dart:math';

enum EmptyMessageType { pokemon, pokeball, mario, mushroom, pacman, pacmanGhost, link }

class EmptyPageRandomizer {
  final Random _rand;

  EmptyPageRandomizer._() : _rand = Random(42);

  static final EmptyPageRandomizer _instance = EmptyPageRandomizer._();
  static EmptyPageRandomizer get instance => _instance;

  EmptyMessageType get randomeMessage => EmptyMessageType
    .values[_rand.nextInt(EmptyMessageType.values.length)];
}
