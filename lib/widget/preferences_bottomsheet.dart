import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/riverpod/preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

class PreferencesButton extends StatelessWidget {
  const PreferencesButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final S translate = S.of(context);
    return IconButton(
      onPressed: () async {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          elevation: 0.0,
          builder: (context) => const _BottomSheetSort(),
        );
      },
      icon: const Icon(Icons.brush_outlined),
      tooltip: translate.appearance,
    );
  }
}

class _BottomSheetSort extends StatelessWidget {
  const _BottomSheetSort({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final S translate = S.of(context);
    final Size size = MediaQuery.of(context).size;
    final double height = (460.0 / size.height).clamp(0.25, 0.50);
    EdgeInsetsGeometry padding = EdgeInsets.zero;
    if (size.longestSide >= 800)
      padding = EdgeInsets.symmetric(
        horizontal: (size.width / 2 - 210).clamp(0.0, double.infinity),
      );
    return Padding(
      padding: padding,
      child: DraggableScrollableSheet(
        key: const Key('Draggable'),
        maxChildSize: height,
        expand: false,
        initialChildSize: 0.30,
        builder: (context, scrollController) {
          final ThemeData theme = Theme.of(context);
          return Material(
            color: theme.colorScheme.background,
            shape: theme.bottomSheetTheme.shape,
            clipBehavior: Clip.antiAlias,
            child: ListTileTheme.merge(
              //selectedTileColor: theme.selectedRowColor.withOpacity(0.16),
              contentPadding: const EdgeInsets.only(left: 8.0, right: 16.0),
              dense: true,
              style: ListTileStyle.drawer,
              minVerticalPadding: 12.0,
              shape: theme.cardTheme.shape,
              selectedColor: theme.textButtonTheme.style?.foregroundColor
                  ?.resolve({MaterialState.selected}),
              child: CustomScrollView(
                controller: scrollController,
                slivers: <Widget>[
                  SliverPinnedHeader(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 12.0,
                              left: 24.0,
                              right: 16.0,
                            ),
                            child: Text(
                              translate.appearance,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          const Gap(8.0),
                          const Divider(
                            height: 0.0,
                            indent: 16.0,
                            endIndent: 16.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: Consumer(
                      builder: (context, ref, child) {
                        final pref = ref.watch(personalProvider);
                        return SliverList(
                          delegate: SliverChildListDelegate([
                            SwitchListTile.adaptive(
                              visualDensity:
                                  const VisualDensity(vertical: -2.0),
                              controlAffinity: ListTileControlAffinity.trailing,
                              title: Text(
                                translate.showPercentage,
                                style: theme.textTheme.bodyLarge,
                              ),
                              inactiveTrackColor:
                                  theme.disabledColor.withOpacity(0.12),
                              value: pref.usePercentage,
                              onChanged: (value) async => await ref
                                  .read(personalProvider.notifier)
                                  .toggleStat(value),
                            ),
                            SwitchListTile.adaptive(
                              visualDensity:
                                  const VisualDensity(vertical: -2.0),
                              controlAffinity: ListTileControlAffinity.trailing,
                              title: Text(
                                translate.showGrid,
                                style: theme.textTheme.bodyLarge,
                              ),
                              inactiveTrackColor:
                                  theme.disabledColor.withOpacity(0.12),
                              value: pref.useGrid,
                              onChanged: (value) async => await ref
                                  .read(personalProvider.notifier)
                                  .toggleVisualList(value),
                            ),
                          ]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
