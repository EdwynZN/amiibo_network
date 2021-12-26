import 'package:freezed_annotation/freezed_annotation.dart';

part 'amiibo.freezed.dart';
part 'amiibo.g.dart';

int boolToInt(bool? value) => value ?? false ? 1 : 0;
bool intToBool(int? value) => value == 1;

List<Amiibo> entityFromMap(Map<String, dynamic>? amiibo) => List<Amiibo>.from(amiibo!["amiibo"].map((x) => Amiibo.fromJson(x)));

@freezed
class Amiibo with _$Amiibo {
  const factory Amiibo({
    required int key,
    String? id,
    @Default('') String amiiboSeries,
    @Default('') String character,
    @Default('') String gameSeries,
    @Default('') String name,
    String? au,
    String? eu,
    String? jp,
    String? na,
    String? type,
    @Default(false) @JsonKey(fromJson: intToBool, toJson: boolToInt) bool wishlist,
    @Default(false) @JsonKey(fromJson: intToBool, toJson: boolToInt) bool owned,
  }) = _Amiibo;
	
  factory Amiibo.fromJson(Map<String, dynamic> json) =>
			_$AmiiboFromJson(json);
}
