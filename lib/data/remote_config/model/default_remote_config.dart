import 'package:amiibo_network/data/remote_config/constants/remote_constant_key.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'default_remote_config.freezed.dart';
part 'default_remote_config.g.dart';

@freezed
class DefaultRemoteConfig with _$DefaultRemoteConfig {
  const factory DefaultRemoteConfig({
    @Default(false) @JsonKey(name: RemoteKey.ownedCategories) bool ownedCategories, 
  }) = _DefaultRemoteConfig;
	
  factory DefaultRemoteConfig.fromJson(Map<String, dynamic> json) =>
			_$DefaultRemoteConfigFromJson(json);
}
