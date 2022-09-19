import 'package:amiibo_network/repository/theme_repository.dart';
import 'package:amiibo_network/resources/resources.dart';
import 'package:amiibo_network/riverpod/query_provider.dart';
import 'package:amiibo_network/riverpod/stat_provider.dart';
import 'package:amiibo_network/riverpod/theme_provider.dart';
import 'package:amiibo_network/utils/format_color_on_theme.dart';
import 'package:flutter/material.dart';
import 'package:amiibo_network/widget/theme_widget.dart';
import 'package:amiibo_network/enum/amiibo_category_enum.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:amiibo_network/widget/selected_chip.dart';
import 'package:amiibo_network/utils/routes_constants.dart';
import 'package:amiibo_network/model/search_result.dart';

class CollectionDrawer extends ConsumerStatefulWidget {
  final VoidCallback? restart;

  CollectionDrawer({Key? key, this.restart}) : super(key: key);

  @override
  _CollectionDrawerState createState() => _CollectionDrawerState();
}

class _CollectionDrawerState extends ConsumerState<CollectionDrawer> {
  static bool _figureExpand = false;
  static bool _cardExpand = false;
  late ThemeData theme;

  @override
  void didChangeDependencies() {
    theme = Theme.of(context);
    super.didChangeDependencies();
  }

  void figureExpand(bool x) => _figureExpand = x;
  void cardExpand(bool x) => _cardExpand = x;

