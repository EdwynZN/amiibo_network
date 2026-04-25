import 'package:flutter/material.dart';
import 'dart:math' as math;

enum _DrawerSlot { Left, Body, Right }

class DashMenu extends StatefulWidget {
  /// Left Drawer Widget (or Drawer as known in the Scaffold widget),
  /// can be null
  final Widget? leftDrawer;

  /// primary content of the scaffold (or body as known in the Scaffold widget),
  /// can be null
  final Widget? body;

  /// Right Drawer Widget (or EndDrawer as known in the Scaffold widget),
  /// can be null
  final Widget? rightDrawer;

  /// Enable gesture to swipe left / right,
  /// defaults to true unless there is no left nor right drawer
  final bool enableGesture;

  final Color? backgroundColor;

  const DashMenu({
    Key? key,
    this.backgroundColor,
    this.leftDrawer,
    this.body,
    this.rightDrawer,
    bool enableGesture = true,
  })  : enableGesture =
            enableGesture && (leftDrawer != null || rightDrawer != null),
        super(key: key);

  static _DashMenuState of(BuildContext context) {
    // ignore: unnecessary_null_comparison
    assert(context != null, 'context can\'t be null');
    final _DashMenuState? result =
        context.findAncestorStateOfType<_DashMenuState>();
    if (result != null) return result;
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
          'DashMenu.of() called with a context that does not contain a DashMenu.'),
      ErrorDescription(
          'No DashMenu ancestor could be found starting from the context that was passed to DashMenu.of(). '
          'This usually happens when the context provided is from the same StatefulWidget as that '
          'whose build function actually creates the Scaffold widget being sought.'),
      ErrorHint(
          'There are several ways to avoid this problem. The simplest is to use a Builder to get a '
          'context that is "under" the Scaffold. For an example of this, please see the '
          'documentation for Scaffold.of():\n'
          '  https://api.flutter.dev/flutter/material/Scaffold/of.html'),
      ErrorHint(
          'A more efficient solution is to split your build function into several widgets. This '
          'introduces a new context from which you can obtain the Scaffold. In this solution, '
          'you would have an outer widget that creates the Scaffold populated by instances of '
          'your new inner widgets, and then in these inner widgets you would use DashMenu.of().\n'
          'A less elegant but more expedient solution is assign a GlobalKey to the DashMenu, '
          'then use the key.currentState property to obtain the ScaffoldState rather than '
          'using the DashMenu.of() function.'),
      context.describeElement('The context used was')
    ]);
  }

  static _DashMenuState? maybeOf(BuildContext context) {
    // ignore: unnecessary_null_comparison
    assert(context != null, 'context can\'t be null');
    return context.findAncestorStateOfType<_DashMenuState>();
  }

  @override
  _DashMenuState createState() => _DashMenuState();
}

class _DashMenuState extends State<DashMenu> with TickerProviderStateMixin {
  late ThemeData theme;
  late Brightness brightness;

  LocalHistoryEntry? _historyEntry;
  late final AnimationController _controller;
  late final AnimationController _rightController;
  late final ProxyAnimation _proxyRight;
  final ProxyAnimation _proxyAnimation = ProxyAnimation();
  final ColorTween _color = ColorTween(end: Colors.black26);

  bool get isDrawerOpened => _controller.isCompleted;
  bool get isEndDrawerOpened => _rightController.isCompleted;

