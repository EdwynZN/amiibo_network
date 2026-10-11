import 'package:amiibo_network/shared/generated/l10n.dart';
import 'package:amiibo_network/app/state/lock_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class const LockButton({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lockValue = ref.watch(lockProvider);
    return IconButton(
      isSelected: lockValue,
      selectedIcon: const Icon(Icons.lock),
      icon: const Icon(Icons.lock_open),
      onPressed: ref.read(lockProvider.notifier).toggle,
      tooltip: S.of(context).lockTooltip(lockValue),
    );
  }
}
