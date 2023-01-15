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
import 'package:go_router/go_router.dart';
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
      style: ListTileStyle.drawer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      dense: true,
      child: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: Expanded(
                child: CustomScrollView(
                  slivers: <Widget>[
                    const SliverPadding(
                      padding: EdgeInsets.only(bottom: 4.0),
                      sliver: SliverToBoxAdapter(child: _HeaderDrawer()),
                    ),
                    Consumer(
                      builder: (context, ref, child) {
                        final query = ref.watch(querySearchProvider);
                        final String? _selected = query.search;
                        final AmiiboCategory _category = query.category;
                        final isAll = _category == AmiiboCategory.All;
                        final isOwned = _category == AmiiboCategory.Owned;
                        final isWishlist = _category == AmiiboCategory.Wishlist;
                        final isCustom = _category == AmiiboCategory.Custom;
                        return SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              SwitchListTile.adaptive(
                                contentPadding:
                                    const EdgeInsets.only(left: 16.0),
                                controlAffinity:
                                    ListTileControlAffinity.trailing,
                                secondary: const Icon(Icons.percent_outlined),
                                title: Text(translate.showPercentage),
                                inactiveTrackColor:
                                    theme.disabledColor.withOpacity(0.12),
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
                                onTap: () => _onTapTile(
                                    ref, AmiiboCategory.Custom, 'Custom'),
                                onLongPress: () async {
                                  final filter =
                                      ref.read(queryProvider.notifier);
                                  final List<String>? figures =
                                      filter.customFigures;
                                  final List<String>? cards =
                                      filter.customCards;
                                  bool save = await showDialog<bool>(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            CustomQueryWidget(
                                          translate
                                              .category(AmiiboCategory.Custom),
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
                                title: Text(
                                  translate.category(AmiiboCategory.Custom),
                                  style: isCustom
                                      ? const TextStyle(
                                          fontWeight: FontWeight.bold)
                                      : null,
                                ),
                                selected: isCustom,
                              ),
                              const Gap(4.0),
                              ListTile(
                                onTap: () => _onTapTile(
                                    ref, AmiiboCategory.Owned, 'Owned'),
                                leading: const Icon(iconOwned),
                                title: Text(
                                  translate.category(AmiiboCategory.Owned),
                                  style: isOwned
                                      ? const TextStyle(
                                          fontWeight: FontWeight.bold)
                                      : null,
                                ),
                                selected: isOwned,
                              ),
                              const Gap(4.0),
                              ListTile(
                                onTap: () => _onTapTile(
                                    ref, AmiiboCategory.Wishlist, 'Wishlist'),
                                leading: const Icon(iconWished),
                                title: Text(
                                  translate.category(AmiiboCategory.Wishlist),
                                  style: isWishlist
                                      ? const TextStyle(
                                          fontWeight: FontWeight.bold)
                                      : null,
                                ),
                                selected: isWishlist,
                              ),
                              const Gap(4.0),
                              ListTile(
                                onTap: () =>
                                    _onTapTile(ref, AmiiboCategory.All, 'All'),
                                leading: const Icon(Icons.all_inclusive),
                                title: Text(
                                  translate.category(AmiiboCategory.All),
                                  style: isAll
                                      ? const TextStyle(
                                          fontWeight: FontWeight.bold)
                                      : null,
                                ),
                                selected: isAll,
                              ),
                              const Gap(4.0),
                              HookConsumer(
                                builder: (context, ref, child) {
                                  final snapshot = ref.watch(figuresProvider);
                                  return Material(
                                    clipBehavior: Clip.antiAlias,
                                    type: MaterialType.transparency,
                                    child: ExpansionTile(
                                      leading: const ImageIcon(
                                        AssetImage(
                                          'assets/collection/icon_1.webp',
                                        ),
                                      ),
                                      title: Text(translate.figures),
                                      initiallyExpanded: _figureExpand,
                                      onExpansionChanged: figureExpand,
                                      iconColor: theme.iconTheme.color,
                                      textColor: theme.iconTheme.color,
                                      collapsedBackgroundColor: Colors.transparent,
                                      backgroundColor: Colors.transparent,
                                      children: <Widget>[
                                        _AmiiboTile(
                                          name: translate.category(AmiiboCategory.Figures),
                                          isSelected: _selected == 'Figures',
                                          icon: const Icon(
                                            Icons.all_inclusive,
                                            size: 16,
                                          ),
                                          onTap: () => _onTapTile(
                                            ref,
                                            AmiiboCategory.Figures,
                                            'Figures',
                                          ),
                                        ),
                                        if (snapshot is AsyncData<List<String>>)
                                          for (String series in snapshot.value)
                                            _AmiiboTile(
                                              name: series,
                                              isSelected: _category ==
                                                AmiiboCategory.FigureSeries &&
                                                _selected == series,
                                              onTap: () => _onTapTile(
                                                ref,
                                                AmiiboCategory.FigureSeries,
                                                series,
                                              ),
                                            ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const Gap(4.0),
                              HookConsumer(
                                builder: (context, ref, child) {
                                  final snapshot = ref.watch(cardsProvider);
                                  return Material(
                                    clipBehavior: Clip.antiAlias,
                                    type: MaterialType.transparency,
                                    child: ExpansionTile(
                                      leading: const Icon(Icons.view_carousel),
                                      title: Text(translate.cards),
                                      initiallyExpanded: _cardExpand,
                                      onExpansionChanged: cardExpand,
                                      iconColor: theme.iconTheme.color,
                                      textColor: theme.iconTheme.color,
                                      children: <Widget>[
                                        _AmiiboTile(
                                          name: translate.category(AmiiboCategory.Cards),
                                          isSelected: _selected == 'Cards',
                                          icon: const Icon(
                                            Icons.all_inclusive,
                                            size: 16,
                                          ),
                                          onTap: () => _onTapTile(
                                            ref,
                                            AmiiboCategory.Cards,
                                            'Cards',
                                          ),
                                        ),
                                        if (snapshot is AsyncData<List<String>>)
                                          for (String series in snapshot.value)
                                            _AmiiboTile(
                                              name: series,
                                              isSelected: _category ==
                                                AmiiboCategory.CardSeries &&
                                                _selected == series,
                                              onTap: () => _onTapTile(
                                                ref,
                                                AmiiboCategory.CardSeries,
                                                series,
                                              ),
                                            ),
                                      ],
                                    ),
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
                final router = GoRouter.of(context);
                Navigator.pop(context);
                router.push(settingsRoute);
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

class _AmiiboTile extends StatelessWidget {
  final String name;
  final VoidCallback? onTap;
  final bool isSelected;
  final Widget? icon;

  const _AmiiboTile({
    // ignore: unused_element
    super.key,
    required this.name,
    required this.isSelected,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.secondary,
          foregroundColor: theme.colorScheme.onSecondary,
          radius: 12.0,
          child: icon ?? Text(name[0]),
        ),
        title: Text(
          name,
          style:
              isSelected ? const TextStyle(fontWeight: FontWeight.bold) : null,
        ),
        onTap: onTap,
        selected: isSelected,
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
    return DrawerHeader(
      decoration: BoxDecoration(
        color: theme.drawerTheme.backgroundColor ?? theme.backgroundColor,
      ),
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      child: Image.asset(
        NetworkIcons.iconApp,
        fit: BoxFit.fitHeight,
        color: color,
      ),
    );
  }
}
