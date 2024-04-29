import 'package:amiibo_network/model/amiibo.dart';
import 'package:amiibo_network/model/update_amiibo_user_attributes.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'amiibo_local_read_json_model.freezed.dart';
part 'amiibo_local_read_json_model.g.dart';

List<AmiiboLocalReadJsonModel> amiiboLocalReadListFromJson(List<dynamic> map) =>
    List<AmiiboLocalReadJsonModel>.from(map.map(
        (x) => AmiiboLocalReadJsonModel.fromJson(x as Map<String, dynamic>)));

_readOwned(Map<dynamic, dynamic> map, String key) =>
    _unwrapIntToBool(map, key, 'owned');
_readWished(Map<dynamic, dynamic> map, String key) =>
    _unwrapIntToBool(map, key, 'wishlist', true);

Object? _unwrapIntToBool(
  Map<dynamic, dynamic> map,
  String key,
  String oldKey, [
  bool isBool = false,
]) {
  if (map.containsKey(key)) {
    return map[key];
  }
  return isBool ? map[oldKey] == 1 : map[oldKey];
}

@freezed
class AmiiboLocalReadJsonModel with _$AmiiboLocalReadJsonModel {
  const AmiiboLocalReadJsonModel._();

  factory AmiiboLocalReadJsonModel({
    required int key,
    @Default(0) int boxed,
    @Default(0) @JsonKey(readValue: _readOwned) int opened,
    @Default(false) @JsonKey(readValue: _readWished) bool wished,
  }) = _AmiiboLocalReadJsonModel;

  factory AmiiboLocalReadJsonModel.fromAmiibo(Amiibo amiibo) {
    final attributes = amiibo.userAttributes;
    final ({int boxed, int opened, bool wished}) args = switch (attributes) {
      const UserAttributes.wished() => const (
          opened: 0,
          boxed: 0,
          wished: true
        ),
      OwnedUserAttributes(
        opened: final opened,
        boxed: final boxed,
      ) =>
        (opened: opened, boxed: boxed, wished: false),
      _ => const (opened: 0, boxed: 0, wished: false),
    };
    return AmiiboLocalReadJsonModel(
      key: amiibo.key,
      boxed: args.boxed,
      opened: args.opened,
      wished: args.wished,
    );
  }

  UpdateAmiiboUserAttributes toDomain() {
    final UserAttributes attributes;
    if (wished) {
      attributes = const UserAttributes.wished();
    } else if (boxed > 0 || opened > 0) {
      attributes = UserAttributes.owned(opened: opened, boxed: boxed);
    } else {
      attributes = const UserAttributes.none();
    }
    return UpdateAmiiboUserAttributes(id: key, attributes: attributes);
  }

  factory AmiiboLocalReadJsonModel.fromJson(Map<String, dynamic> json) =>
      _$AmiiboLocalReadJsonModelFromJson(json);
}
