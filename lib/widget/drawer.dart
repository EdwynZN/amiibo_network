import 'package:amiibo_network/repository/theme_repository.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:amiibo_network/riverpod/query_provider.dart';
import 'package:amiibo_network/riverpod/stat_provider.dart';
import 'package:flutter/material.dart';
import 'package:amiibo_network/widget/theme_widget.dart';
import 'package:amiibo_network/enum/amiibo_category_enum.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:amiibo_network/widget/selected_chip.dart';
import 'package:amiibo_network/utils/routes_constants.dart';
import 'package:amiibo_network/model/search_result.dart';

class CollectionDrawer extends StatefulWidget {
  final VoidCallback? restart;

  CollectionDrawer({Key? key, this.restart}) : super(key: key);

  @override
  _CollectionDrawerState createState() => _CollectionDrawerState();
}

class _CollectionDrawerState extends State<CollectionDrawer> {
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

  _onTapTile(AmiiboCategory category, String tile) {
    final query = context.read(queryProvider);
    if (query.search != tile || query.category != category) {
      context.read(queryProvider.notifier).updateOption(Search(
        category: category,
        search: tile
      ));
      widget.restart!();
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final S translate = S.of(context);
    return ListTileTheme(
      iconColor: theme.iconTheme.color,
      textColor: theme.textTheme.bodyText2!.color,
      style: ListTileStyle.drawer,
      selectedColor: theme.toggleableActiveColor,
      child: Drawer(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: CustomScrollView(
              slivers: <Widget>[
                const SliverToBoxAdapter(
                  child: _HeaderDrawer(),
                ),
                SliverToBoxAdapter(
                  child: Consumer(
                    child: Text(
                      translate.showPercentage,
                      overflow: TextOverflow.fade,
                    ),
                    builder: (ctx, watch, child) {
                      final statMode = watch(statProvider);
                      return CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: child,
                        value: statMode.isPercentage,
                        onChanged: statMode.toggleStat,
                        checkColor: theme
                            .floatingActionButtonTheme
                            .foregroundColor,
                      );
                    },
                  ),
                ),
                Consumer(
                  builder: (context, watch, child) {
                    final query = watch(queryProvider);
                    final String? _selected = query.search;
                    final AmiiboCategory _category = query.category;
                    return SliverList(
                      delegate: SliverChildListDelegate([
                        ListTile(
                          onTap: () =>
                              _onTapTile(AmiiboCategory.Custom, 'Custom'),
                          onLongPress: () async {
                            final filter = context.read(queryProvider.notifier);
                            final List<String>? figures = filter.customFigures;
                            final List<String>? cards = filter.customCards;
                            bool save = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) =>
                                CustomQueryWidget(
                                  translate.category(AmiiboCategory.Custom),
                                  figures: figures,
                                  cards: cards,
                                ),
                              ) ?? false;
                            if (save)
                              await context
                                  .read(queryProvider.notifier)
                                  .updateCustom(figures, cards);
                          },
                          leading: const Icon(Icons.create),
                          title: Text(translate.category(AmiiboCategory.Custom)),
                          selected: _category == AmiiboCategory.Custom,
                        ),
                        ListTile(
                          onTap: () => _onTapTile(AmiiboCategory.All, 'All'),
                          leading: const Icon(Icons.all_inclusive),
                          title: Text(translate.category(AmiiboCategory.All)),
                          selected: _category == AmiiboCategory.All,
                        ),
                        ListTile(
                          onTap: () =>
                              _onTapTile(AmiiboCategory.Owned, 'Owned'),
                          leading: const Icon(iconOwned),
                          title: Text(translate.category(AmiiboCategory.Owned)),
                          selected: _category == AmiiboCategory.Owned,
                        ),
                        ListTile(
                          onTap: () =>
                              _onTapTile(AmiiboCategory.Wishlist, 'Wishlist'),
                          leading: const Icon(iconWished),
                          title:
                              Text(translate.category(AmiiboCategory.Wishlist)),
                          selected: _category == AmiiboCategory.Wishlist,
                        ),
                        ListTile(
                          onTap: () {
                            Navigator.of(context)
                            ..pop()..pushNamed(statsRoute);
                          },
                          leading: const Icon(Icons.timeline),
                          title: Text(translate.stats),
                          selected: _selected == 'Stats',
                        ),
                        HookBuilder(builder: (context) {
                          final snapshot = useProvider(
                            figuresProvider,
                          );
                          return Theme(
                            data: theme.copyWith(
                              dividerColor: Colors.transparent,
                              accentColor: theme.iconTheme.color,
                            ),
                            child: ExpansionTile(
                              leading: const Icon(Icons.toys),
                              title: Text(translate.figures),
                              initiallyExpanded: _figureExpand,
                              onExpansionChanged: figureExpand,
                              children: <Widget>[
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        theme.accentColor,
                                    foregroundColor:
                                        theme.accentIconTheme.color,
                                    radius: 12,
                                    child: const Icon(
                                      Icons.all_inclusive,
                                      size: 16,
                                    ),
                                  ),
                                  title: Text(translate
                                      .category(AmiiboCategory.Figures)),
                                  onTap: () => _onTapTile(
                                      AmiiboCategory.Figures, 'Figures'),
                                  selected: _selected == 'Figures',
                                ),
                                if (snapshot is AsyncData<List<String>>)
                                  for (String series in snapshot.value)
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            theme.accentColor,
                                        foregroundColor: theme
                                            .accentIconTheme
                                            .color,
                                        radius: 12,
                                        child: Text(series[0]),
                                      ),
                                      title: Text(series),
                                      onTap: () => _onTapTile(
                                          AmiiboCategory.FigureSeries, series),
                                      selected: _category ==
                                              AmiiboCategory.FigureSeries &&
                                          _selected == series,
                                    ),
                              ],
                            ),
                          );
                        }),
                        HookBuilder(builder: (context) {
                          final snapshot = useProvider(cardsProvider);
                          return Theme(
                            data: theme.copyWith(
                              dividerColor: Colors.transparent,
                              accentColor: theme.iconTheme.color,
                            ),
                            child: ExpansionTile(
                              leading: const Icon(Icons.view_carousel),
                              title: Text(translate.cards),
                              initiallyExpanded: _cardExpand,
                              onExpansionChanged: cardExpand,
                              children: <Widget>[
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        theme.accentColor,
                                    foregroundColor:
                                        theme.accentIconTheme.color,
                                    radius: 12,
                                    child: const Icon(
                                      Icons.all_inclusive,
                                      size: 16,
                                    ),
                                  ),
                                  title: Text(
                                      translate.category(AmiiboCategory.Cards)),
                                  onTap: () =>
                                      _onTapTile(AmiiboCategory.Cards, 'Cards'),
                                  selected: _selected == 'Cards',
                                ),
                                if (snapshot is AsyncData<List<String>>)
                                  for (String series in snapshot.value)
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            theme.accentColor,
                                        foregroundColor: theme
                                            .accentIconTheme
                                            .color,
                                        radius: 12,
                                        child: Text(series[0]),
                                      ),
                                      title: Text(series),
                                      onTap: () => _onTapTile(
                                          AmiiboCategory.CardSeries, series),
                                      selected: _category ==
                                              AmiiboCategory.CardSeries &&
                                          _selected == series,
                                    ),
                              ],
                            ),
                          );
                        }),
                      ]),
                    );
                  },
                )
              ],
            ),
          ),
          const Divider(height: 1.0),
          ListTile(
            dense: true,
            onTap: () {
              Navigator.popAndPushNamed(context, settingsRoute);
            },
            leading: const Icon(Icons.settings),
            title: Text(translate.settings),
            trailing: ThemeButton(openDialog: true),
          ),
        ],
      )),
    );
  }
}

class _HeaderDrawer extends StatelessWidget {
  const _HeaderDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DrawerHeader(
      decoration: BoxDecoration(color: theme.backgroundColor),
      padding: EdgeInsets.zero,
      child: Image.asset(
        'assets/images/icon_app.png',
        fit: BoxFit.fitHeight,
        color: theme.primaryColorBrightness == Brightness.dark
            ? Colors.white54
            : null,
      ),
    );
  }
}