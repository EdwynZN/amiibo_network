import 'package:amiibo_network/enum/amiibo_category_enum.dart';
import 'package:amiibo_network/enum/selected_enum.dart';
import 'package:amiibo_network/model/amiibo.dart';
import 'package:amiibo_network/repository/theme_repository.dart';
import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:amiibo_network/riverpod/lock_provider.dart';
import 'package:amiibo_network/riverpod/query_provider.dart';
import 'package:amiibo_network/riverpod/screenshot_service.dart';
import 'package:amiibo_network/riverpod/select_provider.dart';
import 'package:amiibo_network/screen/search_screen.dart';
import 'package:amiibo_network/service/storage.dart';
import 'package:amiibo_network/widget/list_stats.dart';
import 'package:amiibo_network/widget/loading_grid_shimmer.dart';
import 'package:amiibo_network/widget/lock_icon.dart';
import 'package:amiibo_network/widget/route_transitions.dart';
import 'package:amiibo_network/widget/selected_chip.dart';
import 'package:amiibo_network/widget/selected_widget.dart';
import 'package:amiibo_network/widget/sort_bottomsheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:amiibo_network/data/database.dart';
import 'package:flutter/rendering.dart';
import 'package:amiibo_network/widget/drawer.dart';
import 'package:amiibo_network/widget/animated_widgets.dart';
import 'package:amiibo_network/widget/floating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/utils/preferences_constants.dart';
import 'package:amiibo_network/widget/markdown_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:amiibo_network/widget/stat_header.dart';
import 'package:amiibo_network/model/search_result.dart';

const String _amiiboIcon = 'assets/collection/icon_2.webp';

