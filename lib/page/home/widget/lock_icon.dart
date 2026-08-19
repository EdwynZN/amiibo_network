import 'package:amiibo_network/shared/generated/l10n.dart';
import 'package:amiibo_network/app/state/lock_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';

class LockButton extends ConsumerWidget {
  const LockButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lockValue = ref.watch(lockProvider);
    return IconButton(
      icon: lockValue ? const Icon(Icons.lock) : const Icon(Icons.lock_open),
      onPressed: ref.read(lockProvider.notifier).toggle,
      tooltip: S.of(context).lockTooltip(lockValue),
    );
  }
}
