import 'package:amiibo_network/enum/amiibo_category_enum.dart';
import 'package:amiibo_network/enum/selected_enum.dart';
import 'package:amiibo_network/model/amiibo.dart';
import 'package:amiibo_network/model/title_search.dart';
import 'package:amiibo_network/repository/theme_repository.dart';
import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:amiibo_network/riverpod/analytics._provider.dart';
import 'package:amiibo_network/riverpod/lock_provider.dart';
import 'package:amiibo_network/riverpod/preferences_provider.dart';
import 'package:amiibo_network/riverpod/query_provider.dart';
import 'package:amiibo_network/riverpod/screenshot_service.dart';
import 'package:amiibo_network/riverpod/select_provider.dart';
import 'package:amiibo_network/screen/search_screen.dart';
import 'package:amiibo_network/service/storage.dart';
import 'package:amiibo_network/widget/dash_menu/dash_menu.dart';
import 'package:amiibo_network/widget/list_stats.dart';
import 'package:amiibo_network/widget/loading_grid_shimmer.dart';
import 'package:amiibo_network/widget/lock_icon.dart';
import 'package:amiibo_network/widget/preferences_bottomsheet.dart';
import 'package:amiibo_network/widget/route_transitions.dart';
import 'package:amiibo_network/widget/selected_chip.dart';
import 'package:amiibo_network/widget/selected_widget.dart';
import 'package:amiibo_network/widget/sort_bottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:amiibo_network/widget/drawer.dart';
import 'package:amiibo_network/widget/animated_widgets.dart';
import 'package:amiibo_network/widget/floating_bar.dart';
import 'package:gap/gap.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/utils/preferences_constants.dart';
import 'package:amiibo_network/widget/markdown_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:amiibo_network/widget/stat_header.dart';
import 'package:amiibo_network/model/search_result.dart';

const String _amiiboIcon = 'assets/collection/icon_2.webp';

final AutoDisposeProvider<TitleSearch> _titleProvider =
    Provider.autoDispose<TitleSearch>((ref) {
  final count = ref.watch(selectProvider);
  final query = ref.watch(queryProvider);
  final category = query.categoryAttributes.category;
  if (count.multipleSelected) {
    return TitleSearch.count(
      title: count.length.toString(),
      category: category,
    );
  }
  final provider = ref.watch(queryProvider.notifier);
  if (provider.isSearch) {
    return TitleSearch.search(
      title: query.searchAttributes!.search,
      searchCategory: query.searchAttributes!.category,
      category: category,
    );
  }
  return TitleSearch(
    title: switch (category) {
      AmiiboCategory.Cards
          when query.categoryAttributes.cards.firstOrNull != null =>
        query.categoryAttributes.cards.first,
      AmiiboCategory.Figures
          when query.categoryAttributes.figures.firstOrNull != null =>
        query.categoryAttributes.figures.first,
      _ => category.name,
    },
    category: category,
  );
});

