import 'package:amiibo_network/page/home/controller/stats_amiibo_provider.dart';
import 'package:amiibo_network/page/home/widget/single_stat_progress_card.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sliver_tools/sliver_tools.dart';

class HomeBodyStats extends ConsumerWidget {
  const HomeBodyStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(statsProvider);
    if (snapshot case AsyncData(:final value)) {
      if (value.length <= 1) return SliverToBoxAdapter();
      final generalStats = value.first;
      final stats = value.sublist(1);
      return MultiSliver(
        children: [
          if (stats.length > 1)
            SliverToBoxAdapter(
              key: const Key('Amiibo Network'),
              child: SingleStatProgressCard(generalStats),
            ),
          SliverLayoutBuilder(
            builder: (context, constraints) {
              return (constraints.crossAxisExtent <= 600)
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) =>
                            SingleStatProgressCard(
                              stats[index],
                              key: ValueKey(index),
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
                        (BuildContext context, int index) =>
                            SingleStatProgressCard(
                              stats[index],
                              key: ValueKey(index),
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
