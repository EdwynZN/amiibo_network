import 'package:amiibo_network/repository/theme_repository.dart';
import 'package:amiibo_network/resources/resources.dart';
import 'package:amiibo_network/riverpod/query_provider.dart';
import 'package:flutter/material.dart';
import 'package:amiibo_network/widget/theme_widget.dart';
import 'package:amiibo_network/enum/amiibo_category_enum.dart';
import 'package:amiibo_network/generated/l10n.dart';
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
      ref.read(queryProvider.notifier).updateOption(Search(
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
          Theme(
            data: theme.copyWith(
              dividerColor: Colors.transparent,
            ),
            child: Expanded(
              child: CustomScrollView(
                slivers: <Widget>[
                  const SliverToBoxAdapter(
                    child: _HeaderDrawer(),
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final query = ref.watch(querySearchProvider);
                      final String? _selected = query.search;
                      final AmiiboCategory _category = query.category;
                      return SliverList(
                        delegate: SliverChildListDelegate([
                          ListTile(
                            onTap: () {
                              Navigator.of(context)
                              ..pop()..pushNamed(statsRoute);
                            },
                            leading: const Icon(Icons.timeline),
                            title: Text(translate.stats),
                            selected: _selected == 'Stats',
                          ),
                          ListTile(
                            onTap: () => _onTapTile(ref, AmiiboCategory.All, 'All'),
                            leading: const Icon(Icons.all_inclusive),
                            title: Text(translate.category(AmiiboCategory.All)),
                            selected: _category == AmiiboCategory.All,
                          ),
                          ListTile(
                            onTap: () =>
                                _onTapTile(ref, AmiiboCategory.Owned, 'Owned'),
                            leading: const Icon(iconOwned),
                            title: Text(translate.category(AmiiboCategory.Owned)),
                            selected: _category == AmiiboCategory.Owned,
                          ),
                          ListTile(
                            onTap: () =>
                                _onTapTile(ref, AmiiboCategory.Wishlist, 'Wishlist'),
                            leading: const Icon(iconWished),
                            title:
                                Text(translate.category(AmiiboCategory.Wishlist)),
                            selected: _category == AmiiboCategory.Wishlist,
                          ),
                          ListTile(
                            onTap: () =>
                                _onTapTile(ref, AmiiboCategory.Custom, 'Custom'),
                            onLongPress: () async {
                              final filter = ref.read(queryProvider.notifier);
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
                                await ref.read(queryProvider.notifier)
                                    .updateCustom(figures, cards);
                            },
                            leading: const Icon(Icons.create),
                            title: Text(translate.category(AmiiboCategory.Custom)),
                            selected: _category == AmiiboCategory.Custom,
                          ),
                          HookConsumer(builder: (context, ref, child) {
                            final snapshot = ref.watch(
                              figuresProvider,
                            );
                            return ExpansionTile(
                              leading: const Icon(Icons.sports_esports),
                              title: Text(translate.figures),
                              initiallyExpanded: _figureExpand,
                              onExpansionChanged: figureExpand,
                              iconColor: theme.iconTheme.color,
                              textColor: theme.iconTheme.color,
                              children: <Widget>[
                                ListTile(
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
                                if (snapshot is AsyncData<List<String>>)
                                  for (String series in snapshot.value)
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                          theme.colorScheme.secondary,
                                        foregroundColor:
                                          theme.colorScheme.onSecondary,
                                        radius: 12,
                                        child: Text(series[0]),
                                      ),
                                      title: Text(series),
                                      onTap: () => _onTapTile(
                                          ref, AmiiboCategory.FigureSeries, series),
                                      selected: _category ==
                                              AmiiboCategory.FigureSeries &&
                                          _selected == series,
                                    ),
                              ],
                            );
                          }),
                          HookConsumer(builder: (context, ref, child) {
                            final snapshot = ref.watch(cardsProvider);
                            return ExpansionTile(
                              leading: const Icon(Icons.view_carousel),
                              title: Text(translate.cards),
                              initiallyExpanded: _cardExpand,
                              onExpansionChanged: cardExpand,
                              iconColor: theme.iconTheme.color,
                              textColor: theme.iconTheme.color,
                              children: <Widget>[
                                ListTile(
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
                                  onTap: () =>
                                      _onTapTile(ref, AmiiboCategory.Cards, 'Cards'),
                                  selected: _selected == 'Cards',
                                ),
                                if (snapshot is AsyncData<List<String>>)
                                  for (String series in snapshot.value)
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                          theme.colorScheme.secondary,
                                        foregroundColor:
                                          theme.colorScheme.onSecondary,
                                        radius: 12,
                                        child: Text(series[0]),
                                      ),
                                      title: Text(series),
                                      onTap: () => _onTapTile(
                                          ref, AmiiboCategory.CardSeries, series),
                                      selected: _category ==
                                              AmiiboCategory.CardSeries &&
                                          _selected == series,
                                    ),
                              ],
                            );
                          }),
                        ]),
                      );
                    },
                  )
                ],
              ),
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
      margin: EdgeInsets.only(bottom: 2.0),
      child: Image.asset(
        NetworkIcons.iconApp,
        fit: BoxFit.fitHeight,
        color: theme.primaryColorBrightness == Brightness.dark
            ? Colors.white54
            : null,
      ),
    );
  }
}