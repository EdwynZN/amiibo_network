import 'package:amiibo_network/entity/amiibo_info/model/amiibo_user_collection_attributes.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'amiibo_info.freezed.dart';

@freezed
class const AmiiboInfo({
  required final int id,
  required final String name,
  required final String series,
  required final String? image,
  required final UserAttributes userAttributes,
}) with _$AmiiboInfo;
