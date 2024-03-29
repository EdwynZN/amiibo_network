import 'package:amiibo_network/enum/amiibo_category_enum.dart';
import 'package:amiibo_network/enum/hidden_types.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/model/search_result.dart';
import 'package:amiibo_network/model/stat.dart';
import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:amiibo_network/riverpod/preferences_provider.dart';
import 'package:amiibo_network/riverpod/service_provider.dart';
import 'package:amiibo_network/widget/single_stat.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

final _statsProvider = FutureProvider.autoDispose<List<Stat>>((ref) async {
  final service = ref.watch(serviceProvider.notifier);
  final list = await ref.watch(amiiboHomeListProvider.future);

  final series = list.map((e) => e.amiiboSeries).toSet().toList();
  Expression exp = InCond.inn('amiiboSeries', series);
  final HiddenType? hidden = ref.watch(hiddenCategoryProvider);
  if (hidden != null) {
    exp = hidden == HiddenType.Figures
      ? InCond.notInn('type', figureType)
      : Cond.ne('type', 'Card') & exp;
  }
  return <Stat>[
    ...await service.fetchStats(expression: exp),
    ...await service.fetchStats(group: true, expression: exp),
  ];
});

class HomeBodyStats extends ConsumerWidget {
  const HomeBodyStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S translate = S.of(context);
    final snapshot = ref.watch(_statsProvider);
    if (snapshot is AsyncData<List<Stat>>) {
      if (snapshot.value.length <= 1)
        return SliverToBoxAdapter(
          child: Center(
            child: Text(
              translate.emptyPage,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        );
      final Stat generalStats = snapshot.value.first;
      final List<Stat> stats = snapshot.value.sublist(1);
      return MultiSliver(
        children: [
          if (stats.length > 1)
            SliverToBoxAdapter(
              key: Key('Amiibo Network'),
              child: SingleStat(
                title: generalStats.name,
                owned: generalStats.owned,
                total: generalStats.total,
                wished: generalStats.wished,
              ),
            ),
          (MediaQuery.of(context).size.width <= 600)
              ? SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) => SingleStat(
                      key: ValueKey(index),
                      title: stats[index].name,
                      owned: stats[index].owned,
                      total: stats[index].total,
                      wished: stats[index].wished,
                    ),
                    semanticIndexOffset: 1,
                    childCount: stats.length,
                  ),
                )
              : SliverGrid(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 230,
                    mainAxisSpacing: 8.0,
                    mainAxisExtent: 140,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) => SingleStat(
                      key: ValueKey(index),
                      title: stats[index].name,
                      owned: stats[index].owned,
                      total: stats[index].total,
                      wished: stats[index].wished,
                    ),
                    semanticIndexOffset: 1,
                    childCount: stats.length,
                  ),
                )
        ],
      );
    }
    return const SliverToBoxAdapter();
  }
}
