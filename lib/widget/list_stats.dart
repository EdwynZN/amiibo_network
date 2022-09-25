import 'dart:async';

import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/model/search_result.dart';
import 'package:amiibo_network/model/stat.dart';
import 'package:amiibo_network/riverpod/service_provider.dart';
import 'package:amiibo_network/widget/single_stat.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

final _statsProvider =
    StreamProvider.autoDispose.family<List<Stat>, Expression>((ref, exp) {
  final service = ref.watch(serviceProvider.notifier);
  final streamController = StreamController<Expression>()..sink.add(exp);

  void listener() => streamController.sink.add(exp);

  service.addListener(listener);

  ref.onDispose(() {
    service.removeListener(listener);
    streamController.close();
  });

  return streamController.stream.asyncMap(
    (cb) async => <Stat>[
      ...await service.fetchStats(expression: cb),
      ...await service.fetchStats(group: true, expression: cb)
    ],
  );
});

AsyncValue<List<Stat>> _usePreviousStat(WidgetRef ref, Expression expression) {
  final snapshot = ref.watch(_statsProvider(expression));
  final previous = usePrevious(snapshot);
  if (previous is AsyncData<List<Stat>> && snapshot is! AsyncData<List<Stat>>)
    return previous;
  return snapshot;
}

class HomeBodyStats extends HookConsumerWidget {
  final Expression expression;

  HomeBodyStats(this.expression, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S translate = S.of(context);
    final snapshot = _usePreviousStat(ref, expression);
    if (snapshot is AsyncData<List<Stat>>) {
      final List<Stat> stats = snapshot.value.sublist(1);
      if (stats.length < 1)
        return SliverToBoxAdapter(
          child: Center(
            child: Text(
              translate.emptyPage,
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
        );
      return (MediaQuery.of(context).size.width <= 600)
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
            );
    }
    return const SliverToBoxAdapter();
  }
}
