import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class SliverFloatingBar extends StatefulWidget {
  final bool pinned;
  final bool floating;
  final bool snap;
  final bool forward;
  final Widget? trailing;
  final Widget? leading;
  final Widget? title;
  final double? elevation;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const SliverFloatingBar({
    Key? key,
    this.pinned = false,
    this.floating = false,
    this.snap = false,
    this.forward = false,
    this.elevation,
    this.title,
    this.leading,
    this.trailing,
    this.onTap,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SliverFloatingBarState();
}

class _SliverFloatingBarState extends State<SliverFloatingBar>
    with TickerProviderStateMixin {
  FloatingHeaderSnapConfiguration? _snapConfiguration;

  void _updateSnapConfiguration() {
    if (widget.snap)
      _snapConfiguration = FloatingHeaderSnapConfiguration(
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 200),
      );
    else
      _snapConfiguration = null;
  }

  @override
  void initState() {
    super.initState();
    _updateSnapConfiguration();
  }

  @override
  void didUpdateWidget(SliverFloatingBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateSnapConfiguration();
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final double collapsedHeight = kToolbarHeight + topPadding;
    return MediaQuery.removePadding(
      context: context,
      removeBottom: true,
      child: SliverPersistentHeader(
        floating: widget.floating,
        pinned: widget.pinned,
        delegate: _SliverFloatingPersistentHeader(
          vsync: this,
          topPadding: topPadding,
          collapsedHeight: collapsedHeight,
          pinned: widget.pinned,
          snap: widget.forward,
          floating: widget.floating,
          snapConfiguration: _snapConfiguration,
          leading: widget.leading,
          title: widget.title,
          trailing: widget.trailing,
          onTap: widget.onTap,
          elevation: widget.elevation,
          backgroundColor: widget.backgroundColor ??
              Theme.of(context).appBarTheme.backgroundColor,
        ),
      ),
    );
  }
}

class _SliverFloatingPersistentHeader extends SliverPersistentHeaderDelegate {
  final double collapsedHeight;
  final double topPadding;
  final bool floating;
  final bool snap;
  final bool pinned;
  final double? elevation;
  final Widget? trailing;
  final Widget? leading;
  final Widget? title;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const _SliverFloatingPersistentHeader({
    required this.topPadding,
    required this.collapsedHeight,
    required this.elevation,
    required this.pinned,
    required this.floating,
    this.vsync,
    this.snap = false,
    this.snapConfiguration,
    this.trailing,
    this.leading,
    this.title,
    this.onTap,
    this.backgroundColor,
  }) : super();

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double extraToolbarHeight =
        math.max(minExtent - topPadding - kToolbarHeight, 0.0);
    final double visibleMainHeight = maxExtent - shrinkOffset;
    final bool isPinnedWithOpacityFade = false;
    final double visibleToolbarHeight = visibleMainHeight - extraToolbarHeight;
    final double toolbarOpacity = !pinned || isPinnedWithOpacityFade
        ? clampDouble(visibleToolbarHeight / kToolbarHeight, 0.0, 1.0)
        : 1.0;
    final bool isScrolledUnder =
        overlapsContent || (pinned && shrinkOffset > maxExtent - minExtent);
    return FlexibleSpaceBar.createSettings(
      minExtent: minExtent,
      maxExtent: maxExtent,
      currentExtent: math.max(minExtent, visibleMainHeight),
      toolbarOpacity: toolbarOpacity,
      isScrolledUnder: isScrolledUnder,
      child: _FloatingBar(
        snap: snap,
        child: _AppBar(
          backgroundColor: backgroundColor,
          elevation: isScrolledUnder ? elevation : null,
          leading: leading,
          title: title,
          onTap: onTap,
          trailing: trailing,
        ),
      ),
    );
  }

  @override
  final TickerProvider? vsync;

  @override
  final FloatingHeaderSnapConfiguration? snapConfiguration;

  @override
  double get minExtent => collapsedHeight;

  @override
  double get maxExtent => math.max(topPadding + kToolbarHeight, minExtent);

  @override
  bool shouldRebuild(_SliverFloatingPersistentHeader oldDelegate) {
    return topPadding != oldDelegate.topPadding ||
        collapsedHeight != oldDelegate.collapsedHeight ||
        elevation != oldDelegate.elevation ||
        pinned != oldDelegate.pinned ||
        snap != oldDelegate.snap ||
        snapConfiguration != oldDelegate.snapConfiguration ||
        trailing != oldDelegate.trailing ||
        leading != oldDelegate.leading ||
        title != oldDelegate.title ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}

class _AppBar extends StatefulWidget implements PreferredSizeWidget {
  final double? elevation;
  final Color? backgroundColor;
  final Widget? leading;
  final Widget? trailing;
  final Widget? title;
  final VoidCallback? onTap;

  _AppBar({
    // ignore: unused_element
    super.key,
    this.backgroundColor,
    this.elevation,
    this.leading,
    this.onTap,
    this.title,
    this.trailing,
  });

  @override
  State<_AppBar> createState() => _AppBarState();

  @override
  final Size preferredSize = Size.fromHeight(kToolbarHeight);
}

class _AppBarState extends State<_AppBar> {
  ScrollNotificationObserverState? _scrollNotificationObserver;
  bool _scrolledUnder = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scrollNotificationObserver != null) {
      _scrollNotificationObserver!.removeListener(_handleScrollNotification);
    }
    _scrollNotificationObserver = ScrollNotificationObserver.of(context);
    if (_scrollNotificationObserver != null) {
      _scrollNotificationObserver!.addListener(_handleScrollNotification);
    }
  }

  @override
  void dispose() {
    if (_scrollNotificationObserver != null) {
      _scrollNotificationObserver!.removeListener(_handleScrollNotification);
      _scrollNotificationObserver = null;
    }
    super.dispose();
  }

  void _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification && notification.depth == 0) {
      final bool oldScrolledUnder = _scrolledUnder;
      final ScrollMetrics metrics = notification.metrics;
      switch (metrics.axisDirection) {
        case AxisDirection.up:
          // Scroll view is reversed
          _scrolledUnder = metrics.extentAfter > 0;
          break;
        case AxisDirection.down:
          _scrolledUnder = metrics.extentBefore > 0;
          break;
        case AxisDirection.right:
        case AxisDirection.left:
          // Scrolled under is only supported in the vertical axis.
          _scrolledUnder = false;
          break;
      }

      if (_scrolledUnder != oldScrolledUnder) {
        setState(() {
          // React to a change in MaterialState.scrolledUnder
        });
      }
    }
  }

  SystemUiOverlayStyle _systemOverlayStyleForBrightness(Brightness brightness,
      [Color? backgroundColor]) {
    final SystemUiOverlayStyle style = brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
    return style.copyWith(statusBarColor: backgroundColor);
  }

  @override
  Widget build(BuildContext context) {
    final FlexibleSpaceBarSettings? settings =
        context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    final Set<MaterialState> states = <MaterialState>{
      if (settings?.isScrolledUnder ?? _scrolledUnder)
        MaterialState.scrolledUnder,
    };

    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final theme = Theme.of(context);
    final appbarTheme = theme.appBarTheme;
    final _background = widget.backgroundColor ??
        appbarTheme.backgroundColor ??
        theme.canvasColor;
    final _elevation = widget.elevation ?? appbarTheme.elevation ?? 0.0;
    final bool useCloseButton =
        parentRoute is PageRoute<dynamic> && parentRoute.fullscreenDialog;
    final double effectiveElevation;
    final double innerElevation;
    if (states.contains(MaterialState.scrolledUnder)) {
      final _possible = _elevation * 2.0;
      effectiveElevation = _possible > 4.0 ? _possible : 4.0;
      innerElevation = 2.0;
    } else {
      effectiveElevation = _elevation;
      innerElevation = 0.0;
    }
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: appbarTheme.systemOverlayStyle ??
          _systemOverlayStyleForBrightness(
            ThemeData.estimateBrightnessForColor(_background),
            theme.useMaterial3 ? const Color(0x00000000) : null,
          ),
      child: Material(
        color: _background,
        elevation: effectiveElevation,
        surfaceTintColor: appbarTheme.surfaceTintColor,
        type: MaterialType.canvas,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 4.0,
            ),
            child: ListTileTheme(
              contentPadding: EdgeInsets.zero,
              horizontalTitleGap: 0.0,
              iconColor: theme.iconTheme.color,
              textColor: theme.textTheme.headline6!.color,
              dense: true,
              child: Material(
                type: MaterialType.card,
                surfaceTintColor: theme.cardTheme.surfaceTintColor,
                elevation: innerElevation,
                shape: const StadiumBorder(),
                //borderRadius: BorderRadius.circular(32.0),
                clipBehavior: Clip.hardEdge,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                  leading: widget.leading ??
                      (useCloseButton ? CloseButton() : BackButton()),
                  title: widget.title == null
                      ? null
                      : DefaultTextStyle.merge(
                          textAlign: TextAlign.left,
                          style: appbarTheme.titleTextStyle,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          child: widget.title!,
                        ),
                  trailing: widget.trailing,
                  onTap: widget.onTap,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingBar extends StatefulWidget {
  final Widget child;
  final bool? snap;

  _FloatingBar({Key? key, required this.child, this.snap}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FloatingBarState();
}

class _FloatingBarState extends State<_FloatingBar> {
  ScrollPosition? _position;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_position != null)
      _position!.isScrollingNotifier.removeListener(_isScrollingListener);
    _position = Scrollable.of(context)?.position;
    if (_position != null)
      _position!.isScrollingNotifier.addListener(_isScrollingListener);
  }

  @override
  void dispose() {
    if (_position != null)
      _position!.isScrollingNotifier.removeListener(_isScrollingListener);
    super.dispose();
  }

  RenderSliverFloatingPersistentHeader? _headerRenderer() {
    return context
        .findAncestorRenderObjectOfType<RenderSliverFloatingPersistentHeader>();
  }

  void _isScrollingListener() {
    if (_position == null) return;
    final RenderSliverFloatingPersistentHeader? header = _headerRenderer();
    if (_position!.isScrollingNotifier.value)
      header?.maybeStopSnapAnimation(_position!.userScrollDirection);
    else
      header?.maybeStartSnapAnimation(_position!.userScrollDirection);
  }

  @override
  void didUpdateWidget(_FloatingBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.snap != oldWidget.snap && widget.snap!) {
      final RenderSliverFloatingPersistentHeader? header = _headerRenderer();
      header?.maybeStartSnapAnimation(ScrollDirection.forward);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
