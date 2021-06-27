
import 'package:freezed_annotation/freezed_annotation.dart';

part 'game.freezed.dart';
part 'game.g.dart';

@freezed
class NintendoPlatform with _$NintendoPlatform {
  const factory NintendoPlatform({
    @JsonKey(name: 'games3DS') List<Game>? games3DS,
    @JsonKey(name: 'gamesSwitch') List<Game>? gamesSwitch,
    @JsonKey(name: 'gamesWiiU') List<Game>? gamesWiiU,
  }) = _NintendoPlatform;
	
  factory NintendoPlatform.fromJson(Map<String, dynamic> json) =>
			_$NintendoPlatformFromJson(json);
}

@freezed
class Game with _$Game {
  const factory Game({
    @JsonKey(name: 'gameID', required: true, disallowNullValue: true) required List<String> ids,
    @JsonKey(name: 'gameName', required: true, disallowNullValue: true) required String name,
    @JsonKey(name: 'amiiboUsage') List<AmiiboUsage>? usage,
  }) = _Game;
	
  factory Game.fromJson(Map<String, dynamic> json) =>
			_$GameFromJson(json);
}

@freezed
class AmiiboUsage with _$AmiiboUsage {
  const factory AmiiboUsage({
    @JsonKey(name: 'Usage', required: true, disallowNullValue: true) required String use,
    @JsonKey(name: 'write') bool? write,
  }) = _AmiiboUsage;
	
  factory AmiiboUsage.fromJson(Map<String, dynamic> json) =>
			_$AmiiboUsageFromJson(json);
}
