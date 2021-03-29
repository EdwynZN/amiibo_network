import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/riverpod/query_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SortCollection extends StatelessWidget {
  const SortCollection({Key key}) : super(key: key);

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
      icon: const Icon(Icons.sort_by_alpha),
      tooltip: translate.sort,
    );
  }
}

class _BottomSheetSort extends StatelessWidget {
  const _BottomSheetSort({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final _accentColor = theme.accentColor;
    final _accentTextThemeColor = theme.accentTextTheme.headline6.color;
    final S translate = S.of(context);
    final Size size = MediaQuery.of(context).size;
    final double height = (460.0 / size.height).clamp(0.25, 0.66);
    EdgeInsetsGeometry padding = EdgeInsets.zero;
    if (size.longestSide >= 800)
      padding = EdgeInsets.symmetric(
          horizontal: (size.width / 2 - 210).clamp(0.0, double.infinity));
    return Padding(
      padding: padding,
      child: DraggableScrollableSheet(
        key: Key('Draggable'),
        maxChildSize: height,
        expand: false,
        initialChildSize: height,
        builder: (context, scrollController) {
          return Material(
            color: Theme.of(context).backgroundColor,
            shape: Theme.of(context).bottomSheetTheme.shape,
            child: CustomScrollView(
              controller: scrollController,
              slivers: <Widget>[
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _BottomSheetHeader(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(translate.sort,
                            style: Theme.of(context).textTheme.headline6),
                        TextButton(
                          style: TextButton.styleFrom(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity(vertical: -0.5)),
                          onPressed: () => Navigator.pop(context),
                          child: Text(translate.done),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  sliver: SliverToBoxAdapter(
                    child: SizedBox(
                      height: 36,
                      child: Consumer(
                        builder: (context, watch, _) {
                          final sortBy = watch(sortByProvider.state);
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: sortBy.contains('ASC')
                                      ? OutlinedButton.styleFrom(
                                          primary: _accentTextThemeColor,
                                          backgroundColor: _accentColor)
                                      : null,
                                  onPressed: () => context
                                      .read(sortByProvider)
                                      .changeState('ASC'),
                                  icon: const Icon(
                                    Icons.arrow_downward,
                                    size: 20,
                                  ),
                                  label: Flexible(
                                      child: FittedBox(
                                    child: Text(translate.asc),
                                  )),
                                ),
                              ),
                              Expanded(
                                child: OutlinedButton.icon(
                                  key: Key('DESC'),
                                  style: sortBy.contains('DESC')
                                      ? OutlinedButton.styleFrom(
                                          primary: _accentTextThemeColor,
                                          backgroundColor: _accentColor)
                                      : null,
                                  onPressed: () => context
                                      .read(sortByProvider)
                                      .changeState('DESC'),
                                  icon:
                                      const Icon(Icons.arrow_upward, size: 20),
                                  label: Flexible(
                                      child: FittedBox(
                                    child: Text(translate.desc),
                                  )),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Consumer(
                  builder: (context, watch, _) {
                    final order = watch(orderCategoryProvider.state);
                    return SliverList(
                      delegate: SliverChildListDelegate([
                        RadioListTile<String>(
                          value: 'name',
                          groupValue: order,
                          onChanged:
                              context.read(orderCategoryProvider).changeState,
                          title: Text(translate.sortName),
                          selected: order.contains('name'),
                        ),
                        RadioListTile<String>(
                          value: 'owned',
                          groupValue: order,
                          onChanged:
                              context.read(orderCategoryProvider).changeState,
                          title: Text(translate.owned),
                          selected: order.contains('owned'),
                        ),
                        RadioListTile<String>(
                          value: 'wishlist',
                          groupValue: order,
                          onChanged:
                              context.read(orderCategoryProvider).changeState,
                          title: Text(translate.wished),
                          selected: order.contains('wishlist'),
                        ),
                        RadioListTile<String>(
                          value: 'na',
                          groupValue: order,
                          onChanged:
                              context.read(orderCategoryProvider).changeState,
                          title: Text(translate.na),
                          selected: order == 'na',
                          secondary: Image.asset(
                            'assets/images/na.png',
                            height: 16,
                            width: 25,
                            fit: BoxFit.fill,
                            semanticLabel: translate.na,
                          ),
                        ),
                        RadioListTile<String>(
                          value: 'eu',
                          groupValue: order,
                          onChanged:
                              context.read(orderCategoryProvider).changeState,
                          title: Text(translate.eu),
                          selected: order.contains('eu'),
                          secondary: Image.asset(
                            'assets/images/eu.png',
                            height: 16,
                            width: 25,
                            fit: BoxFit.fill,
                            semanticLabel: translate.eu,
                          ),
                        ),
                        RadioListTile<String>(
                          value: 'jp',
                          groupValue: order,
                          onChanged:
                              context.read(orderCategoryProvider).changeState,
                          title: Text(translate.jp),
                          selected: order.contains('jp'),
                          secondary: DecoratedBox(
                            decoration:
                                BoxDecoration(border: Border.all(width: 0.75)),
                            position: DecorationPosition.foreground,
                            child: Image.asset(
                              'assets/images/jp.png',
                              height: 16,
                              width: 25,
                              fit: BoxFit.fill,
                              semanticLabel: translate.jp,
                            ),
                          ),
                        ),
                        RadioListTile<String>(
                          value: 'au',
                          groupValue: order,
                          onChanged:
                              context.read(orderCategoryProvider).changeState,
                          title: Text(translate.au),
                          selected: order.contains('au'),
                          secondary: Image.asset(
                            'assets/images/au.png',
                            height: 16,
                            width: 25,
                            fit: BoxFit.fill,
                            semanticLabel: translate.au,
                          ),
                        ),
                      ]),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BottomSheetHeader extends SliverPersistentHeaderDelegate {
  final Widget child;
  const _BottomSheetHeader({@required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: kToolbarHeight,
      child: Material(
        color: Theme.of(context).backgroundColor,
        shape: Theme.of(context).bottomSheetTheme.shape,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 24, right: 16),
              child: child,
            ),
            const Divider()
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => kToolbarHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
