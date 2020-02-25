import 'package:flutter/material.dart';
import 'dart:math';

class RadialProgression extends CustomPainter{
  final Paint line;
   Paint progressLine;
  final double percent;

  RadialProgression(this.percent):
    progressLine = Paint()
      ..color =
        percent <= 0.25 ? Colors.red[300] :
        percent <= 0.50 ? Colors.yellow[300] :
        percent <= 0.75 ? Colors.amber[300] :
        percent <= 0.99 ? Colors.lightGreen[300] :
        Colors.green[800]
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3,
    line = Paint()
      ..color = const Color(0xFF2B2922)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width/2, size.height/2);
    double radius = min(size.width/2, size.height/2);
    canvas..drawCircle(center, radius, line)..drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi/2,
      2*pi*percent,
      false,
      progressLine
    );
  }

  @override
  bool shouldRepaint(RadialProgression oldDelegate) => oldDelegate.percent != percent;
}

class Radial extends StatelessWidget{
  final Widget label;
  final Widget icon;
  final MainAxisAlignment mainAxisAlignment;

  Radial({
    @required this.label,
    @required this.icon,
    this.mainAxisAlignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        icon,
        const SizedBox(width: 8.0),
        label
      ],
    );
  }
}

class AnimatedRadial extends ImplicitlyAnimatedWidget {
  final Widget child;
  final double percentage;

  AnimatedRadial({
    Key key,
    @required this.percentage,
    Duration duration = const Duration(milliseconds: 400),
    this.child,
    Curve curve = Curves.linear
  }) : super(duration: duration, curve: curve, key: key);

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() => _AnimatedRadialState();
}

class _AnimatedRadialState extends AnimatedWidgetBaseState<AnimatedRadial> {
  Tween<double> _percentage;
  Tween<double> _opacity;

  @override
  void forEachTween(TweenVisitor visitor) {
    _percentage = visitor(_percentage, widget.percentage, (dynamic value) => Tween<double>(begin: value));
    _opacity = visitor(_opacity, widget.percentage == 1 ? 1.0 : 0.0, (dynamic value) => Tween<double>(begin: value));
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RadialProgression(_percentage.evaluate(animation)),
      isComplex: true,
      willChange: true,
      child: Opacity(
        opacity: _opacity.evaluate(animation),
        child: widget.child,
      )
    );
  }
}