  _onTapTile(WidgetRef ref, AmiiboCategory category, String tile) {
    final query = ref.read(querySearchProvider);
    if (query.search != tile || query.category != category) {
      ref
          .read(queryProvider.notifier)
          .updateOption(Search(category: category, search: tile));
      widget.restart?.call();
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final S translate = S.of(context);
    return ListTileTheme.merge(
      iconColor: theme.iconTheme.color,
      textColor: theme.textTheme.bodyText2!.color,
      selectedTileColor: theme.selectedRowColor.withOpacity(0.16),
      style: ListTileStyle.drawer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0))
      ),
      dense: true,
      selectedColor: theme.toggleableActiveColor,
      child: Drawer(
        backgroundColor: theme.colorScheme.background,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: Expanded(
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverPadding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      sliver: const SliverToBoxAdapter(child: _HeaderDrawer()),
                    ),
                    Consumer(
                      builder: (context, ref, child) {
                        final query = ref.watch(querySearchProvider);
                        final String? _selected = query.search;
                        final AmiiboCategory _category = query.category;
                        return SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              SwitchListTile.adaptive(
                                contentPadding:  const EdgeInsets.only(left: 16.0),
                                controlAffinity: ListTileControlAffinity.trailing,
                                secondary: const Icon(Icons.percent_outlined),
                                title: Text(translate.showPercentage),
                                inactiveTrackColor: theme.disabledColor.withOpacity(0.12),
                                value: ref.watch(statProvider).isPercentage,
                                onChanged: (value) async => await ref
                                  .read(statProvider)
                                  .toggleStat(value),
                              ),
                              Divider(
                                color: theme.dividerColor,
                                height: 8.0,
                              ),
                              ListTile(
                                onTap: () =>
                                    _onTapTile(ref, AmiiboCategory.All, 'All'),
                                leading: const Icon(Icons.all_inclusive),
                                title: Text(translate.category(AmiiboCategory.All)),
                                selected: _category == AmiiboCategory.All,
                              ),
                              const Gap(4.0),
                              ListTile(
                                onTap: () =>
                                    _onTapTile(ref, AmiiboCategory.Owned, 'Owned'),
                                leading: const Icon(iconOwned),
                                title:
                                    Text(translate.category(AmiiboCategory.Owned)),
                                selected: _category == AmiiboCategory.Owned,
                              ),
                              const Gap(4.0),
                              ListTile(
                                onTap: () => _onTapTile(
                                    ref, AmiiboCategory.Wishlist, 'Wishlist'),
                                leading: const Icon(iconWished),
                                title: Text(
                                    translate.category(AmiiboCategory.Wishlist)),
                                selected: _category == AmiiboCategory.Wishlist,
                              ),
                              const Gap(4.0),
                              ListTile(
                                onTap: () => _onTapTile(
                                    ref, AmiiboCategory.Custom, 'Custom'),
                                onLongPress: () async {
                                  final filter = ref.read(queryProvider.notifier);
                                  final List<String>? figures =
                                      filter.customFigures;
                                  final List<String>? cards = filter.customCards;
                                  bool save = await showDialog<bool>(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            CustomQueryWidget(
                                          translate.category(AmiiboCategory.Custom),
                                          figures: figures,
                                          cards: cards,
                                        ),
                                      ) ??
                                      false;
                                  if (save)
                                    await ref
                                        .read(queryProvider.notifier)
                                        .updateCustom(figures, cards);
                                },
                                leading: const Icon(Icons.create),
                                title:
                                    Text(translate.category(AmiiboCategory.Custom)),
                                selected: _category == AmiiboCategory.Custom,
                              ),
                              const Gap(4.0),
                              HookConsumer(
                                builder: (context, ref, child) {
                                  final snapshot = ref.watch(figuresProvider);
                                  return ExpansionTile(
                                    leading: const ImageIcon(AssetImage('assets/collection/icon_1.webp')),
                                    title: Text(translate.figures),
                                    initiallyExpanded: _figureExpand,
                                    onExpansionChanged: figureExpand,
                                    iconColor: theme.iconTheme.color,
                                    textColor: theme.iconTheme.color,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor:
                                                theme.colorScheme.secondary,
                                            foregroundColor:
                                                theme.colorScheme.onSecondary,
                                            radius: 12,
                                            child: const Icon(
                                              Icons.all_inclusive,
                                              size: 16,
                                            ),
                                          ),
                                          title: Text(translate
                                              .category(AmiiboCategory.Figures)),
                                          onTap: () => _onTapTile(
                                              ref, AmiiboCategory.Figures, 'Figures'),
                                          selected: _selected == 'Figures',
                                        ),
                                      ),
                                      if (snapshot is AsyncData<List<String>>)
                                        for (String series in snapshot.value)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                                            child: ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor:
                                                    theme.colorScheme.secondary,
                                                foregroundColor:
                                                    theme.colorScheme.onSecondary,
                                                radius: 12,
                                                child: Text(series[0]),
                                              ),
                                              title: Text(series),
                                              onTap: () => _onTapTile(ref,
                                                  AmiiboCategory.FigureSeries, series),
                                              selected: _category ==
                                                      AmiiboCategory.FigureSeries &&
                                                  _selected == series,
                                            ),
                                          ),
                                    ],
                                  );
                                },
                              ),
                              const Gap(4.0),
                              HookConsumer(
                                builder: (context, ref, child) {
                                  final snapshot = ref.watch(cardsProvider);
                                  return ExpansionTile(
                                    leading: const Icon(Icons.view_carousel),
                                    title: Text(translate.cards),
                                    initiallyExpanded: _cardExpand,
                                    onExpansionChanged: cardExpand,
                                    iconColor: theme.iconTheme.color,
                                    textColor: theme.iconTheme.color,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor:
                                                theme.colorScheme.secondary,
                                            foregroundColor:
                                                theme.colorScheme.onSecondary,
                                            radius: 12,
                                            child: const Icon(
                                              Icons.all_inclusive,
                                              size: 16,
                                            ),
                                          ),
                                          title: Text(
                                              translate.category(AmiiboCategory.Cards)),
                                          onTap: () => _onTapTile(
                                              ref, AmiiboCategory.Cards, 'Cards'),
                                          selected: _selected == 'Cards',
                                        ),
                                      ),
                                      if (snapshot is AsyncData<List<String>>)
                                        for (String series in snapshot.value)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                                            child: ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor:
                                                    theme.colorScheme.secondary,
                                                foregroundColor:
                                                    theme.colorScheme.onSecondary,
                                                radius: 12,
                                                child: Text(series[0]),
                                              ),
                                              title: Text(series),
                                              onTap: () => _onTapTile(ref,
                                                  AmiiboCategory.CardSeries, series),
                                              selected: _category ==
                                                      AmiiboCategory.CardSeries &&
                                                  _selected == series,
                                            ),
                                          ),
                                    ],
                                  );
                                },
                              ),
                            ]),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
            const Divider(height: 1.0),
            ListTile(
              shape: const ContinuousRectangleBorder(),
              dense: true,
              onTap: () {
                Navigator.popAndPushNamed(context, settingsRoute);
              },
              leading: const Icon(Icons.settings),
              title: Text(translate.settings),
              trailing: ThemeButton(openDialog: true),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderDrawer extends ConsumerWidget {
  const _HeaderDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaBrightness = MediaQuery.of(context).platformBrightness;
    final themeMode = ref.watch(themeProvider.select((t) => t.preferredTheme));
    final color = colorOnThemeMode(themeMode, mediaBrightness);
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.appBarTheme.systemOverlayStyle!.statusBarColor ?? theme.primaryColor,
      child: DrawerHeader(
        decoration: BoxDecoration(
          color: theme.backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32.0),
          ),
        ),
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        child: Image.asset(
          NetworkIcons.iconApp,
          fit: BoxFit.fitHeight,
          color: color,
        ),
      ),
    );
  }
}
