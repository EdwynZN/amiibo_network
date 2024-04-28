import 'package:amiibo_network/enum/hidden_types.dart';
import 'package:amiibo_network/repository/theme_repository.dart';
import 'package:amiibo_network/resources/resources.dart';
import 'package:amiibo_network/riverpod/preferences_provider.dart';
import 'package:amiibo_network/riverpod/query_provider.dart';
import 'package:amiibo_network/riverpod/theme_provider.dart';
import 'package:amiibo_network/utils/format_color_on_theme.dart';
import 'package:amiibo_network/utils/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:amiibo_network/widget/theme_widget.dart';
import 'package:amiibo_network/enum/amiibo_category_enum.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:flutter/services.dart';
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
  late PreferencesExtension preferencesExtension;
  late SystemUiOverlayStyle? overlay;

  @override
  void didChangeDependencies() {
    theme = Theme.of(context);
    preferencesExtension = theme.extension<PreferencesExtension>()!;
    final style = theme.appBarTheme.systemOverlayStyle;
    overlay = style?.copyWith(statusBarColor: const Color(0x00000000));
    super.didChangeDependencies();
  }

  void figureExpand(bool x) => _figureExpand = x;
  void cardExpand(bool x) => _cardExpand = x;

  _onTapTile(WidgetRef ref, AmiiboCategory category, String? tile) {
    final query = ref.read(queryProvider);
    final attributes = CategoryAttributes(
      category: category,
      filters: tile != null ? [tile] : null,
    );
    if (query.categoryAttributes != attributes) {
      ref.read(queryProvider.notifier).updateTile(
            CategoryAttributes(
              category: category,
              filters: tile != null ? [tile] : null,
            ),
          );
      //.updateOption(Search(category: category, search: tile));
      widget.restart?.call();
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final S translate = S.of(context);
    final Widget child = ListTileTheme.merge(
      iconColor: theme.iconTheme.color,
      textColor: theme.textTheme.bodyMedium!.color,
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
                        final query = ref.watch(queryProvider);
                        final categoryAttributes = query.categoryAttributes;
                        final String? _selected = 
                          (categoryAttributes.filters?.isEmpty ?? true)
                            ? null
                            : categoryAttributes.filters!.first;
                        final AmiiboCategory _category = categoryAttributes.category;
                        final isAll = _category == AmiiboCategory.All;
                        final isOwned = _category == AmiiboCategory.Owned;
                        final isWishlist = _category == AmiiboCategory.Wishlist;
                        final isCustom = _category == AmiiboCategory.Custom;
                        final hidden = ref.watch(hiddenCategoryProvider);
                        final isFiguresShown =
                            hidden == null || hidden != HiddenType.Figures;
                        final isCardsShown =
                            hidden == null || hidden != HiddenType.Cards;
                        return SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              ListTile(
                                onTap: () => _onTapTile(
                                    ref, AmiiboCategory.Custom, 'Custom'),
                                leading: const Icon(
                                    Icons.dashboard_customize_rounded),
                                title: Text(
                                  translate.category(AmiiboCategory.Custom),
                                  style: isCustom
                                      ? const TextStyle(
                                          fontWeight: FontWeight.bold)
                                      : null,
                                ),
                                trailing: IconButton.filledTonal(
                                  icon: const Icon(Icons.create_outlined),
                                  iconSize: 20.0,
                                  onPressed: () async {
                                    final filter =
                                        ref.read(queryProvider.notifier);
                                    final List<String> figures =
                                        filter.customFigures;
                                    final List<String> cards =
                                        filter.customCards;
                                    bool save = await showDialog<bool>(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              CustomQueryWidget(
                                            translate.category(
                                                AmiiboCategory.Custom),
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
                                ),
                                contentPadding: const EdgeInsets.only(
                                  left: 16.0,
                                  right: 8.0,
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
                                selectedTileColor: preferencesExtension
                                    .ownContainer
                                    .withOpacity(0.54),
                                selectedColor:
                                    preferencesExtension.onOwnContainer,
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
                                selectedTileColor: preferencesExtension
                                    .wishContainer
                                    .withOpacity(0.54),
                                selectedColor:
                                    preferencesExtension.onWishContainer,
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
                              if (isFiguresShown) ...[
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
                                        collapsedBackgroundColor:
                                            Colors.transparent,
                                        backgroundColor: Colors.transparent,
                                        children: <Widget>[
                                          _AmiiboTile(
                                            name: translate.category(
                                                AmiiboCategory.Figures),
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
                                          if (snapshot
                                              is AsyncData<List<String>>)
                                            for (String series
                                                in snapshot.value)
                                              _AmiiboTile(
                                                name: series,
                                                isSelected: _category ==
                                                        AmiiboCategory
                                                            .FigureSeries &&
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
                              ],
                              if (isCardsShown) ...[
                                const Gap(4.0),
                                HookConsumer(
                                  builder: (context, ref, child) {
                                    final snapshot = ref.watch(cardsProvider);
                                    return Material(
                                      clipBehavior: Clip.antiAlias,
                                      type: MaterialType.transparency,
                                      child: ExpansionTile(
                                        leading:
                                            const Icon(Icons.view_carousel),
                                        title: Text(translate.cards),
                                        initiallyExpanded: _cardExpand,
                                        onExpansionChanged: cardExpand,
                                        iconColor: theme.iconTheme.color,
                                        textColor: theme.iconTheme.color,
                                        collapsedBackgroundColor:
                                            Colors.transparent,
                                        backgroundColor: Colors.transparent,
                                        children: <Widget>[
                                          _AmiiboTile(
                                            name: translate
                                                .category(AmiiboCategory.Cards),
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
                                          if (snapshot
                                              is AsyncData<List<String>>)
                                            for (String series
                                                in snapshot.value)
                                              _AmiiboTile(
                                                name: series,
                                                isSelected: _category ==
                                                        AmiiboCategory
                                                            .CardSeries &&
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
                              ],
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
    if (overlay == null) {
      return child;
    }
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay!,
      child: child,
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
    return DrawerHeader(
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
