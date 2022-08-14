import 'package:freezed_annotation/freezed_annotation.dart';

part 'stat.freezed.dart';
part 'stat.g.dart';

@freezed
class Stat with _$Stat {
  const factory Stat({
    @Default('Amiibo Network') @JsonKey(name: 'amiiboSeries', includeIfNull: true) String name,
    @Default(0) @JsonKey(name: 'Total', includeIfNull: true) int total,
    @Default(0) @JsonKey(name: 'Owned', includeIfNull: true) int owned,
    @Default(0) @JsonKey(name: 'Wished', includeIfNull: true) int wished,
  }) = _Stat;
	
  factory Stat.fromJson(Map<String, dynamic> json) =>
			_$StatFromJson(json);
}
