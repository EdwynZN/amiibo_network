import 'package:amiibo_network/entity/amiibo_info/model/amiibo.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_amiibo_user_attributes.freezed.dart';
part 'update_amiibo_user_attributes.g.dart';

@freezed
sealed class UpdateAmiiboUserAttributes with _$UpdateAmiiboUserAttributes {
  const factory UpdateAmiiboUserAttributes({
    required int id,
    required UserAttributes attributes,
  }) = _UpdateAmiiboUserAttributes;
	
  factory UpdateAmiiboUserAttributes.fromJson(Map<String, dynamic> json) =>
			_$UpdateAmiiboUserAttributesFromJson(json);
}
