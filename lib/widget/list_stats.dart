import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/model/search_result.dart';
import 'package:amiibo_network/model/stat.dart';
import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:amiibo_network/riverpod/service_provider.dart';
import 'package:amiibo_network/widget/single_stat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

final _statsProvider = StreamProvider.autoDispose<List<Stat>>((ref) {
  final service = ref.watch(serviceProvider.notifier);
  final listStream = ref.watch(amiiboHomeListProvider.stream);

  return listStream.asyncMap(
    (cb) async {
      final series = cb.map((e) => e.amiiboSeries).toSet().toList();
      final exp = InCond.inn('amiiboSeries', series);
      return <Stat>[
        ...await service.fetchStats(expression: exp),
        ...await service.fetchStats(group: true, expression: exp),
      ];
    },
  );
});

AsyncValue<List<Stat>> _usePreviousStat(WidgetRef ref) {
  final snapshot = ref.watch(_statsProvider);
  final previous = usePrevious(snapshot);
  if (previous is AsyncData<List<Stat>> && snapshot is! AsyncData<List<Stat>>)
    return previous;
  return snapshot;
}

class HomeBodyStats extends HookConsumerWidget {
  const HomeBodyStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S translate = S.of(context);
    final snapshot = _usePreviousStat(ref);
    if (snapshot is AsyncData<List<Stat>>) {
      if (snapshot.value.length <= 1)
        return SliverToBoxAdapter(
          child: Center(
            child: Text(
              translate.emptyPage,
              style: Theme.of(context).textTheme.headline4,
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
