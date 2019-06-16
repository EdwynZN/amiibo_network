import 'package:flutter/material.dart';
import 'dart:math' as math;

MaterialPageRoute materialRoute(Widget builder, RouteSettings settings) {
  return MaterialPageRoute(settings: settings, builder: (ctx) => builder);
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
    final double maxWidth = MediaQuery.of(context).size.width;
    return SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(animation),
        child: GestureDetector(
          child: child,
          onHorizontalDragUpdate: (DragUpdateDetails details) => _handleDragUpdate(details, maxWidth),
          onHorizontalDragEnd: (DragEndDetails details) => _handleDragEnd(details, maxWidth, context),
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