final AutoDisposeProvider<bool> _canPopProvider = Provider.autoDispose<bool>(
  (ref) {
    final selected = ref.watch(selectProvider);
    ref.watch(queryProvider);
    final isSearch = ref.watch(
      queryProvider.notifier.select((provider) => provider.isSearch),
    );
    return !(selected.multipleSelected || isSearch);
  },
);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final ScrollController _controller;
  late final AnimationController _animationController;
  late S translate;
  late MaterialLocalizations localizations;
  int index = 0;
  static Widget _defaultLayoutBuilder(
      Widget? currentChild, List<Widget> previousChildren) {
    List<Widget> children = previousChildren;
    if (currentChild != null) children = children.toList()..add(currentChild);
    return Stack(
      children: children,
      alignment: Alignment.centerRight,
    );
  }

  void _restartAnimation() {
    if (!_controller.hasClients) return;
    _controller.jumpTo(0);
    _animationController.forward();
    ref.read(selectProvider).clearSelected();
  }

  void _cancelSelection() => ref.read(selectProvider).clearSelected();

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()..addListener(_scrollListener);
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this)
      ..value = 1.0;
    WidgetsBinding.instance.addPostFrameCallback((_) => _showWhatsNew());
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    translate = S.of(context);
    localizations = MaterialLocalizations.of(context);
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollListener);
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_controller.hasClients &&
        !_animationController.isAnimating &&
        _controller.offset > 56.0) {
      switch (_controller.position.userScrollDirection) {
        case ScrollDirection.forward:
          if (_animationController.isDismissed) _animationController.forward();
          break;
        case ScrollDirection.reverse:
          if (_animationController.isCompleted) _animationController.reverse();
          break;
        case ScrollDirection.idle:
          break;
      }
    }
  }

  Future<void> _showWhatsNew() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final int? version = preferences.getInt(sharedVersion);
    if (version != versionApp) {
      await preferences.setInt(sharedVersion, versionApp);
      if (version != null)
        showDialog(
          context: context,
          builder: (context) => MarkdownReader(
            file: translate.changelog.replaceAll(' ', '_'),
            title: translate.changelogSubtitle,
          ),
        );
    }
  }

  Future<void> _search() async {
    SearchAttributes? search = await Navigator.push<SearchAttributes?>(
      context,
      FadeRoute<SearchAttributes>(builder: (_) => const SearchScreen()),
    );
    if (search != null) {
      ref.read(analyticsProvider).logSearch(search.search);
      final query = ref.read(queryProvider.notifier);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        query.updateOption(search);
        _restartAnimation();
      });
    }
  }

  Future<void> _exitApp(bool canPop) async {
    if (!canPop) {
      final selected = ref.read(selectProvider);
      final query = ref.read(queryProvider.notifier);
      if (selected.multipleSelected) {
        selected.clearSelected();
      } else if (query.isSearch) {
        query.restart();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAmiiboList = index == 0;
    final canPop = ref.watch(_canPopProvider);
    return DashMenu(
      leftDrawer: CollectionDrawer(restart: _restartAnimation),
      body: PopScope(
        canPop: canPop,
        onPopInvoked: _exitApp,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          //drawer: CollectionDrawer(restart: _restartAnimation),
          body: HookConsumer(
            builder: (context, ref, child) {
              final _multipleSelection = ref.watch(
                selectProvider.select<bool>((value) => value.multipleSelected),
              );
              return Scrollbar(
                controller: _controller,
                interactive: true,
                child: CustomScrollView(
                  controller: _controller,
                  slivers: <Widget>[
                    SliverFloatingBar(
                      floating: true,
                      forward: _multipleSelection,
                      snap: true,
                      leading: _Leading(
                        isClose: _multipleSelection,
                        onClose: _cancelSelection,
                      ),
                      title: const _TitleAppBar(),
                      onTap: _multipleSelection ? null : _search,
                      trailing: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        layoutBuilder: _defaultLayoutBuilder,
                        child: !isAmiiboList
                            ? const PreferencesButton()
                            : _multipleSelection
                                ? const _SelectedOptions()
                                : const _DefaultOptions(),
                      ),
                    ),
                    if (isAmiiboList) ...[
                      Builder(
                        builder: (context) {
                          return SliverPersistentHeader(
                            delegate: SliverStatsHeader(
                              topPadding: MediaQuery.of(context).padding.top,
                              hideOptional: isAmiiboList,
                            ),
                            pinned: true,
                          );
                        },
                      ),
                      const SliverPadding(
                        padding: EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 4,
                        ),
                        sliver: _AmiiboListWidget(),
                      ),
                    ] else
                      const HomeBodyStats(),
                    const SliverPadding(
                      padding: EdgeInsets.only(bottom: 96.0),
                    ),
                  ],
                ),
              );
            },
          ),
          extendBody: true,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: _FAB(
            animationController: _animationController,
            index: index,
          ),
          bottomNavigationBar: _BottomBar(
            animationController: _animationController,
            index: index,
            onTap: (selected) => setState(() {
              index = selected;
              _controller.jumpTo(0);
              ref.read(selectProvider.notifier).clearSelected();
            }),
          ),
        ),
      ),
    );
  }
}

