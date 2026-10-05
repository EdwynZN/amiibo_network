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
  CollectorAggregateRoot({
    Map<int, AmiiboPreferenceItem>? amiibosOwned,
    Map<int, AmiiboWishItem>? amiibosWished,
    Map<int, AmiiboBundlePreferenceAggregate>? bundlesWished,
    Map<int, AmiiboBundlePreferenceAggregate>? bundlesOwned,
  }) : _amiibosOwned = Map.from(amiibosOwned ?? {}),
       _amiibosWished = Map.from(amiibosWished ?? {}),
       _bundlesWished = Map.from(bundlesWished ?? {}),
       _bundlesOwned = Map.from(bundlesOwned ?? {});

  final Map<int, AmiiboPreferenceItem> _amiibosOwned;
  final Map<int, AmiiboWishItem> _amiibosWished;

  final Map<int, AmiiboBundlePreferenceAggregate> _bundlesWished;
  final Map<int, AmiiboBundlePreferenceAggregate> _bundlesOwned;

  Map<int, AmiiboPreferenceItem> get amiibosOwned =>
      .unmodifiableOf(_amiibosOwned);
  Map<int, AmiiboWishItem> get amiibosWished => .unmodifiableOf(_amiibosWished);

  Map<int, AmiiboBundlePreferenceAggregate> get bundlesOwned =>
      .unmodifiableOf(_bundlesOwned);
  Map<int, AmiiboBundlePreferenceAggregate> get bundlesWished =>
      .unmodifiableOf(_bundlesWished);

  void ownAmiibo(int id, OwnedUserPreferenceAttributes attributes) {
    _amiibosOwned.update(
      id,
      (value) => value.copyWith(preferences: attributes),
      ifAbsent: () => AmiiboPreferenceItem(id: id, preferences: attributes),
    );

    if (_amiibosWished.containsKey(id)) _amiibosWished.remove(id);
  }

  void wishAmiibo(int id) {
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

  void removeAmiibo(int id) {
    _amiibosOwned.remove(id);
    _amiibosWished.remove(id);
  }

  void updateBundle(AmiiboBundlePreferenceAggregate bundle) {
    switch (bundle.preferences) {
      case null:
        _removeBundle(bundle.id);
      case WishedUserPreferenceAttributes():
        _wishBundle(bundle);
      case OwnedUserPreferenceAttributes():
        _ownBundle(bundle);
    }
  }

  void _ownBundle(AmiiboBundlePreferenceAggregate bundle) {
    final id = bundle.id;
    _bundlesOwned[id] = bundle;

    if (_bundlesWished.containsKey(id)) _bundlesWished.remove(id);
    bundle.amiibosId.forEach(_amiibosWished.remove);
  }

  void _wishBundle(AmiiboBundlePreferenceAggregate bundle) {
    final id = bundle.id;
    _bundlesWished[id] = bundle;
    if (_bundlesOwned.containsKey(id)) _bundlesOwned.remove(id);
  }

  void _removeBundle(int bundleId) {
    _bundlesOwned.remove(bundleId);
    _bundlesWished.remove(bundleId);
  }

  void removeAll(int amiiboId) {
    removeAmiibo(amiiboId);
    _bundlesOwned.removeWhere((_, v) => v.amiibosId.contains(amiiboId));
    _bundlesWished.removeWhere((_, v) => v.amiibosId.contains(amiiboId));
  }

  void clearCollection() {
    _amiibosOwned.clear();
    _amiibosWished.clear();
    _bundlesOwned.clear();
    _bundlesWished.clear();
  }
}
