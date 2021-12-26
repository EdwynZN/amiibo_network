import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/riverpod/lock_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';

class LockButton extends ConsumerWidget {
  const LockButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lockValue = ref.watch(lockProvider);
    final lock = lockValue.lock;
    return IconButton(
      icon: lock ? const Icon(Icons.lock) : const Icon(Icons.lock_open),
      onPressed: () async => await lockValue.toggle(),
      tooltip: S.of(context).lockTooltip(lock),
    );
  }
}
