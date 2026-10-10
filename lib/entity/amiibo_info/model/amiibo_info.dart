import 'package:amiibo_network/entity/amiibo_info/model/amiibo.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'amiibo_info.freezed.dart';

enum CollectionType { owned, wished, none }

@freezed
class const AmiiboInfo({
  required final int id,
  required final String name,
  required final String series,
  required final String? image,
  required final UserAttributes userAttributes,
  required final CollectionType collection,
}) with _$AmiiboInfo;
