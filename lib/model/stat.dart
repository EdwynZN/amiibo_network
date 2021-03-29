import 'package:freezed_annotation/freezed_annotation.dart';

part 'stat.freezed.dart';
part 'stat.g.dart';

@freezed
abstract class Stat with _$Stat {
  const factory Stat({
    @Default(0) @JsonKey(includeIfNull: true) double total,
    @Default(0) @JsonKey(includeIfNull: true) double owned,
    @Default(0) @JsonKey(includeIfNull: true) double wished,
  }) = _Stat;
	
  factory Stat.fromJson(Map<String, dynamic> json) =>
			_$StatFromJson(json);
}
