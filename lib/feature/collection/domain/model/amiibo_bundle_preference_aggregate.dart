import 'package:amiibo_network/feature/collection/domain/model/user_preference_attribute.dart';
import 'package:collection/collection.dart';

class AmiiboBundlePreferenceAggregate({
  required final int id,
  required final UnmodifiableListView<int> amiibosId,
  required this._preferences,
}) {
  UserPreferenceAttributes? _preferences;

  UserPreferenceAttributes? get preferences => _preferences;

  set preferences(UserPreferenceAttributes? preferences) {
    _preferences = preferences;
  }
}
