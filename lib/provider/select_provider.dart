import 'package:flutter/material.dart';
import 'package:amiibo_network/model/amiibo_local_db.dart';

class SelectProvider with ChangeNotifier{
  final Set<ValueKey<int>> set = Set<ValueKey<int>>();

  bool get multipleSelected => set.isNotEmpty;
  int get selected => set.length;
  bool addSelected(ValueKey<int> value) => set.add(value);
  bool removeSelected(ValueKey<int> value) => set.remove(value);
  bool isSelected(ValueKey<int> value) => set.contains(value);

  AmiiboLocalDB amiibos(SelectedType type) {
    int wished = type == SelectedType.Wished ? 1 : 0;
    int owned = type == SelectedType.Owned ? 1 : 0;
    return AmiiboLocalDB(
      amiibo: List<AmiiboDB>.of(
        set.map((x) => AmiiboDB(key: x.value, wishlist: wished, owned: owned))
      )
    );
  }

  void clearSelected() {
    if(set.isEmpty) return;
    set.clear();
    notifyListeners();
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}

enum SelectedType{
  Clear,
  Owned,
  Wished
}