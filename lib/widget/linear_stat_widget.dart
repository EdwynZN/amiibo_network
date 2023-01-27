import 'package:amiibo_network/utils/theme_extensions.dart';
import 'package:flutter/material.dart';

class AnimatedLineProgress extends ImplicitlyAnimatedWidget {
  final Size? size;
  final double ownPercentage;
  final double wishPercentage;
  final double total;

  const AnimatedLineProgress({
    Key? key,
    required this.ownPercentage,
    required this.wishPercentage,
    required this.total,
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.easeInOutCubicEmphasized,
    this.size,
  }) : super(duration: duration, curve: curve, key: key);

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() =>
      _AnimatedRadialState();
}

class _AnimatedRadialState
    extends AnimatedWidgetBaseState<AnimatedLineProgress> {
  Tween<double>? _ownPercent;
  Tween<double>? _wishPercent;
  late ThemeData theme;
  late PreferencesExtension preferred;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    theme = Theme.of(context);
    preferred = theme.extension<PreferencesExtension>()!;
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    final ownPercent = widget.ownPercentage / widget.total;
    final wishPercent = widget.wishPercentage / widget.total;
    _ownPercent = visitor(_ownPercent, ownPercent,
        (dynamic value) => Tween<double>(begin: value)) as Tween<double>?;
    _wishPercent = visitor(_wishPercent, wishPercent,
        (dynamic value) => Tween<double>(begin: value)) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: widget.size ?? const Size.fromHeight(8.0),
      painter: LinearProgression(
        emptyColor: Colors.transparent,
        ownColor: preferred.ownContainer,
        wishColor: preferred.wishContainer,
        ownPercent: _ownPercent!.evaluate(animation),
        wishPercent: _wishPercent!.evaluate(animation),
      ),
      willChange: true,
    );
  }
}

class LinearProgression extends CustomPainter {
  final Color emptyColor;
  final Color ownColor;
  final Color wishColor;
  final double ownPercent;
  final double wishPercent;

  LinearProgression({
    required this.emptyColor,
    required this.ownColor,
    required this.wishColor,
    required this.ownPercent,
    required this.wishPercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    //print(wishPercent);
    final height = size.height;
    final width = size.width;
    final wishWidth = wishPercent * width;
    final ownWidth = ownPercent * width;
    final line = Paint()
      ..color = emptyColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = height;
    canvas.drawLine(Offset.zero, Offset(width, 0), line);
    if (wishWidth != 0) {
      final progressWishLine = Paint()
        ..color = wishColor
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = height;
      canvas.drawLine(
        Offset(width, 0),
        Offset(width - wishWidth, 0),
        progressWishLine,
      );
    }
    if (ownWidth != 0) {
      final progressOwnLine = Paint()
        ..color = ownColor
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = height;
      canvas.drawLine(Offset.zero, Offset(ownWidth, 0), progressOwnLine);
    }
  }

  @override
  bool shouldRepaint(LinearProgression oldDelegate) =>
      oldDelegate.wishColor != wishColor ||
      oldDelegate.ownColor != ownColor ||
      oldDelegate.emptyColor != emptyColor ||
      oldDelegate.wishPercent != wishPercent ||
      oldDelegate.ownPercent != ownPercent;
}
