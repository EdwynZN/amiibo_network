import 'package:amiibo_network/app/state/preferences_provider.dart';
import 'package:amiibo_network/shared/generated/l10n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class const AmiiboViewTypeWidget() extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useGrid = ref.watch(personalProvider.select((s) => s.useGrid));
    final translate = S.of(context);
    return IconButton(
      style: .new(sizeVariant: .small, shapeVariant: .round),
      visualDensity: .compact,
      tooltip: translate.showGrid,
      onPressed: () =>
          ref.read(personalProvider.notifier).toggleVisualList(!useGrid),
      isSelected: useGrid,
      icon: const Icon(Icons.list_outlined),
      selectedIcon: const Icon(Icons.grid_view_outlined),
    );
  }
}
