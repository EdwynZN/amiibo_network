import 'package:amiibo_network/enum/hidden_types.dart';
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
    final double height = (460.0 / size.height).clamp(0.30, 0.50);
    EdgeInsetsGeometry padding = EdgeInsets.zero;
    if (size.longestSide >= 800)
      padding = EdgeInsets.symmetric(
        horizontal: (size.width / 2 - 210).clamp(0.0, double.infinity),
      );
    const visualList = VisualDensity(vertical: -2.0);
    return Padding(
      padding: padding,
      child: DraggableScrollableSheet(
        key: const Key('Draggable'),
        maxChildSize: 0.50,
        expand: false,
        initialChildSize: height,
        snap: true,
        snapSizes: const [0.25, 0.50],
        builder: (context, scrollController) {
          final ThemeData theme = Theme.of(context);
          return Material(
            color: theme.colorScheme.background,
            shape: theme.bottomSheetTheme.shape,
            clipBehavior: Clip.antiAlias,
            child: ListTileTheme.merge(
              //selectedTileColor: theme.selectedRowColor.withOpacity(0.16),
              contentPadding: const EdgeInsets.only(left: 8.0, right: 8.0),
              dense: true,
              style: ListTileStyle.drawer,
              minVerticalPadding: 12.0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              selectedColor: theme.textButtonTheme.style?.foregroundColor
                  ?.resolve({MaterialState.selected}),
              child: CustomScrollView(
                controller: scrollController,
                slivers: <Widget>[
                  SliverSafeArea(
                    sliver: SliverPinnedHeader(
                      child: Container(
                        color: theme.colorScheme.background,
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: Consumer(
                      builder: (context, ref, child) {
                        final pref = ref.watch(personalProvider);
                        return SliverList(
                          delegate: SliverChildListDelegate([
                            SwitchListTile.adaptive(
                              visualDensity: visualList,
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
                            const Gap(4.0),
                            SwitchListTile.adaptive(
                              visualDensity: visualList,
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
                            const Divider(),
                            const Gap(8.0),
                            Card(
                              color: theme.colorScheme.tertiaryContainer,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        baseline: TextBaseline.ideographic,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: Icon(
                                            Icons.lightbulb_outline_sharp,
                                            size: 16.0,
                                            color: theme.colorScheme
                                                .onTertiaryContainer,
                                          ),
                                        ),
                                      ),
                                      TextSpan(text: translate.hide_caution),
                                    ],
                                  ),
                                  softWrap: true,
                                  style: TextStyle(
                                    color:
                                        theme.colorScheme.onTertiaryContainer,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 8.0,
                              ),
                              child: Consumer(
                                builder: (context, ref, _) {
                                  final category =
                                      ref.watch(hiddenCategoryProvider);
                                  return SegmentedButton<HiddenType>(
                                    emptySelectionAllowed: false,
                                    multiSelectionEnabled: true,
                                    segments: <ButtonSegment<HiddenType>>[
                                      ButtonSegment<HiddenType>(
                                        value: HiddenType.Figures,
                                        label: Text(translate.figures),
                                        icon: const ImageIcon(
                                          AssetImage(
                                            'assets/collection/icon_1.webp',
                                          ),
                                        ),
                                      ),
                                      ButtonSegment<HiddenType>(
                                        value: HiddenType.Cards,
                                        label: Text(translate.cards),
                                        icon: const Icon(Icons.view_carousel),
                                      ),
                                    ],
                                    selected: <HiddenType>{
                                      if (category != HiddenType.Cards)
                                        HiddenType.Figures,
                                      if (category != HiddenType.Figures)
                                        HiddenType.Cards,
                                    },
                                    onSelectionChanged: (newSelection) {
                                      HiddenType? newCategory;
                                      if (newSelection.length == 1) {
                                        newCategory = newSelection.first;
                                      }
                                      ref
                                          .read(personalProvider.notifier)
                                          .updateIgnoredList(newCategory);
                                    },
                                  );
                                },
                              ),
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