final AutoDisposeProvider<String>? _titleProvider =
    Provider.autoDispose<String>((ref) {
  final count = ref.watch(selectProvider);
  if (count.multipleSelected) return count.length.toString();
  final query = ref.watch(querySearchProvider);
  return query.search ?? describeEnum(query.category);
});

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
    if (_controller.hasClients && !_animationController.isAnimating &&
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
    Search? value = await Navigator.push<Search?>(
      context, 
      FadeRoute<Search>(builder: (_) => const SearchScreen()),
    );
    if (value?.search?.trim().isNotEmpty ?? false) {
      final query = ref.read(queryProvider.notifier);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        query.updateOption(value!);
        _restartAnimation();
      });
    }
  }

  Future<bool> _exitApp() async {
    final selected = ref.read(selectProvider);
    if (selected.multipleSelected) {
      selected.clearSelected();
      return false;
    } else {
      await ConnectionFactory().close();
      return await Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _exitApp,
      child: SafeArea(
        child: Scaffold(
          extendBody: true,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          resizeToAvoidBottomInset: false,
          drawer: CollectionDrawer(restart: _restartAnimation),
          body: HookConsumer(
            builder: (context, ref, child) {
              final _multipleSelection = ref.watch(
                selectProvider.select<bool>((value) => value.multipleSelected),
              );
              final expression =
                  ref.watch(queryProvider.select<Expression>((cb) => cb.where));
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
                      leading: Builder(
                        builder: (context) {
                          return IconButton(
                            icon: Hero(
                              tag: 'MenuButton',
                              child: ImplicitIcon(
                                key: Key('Menu'),
                                forward: _multipleSelection,
                              ),
                            ),
                            tooltip: _multipleSelection
                                ? localizations.cancelButtonLabel
                                : localizations.openAppDrawerTooltip,
                            onPressed: _multipleSelection
                                ? _cancelSelection
                                : () => Scaffold.of(context).openDrawer(),
                          );
                        },
                      ),
                      title: const _TitleAppBar(),
                      onTap: _multipleSelection ? null : _search,
                      trailing: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        layoutBuilder: _defaultLayoutBuilder,
                        child: index != 0
                            ? const SizedBox()
                            : _multipleSelection
                                ? const _SelectedOptions()
                                : const _DefaultOptions(),
                      ),
                    ),
                    const SliverPersistentHeader(
                      delegate: SliverStatsHeader(),
                      pinned: true,
                    ),
                    index == 0
                        ? const SliverPadding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            sliver: _AmiiboListWidget(),
                          )
                        : HomeBodyStats(expression),
                    const SliverPadding(
                      padding: EdgeInsets.symmetric(vertical: 48.0),
                    ),
                  ],
                ),
              );
            },
          ),
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
    final isCustom = ref.watch(queryProvider.notifier
        .select<bool>((cb) => cb.search.category == AmiiboCategory.Custom));
    final controller = useAnimationController(
      duration: const Duration(seconds: 1),
      animationBehavior: AnimationBehavior.preserve,
    );
    useMemoized(() {
      if (amiiboList is AsyncLoading<List<Amiibo>>)
        controller.repeat();
      else
        controller.forward();
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
              style: theme.textTheme.headline4!,
            );
          else
            child = TextButton.icon(
              style: theme.textButtonTheme.style?.copyWith(
                textStyle: MaterialStateProperty.all(theme.textTheme.headline4),
              ),
              onPressed: () async {
                final filter = ref.read(queryProvider.notifier);
                final List<String>? figures = filter.customFigures;
                final List<String>? cards = filter.customCards;
                bool save = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) => CustomQueryWidget(
                        translate.category(AmiiboCategory.Custom),
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
              icon: const Icon(Icons.create),
              label: Text(translate.emptyPage),
            );
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: child),
          );
        }
        late final SliverGridDelegate grid;
        final bool bigGrid = MediaQuery.of(context).size.width >= 600;
        if (bigGrid)
          grid = SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 192,
            mainAxisSpacing: 8.0,
          );
        else
          grid = SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8.0,
          );
        return SliverGrid(
          gridDelegate: grid,
          delegate: SliverChildBuilderDelegate(
            (BuildContext _, int index) {
              late final Widget child;
              if (data != null) {
                child = ProviderScope(
                  key: ValueKey<int?>(data[index].key),
                  overrides: [
                    indexAmiiboProvider.overrideWithValue(index),
                    keyAmiiboProvider.overrideWithValue(data[index].key),
                  ],
                  child: AnimatedSelection(ignore: ignore),
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

class _DefaultOptions extends StatelessWidget {
  const _DefaultOptions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: const <Widget>[
        LockButton(),
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
    final title = ref.watch(_titleProvider!);
    return Tooltip(
      message: num.tryParse(title) == null
          ? localizations.searchFieldLabel
          : localizations.selectedRowCountTitle(num.parse(title) as int),
      child: Text(translate.category(title)),
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
    final isLoading =
        ref.watch(screenshotProvider.select((value) => value is AsyncLoading));
    return SlideTransition(
      position: slide,
      child: ScaleTransition(
        scale: scale,
        child: FloatingActionButton(
          elevation: 0.0,
          child: isLoading
              ? ConstrainedBox(
                  constraints: BoxConstraints.loose(const Size.square(24.0)),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Theme.of(context)
                        .floatingActionButtonTheme
                        .foregroundColor,
                  ),
                )
              : const Icon(Icons.save),
          tooltip:
              isAmiibo ? translate.saveCollection : translate.saveStatsTooltip,
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
        ),
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
    return SlideTransition(
      position: slide,
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          iconSize: 24.0,
          selectedLabelStyle: const TextStyle(fontSize: 2.0),
          unselectedLabelStyle: const TextStyle(fontSize: 2.0),
          items: [
            BottomNavigationBarItem(
              icon: const ImageIcon(AssetImage(_amiiboIcon)),
              activeIcon: const ImageIcon(AssetImage(_amiiboIcon)),
              label: 'Amiibos',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.timeline),
              activeIcon: const Icon(Icons.timeline),
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