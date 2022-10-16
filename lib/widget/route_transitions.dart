import 'package:amiibo_network/model/search_result.dart';
import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:amiibo_network/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:amiibo_network/screen/detail_page.dart';
import 'package:amiibo_network/screen/settings_screen.dart';
import 'package:amiibo_network/screen/search_screen.dart';
import 'package:amiibo_network/screen/stats_page.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:amiibo_network/utils/routes_constants.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Routes{
  static Route<dynamic>? getRoute(RouteSettings settings) {
    switch(settings.name){
      case detailsRoute:
        return cupertinoRoute(
          child: ProviderScope(
            overrides: [
              keyAmiiboProvider.overrideWithValue((settings.arguments as int?) ?? 0)
            ],
            child: const DetailPage(),
          ), 
          settings: settings,
        );
      case homeRoute:
        return FadeRoute(builder: (_) => const HomeScreen());
      case settingsRoute:
        return cupertinoRoute(child: const SettingsPage(), settings: settings);
      case searchRoute:
        return FadeRoute<Search>(builder: (_) => const SearchScreen());
      case statsRoute:
        return cupertinoRoute(child: const StatsPage(), settings: settings);
      default:
        return null;
    }
  }
}

CupertinoPageRoute cupertinoRoute({Widget? child, RouteSettings? settings, bool fullscreenDialog = false}){
  return CupertinoPageRoute(
    settings: settings,
    fullscreenDialog: fullscreenDialog,
    builder: (ctx) => child!
  );
}

MaterialPageRoute materialRoute({Widget? child, RouteSettings? settings, bool fullscreenDialog = false}) {
  return MaterialPageRoute(
    settings: settings,
    fullscreenDialog: fullscreenDialog,
    builder: (ctx) => AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppBarTheme.of(ctx).systemOverlayStyle ?? SystemUiOverlayStyle(),
      child: child!,
    )
  );
}

class FadeRoute<T> extends MaterialPageRoute<T> {
  FadeRoute({required WidgetBuilder builder, RouteSettings? settings, bool fullscreenDialog = false})
      : super(builder: builder, settings: settings, fullscreenDialog: fullscreenDialog);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(opacity: animation, child: child);
  }
}

class VerticalSlideRoute<T> extends PageRoute<T> {
  VerticalSlideRoute({Key? key, this.builder, RouteSettings? settings, bool fullscreenDialog = false})
      : super(settings: settings, fullscreenDialog: fullscreenDialog);

  final WidgetBuilder? builder;

  @override
  bool get opaque => false;

  @override
  String? get barrierLabel => null;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => Colors.black54;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder!(context);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final double maxHeight = MediaQuery.of(context).size.height;
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(animation),
      child: GestureDetector(
        child: child,
        onVerticalDragUpdate: (DragUpdateDetails details) => _handleDragUpdate(details, maxHeight),
        onVerticalDragEnd: (DragEndDetails details) => _handleDragEnd(details, maxHeight),
      )
    );
  }

  void _handleDragUpdate(DragUpdateDetails details, double maxHeight){
    if(!navigator!.userGestureInProgress) navigator!.didStartUserGesture();
    controller!.value -= details.primaryDelta! / maxHeight;
    if(controller!.value == 1.0 && navigator!.userGestureInProgress) navigator!.didStopUserGesture();
  }

  void _handleDragEnd(DragEndDetails details, double maxHeight){
    final NavigatorState? _navigator = navigator;
    if(controller!.value == 1.0 && !_navigator!.userGestureInProgress) return;
    bool animateForward;

    final double flingVelocity = details.primaryVelocity! / maxHeight;
    if (flingVelocity.abs() >= 2.0)
      animateForward = flingVelocity <= 0;
    else
      animateForward = controller!.value > 0.85;

    if(animateForward){
      controller!.fling(velocity: math.max(2.0, -flingVelocity));
    } else{
      _navigator!.pop();
      if (controller!.isAnimating)
        controller!.fling(velocity: math.min(-2.0, -flingVelocity));
    }

    if (controller!.isAnimating) {
      late AnimationStatusListener animationStatusCallback;
      animationStatusCallback = (AnimationStatus status) {
        _navigator!.didStopUserGesture();
        controller!.removeStatusListener(animationStatusCallback);
      };
      controller!.addStatusListener(animationStatusCallback);
    } else {
      _navigator!.didStopUserGesture();
    }
  }

}

class SlideRoute<T> extends MaterialPageRoute<T> {
  SlideRoute({Key? key, required WidgetBuilder builder, RouteSettings? settings, bool fullscreenDialog = false})
      : super(builder: builder, settings: settings, fullscreenDialog: fullscreenDialog);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final double maxWidth = MediaQuery.of(context).size.width;
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(animation),
      child: GestureDetector(
        child: child,
        onHorizontalDragUpdate: (DragUpdateDetails details) => _handleDragUpdate(details, maxWidth),
        onHorizontalDragEnd: (DragEndDetails details) => _handleDragEnd(details, maxWidth),
      )
    );
  }

  void _handleDragUpdate(DragUpdateDetails details, double maxWidth){
    if(!navigator!.userGestureInProgress) navigator!.didStartUserGesture();
    controller!.value -= details.primaryDelta! / maxWidth;
    if(controller!.value == 1.0 && navigator!.userGestureInProgress) navigator!.didStopUserGesture();
  }

  void _handleDragEnd(DragEndDetails details, double maxWidth){
    final NavigatorState? _navigator = navigator;
    if(controller!.value == 1.0 && !_navigator!.userGestureInProgress) return;
    bool animateForward;

    final double flingVelocity = details.primaryVelocity! / maxWidth;
    if (flingVelocity.abs() >= 2.0)
      animateForward = flingVelocity <= 0;
    else
      animateForward = controller!.value > 0.8;

    if(animateForward){
      controller!.fling(velocity: math.max(2.0, -flingVelocity));
    } else{
      _navigator!.pop();
      if (controller!.isAnimating)
        controller!.fling(velocity: math.min(-2.0, -flingVelocity));
    }

    if (controller!.isAnimating) {
      late AnimationStatusListener animationStatusCallback;
      animationStatusCallback = (AnimationStatus status) {
        _navigator!.didStopUserGesture();
        controller!.removeStatusListener(animationStatusCallback);
      };
      controller!.addStatusListener(animationStatusCallback);
    } else {
      _navigator!.didStopUserGesture();
    }
  }

}