class _AmiiboListWidget extends HookConsumerWidget {
  const _AmiiboListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ignore = ref.watch(lockProvider).lock;
    final amiiboList = ref.watch(amiiboHomeListProvider);
    final isCustom = ref.watch(queryProvider.select<bool>(
        (cb) => cb.categoryAttributes.category == AmiiboCategory.AmiiboSeries));
    final controller = useAnimationController(
      duration: const Duration(seconds: 1),
      animationBehavior: AnimationBehavior.preserve,
    );
    useEffect(() {
      if (amiiboList is AsyncLoading<List<Amiibo>>)
        controller.repeat();
      else
        controller.forward();
      return null;
    }, [amiiboList]);
    return amiiboList.maybeWhen(
      error: (_, __) => const SliverToBoxAdapter(),
      orElse: () {
        late final List<Amiibo>? data;
        if (amiiboList is AsyncData<List<Amiibo>>)
          data = amiiboList.value;
        else
          data = null;
        if (data != null && data.isEmpty) {
          late final Widget child;
          final theme = Theme.of(context);
          final S translate = S.of(context);
          if (!isCustom)
            child = Text(
              translate.emptyPage,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium!,
            );
          else
            child = Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    translate.emptyPage,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  const Gap(24.0),
                  ElevatedButton.icon(
                    style: theme.textButtonTheme.style?.copyWith(
                      textStyle: MaterialStateProperty.all(
                          theme.textTheme.headlineMedium),
                    ),
                    onPressed: () async {
                      final filter = ref.read(queryProvider.notifier);
                      final List<String> figures = filter.customFigures;
                      final List<String> cards = filter.customCards;
                      bool save = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) =>
                                CustomQueryWidget(
                              translate.category(AmiiboCategory.AmiiboSeries),
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
                    icon: const Icon(Icons.create_outlined),
                    label: Text(translate.emptyPageAction),
                  ),
                ],
              ),
            );
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: child),
          );
        }
        final useGrid = ref.watch(personalProvider.select((p) => p.useGrid));
        if (!useGrid) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext _, int index) {
                late final Widget child;
                if (data != null) {
                  final amiibo = data[index];
                  child = AnimatedSelectedListTile(
                    amiibo: amiibo,
                    ignore: ignore,
                  );
                } else {
                  child = ShimmerCard(listenable: controller, isGrid: false);
                }
                return ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 104.0,
                    minHeight: 72.0,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(seconds: 1),
                    child: child,
                  ),
                );
              },
              childCount: data != null ? data.length : null,
            ),
          );
        }

        late final SliverGridDelegate grid;
        final bool bigGrid = MediaQuery.of(context).size.width >= 600;
        if (bigGrid)
          grid = const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 192.0,
            mainAxisSpacing: 8.0,
          );
        else
          grid = const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8.0,
            mainAxisExtent: 192.0,
          );
        return SliverGrid(
          gridDelegate: grid,
          delegate: SliverChildBuilderDelegate(
            (BuildContext _, int index) {
              late final Widget child;
              if (data != null) {
                final amiibo = data[index];
                child = AnimatedSelection(
                  key: ValueKey<int?>(amiibo.key),
                  ignore: ignore,
                  amiibo: amiibo,
                );
              } else {
                child = ShimmerCard(listenable: controller);
              }
              return AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                child: child,
              );
            },
            childCount: data != null ? data.length : null,
          ),
        );
      },
    );
  }
}

class _Leading extends HookConsumerWidget {
  final bool isClose;
  final VoidCallback onClose;

