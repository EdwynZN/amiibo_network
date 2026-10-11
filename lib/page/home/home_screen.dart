import 'package:amiibo_network/app/configuration/analytics_provider.dart';
import 'package:amiibo_network/app/configuration/model/search_result.dart';
import 'package:amiibo_network/app/configuration/query_provider.dart';
import 'package:amiibo_network/app/state/collection/amiibo_user_collection_notifier.dart';
import 'package:amiibo_network/page/home/controller/select_provider.dart';
import 'package:amiibo_network/page/home/controller/stats_amiibo_provider.dart';
import 'package:amiibo_network/page/home/widget/drawer.dart';
import 'package:amiibo_network/page/home/widget/home_app_bar.dart';
import 'package:amiibo_network/page/home/widget/home_list_body.dart';
import 'package:amiibo_network/page/home/widget/list_stats.dart';
import 'package:amiibo_network/page/home/widget/screenshot_fab_widget.dart';
import 'package:amiibo_network/page/search/search_screen.dart';
import 'package:amiibo_network/shared/generated/l10n.dart';
import 'package:amiibo_network/shared/routes/route_transitions.dart';
import 'package:amiibo_network/shared/utils/preferences_constants.dart';
import 'package:amiibo_network/shared/utils/tablet_utils.dart';
import 'package:amiibo_network/shared/widget/dash_menu.dart';
import 'package:amiibo_network/shared/widget/markdown_widget.dart';
import 'package:flutter/rendering.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  late bool isTablet;

  void _restartAnimation() {
    if (!_controller.hasClients) return;
    _controller.jumpTo(0);
    _animationController.forward();
    ref.read(selectProvider.notifier).clearSelected();
  }

  void _cancelSelection() => ref.read(selectProvider.notifier).clearSelected();

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()..addListener(_scrollListener);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..value = 1.0;
    WidgetsBinding.instance.addPostFrameCallback((_) => _showWhatsNew());
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    isTablet = isHorizontalTablet(MediaQuery.of(context).size);
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

  Future<void> _exitApp(bool canPop, dynamic _) async {
    if (!canPop) {
      final selected = ref.read(selectProvider);
      final selectedNotif = ref.read(selectProvider.notifier);
      final query = ref.read(queryProvider.notifier);
      if (selected.isNotEmpty) {
        selectedNotif.clearSelected();
      } else if (ref.read(isSearchProvider)) {
        query.restart();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final route = ModalRoute.of(context);
    final canPopModalRoute =
        route != null && route.isCurrent && route.willHandlePopInternally;
    final canPop = canPopModalRoute || ref.watch(canPopProvider);

    final Widget statWidget = Material(
      key: const ValueKey<String>('ColumnStats'),
      type: .card,
      color: theme.colorScheme.surface,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      elevation: 2.0,
      child: Consumer(
        builder: (context, ref, child) {
          final hasStats = ref.watch(
            statsProvider.select((stats) {
              return stats.maybeWhen(
                data: (data) {
                  if (data.isEmpty) {
                    return false;
                  } else if (data.length == 1) {
                    return data.first.total != 0;
                  }
                  return false;
                },
                orElse: () => false,
              );
            }),
          );
          return Stack(
            fit: .passthrough,
            children: [
              child!,
              if (hasStats)
                Positioned(
                  right: 0.0,
                  bottom: 0.0,
                  child: Container(
                    margin: const .only(right: 16.0, bottom: 16.0),
                    alignment: .centerRight,
                    child: ScreenshotFabWidget(
                      animation: const AlwaysStoppedAnimation(1.0),
                      isAmiibo: false,
                    ),
                  ),
                ),
            ],
          );
        },
        child: const Positioned.fill(
          child: CustomScrollView(
            slivers: [
              SliverSafeArea(sliver: HomeBodyStats()),
              SliverGap(72.0),
            ],
          ),
        ),
      ),
    );

    final Widget body = PopScope(
      canPop: canPop,
      onPopInvokedWithResult: _exitApp,
      child: Consumer(
        builder: (context, ref, innerBody) {
          final hasAmiibos = ref.watch(
            amiiboUserCollectionProvider.select((amiiboList) {
              return amiiboList.maybeWhen(
                data: (data) => data.isNotEmpty,
                orElse: () => false,
              );
            }),
          );
          return Scaffold(
            key: const ValueKey<String>('AmiiboScaffoldBody'),
            resizeToAvoidBottomInset: false,
            drawer: isTablet
                ? CollectionDrawer(restart: _restartAnimation)
                : null,
            body: innerBody,
            floatingActionButtonLocation: .endFloat,
            floatingActionButton: hasAmiibos
                ? ScreenshotFabWidget(
                    animation: _animationController,
                    isAmiibo: true,
                  )
                : null,
          );
        },
        child: Scrollbar(
          controller: _controller,
          interactive: true,
          child: CustomScrollView(
            controller: _controller,
            slivers: [
              SliverHomeAppBar(
                isTablet: isTablet,
                onClose: _cancelSelection,
                onSearch: _search,
              ),
              const SliverPadding(
                padding: .symmetric(vertical: 12.0, horizontal: 4),
                sliver: HomeListBody(),
              ),
            ],
          ),
        ),
      ),
    );

    if (isTablet) {
      return Row(
        children: [
          Expanded(child: body),
          SizedBox(width: 350, child: statWidget),
        ],
      );
    }

    return DashMenu(
      leftDrawer: CollectionDrawer(restart: _restartAnimation),
      rightDrawer: statWidget,
      body: body,
    );
  }
}
