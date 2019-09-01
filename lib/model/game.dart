import 'dart:convert';

Games gamesFromJson(String str) => Games.fromJson(json.decode(str));

String gamesToJson(Games data) => json.encode(data.toJson());

class Games {
  List<Game> game;

  Games({this.game});

  factory Games.fromJson(Map<String, dynamic> json) => Games(
    game: List<Game>.from(json["game"].map((x) => Game.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "game": List<dynamic>.from(game.map((x) => x.toJson())),
  };
}

class Game {
  int id;
  Platform platform;
  String feature;
  String name;
  String description;
  List<String> amiibo;

  Game({
    this.id,
    this.platform,
    this.feature,
    this.name,
    this.description,
    this.amiibo,
  });

  factory Game.fromJson(Map<String, dynamic> json) => Game(
    id: json["id"],
    platform: platformValues.map[json["platform"]],
    feature: json["feature"],
    name: json["name"],
    description: json["description"],
    amiibo: List<String>.from(json["amiibo"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "platform": platformValues.reverse[platform],
    "feature": feature,
    "name": name,
    "description": description,
    "amiibo": List<String>.from(amiibo.map((x) => x)),
  };
}

enum Platform { SWITCH, THE_3_DS, WII_U }

final platformValues = new EnumValues({
  "Switch": Platform.SWITCH,
  "3DS": Platform.THE_3_DS,
  "WiiU": Platform.WII_U
});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}