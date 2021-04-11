import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;
import 'package:flutter/widgets.dart';

class SliverFloatingBar extends StatefulWidget{
  final bool pinned;
  final bool floating;
  final bool snap;
  final bool forward;
  final Widget? trailing;
  final Widget? leading;
  final Widget? title;
  final double elevation;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const SliverFloatingBar({
    Key? key,
    this.pinned = false,
    this.floating = false,
    this.snap = false,
    this.forward = false,
    this.elevation = 0.0,
    this.title,
    this.leading,
    this.trailing,
    this.onTap,
    this.backgroundColor
  }) : super(key:key);

  @override
  State<StatefulWidget> createState() => _SliverFloatingBarState();
}

class _SliverFloatingBarState extends State<SliverFloatingBar>
  with TickerProviderStateMixin {
  FloatingHeaderSnapConfiguration? _snapConfiguration;

  void _updateSnapConfiguration() {
    if(widget.snap)
      _snapConfiguration = FloatingHeaderSnapConfiguration(
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 200),
      );
    else _snapConfiguration = null;
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
    return SliverPersistentHeader(
      floating: widget.floating,
      pinned: widget.pinned,
      delegate: _SliverFloatingPersistentHeader(
        vsync: this,
        snap: widget.forward,
        snapConfiguration: _snapConfiguration,
        leading: widget.leading,
        title: widget.title,
        trailing: widget.trailing,
        onTap: widget.onTap,
        elevation: widget.elevation,
        backgroundColor: widget.backgroundColor ?? Theme.of(context).appBarTheme.color
      )
    );
  }
}

class _SliverFloatingPersistentHeader extends SliverPersistentHeaderDelegate {
  final bool snap;
  final double _maxExtent;
  final double _minExtent;
  final double? elevation;
  final Widget? trailing;
  final Widget? leading;
  final Widget? title;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const _SliverFloatingPersistentHeader({
    this.vsync,
    this.snap = false,
    this.snapConfiguration,
    this.elevation,
    this.trailing,
    this.leading,
    this.title,
    this.onTap,
    this.backgroundColor
  }) : _maxExtent = kToolbarHeight,
        _minExtent = kToolbarHeight,
        super();

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double visibleMainHeight = maxExtent - shrinkOffset;
    final double toolbarOpacity = 1.0;
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool useCloseButton = parentRoute is PageRoute<dynamic> && parentRoute.fullscreenDialog;
    return FlexibleSpaceBarSettings(
      toolbarOpacity: toolbarOpacity,
      minExtent: _minExtent,
      maxExtent: _maxExtent,
      currentExtent: math.max(minExtent, visibleMainHeight),
      child: _FloatingBar(
        snap: snap,
        child: Container(
          color: backgroundColor,
          padding: const EdgeInsets.fromLTRB(12,8,12,0),
          child: ListTileTheme(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
            iconColor: Theme.of(context).iconTheme.color,
            textColor: Theme.of(context).textTheme.headline6!.color,
            dense: true,
            child: Material(
              color: Theme.of(context).backgroundColor,
              type: MaterialType.card,
              elevation: elevation!,
              borderRadius: BorderRadius.circular(8.0),
              clipBehavior: Clip.hardEdge,
              child: ListTile(
                leading: leading ?? (useCloseButton ? CloseButton() : BackButton()),
                title: DefaultTextStyle(
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.headline4!,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  child: title!,
                ),
                trailing: trailing,
                onTap: onTap,
              ),
            )
          )
        ),
      ),
    );
  }

  @override
  final TickerProvider? vsync;

  @override
  final FloatingHeaderSnapConfiguration? snapConfiguration;

  @override
  double get maxExtent => _maxExtent;

  @override
  double get minExtent => _minExtent;

  @override
  bool shouldRebuild(_SliverFloatingPersistentHeader oldDelegate) {
    return snap != oldDelegate.snap
      || snapConfiguration != oldDelegate.snapConfiguration
      || trailing != oldDelegate.trailing
      || leading != oldDelegate.leading
      || title != oldDelegate.title
      || backgroundColor != oldDelegate.backgroundColor
    ;
  }
}

class _FloatingBar extends StatefulWidget{
  final Widget? child;
  final bool? snap;

  _FloatingBar({Key? key, this.child, this.snap}) : super(key : key);

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
    return context.findAncestorRenderObjectOfType<RenderSliverFloatingPersistentHeader>();
  }

  void _isScrollingListener() {
    if (_position == null)
      return;
    final RenderSliverFloatingPersistentHeader? header = _headerRenderer();
    if (_position!.isScrollingNotifier.value)
      header?.maybeStopSnapAnimation(_position!.userScrollDirection);
    else
      header?.maybeStartSnapAnimation(_position!.userScrollDirection);
  }

  @override
  void didUpdateWidget(_FloatingBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(widget.snap != oldWidget.snap && widget.snap!){
      final RenderSliverFloatingPersistentHeader? header = _headerRenderer();
      header?.maybeStartSnapAnimation(ScrollDirection.forward);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child!;
}