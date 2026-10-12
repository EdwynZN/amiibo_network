import 'package:amiibo_network/app/configuration/model/sort_enum.dart';
import 'package:amiibo_network/app/configuration/query_provider.dart';
import 'package:amiibo_network/app/state/preferences_provider.dart';
import 'package:amiibo_network/shared/generated/l10n.dart';
import 'package:amiibo_network/shared/resources/resources.dart';
import 'package:amiibo_network/shared/utils/gap_helper.dart';
import 'package:amiibo_network/shared/widget/implicit_sort_direction_widget.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sliver_tools/sliver_tools.dart';

class const SortCollection({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortBy = ref.watch(sortByProvider);
    final orderBy = ref.watch(orderCategoryProvider);
    final S translate = S.of(context);
    final text = switch (orderBy) {
      .NA => translate.na,
      .EU => translate.eu,
      .JP => translate.jp,
      .AU => translate.au,
      .Name => translate.sortName,
      .Owned => translate.owned,
      .Wishlist => translate.wished,
      .CardNumber => translate.cardNumber,
      .Type => translate.amiibo_type,
      _ => translate.sortName,
    };
    return Card(
      margin: .zero,
      clipBehavior: .antiAlias,
      shape: const StadiumBorder(),
      child: ConstrainedBox(
        constraints: .new(minHeight: 48),
        child: Row(
          crossAxisAlignment: .center,
          mainAxisAlignment: .center,
          mainAxisSize: .min,
          children: [
            GestureDetector(
              onTap: () {
                final queryNotifier = ref.read(queryProvider.notifier);
                final SortBy sort = sortBy == .ASC ? .DESC : .ASC;
                queryNotifier.changeSortAndOrder(orderBy, sort);
              },
              child: Padding(
                padding: horizontalPadding12,
                child: ImplicitDirectionIconButton(direction: sortBy),
              ),
            ),
            ConstrainedBox(
              constraints: .tightFor(height: 32),
              child: VerticalDivider(
                width: 0,
                thickness: 1,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
            GestureDetector(
              onTap: () async {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  elevation: 0.0,
                  builder: (context) => const _BottomSheetSort(),
                );
              },
              child: Container(
                constraints: .new(minWidth: 92),
                padding: horizontalPadding16,
                child: Text(text, textAlign: .center),
              ),
            ),
          ],
        ),
      ),
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
    return DraggableScrollableSheet(
      key: const Key('Draggable'),
      maxChildSize: height,
      expand: false,
      initialChildSize: height,
      builder: (context, scrollController) {
        final ThemeData theme = Theme.of(context);
        return Material(
          color: theme.colorScheme.surface,
          shape: theme.bottomSheetTheme.shape,
          clipBehavior: Clip.antiAlias,
          child: ListTileTheme.merge(
            //selectedTileColor: theme.selectedRowColor.withOpacity(0.16),
            contentPadding: const EdgeInsets.only(left: 8.0, right: 16.0),
            dense: true,
            style: ListTileStyle.list,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(32.0),
              ),
            ),
            selectedColor: theme.textButtonTheme.style?.foregroundColor
                ?.resolve({WidgetState.selected}),
            child: CustomScrollView(
              controller: scrollController,
              slivers: <Widget>[
                SliverPinnedHeader(
                  child: Container(
                    color: theme.colorScheme.surface,
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 6,
                            left: 24,
                            right: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: .spaceBetween,
                            children: [
                              Text(
                                translate.sort,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  tapTargetSize: .shrinkWrap,
                                  visualDensity: .new(vertical: -0.5),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: Text(translate.done),
                              ),
                            ],
                          ),
                        ),
                        gap8,
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
                  padding: const EdgeInsets.only(left: 16.0),
                  sliver: Consumer(
                    builder: (context, ref, child) {
                      final order = ref.watch(orderCategoryProvider);
                      final canUseCardNumber = ref.watch(canSortCardProvider);
                      return SliverList(
                        delegate: SliverChildListDelegate([
                          _SortListTile(
                            groupValue: order,
                            value: OrderBy.Name,
                            title: Text(translate.sortName),
                          ),
                          const Gap(4.0),
                          _SortListTile(
                            groupValue: order,
                            value: OrderBy.Owned,
                            title: Text(translate.owned),
                          ),
                          const Gap(4.0),
                          _SortListTile(
                            groupValue: order,
                            value: OrderBy.Wishlist,
                            title: Text(translate.wished),
                          ),
                          if (canUseCardNumber) ...[
                            const Gap(4.0),
                            _SortListTile(
                              groupValue: order,
                              value: OrderBy.CardNumber,
                              title: Text(translate.cardNumber),
                            ),
                          ],
                          const Gap(4.0),
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
                          const Gap(4.0),
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
                          const Gap(4.0),
                          _SortListTile(
                            groupValue: order,
                            value: OrderBy.JP,
                            title: Text(translate.jp),
                            trailing: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(width: 0.75),
                              ),
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
                          const Gap(4.0),
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
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SortListTile extends ConsumerWidget {
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
    final bool isSelected = value == groupValue;
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
        final SortBy sort = sortP == SortBy.ASC && isSelected
            ? SortBy.DESC
            : SortBy.ASC;
        queryNotifier.changeSortAndOrder(value, sort);
      },
      trailing: trailing,
    );
  }
}
