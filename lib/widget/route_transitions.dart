import 'package:flutter/material.dart';


MaterialPageRoute materialRoute(Widget builder, RouteSettings settings) {
  return MaterialPageRoute(
    settings: settings,
    builder: (ctx) => builder,
  );
}

class FadeRoute<T> extends MaterialPageRoute<T> {
  FadeRoute({ WidgetBuilder builder, RouteSettings settings })
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
    Animation<double> secondaryAnimation, Widget child) {
      return FadeTransition(opacity: animation, child: child);
    }
}

class SlideRoute<T> extends MaterialPageRoute<T> {
  SlideRoute({ WidgetBuilder builder, RouteSettings settings })
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
    Animation<double> secondaryAnimation, Widget child) {
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
          .animate(animation),
        child: child
      );
  }
}