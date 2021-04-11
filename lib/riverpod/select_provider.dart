import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:amiibo_network/riverpod/query_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amiibo_network/enum/selected_enum.dart';
import 'package:amiibo_network/model/amiibo.dart';

final AutoDisposeChangeNotifierProvider<SelectProvider>? selectProvider = ChangeNotifierProvider.autoDispose<SelectProvider>(
  (ref) {
    final service = ref.watch(controlProvider.notifier);
    ref.watch(queryProvider.notifier);
    return SelectProvider(service);
  },
);

class SelectProvider extends ChangeNotifier {
  final AmiiboProvider provider;
  final Set<int> _set = Set<int>();

  SelectProvider(this.provider);

  bool get multipleSelected => _set.isNotEmpty;
  int get length => _set.length;
  bool addSelected(int value) => _set.add(value);
  bool removeSelected(int? value) => _set.remove(value);
  bool isSelected(int? value) => _set.contains(value);

  void updateAmiibos(SelectedType type) {
    bool wished = type == SelectedType.Wished;
    bool owned = type == SelectedType.Owned;
    final amiibos = _set.map(
      (cb) => Amiibo(key: cb, wishlist: wished, owned: owned),
    ).toList();
    provider.updateAmiiboDB(amiibos);
    clearSelected();
  }

  void onLongPress(int key) {
    if (!addSelected(key)) removeSelected(key);
    notifyListeners();
  }

  void clearSelected() {
    if (_set.isEmpty) return;
    _set.clear();
    notifyListeners();
  }
}
