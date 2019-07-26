AmiiboLocalDB entityFromMap(Map<String, dynamic> amiibo) => AmiiboLocalDB.fromJson(amiibo);

Map<String, dynamic> entityToMap(AmiiboLocalDB data) => data.toMap();

List<Map<String, dynamic>> entityToListOfMaps(AmiiboLocalDB data) => data.toListOfMaps();

AmiiboLocalDB entityFromList(List<Map<String, dynamic>> amiibo) => AmiiboLocalDB.fromDB(amiibo);

class AmiiboLocalDB {
  List<AmiiboDB> amiibo;

  AmiiboLocalDB({
    this.amiibo,
  });

  factory AmiiboLocalDB.fromJson(Map<String, dynamic> amiibo) => AmiiboLocalDB(
    amiibo: List<AmiiboDB>.from(amiibo["amiibo"].map((x) => AmiiboDB.fromMap(x))),
  );

  factory AmiiboLocalDB.fromDB(List<Map> amiibo) => AmiiboLocalDB(
    amiibo: List<AmiiboDB>.from(amiibo.map((x) => AmiiboDB.fromMap(x))),
  );

  Map<String, dynamic> toJson() => {
    "amiibo": List<dynamic>.from(amiibo.map((x) => x.toJson())),
  };

  Map<String, dynamic> toMap() => {
    "amiibo": List<dynamic>.from(amiibo.map((x) => x.toMap())),
  };
  
  List<Map<String, dynamic>> toListOfMaps() =>
    List<Map<String, dynamic>>.from(amiibo.map((x) => x.toMap()));
}

class AmiiboDB {
  String id;
  String amiiboSeries;
  String character;
  String gameSeries;
  String name;
  String au;
  String eu;
  String jp;
  String na;
  String type;
  int wishlist;
  int owned;

  AmiiboDB({
    this.id,
    this.amiiboSeries,
    this.character,
    this.gameSeries,
    this.name,
    this.au,
    this.eu,
    this.jp,
    this.na,
    this.type,
    this.wishlist,
    this.owned,
  });

  factory AmiiboDB.fromMap(Map<String, dynamic> amiibo) => AmiiboDB(
    id: amiibo["id"],
    amiiboSeries: amiibo["amiiboSeries"],
    character: amiibo["character"],
    gameSeries: amiibo["gameSeries"],
    name: amiibo["name"],
    au: amiibo["au"],
    eu: amiibo["eu"],
    jp: amiibo["jp"],
    na: amiibo["na"],
    type: amiibo["type"],
    wishlist: amiibo["wishlist"],
    owned: amiibo["owned"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "amiiboSeries": amiiboSeries,
    "character": character,
    "gameSeries": gameSeries,
    "name": name,
    "au": au,
    "eu": eu,
    "jp": jp,
    "na": na,
    "type": type,
    if(wishlist != null) "wishlist": wishlist,
    if(owned != null) "owned": owned,
  };

  Map<String, dynamic> toJson() => {
    "id": id,
    if(wishlist != null) "wishlist": wishlist,
    if(owned != null) "owned": owned
    /*"id": id,
    "amiiboSeries": amiiboSeries,
    "character": character,
    "gameSeries": gameSeries,
    "name": name,
    "au": au,
    "eu": eu,
    "jp": jp,
    "na": na,
    "type": type,*/
  };

  @override
  toString(){
    return 'amiibo: $id, $amiiboSeries, $character, $gameSeries, $name,'
      ' $au, $eu, $jp, $na, $type, ${wishlist.toString()}, ${owned.toString()}';
  }
}

class LastUpdateDB{
  DateTime lastUpdated;

  LastUpdateDB({
    this.lastUpdated,
  });

  factory LastUpdateDB.fromMap(Map<String, dynamic> date) => LastUpdateDB(
    lastUpdated: DateTime.parse(date["lastUpdated"]),
  );

  factory LastUpdateDB.fromDate(DateTime date) => LastUpdateDB(
    lastUpdated: date,
  );

  Map<String, dynamic> toMap() => {
    "lastUpdated": lastUpdated.toIso8601String(),
  };
}