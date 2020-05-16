import 'package:flutter/material.dart';

class SelectProvider with ChangeNotifier{
  final Set<ValueKey<int>> set = Set<ValueKey<int>>();

  bool get multipleSelected => set.isNotEmpty;
  int get selected => set.length;
  bool addSelected(ValueKey<int> value) => set.add(value);
  bool removeSelected(ValueKey<int> value) => set.remove(value);
  bool isSelected(ValueKey<int> value) => set.contains(value);

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