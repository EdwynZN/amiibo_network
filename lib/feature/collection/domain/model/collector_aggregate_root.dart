import 'package:amiibo_network/feature/collection/domain/model/amiibo_bundle_preference_aggregate.dart';
import 'package:amiibo_network/feature/collection/domain/model/amiibo_preference_item.dart';
import 'package:amiibo_network/feature/collection/domain/model/user_preference_attribute.dart';

/// Rules:
/// - A collector that owns an amiibo cannot wish it and the other way around
/// - A collector that owns a bundle cannot wish it and the other way around
/// - A collector can own all amiibos of a bundle and still wish the bundle
/// itself until its owned
/// - A collector can wish both the amiibos and bundle at the same time
/// - A collector can own all the amiibos from a bundle and still wish
/// that bundle
/// - If you own a bundle all the amiibos inside cannot be wished
class CollectorAggregateRoot {
  CollectorAggregateRoot();

  final Map<String, AmiiboPreferenceItem> _amiibosOwned = {};
  final Map<String, AmiiboWishItem> _amiibosWished = {};

  final Map<String, AmiiboBundlePreferenceAggregate> _bundlesWished = {};
  final Map<String, AmiiboBundlePreferenceAggregate> _bundlesOwned = {};

  void ownAmiibo(String id, UserPreferenceAttributes attributes) {
    _amiibosOwned.update(
      id,
      (value) => value.copyWith(preferences: attributes),
      ifAbsent: () => AmiiboPreferenceItem(id: id, preferences: attributes),
    );

    if (_amiibosWished.containsKey(id)) _amiibosWished.remove(id);
  }

  void wishAmiibo(String id) {
    if (!_amiibosWished.containsKey(id)) return;
    if (_bundlesOwned.values.expand((e) => e.amiibosId).toSet().contains(id)) {
      throw ArgumentError.value(
        id,
        'Amiibo ID',
        'You own a bundle with this amiibo. Remove it first!',
      );
    }

    _amiibosWished[id] = AmiiboWishItem(id: id);
    if (_amiibosOwned.containsKey(id)) _amiibosOwned.remove(id);
  }

  void removeAmiibo(String id) {
    _amiibosOwned.remove(id);
    _amiibosWished.remove(id);
  }

  void ownBundle(AmiiboBundlePreferenceAggregate bundle) {
    final id = bundle.id;
    _bundlesOwned[id] = bundle;

    if (_bundlesWished.containsKey(id)) _bundlesWished.remove(id);
    bundle.amiibosId.forEach(_amiibosWished.remove);

    if (_amiibosWished.containsKey(id)) _amiibosWished.remove(id);
  }

  void wishBundle(AmiiboBundlePreferenceAggregate bundle) {
    final id = bundle.id;
    _bundlesOwned[id] = bundle;
    if (_bundlesOwned.containsKey(id)) _bundlesOwned.remove(id);
  }

  void removeBundles(String bundleId) {
    _bundlesOwned.remove(bundleId);
    _bundlesWished.remove(bundleId);
  }

  void removeAll(String amiiboId) {
    removeAmiibo(amiiboId);
    _bundlesOwned.removeWhere((_, v) => v.amiibosId.contains(amiiboId));
    _bundlesWished.removeWhere((_, v) => v.amiibosId.contains(amiiboId));
  }
}