  const _Leading({
    // ignore: unused_element
    super.key,
    required this.isClose,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = MaterialLocalizations.of(context);
    final searchSelect = ref.watch(
      queryProvider.select<bool>((q) => q.searchAttributes != null),
    );
    final isForward = searchSelect || isClose;
    final effectiveSearch = searchSelect && !isClose;
    final HeroFlightShuttleBuilder flightShuttleBuilder =
        useCallback<HeroFlightShuttleBuilder>((
      BuildContext flightContext,
      Animation<double> animation,
      HeroFlightDirection flightDirection,
      BuildContext fromHeroContext,
      BuildContext toHeroContext,
    ) {
      if (isForward) {
        return AnimatedBuilder(
          animation: animation,
          child: flightDirection == HeroFlightDirection.push
              ? const Icon(Icons.arrow_back)
              : const Icon(Icons.close),
          builder: (context, child) {
            return Opacity(
              opacity: flightDirection == HeroFlightDirection.push
                  ? animation.value
                  : 1 - animation.value,
              child: child,
            );
          },
        );
      }

      return AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: animation,
      );
    }, [isForward]);
    final VoidCallback onPressed = useCallback(() {
      if (effectiveSearch) {
        ref.read(queryProvider.notifier).restart();
      } else if (isClose) {
        onClose();
      } else {
        DashMenu.of(context).openDrawer();
      }
    }, [effectiveSearch, isClose, onClose]);
    final icon = ImplicitIcon(key: const Key('Menu'), forward: isForward);
    return IconButton(
      icon: Hero(
        key: const Key('HeroMenu'),
        flightShuttleBuilder: flightShuttleBuilder,
        tag: 'MenuButton',
        child: icon,
      ),
      tooltip: effectiveSearch
          ? localizations.closeButtonTooltip
          : isClose
              ? localizations.cancelButtonLabel
              : localizations.openAppDrawerTooltip,
      onPressed: onPressed,
    );
  }
}

class _DefaultOptions extends StatelessWidget {
  const _DefaultOptions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: const <Widget>[
        LockButton(),
        PreferencesButton(),
        SortCollection(),
      ],
    );
  }
}

class _TitleAppBar extends ConsumerWidget {
  const _TitleAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final S translate = S.of(context);
    final searchTitle = ref.watch(_titleProvider);
    final Widget child;
    final InlineSpan title =
        TextSpan(text: translate.category(searchTitle.title));
    InlineSpan? categorySpan;
    if (searchTitle is TitleSearchCategory) {
      final theme = Theme.of(context);
      final size = theme.appBarTheme.toolbarTextStyle?.fontSize;
      final foreground = theme.colorScheme.onSecondaryContainer;
      categorySpan = WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        baseline: TextBaseline.ideographic,
        child: Card(
          elevation: 12.0,
          margin: const EdgeInsets.only(right: 4.0),
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(4.0)),
            side: BorderSide(color: theme.primaryColor),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 2.0,
              horizontal: 4.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search, size: size, color: foreground),
                const SizedBox(width: 2.0),
                Text(
                  translate.searchCategory(searchTitle.searchCategory),
                  style: TextStyle(
                    fontSize: size,
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final message = switch (searchTitle) {
      TitleCount(title: final title) =>
        localizations.selectedRowCountTitle(num.parse(title) as int),
      TitleSearchCategory() => localizations.searchFieldLabel,
      TitleCategory(category: final category) => translate.category(category),
    };
    child = Text.rich(
      categorySpan != null ? TextSpan(children: [categorySpan, title]) : title,
    );
    return Tooltip(
      message: message,
      child: child,
    );
  }
}

class _SelectedOptions extends ConsumerWidget {
  const _SelectedOptions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S translate = S.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () =>
              ref.read(selectProvider).updateAmiibos(SelectedType.Clear),
          tooltip: translate.removeTooltip,
        ),
        IconButton(
          icon: const Icon(iconOwned),
          onPressed: () =>
              ref.read(selectProvider).updateAmiibos(SelectedType.Owned),
          tooltip: translate.ownTooltip,
        ),
        IconButton(
          icon: const Icon(iconWished),
          onPressed: () =>
              ref.read(selectProvider).updateAmiibos(SelectedType.Wished),
          tooltip: translate.wishTooltip,
        ),
      ],
    );
  }
}

