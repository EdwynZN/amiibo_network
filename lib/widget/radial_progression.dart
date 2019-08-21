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
        Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0,
    line = Paint()
      ..color = const Color(0xFF2B2922)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width/2, size.height/2);
    double radius = min(size.width/2, size.height/2);
    canvas.drawCircle(center, radius, line);
    canvas.drawArc(
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

  @override
  void forEachTween(TweenVisitor visitor) {
    _percentage = visitor(_percentage, widget.percentage, (dynamic value) => Tween<double>(begin: value));
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RadialProgression(_percentage.evaluate(animation)),
      isComplex: true,
      willChange: true,
      child: AnimatedSwitcher(
        duration: widget.duration,
        child: _percentage.evaluate(animation) == 1 ? widget.child : const SizedBox(width: 24, height: 24),
      ),
    );
  }
}