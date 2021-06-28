import 'package:amiibo_network/riverpod/service_provider.dart';
import 'package:amiibo_network/service/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amiibo_network/enum/selected_enum.dart';
import 'package:amiibo_network/model/amiibo.dart';

final selectProvider = ChangeNotifierProvider.autoDispose<SelectProvider>(
  (ref) {
    final service = ref.watch(serviceProvider.notifier);
    return SelectProvider(service);
  },
);

class SelectProvider extends ChangeNotifier {
  final Service provider;
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
    provider.update(amiibos);
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
