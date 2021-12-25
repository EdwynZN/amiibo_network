import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:amiibo_network/riverpod/select_provider.dart';
import 'package:amiibo_network/riverpod/service_provider.dart';
import 'package:amiibo_network/utils/routes_constants.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:amiibo_network/widget/amiibo_grid.dart';
import 'package:amiibo_network/model/selection.dart';

class AnimatedSelection extends StatefulHookConsumerWidget {
  const AnimatedSelection({Key? key}) : super(key: key);

  @override
  _AnimatedSelectionState createState() => _AnimatedSelectionState();
}

class _AnimatedSelectionState extends ConsumerState<AnimatedSelection> {
  void _onDoubleTap(int key) =>
      Navigator.pushNamed(context, detailsRoute, arguments: key);

  void _onTap(WidgetRef ref, int key) {
    ref.read(serviceProvider.notifier).shift(key);
  }

  void _onLongPress(WidgetRef ref, int key) => ref.read(selectProvider).onLongPress(key);

  @override
  Widget build(BuildContext context) {
    final key = ref.watch(keyAmiiboProvider);
    final select = ref.watch(
      selectProvider.select<Selection>(
        (cb) => Selection(
          activated: cb.multipleSelected,
          selected: cb.isSelected(key),
        ),
      ),
    );
    return GestureDetector(
      onDoubleTap: select.activated ? null : () => _onDoubleTap(key),
      onTap: select.activated ? () => _onLongPress(ref, key) : () => _onTap(ref, key),
      onLongPress: () => _onLongPress(ref, key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.linearToEaseOut,
        margin: select.selected
            ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
            : EdgeInsets.zero,
        padding: select.selected ? const EdgeInsets.all(8) : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: select.selected
              ? Theme.of(context).selectedRowColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const AmiiboGrid(),
      ),
    );
  }
}