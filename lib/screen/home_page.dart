import 'package:amiibo_network/enum/amiibo_category_enum.dart';
import 'package:amiibo_network/enum/selected_enum.dart';
import 'package:amiibo_network/model/amiibo.dart';
import 'package:amiibo_network/repository/theme_repository.dart';
import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:amiibo_network/riverpod/lock_provider.dart';
import 'package:amiibo_network/riverpod/query_provider.dart';
import 'package:amiibo_network/riverpod/select_provider.dart';
import 'package:amiibo_network/utils/routes_constants.dart';
import 'package:amiibo_network/widget/loading_grid_shimmer.dart';
import 'package:amiibo_network/widget/lock_icon.dart';
import 'package:amiibo_network/widget/selected_chip.dart';
import 'package:amiibo_network/widget/selected_widget.dart';
import 'package:amiibo_network/widget/sort_bottomsheet.dart';
import 'package:amiibo_network/widget/stat_icon.dart';
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

final AutoDisposeProvider<String>? _titleProvider =
    Provider.autoDispose<String>((ref) {
  final count = ref.watch(selectProvider);
  if (count.multipleSelected) return count.length.toString();
  final query = ref.watch(querySearchProvider);
  return query.search ?? describeEnum(query.category);
});

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => HomeState();
}

class HomeState extends ConsumerState<Home> with SingleTickerProviderStateMixin {
  ScrollController? _controller;
  AnimationController? _animationController;
  late S translate;
  late MaterialLocalizations localizations;
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
    _controller!.jumpTo(0);
    _animationController!.forward();
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
    WidgetsBinding.instance!.addPostFrameCallback((_) => _showWhatsNew());
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    translate = S.of(context);
    localizations = MaterialLocalizations.of(context);
  }

  @override
  void dispose() {
    _controller?.removeListener(_scrollListener);
    _controller?.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if ((_controller?.hasClients ?? false) &&
        !_animationController!.isAnimating &&
        _controller!.offset > 56.0) {
      switch (_controller!.position.userScrollDirection) {
        case ScrollDirection.forward:
          if (_animationController!.isDismissed)
            _animationController!.forward();
          break;
        case ScrollDirection.reverse:
          if (_animationController!.isCompleted)
            _animationController!.reverse();
          break;
        case ScrollDirection.idle:
          break;
      }
    }
  }

  Future<void> _showWhatsNew() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final int version = preferences.getInt(sharedVersion) ?? 0;
    if (version != versionApp) {
      await preferences.setInt(sharedVersion, versionApp);
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
    Search? value = await Navigator.pushNamed<Search?>(context, searchRoute);
    if (value?.search?.trim().isNotEmpty ?? false) {
      final query = ref.read(queryProvider.notifier);
      WidgetsBinding.instance!.addPostFrameCallback((_) {
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
        child: HookConsumer(
          builder: (_, ref, child) {
            final _multipleSelection = ref.watch(
                selectProvider.select<bool>((value) => value.multipleSelected));
            return Scaffold(
              resizeToAvoidBottomInset: false,
              drawer: _multipleSelection
                  ? null
                  : CollectionDrawer(restart: _restartAnimation),
              body: Scrollbar(
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
                        child: _multipleSelection
                            ? const _SelectedOptions()
                            : const _DefaultOptions(),
                      ),
                    ),
                    const SliverPersistentHeader(
                      delegate: SliverStatsHeader(),
                      pinned: true,
                    ),
                    const SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      sliver: _AmiiboListWidget(),
                    ),
                  ],
                ),
              ),
              floatingActionButton: FAB(
                _animationController!,
                () => _controller!.jumpTo(0),
              ),
            );
          },
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
                  await ref.read(queryProvider.notifier)
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
        return SliverIgnorePointer(
          ignoring: ignore,
          sliver: SliverGrid(
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
                    child: const AnimatedSelection(),
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
      children: <Widget>[
        const LockButton(),
        const StatButton(),
        const SortCollection(),
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

class FAB extends StatelessWidget {
  final Animation<double> scale;
  final AnimationController controller;
  final VoidCallback goTop;

  FAB(this.controller, this.goTop)
      : scale = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: controller,
          curve: Interval(0.0, 1, curve: Curves.decelerate),
        ));

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scale,
      child: FloatingActionButton(
        tooltip: S.of(context).upToolTip,
        heroTag: 'MenuFAB',
        onPressed: goTop,
        child: const Icon(Icons.keyboard_arrow_up, size: 36),
      ),
    );
  }
}
