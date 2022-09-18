import 'package:amiibo_network/enum/sort_enum.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/resources/resources.dart';
import 'package:amiibo_network/riverpod/query_provider.dart';
import 'package:amiibo_network/widget/implicit_sort_direction_widget.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sliver_tools/sliver_tools.dart';

class SortCollection extends StatelessWidget {
  const SortCollection({Key? key}) : super(key: key);

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
  const _BottomSheetSort({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final S translate = S.of(context);
    final Size size = MediaQuery.of(context).size;
    final double height = (460.0 / size.height).clamp(0.25, 0.5);
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
        initialChildSize: height,
        builder: (context, scrollController) {
          final ThemeData theme = Theme.of(context);
          return Material(
            color: theme.backgroundColor,
            shape: theme.bottomSheetTheme.shape,
            child: ListTileTheme.merge(
              selectedColor: theme.textButtonTheme.style?.foregroundColor?.resolve({MaterialState.selected}),
              child: CustomScrollView(
                controller: scrollController,
                slivers: <Widget>[
                  SliverPinnedHeader(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 24, right: 16),
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
                        const Divider(),
                      ],
                    ),
                  ),
                  HookConsumer(
                    builder: (context, ref, child) {
                      final order = ref.watch(orderCategoryProvider);
                      return ListTileTheme.merge(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SliverList(
                          delegate: SliverChildListDelegate([
                            _SortListTile(
                              groupValue: order,
                              value: OrderBy.Name,
                              title: Text(translate.sortName),
                            ),
                            _SortListTile(
                              groupValue: order,
                              value: OrderBy.Owned,
                              title: Text(translate.owned),
                            ),
                            _SortListTile(
                              groupValue: order,
                              value: OrderBy.Wishlist,
                              title: Text(translate.wished),
                            ),
                            _SortListTile(
                              groupValue: order,
                              value: OrderBy.NA,
                              title: Text(translate.na),
                              trailing: Image.asset(
                                NetworkIcons.na,
                                height: 16,
                                width: 25,
                                fit: BoxFit.fill,
                                semanticLabel: translate.na,
                              ),
                            ),
                            _SortListTile(
                              groupValue: order,
                              value: OrderBy.EU,
                              title: Text(translate.eu),
                              trailing: Image.asset(
                                NetworkIcons.eu,
                                height: 16,
                                width: 25,
                                fit: BoxFit.fill,
                                semanticLabel: translate.eu,
                              ),
                            ),
                            _SortListTile(
                              groupValue: order,
                              value: OrderBy.JP,
                              title: Text(translate.jp),
                              trailing: DecoratedBox(
                                decoration: BoxDecoration(
                                    border: Border.all(width: 0.75)),
                                position: DecorationPosition.foreground,
                                child: Image.asset(
                                  NetworkIcons.jp,
                                  height: 16,
                                  width: 25,
                                  fit: BoxFit.fill,
                                  semanticLabel: translate.jp,
                                ),
                              ),
                            ),
                            _SortListTile(
                              groupValue: order,
                              value: OrderBy.AU,
                              title: Text(translate.au),
                              trailing: Image.asset(
                                NetworkIcons.au,
                                height: 16,
                                width: 25,
                                fit: BoxFit.fill,
                                semanticLabel: translate.au,
                              ),
                            ),
                          ]),
                        ),
                      );
                    },
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

class _SortListTile extends HookConsumerWidget {
  final Widget? title;
  final Widget? trailing;
  final OrderBy value;
  final OrderBy? groupValue;

  const _SortListTile({
    Key? key,
    this.title,
    this.trailing,
    required this.value,
    required this.groupValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortP = ref.watch(sortByProvider);
    final bool isSelected =
        useMemoized(() => value == groupValue, [value, groupValue]);
    return ListTile(
      leading: AnimatedSwitcher(
        duration: kRadialReactionDuration,
        child: isSelected
          ? ImplicitDirectionIconButton(direction: sortP)
          : const SizedBox(width: 24.0),
      ),
      title: title,
      selected: isSelected,
      onTap: () {
        final queryNotifier = ref.read(queryProvider.notifier);
        final SortBy sort =
            sortP == SortBy.ASC && isSelected ? SortBy.DESC : SortBy.ASC;
        queryNotifier.changeSortAndOrder(value, sort);
      },
      trailing: trailing,
    );
  }
}