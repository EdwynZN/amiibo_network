import 'dart:async';

import 'package:amiibo_network/enum/amiibo_category_enum.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/model/search_result.dart';
import 'package:amiibo_network/model/stat.dart';
import 'package:amiibo_network/riverpod/preferences_provider.dart';
import 'package:amiibo_network/riverpod/query_provider.dart';
import 'package:amiibo_network/riverpod/screenshot_service.dart';
import 'package:amiibo_network/riverpod/service_provider.dart';
import 'package:amiibo_network/service/storage.dart';
import 'package:amiibo_network/widget/single_stat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _statsProvider = StreamProvider.autoDispose
    .family<List<Stat>, AmiiboCategory>((ref, category) {
  final service = ref.watch(serviceProvider.notifier);
  final query = ref.watch(queryProvider.notifier);
  final hidden = ref.watch(hiddenCategoryProvider);
  final streamController = StreamController<AmiiboCategory>()
    ..sink.add(category);

  void listener() => streamController.sink.add(category);

  service.addListener(listener);

  ref.onDispose(() {
    service.removeListener(listener);
    streamController.close();
  });

  return streamController.stream.asyncMap(
    (cb) async => <Stat>[
      ...await service.fetchStats(
        category: cb,
        cards: query.customCards,
        figures: query.customCards,
        hiddenCategories: hidden,
      ),
      ...await service.fetchStats(
        group: true,
        category: cb,
        cards: query.customCards,
        figures: query.customCards,
        hiddenCategories: hidden,
      )
    ],
  );
});

class StatsPage extends StatefulHookConsumerWidget {
  const StatsPage({Key? key}) : super(key: key);

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage> {
  AmiiboCategory category = AmiiboCategory.All;
  S? translate;
  late Size size;

  @override
  void didChangeDependencies() {
    translate = S.of(context);
    size = MediaQuery.of(context).size;
    super.didChangeDependencies();
  }

  void _updateCategory(AmiiboCategory newCategory) {
    if (newCategory == category) return;
    setState(() {
      category = newCategory;
      /* switch (category) {
        case AmiiboCategory.All:
          expression = And();
          break;
        case AmiiboCategory.Custom:
          final query = ref.read(queryProvider.notifier);
          expression = Bracket(InCond.inn('type', figureType) &
                  InCond.inn('amiiboSeries', query.customFigures)) |
              Bracket(Cond.eq('type', 'Card') &
                  InCond.inn('amiiboSeries', query.customCards));
          break;
        case AmiiboCategory.Figures:
          expression = InCond.inn('type', figureType);
          break;
        case AmiiboCategory.Cards:
          expression = Cond.eq('type', 'Card');
          break;
        default:
          break;
      } */
    });
  }

  @override
  Widget build(BuildContext context) {
    final _canSave = ref.watch(
      queryProvider.select<bool>((value) =>
          AmiiboCategory.Custom != category ||
          value.customFigures.isNotEmpty ||
          value.customCards.isNotEmpty),
    );
    if (size.longestSide >= 800)
      return SafeArea(
        child: Scaffold(
          body: Scrollbar(
            child: Row(
              children: <Widget>[
                NavigationRail(
                  destinations: <NavigationRailDestination>[
                    NavigationRailDestination(
                      icon: const Icon(Icons.all_inclusive),
                      label: Text(translate!.all),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.edit_outlined),
                      selectedIcon: const Icon(Icons.edit),
                      label: Text(translate!.category(AmiiboCategory.Custom)),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.sports_esports_outlined),
                      selectedIcon: const Icon(Icons.sports_esports),
                      label: Text(translate!.figures),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.view_carousel_outlined),
                      selectedIcon: const Icon(Icons.view_carousel),
                      label: Text(translate!.cards),
                    )
                  ],
                  selectedIndex: category.index,
                  trailing: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: SizeTransition(
                            sizeFactor: animation,
                            child: child,
                          ),
                        );
                      },
                      child: _canSave ? _FAB(category) : const SizedBox(),
                    ),
                  ),
                  onDestinationSelected: (selected) =>
                      _updateCategory(AmiiboCategory.values[selected]),
                ),
                Expanded(child: BodyStats(category))
              ],
            ),
          ),
        ),
      );
    return SafeArea(
      child: Scaffold(
        body: BodyStats.expanded(category),
        floatingActionButton: _canSave ? _FAB(category) : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        extendBody: true,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: _canSave
                ? const EdgeInsetsDirectional.only(end: 64)
                : EdgeInsets.zero,
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.all_inclusive_outlined),
                  activeIcon: const Icon(Icons.all_inclusive_sharp),
                  label: translate!.all,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.edit_outlined),
                  activeIcon: const Icon(Icons.edit),
                  label: translate!.category(AmiiboCategory.Custom),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.sports_esports_outlined),
                  activeIcon: const Icon(Icons.sports_esports),
                  label: translate!.figures,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.view_carousel_outlined),
                  activeIcon: const Icon(Icons.view_carousel),
                  label: translate!.cards,
                )
              ],
              currentIndex: category.index,
              onTap: (selected) =>
                  _updateCategory(AmiiboCategory.values[selected]),
            ),
          ),
        ),
      ),
    );
  }
}

