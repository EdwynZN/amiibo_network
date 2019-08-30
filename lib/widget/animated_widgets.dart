import 'package:flutter/material.dart';

class ImplicitIcon extends ImplicitlyAnimatedWidget{
  final bool forward;
  final AnimatedIconData icon;
  double get targetValue => forward ? 1.0 : 0.0;

  ImplicitIcon({
    Key key,
    this.icon = AnimatedIcons.menu_close,
    this.forward,
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.linear
  }) : super(key: key, duration: duration, curve: curve);

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() => _ImplicitIconState();
}

class _ImplicitIconState extends ImplicitlyAnimatedWidgetState<ImplicitIcon> {
  Tween<double> _progress;

  @override
  void initState() {
    super.initState();
  }

  @override
  void forEachTween(TweenVisitor visitor){
    _progress = visitor(_progress, widget.targetValue, (value) => Tween<double>(begin: value));
  }

  @override
  Widget build(BuildContext context){
    return AnimatedIcon(
      icon: widget.icon,
      progress: _progress.animate(animation),
    );
  }
}

class FadeSwitchAnimation extends StatefulWidget{
  final Widget child;
  final Duration duration;

  FadeSwitchAnimation({
    Key key,
    @required this.child,
    this.duration = const Duration(milliseconds: 750)
  }) : super(key :key);

  @override
  _FadeSwitchAnimationState createState() => _FadeSwitchAnimationState();
}

class _FadeSwitchAnimationState extends State<FadeSwitchAnimation>
    with SingleTickerProviderStateMixin{
  AnimationController _controller;
  final Tween<double> _opacity = Tween<double>(begin: 0, end: 1);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..forward();
  }

  @override
  void didUpdateWidget(FadeSwitchAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(widget.child.key != oldWidget.child.key){
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity.animate(_controller),
      child: widget.child,
    );
  }
}