import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/model/stat.dart';
import 'package:amiibo_network/riverpod/stats_amiibo_provider.dart';
import 'package:amiibo_network/widget/single_stat.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

class HomeBodyStats extends ConsumerWidget {
  const HomeBodyStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S translate = S.of(context);
    final snapshot = ref.watch(statsProvider);
    if (snapshot is AsyncData<List<Stat>>) {
      if (snapshot.value.length <= 1)
        return SliverFillRemaining(
          hasScrollBody: false,
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
              child: SingleStat(stat: generalStats),
            ),
          SliverLayoutBuilder(
            builder: (context, constraints) {
              return (constraints.crossAxisExtent <= 600)
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) => SingleStat(
                          key: ValueKey(index),
                          stat: stats[index],
                        ),
                        semanticIndexOffset: 1,
                        childCount: stats.length,
                      ),
                    )
                  : SliverGrid(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 360,
                        mainAxisSpacing: 8.0,
                        mainAxisExtent: 180,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) => SingleStat(
                          key: ValueKey(index),
                          stat: stats[index],
                        ),
                        semanticIndexOffset: 1,
                        childCount: stats.length,
                      ),
                    );
            },
          ),
        ],
      );
    }
    return const SliverToBoxAdapter();
  }
}
