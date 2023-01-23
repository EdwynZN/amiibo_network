import 'package:flutter/material.dart';
import 'dart:math';

class RadialProgression extends CustomPainter {
  final Paint line;
  final Paint progressLine;
  final Color emptyColor;
  final double? percent;

  RadialProgression({
    this.percent,
    required Color color,
    required this.emptyColor,
  })
      : progressLine = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
        line = Paint()
          ..color = emptyColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);
    canvas
      ..drawCircle(center, radius, line)
      ..drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2,
          2 * pi * percent!, false, progressLine);
  }

  @override
  bool shouldRepaint(RadialProgression oldDelegate) =>
      oldDelegate.percent != percent;
}