class _FAB extends ConsumerWidget {
  final bool isAmiibo;
  final Animation<double> scale;
  final Animation<Offset> slide;

  _FAB({
    // ignore: unused_element
    super.key,
    required AnimationController animationController,
    required int index,
  })  : scale = Tween<double>(begin: 0.25, end: 1.0).animate(CurvedAnimation(
          parent: animationController,
          curve: Interval(0.25, 1.0, curve: Curves.decelerate),
        )),
        slide = Tween<Offset>(begin: const Offset(0.0, 2.0), end: Offset.zero)
            .animate(CurvedAnimation(
          parent: animationController,
          curve: Interval(0.0, 1),
        )),
        isAmiibo = index == 0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S translate = S.of(context);
    final theme = Theme.of(context);
    final isLoading =
        ref.watch(screenshotProvider.select((value) => value is AsyncLoading));
    final fab = FloatingActionButton(
      elevation: 0.0,
      child: isLoading
          ? ConstrainedBox(
              constraints: BoxConstraints.loose(const Size.square(24.0)),
              child: LoadingAnimationWidget.inkDrop(
                color: theme.floatingActionButtonTheme.foregroundColor ??
                    theme.colorScheme.onSecondaryContainer,
                size: 24,
              ),
            )
          : const Icon(Icons.save),
      tooltip: isAmiibo ? translate.saveCollection : translate.saveStatsTooltip,
      heroTag: 'MenuFAB',
      onPressed: () async {
        final _screenshotProvider = ref.watch(screenshotProvider.notifier);
        final scaffoldState = ScaffoldMessenger.of(context);
        if (!(await permissionGranted(scaffoldState))) return;
        final isLoading = _screenshotProvider.isLoading;
        final message = isLoading
            ? translate.recordMessage
            : translate.savingCollectionMessage;
        scaffoldState
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
        if (isLoading) return;
        if (isAmiibo) {
          await _screenshotProvider.saveAmiibos(context);
        } else {
          await _screenshotProvider.saveStats(context);
        }
      },
    );
    return SlideTransition(
      position: slide,
      child: ScaleTransition(
        scale: scale,
        child: fab,
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final Animation<Offset> slide;
  final ValueChanged<int> onTap;
  final int index;

  _BottomBar({
    // ignore: unused_element
    super.key,
    required AnimationController animationController,
    required this.onTap,
    required this.index,
  }) : slide = Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero)
            .animate(CurvedAnimation(
          parent: animationController,
          curve: Interval(0.0, 1),
        ));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SlideTransition(
      position: slide,
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        elevation: 0.0,
        color: theme.appBarTheme.systemOverlayStyle?.systemNavigationBarColor,
        clipBehavior: Clip.hardEdge,
        child: BottomNavigationBar(
          showSelectedLabels: true,
          showUnselectedLabels: false,
          elevation: 0.0,
          backgroundColor:
              theme.appBarTheme.systemOverlayStyle?.systemNavigationBarColor,
          iconSize: 20.0,
          selectedLabelStyle: const TextStyle(fontSize: 11.0),
          unselectedLabelStyle: const TextStyle(fontSize: 11.0),
          items: [
            BottomNavigationBarItem(
              icon: const ImageIcon(AssetImage(_amiiboIcon)),
              activeIcon: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                decoration: ShapeDecoration(
                  shape: const StadiumBorder(),
                  color: theme.colorScheme.secondaryContainer,
                ),
                child: const ImageIcon(AssetImage(_amiiboIcon)),
              ),
              label: 'Amiibos',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.timeline),
              activeIcon: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                decoration: ShapeDecoration(
                  shape: const StadiumBorder(),
                  color: theme.colorScheme.secondaryContainer,
                ),
                child: const Icon(Icons.timeline),
              ),
              label: S.of(context).stats,
            ),
          ],
          currentIndex: index,
          onTap: onTap,
        ),
      ),
    );
  }
}
