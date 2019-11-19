
class QuerySearch {
  int id;
  TableColumn column;
  String orderBy;

  QuerySearch({
    this.id,
    this.column,
  });

  factory QuerySearch.fromJson(Map<String, dynamic> json) => QuerySearch(
    id: json["id"],
    column: platformValues.map[json["platform"]],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "platform": platformValues.reverse[column],
  };
}

enum TableColumn { SWITCH, THE_3_DS, WII_U }

final platformValues = EnumValues({
  "Switch": TableColumn.SWITCH,
  "3DS": TableColumn.THE_3_DS,
  "WiiU": TableColumn.WII_U
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