  bool get hasDrawer => widget.leftDrawer != null;
  bool get hasEndDrawer => widget.rightDrawer != null;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 100),
    );
    _rightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 100),
    );
    _proxyRight = _NegativeAnimation(_rightController);
    _proxyAnimation
      ..addStatusListener(_animationStatusChanged)
      ..parent = hasDrawer
          ? _controller
          : hasEndDrawer
              ? _proxyRight
              : null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    theme = Theme.of(context);
    brightness = theme.brightness;
  }

  @override
  void didUpdateWidget(DashMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (isDrawerOpened && !hasDrawer)
      _controller.reverse()
        ..whenCompleteOrCancel(
            () => _proxyAnimation.parent = hasEndDrawer ? _proxyRight : null);
    else if (isEndDrawerOpened && !hasEndDrawer)
      _rightController.reverse().whenCompleteOrCancel(
          () => _proxyAnimation.parent = hasDrawer ? _controller : null);
    else if (!hasDrawer || !hasEndDrawer)
      _proxyAnimation.parent = hasDrawer
          ? _controller
          : hasEndDrawer
              ? _proxyRight
              : null;
  }

  void _animationStatusChanged(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.forward:
        _ensureHistoryEntry();
        break;
      case AnimationStatus.reverse:
        _historyEntry?.remove();
        _historyEntry = null;
        break;
      case AnimationStatus.dismissed:
      case AnimationStatus.completed:
        break;
    }
  }

  void _ensureHistoryEntry() {
    if (_historyEntry == null) {
      final ModalRoute<dynamic>? route = ModalRoute.of(context);
      if (route != null) {
        _historyEntry = LocalHistoryEntry(onRemove: _handleHistoryEntryRemoved);
        route.addLocalHistoryEntry(_historyEntry!);
        FocusManager.instance.primaryFocus?.unfocus();
      }
    }
  }

  void _handleHistoryEntryRemoved() {
    _historyEntry = null;
    _controller.reverse();
    _rightController.reverse();
  }

  /// Open drawer
  void openDrawer() {
    if (hasDrawer) {
      if (hasEndDrawer && isEndDrawerOpened) _rightController.reverse();
      _proxyAnimation.parent = _controller;
      _controller.forward();
    }
  }

  /// Open drawer
  void openRightDrawer() {
    if (hasEndDrawer) {
      if (hasDrawer && isDrawerOpened) _controller.reverse();
      _proxyAnimation.parent = _proxyRight;
      _rightController.forward();
    }
  }

  void _handleDragDown(DragDownDetails details) {
    if (_proxyAnimation.parent == _controller)
      _controller.stop();
    else if (_proxyAnimation.parent == _proxyRight) _rightController.stop();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final double _move = details.primaryDelta! / context.size!.width;
    if (_proxyAnimation.value == 0 && hasDrawer && hasEndDrawer) {
      _proxyAnimation.parent = _move.isNegative ? _proxyRight : _controller;
    }
    if (_proxyAnimation.parent == _controller)
      _controller.value += _move;
    else if (_proxyAnimation.parent == _proxyRight)
      _rightController.value -= _move;
  }

  void _handleDragEnd(DragEndDetails details) {
    late final bool shouldOpen;
    final double flingVelocity = details.primaryVelocity! / context.size!.width;
    if (_proxyAnimation.parent == _controller) {
      shouldOpen = flingVelocity.abs() >= 2.0
          ? !flingVelocity.isNegative
          : _proxyAnimation.value.abs() > 0.5;
      if (shouldOpen) {
        _controller.fling(velocity: math.max(2.0, flingVelocity));
      } else {
        _controller.fling(velocity: math.min(-2.0, flingVelocity));
      }
    } else if (_proxyAnimation.parent == _proxyRight) {
      shouldOpen = flingVelocity.abs() >= 2.0
          ? flingVelocity.isNegative
          : _proxyAnimation.value.abs() > 0.5;
      if (shouldOpen) {
        _rightController.fling(velocity: math.max(2.0, flingVelocity));
      } else {
        _rightController.fling(velocity: math.min(-2.0, flingVelocity));
      }
    }
  }

  void _handleDragCancel() {
    if (_proxyAnimation.isDismissed || _proxyAnimation.isCompleted) return;

    if (_controller.value < 0.5)
      _controller.reverse();
    else
      _controller.forward();

    if (_rightController.value < 0.5)
      _rightController.reverse();
    else
      _rightController.forward();
  }

  @override
  void dispose() {
    _historyEntry?.remove();
    _proxyAnimation.removeStatusListener(_animationStatusChanged);
    _controller.dispose();
    _rightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragDown: widget.enableGesture ? _handleDragDown : null,
      onHorizontalDragUpdate: widget.enableGesture ? _handleDragUpdate : null,
      onHorizontalDragEnd: widget.enableGesture ? _handleDragEnd : null,
      onHorizontalDragCancel: _handleDragCancel,
      child: Material(
        color: widget.backgroundColor ?? theme.colorScheme.surface,
        child: SafeArea(
          top: false,
          child: CustomMultiChildLayout(
            children: [
              if (hasDrawer)
                LayoutId(
                  id: _DrawerSlot.Left,
                  child: _Drawer(
                    child: widget.leftDrawer,
                    controller: _controller,
                  ),
                ),
              if (hasEndDrawer)
                LayoutId(
                  id: _DrawerSlot.Right,
                  child: _Drawer(
                    child: widget.rightDrawer,
                    controller: _rightController,
                  ),
                ),
              if (widget.body != null)
                LayoutId(
                  id: _DrawerSlot.Body,
                  child: AnimatedBuilder(
                    animation: _proxyAnimation,
                    child: widget.body,
                    builder: (context, child) {
                      final shadow = Theme.of(context).shadowColor;
                      final lerp = _proxyAnimation.value.abs() - 0.25;
                      final elevationLerp = _proxyAnimation.value.abs() - 0.05;
                      final color = _color.lerp(lerp);
                      return RepaintBoundary(
                        child: Stack(
                          fit: StackFit.passthrough,
                          children: [
                            Material(
                              animationDuration:
                                  const Duration(milliseconds: 700),
                              type: MaterialType.card,
                              color: Colors.transparent,
                              surfaceTintColor: null,
                              elevation: !elevationLerp.isNegative ? 16.0 : 0.0,
                              child: widget.body,
                              shadowColor: shadow,
                            ),
                            if (!lerp.isNegative) ModalBarrier(color: color),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
            delegate: _MenuLayout(_proxyAnimation),
          ),
        ),
      ),
    );
  }
}

class _Drawer extends StatefulWidget {
  final Widget? child;
  final AnimationController controller;

  _Drawer({
    Key? key,
    this.child,
    required this.controller,
  }) : super(key: key);

  @override
  _DrawerState createState() => _DrawerState();
}

class _DrawerState extends State<_Drawer> {
  bool shouldExist = false;
  final double lowerBound = 0.0;

  @override
  void initState() {
    super.initState();
    widget.controller.addStatusListener(_updateWidget);
    if (widget.controller.value != lowerBound) shouldExist = true;
  }

  @override
  void didUpdateWidget(_Drawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.addStatusListener(_updateWidget);
      widget.controller.removeStatusListener(_updateWidget);
      if (widget.controller.value != lowerBound) shouldExist = true;
    }
  }

  void _updateWidget(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && shouldExist)
      setState(() => shouldExist = false);
    else if (status != AnimationStatus.dismissed && !shouldExist)
      setState(() => shouldExist = true);
  }

  @override
  void dispose() {
    widget.controller.removeStatusListener(_updateWidget);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!shouldExist) return const SizedBox();
    return BlockSemantics(
      child: ExcludeSemantics(
        excluding: Theme.of(context).platform == TargetPlatform.android,
        child: widget.child,
      ),
    );
  }
}

class _MenuLayout extends MultiChildLayoutDelegate {
  final Animation<double> listener;
  _MenuLayout(this.listener) : super(relayout: listener);

  @override
  void performLayout(Size size) {
    final BoxConstraints looseConstraints = BoxConstraints.loose(size);
    final BoxConstraints drawerWidthConstraints = looseConstraints.tighten(
        width: size.width > 450 ? 300 : size.width * 0.8);

    if (hasChild(_DrawerSlot.Left))
      layoutChild(_DrawerSlot.Left, drawerWidthConstraints);

    if (hasChild(_DrawerSlot.Body)) {
      layoutChild(_DrawerSlot.Body, looseConstraints);
      positionChild(_DrawerSlot.Body,
          Offset(listener.value * drawerWidthConstraints.maxWidth, 0.0));
    }

    if (hasChild(_DrawerSlot.Right)) {
      final rightSize = layoutChild(_DrawerSlot.Right, drawerWidthConstraints);
      positionChild(_DrawerSlot.Right,
          Offset.fromDirection(0, size.width - rightSize.width));
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) => false;
}

/// A Negative ProxyAnimation where the initial value is 0 and ending -1.0
class _NegativeAnimation extends ProxyAnimation {
  _NegativeAnimation(Animation<double> parent) : super(parent);

  @override
  double get value => parent != null ? -parent!.value : 0.0;
}
