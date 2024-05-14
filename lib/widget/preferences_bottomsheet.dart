import 'package:amiibo_network/enum/hidden_types.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/riverpod/preferences_provider.dart';
import 'package:amiibo_network/riverpod/stat_ui_remote_config_provider.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
    final double height = (460.0 / size.height).clamp(0.30, 0.75);
    const visualList = VisualDensity(vertical: -2.0);
    return DraggableScrollableSheet(
      key: const Key('Draggable'),
      maxChildSize: 0.75,
      minChildSize: 0.25,
      expand: false,
      initialChildSize: height,
      snap: true,
      snapSizes: const [0.35, 0.75],
      builder: (context, scrollController) {
        final ThemeData theme = Theme.of(context);
        return Material(
          color: theme.colorScheme.surface,
          shape: theme.bottomSheetTheme.shape,
          elevation: 4.0,
          surfaceTintColor: theme.colorScheme.surfaceTint,
          clipBehavior: Clip.antiAlias,
          child: ListTileTheme.merge(
            //selectedTileColor: theme.selectedRowColor.withOpacity(0.16),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            dense: true,
            style: ListTileStyle.drawer,
            minVerticalPadding: 12.0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            selectedColor: theme.textButtonTheme.style?.foregroundColor
                ?.resolve({WidgetState.selected}),
            child: CustomScrollView(
              controller: scrollController,
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: Consumer(
                    builder: (context, ref, child) {
                      final pref = ref.watch(personalProvider);
                      return SliverList(
                        delegate: SliverChildListDelegate([
                          _CategoryTitle(title: translate.appearance),
                          const Gap(8.0),
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
                        ]),
                      );
                    },
                  ),
                ),
                SliverGap(16.0, color: theme.colorScheme.surface),
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: Consumer(
                      child: _CategoryTitle(title: translate.features),
                      builder: (context, ref, child) {
                        final ownedCategoriesRemote =
                            ref.watch(remoteOwnedCategoryProvider);
                        return SliverList(
                          delegate: SliverChildListDelegate([
                            child!,
                            const Gap(8.0),
                            Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              color: theme.colorScheme.tertiaryContainer,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.baseline,
                                        baseline: TextBaseline.ideographic,
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 4.0),
                                          child: Icon(
                                            Icons.warning_rounded,
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
                                    fontWeight: FontWeight.w600,
                                    color:
                                        theme.colorScheme.onTertiaryContainer,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            if (ownedCategoriesRemote) ...[
                              Consumer(builder: (context, ref, _) {
                                return SwitchListTile.adaptive(
                                  visualDensity: visualList,
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                  title: Text(
                                    translate.showOwnerCategories,
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                  subtitle: Text(
                                    translate.showOwnerCategoriesDetails,
                                  ),
                                  isThreeLine: true,
                                  inactiveTrackColor:
                                      theme.disabledColor.withOpacity(0.12),
                                  value: ref.watch(ownTypesCategoryProvider),
                                  onChanged: (value) async => await ref
                                      .read(personalProvider.notifier)
                                      .toggleOwnType(value),
                                );
                              }),
                              const Gap(8.0),
                            ],
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
                                      if (category != HiddenType.Figures)
                                        HiddenType.Figures,
                                      if (category != HiddenType.Cards)
                                        HiddenType.Cards,
                                    },
                                    onSelectionChanged: (newSelection) {
                                      HiddenType? newCategory;
                                      if (newSelection.length == 1) {
                                        newCategory = newSelection.first ==
                                                HiddenType.Cards
                                            ? HiddenType.Figures
                                            : HiddenType.Cards;
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
                      }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoryTitle extends StatelessWidget {
  final String title;

  // ignore: unused_element
  const _CategoryTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        title,
        maxLines: 1,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
