// To parse this JSON data, do
//
//     final client = clientFromJson(jsonString);

import 'dart:convert';

AmiiboClient clientFromJson(String str) => AmiiboClient.fromMap(json.decode(str));

LastUpdate lastUpdateFromJson(String str) => LastUpdate.fromMap(json.decode(str));

String clientToJson(AmiiboClient data) => json.encode(data.toMap());

class AmiiboClient {
  List<Amiibo> amiibo;

  AmiiboClient({
    this.amiibo,
  });

  factory AmiiboClient.fromMap(Map<String, dynamic> json) => AmiiboClient(
    amiibo: List<Amiibo>.from(json["amiibo"].map((x) => Amiibo.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "amiibo": List<dynamic>.from(amiibo.map((x) => x.toMap())),
  };
}

class Amiibo {
  String amiiboSeries;
  String character;
  String gameSeries;
  String head;
  String image;
  String name;
  Release release;
  String tail;
  String type;

  Amiibo({
    this.amiiboSeries,
    this.character,
    this.gameSeries,
    this.head,
    this.image,
    this.name,
    this.release,
    this.tail,
    this.type,
  });

  factory Amiibo.fromMap(Map<String, dynamic> json) => Amiibo(
    amiiboSeries: json["amiiboSeries"],
    character: json["character"],
    gameSeries: json["gameSeries"],
    head: json["head"],
    image: json["image"],
    name: json["name"],
    release: Release.fromMap(json["release"]),
    tail: json["tail"],
    type: json["type"],
  );

  Map<String, dynamic> toMap() => {
    "amiiboSeries": amiiboSeries,
    "character": character,
    "gameSeries": gameSeries,
    "head": head,
    "image": image,
    "name": name,
    "release": release.toMap(),
    "tail": tail,
    "type": type,
  };
}

class Release {
  String au;
  String eu;
  String jp;
  String na;

  Release({
    this.au,
    this.eu,
    this.jp,
    this.na,
  });

  factory Release.fromMap(Map<String, dynamic> json) => Release(
    au: json["au"],
    eu: json["eu"],
    jp: json["jp"],
    na: json["na"],
  );

  Map<String, dynamic> toMap() => {
    "au": au,
    "eu": eu,
    "jp": jp,
    "na": na,
  };
}

class LastUpdate{
  DateTime lastUpdated;

  LastUpdate({
    this.lastUpdated,
  });

  factory LastUpdate.fromMap(Map<String, dynamic> json) => LastUpdate(
    lastUpdated: DateTime.parse(json["lastUpdated"]),
  );

  Map<String, dynamic> toMap() => {
    "lastUpdated": lastUpdated.toIso8601String(),
  };
}