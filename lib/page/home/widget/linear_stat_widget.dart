import 'package:amiibo_network/shared/utils/theme_extensions.dart';
import 'package:material_ui/material_ui.dart';

class AnimatedLineProgress extends ImplicitlyAnimatedWidget {
  final Size? size;
  final int owned;
  final int wished;
  final int total;
  final bool showEmptyColor;

  const AnimatedLineProgress({
    Key? key,
    required this.owned,
    required this.wished,
    required this.total,
    this.showEmptyColor = false,
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.easeInOutCubicEmphasized,
    this.size,
  })  : assert(
            owned <= total, 'owned cannot be more than total: $owned > $total'),
        assert(wished <= total,
            'wished cannot be more than total: $wished > $total'),
        super(duration: duration, curve: curve, key: key);

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
    final double den = widget.total.toDouble();
    final ownPercent = widget.owned / den;
    final wishPercent = widget.wished / den;
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
        emptyColor: widget.showEmptyColor
          ? theme.scaffoldBackgroundColor.withValues(alpha: .32)
          : Colors.transparent,
        ownColor: preferred.ownPrimary,
        wishColor: preferred.wishPrimary,
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
    final height = size.height;
    final width = size.width;

    final line = Paint()
      ..color = emptyColor
      ..style = .fill
      ..strokeCap = .butt
      ..strokeWidth = height;

    final rect = Offset.zero & size;
    final radius = Radius.circular(rect.shortestSide / 2);
    final borderRect = RRect.fromRectAndRadius(rect, radius);
    canvas
      ..clipRRect(borderRect)
      ..save()
      ..drawRect(rect, line);

    final ownWidth = ownPercent * width;
    if (ownWidth != 0) {
      line.color = ownColor;
      canvas.drawRect(Offset.zero & Size(ownWidth, height), line);
    }

    final wishWidth = wishPercent * width;
    if (wishWidth != 0) {
      line.color = wishColor;
      canvas.drawRect(
        (Offset.zero & Size(wishWidth, height)).translate(ownWidth, 0),
        line,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(LinearProgression oldDelegate) =>
      oldDelegate.wishColor != wishColor ||
      oldDelegate.ownColor != ownColor ||
      oldDelegate.emptyColor != emptyColor ||
      oldDelegate.wishPercent != wishPercent ||
      oldDelegate.ownPercent != ownPercent;
}
