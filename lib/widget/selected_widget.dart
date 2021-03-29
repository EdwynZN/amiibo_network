import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:amiibo_network/riverpod/select_provider.dart';
import 'package:amiibo_network/utils/routes_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:amiibo_network/widget/amiibo_grid.dart';

class AnimatedSelection extends StatefulHookWidget {
  const AnimatedSelection({Key key}) : super(key: key);

  @override
  _AnimatedSelectionState createState() => _AnimatedSelectionState();
}

class _AnimatedSelectionState extends State<AnimatedSelection> {
  void _onDoubleTap(int key) => Navigator.pushNamed(context, detailsRoute,
      arguments: key);

  void _onTap(int key) {
    context.read(controlProvider).shift(key);
  }

  void _onLongPress(int key) => context.read(selectProvider).onLongPress(key);

  @override
  Widget build(BuildContext context) {
    final key = useProvider(indexAmiiboProvider);
    final _multipleSelected =
        useProvider(selectProvider.select((cb) => cb.multipleSelected));
    final _isSelected = useProvider(
        selectProvider.select((cb) => cb.isSelected(key)));
    return GestureDetector(
      onDoubleTap: _multipleSelected ? null : () => _onDoubleTap(key),
      onTap: _multipleSelected ? () => _onLongPress(key) :  () => _onTap(key),
      onLongPress: () => _onLongPress(key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.linearToEaseOut,
        margin: _isSelected
            ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
            : EdgeInsets.zero,
        padding: _isSelected ? const EdgeInsets.all(8) : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: _isSelected
              ? Theme.of(context).selectedRowColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const AmiiboGrid(),
      ),
    );
  }
}