import 'package:freezed_annotation/freezed_annotation.dart';

part 'amiibo.freezed.dart';
part 'amiibo.g.dart';

int boolToInt(bool value) => value ? 1 : 0;
bool intToBool(int value) => value == 1;

List<Amiibo> entityFromMap(Map<String, dynamic> amiibo) => List<Amiibo>.from(amiibo["amiibo"].map((x) => Amiibo.fromJson(x)));

@freezed
abstract class Amiibo with _$Amiibo {
  const factory Amiibo({
    int key,
    String id,
    String amiiboSeries,
    String character,
    String gameSeries,
    String name,
    String au,
    String eu,
    String jp,
    String na,
    String type,
    @Default(false) @JsonKey(includeIfNull: false, fromJson: intToBool, toJson: boolToInt) bool wishlist,
    @Default(false) @JsonKey(includeIfNull: false, fromJson: intToBool, toJson: boolToInt) bool owned,
  }) = _Amiibo;
	
  factory Amiibo.fromJson(Map<String, dynamic> json) =>
			_$AmiiboFromJson(json);
}