AsyncValue<List<Stat>> _usePreviousStat(
    WidgetRef ref, AmiiboCategory category) {
  final snapshot = ref.watch(_statsProvider(category));
  final previous = usePrevious(snapshot);
  if (previous is AsyncData<List<Stat>> && snapshot is! AsyncData<List<Stat>>)
    return previous;
  return snapshot;
}

class BodyStats extends HookConsumerWidget {
  final AmiiboCategory category;
  final bool expanded;

  BodyStats(this.category) : expanded = false;
  BodyStats.expanded(this.category) : expanded = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S translate = S.of(context);
    final snapshot = _usePreviousStat(ref, category);
    if (snapshot is AsyncData<List<Stat>>) {
      if (snapshot.value.length <= 1)
        return Center(
          child: Text(
            translate.emptyPage,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        );

      final Stat generalStats = snapshot.value.first;
      final List<Stat> stats = snapshot.value.sublist(1);
      return Scrollbar(
        child: CustomScrollView(
          slivers: <Widget>[
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
            if (MediaQuery.of(context).size.width <= 600)
              SliverList(
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
              ),
            if (MediaQuery.of(context).size.width > 600)
              SliverGrid(
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
              ),
            if (expanded)
              const SliverToBoxAdapter(child: SizedBox(height: 92.0))
          ],
        ),
      );
    }
    return const SizedBox();
  }
}

class _FAB extends ConsumerWidget {
  final AmiiboCategory _category;

  _FAB(this._category);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S translate = S.of(context);
    final isLoading =
        ref.watch(screenshotProvider.select((value) => value.isLoading));
    return FloatingActionButton(
      elevation: 0.0,
      child: const Icon(Icons.save),
      tooltip: translate.saveStatsTooltip,
      heroTag: 'MenuFAB',
      onPressed: isLoading ? null : () async {
        final ScaffoldMessengerState scaffoldState =
            ScaffoldMessenger.of(context);
        if (!(await permissionGranted(scaffoldState))) return;
        String message = translate.savingCollectionMessage;
        final _screenshot = ref.read(screenshotProvider.notifier);
        if (_screenshot.isLoading) message = translate.recordMessage;
        scaffoldState.hideCurrentSnackBar();
        scaffoldState.showSnackBar(SnackBar(content: Text(message)));
        if (!_screenshot.isLoading) {
          await _screenshot.saveStats(
            context,
            search: Search(
              categoryAttributes: CategoryAttributes(category: _category),
            ),
          );
        }
      },
    );
  }
}
