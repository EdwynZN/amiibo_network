import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/riverpod/stat_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';

class StatButton extends ConsumerWidget {
  const StatButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statMode = ref.watch(statProvider);
    final isPercentage = statMode.isPercentage;
    return IconButton(
      icon: isPercentage ? const Icon(Icons.pie_chart_rounded) 
      : const Icon(Icons.pie_chart_outline_rounded),
      onPressed: () async => await statMode.toggleStat(!isPercentage),
      tooltip: S.of(context).statTooltip(isPercentage),
    );
  }
}
