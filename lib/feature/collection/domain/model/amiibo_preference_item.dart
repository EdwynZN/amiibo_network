import 'package:amiibo_network/feature/collection/domain/model/user_preference_attribute.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'amiibo_preference_item.freezed.dart';

@freezed
class const AmiiboPreferenceItem({
  required final String id,
  required final UserPreferenceAttributes preferences,
}) with _$AmiiboPreferenceItem;

class const AmiiboWishItem({required final String id});
