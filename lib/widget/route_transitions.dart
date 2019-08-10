import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:amiibo_network/screen/home_page.dart';
import 'package:amiibo_network/screen/detail_page.dart';
import 'package:amiibo_network/screen/settings_screen.dart';
import 'package:amiibo_network/screen/settings_detail.dart';
import 'package:amiibo_network/screen/search_screen.dart';
import 'package:amiibo_network/screen/stats_page.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class Routes{
  static Route<dynamic> getRoute(RouteSettings settings) {
    switch(settings.name){
      case '/details':
        return cupertinoRoute(DetailPage(amiibo: settings.arguments), settings);
      case '/home':
        return FadeRoute(builder: (_) => HomePage());
      case '/settings':
        return SlideRoute(builder: (_) => SettingsPage());
      case '/settingsdetail':
        return SlideRoute(builder: (_) => SettingsDetail(title: settings.arguments), settings: settings);
      case '/search':
        return FadeRoute(builder: (_) => SearchScreen());
      case '/stats':
        return FadeRoute(builder: (_) => StatsPage());
      default:
        return null;
    }
  }
}

CupertinoPageRoute cupertinoRoute(Widget builder, RouteSettings settings){
  return CupertinoPageRoute(
    settings: settings,
    builder: (ctx) => AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Theme.of(ctx).scaffoldBackgroundColor,
        systemNavigationBarColor: Theme.of(ctx).scaffoldBackgroundColor
      ),
      child: builder
    )
  );
}

MaterialPageRoute materialRoute(Widget builder, RouteSettings settings) {
  return MaterialPageRoute(
    settings: settings,
    builder: (ctx) => AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Theme.of(ctx).scaffoldBackgroundColor,
        systemNavigationBarColor: Theme.of(ctx).scaffoldBackgroundColor
      ),
      child: builder,
    )
  );
}

class FadeRoute<T> extends MaterialPageRoute<T> {
  FadeRoute({ WidgetBuilder builder, RouteSettings settings })
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).scaffoldBackgroundColor,
        systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor
      ),
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}

class SlideRoute<T> extends MaterialPageRoute<T> {
  SlideRoute({Key key, WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final double maxWidth = MediaQuery.of(context).size.width;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).scaffoldBackgroundColor,
        systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
          .animate(animation),
        child: GestureDetector(
          child: child,
          onHorizontalDragUpdate: (DragUpdateDetails details) => _handleDragUpdate(details, maxWidth),
          onHorizontalDragEnd: (DragEndDetails details) => _handleDragEnd(details, maxWidth, context),
        )
      )
    );
  }

  void _handleDragUpdate(DragUpdateDetails details, double maxWidth){
    controller.value -= details.primaryDelta / maxWidth;
  }

  void _handleDragEnd(DragEndDetails details, double maxWidth, BuildContext context){
    if (controller.isAnimating || controller.status == AnimationStatus.completed) return;

    final double flingVelocity = details.velocity.pixelsPerSecond.dx / maxWidth;
    if (flingVelocity < 0.0)
      controller.fling(velocity: math.max(2.0, -flingVelocity));
    else if (flingVelocity > 0.0)
      controller.fling(velocity: math.min(-2.0, -flingVelocity))
        .whenComplete(() => Navigator.of(context).maybePop());
    else
      controller.fling(velocity: controller.value < 0.5 ? -2.0 : 2.0)
        .whenComplete(() {if(controller.value == 0) Navigator.of(context).maybePop();});
  }

}