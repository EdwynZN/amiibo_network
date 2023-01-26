import 'package:flutter/material.dart';
import 'package:amiibo_network/widget/radial_progression.dart';
import 'package:amiibo_network/riverpod/stat_provider.dart';
import 'dart:ui' as ui show FontFeature;

import 'package:hooks_riverpod/hooks_riverpod.dart';

class StatWidget extends StatelessWidget {
  final double numerator;
  final double den;
  final double stat;
  final String text;
  final Widget icon;

  StatWidget({
    Key? key,
    required this.numerator,
    required this.den,
    required this.text,
    required this.icon,
  })  : stat = den != 0 ? numerator / den : 0,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Radial(
      icon: _AnimatedRadial(
        key: Key(text),
        brightness: theme.brightness,
        percentage: stat,
        child: icon,
      ),
      label: Flexible(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Consumer(builder: (ctx, ref, _) {
            final stats = ref.watch(statProvider);
            final String myStat = stats.statLabel(numerator, den);
            final bool fontFeatureStyle =
                !stats.isPercentage && isFontFeatureEnable;

            /// Activate fontFeature only if StatMode is Ratio and isFontFeatureEnable is true for this device
            return RichText(
              text: TextSpan(
                text: myStat,
                style: theme.textTheme.titleMedium!.copyWith(
                  fontSize: fontFeatureStyle ? 22 : null,
                  fontFeatures: [
                    if (fontFeatureStyle) ui.FontFeature.enable('frac'),
                    if (!fontFeatureStyle) ui.FontFeature.tabularFigures()
                  ],
                ),
                children: [
                  TextSpan(
                    style: Theme.of(context).textTheme.titleMedium,
                    text: ' $text',
                  )
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _Radial extends StatelessWidget {
  final Widget label;
  final Widget icon;
  final MainAxisAlignment mainAxisAlignment;

  _Radial({
    required this.label,
    required this.icon,
    // ignore: unused_element
    this.mainAxisAlignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[icon, const SizedBox(width: 8.0), label],
    );
  }
}

class _AnimatedRadial extends ImplicitlyAnimatedWidget {
  final Widget? child;
  final double percentage;
  final Brightness brightness;

  _AnimatedRadial({
    Key? key,
    required this.percentage,
    required this.brightness,
    Duration duration = const Duration(milliseconds: 300),
    this.child,
    Curve curve = Curves.linear,
  }) : super(duration: duration, curve: curve, key: key);

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() =>
      _AnimatedRadialState();
}

class _AnimatedRadialState extends AnimatedWidgetBaseState<_AnimatedRadial> {
  Tween<double>? _percentage;
  ColorTween? _color;
  Tween<double>? _opacity;
  late Animation<double?> _opacityAnimation;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    Color color = widget.percentage == 0.0
        ? (widget.brightness == Brightness.light ? const Color(0xFF2B2922) : const Color(0xFFE7D9D9))
        : widget.percentage <= 0.25
            ? Colors.red.shade300
            : widget.percentage <= 0.50
                ? Colors.yellow.shade300
                : widget.percentage <= 0.75
                    ? Colors.amber.shade300
                    : widget.percentage < 1.0
                        ? Colors.lightGreen.shade300
                        : Colors.green.shade800;

    _color = visitor(_color, color, (dynamic value) => ColorTween(begin: value))
        as ColorTween?;
    _percentage = visitor(_percentage, widget.percentage,
        (dynamic value) => Tween<double>(begin: value)) as Tween<double>?;
    _opacity = visitor(_opacity, widget.percentage == 1 ? 1.0 : 0.0,
        (dynamic value) => Tween<double>(begin: value)) as Tween<double>?;
  }

  @override
  void didUpdateTweens() {
    _opacityAnimation = animation.drive(_opacity!);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RadialProgression(
        emptyColor: widget.brightness == Brightness.light ? const Color(0xFF2B2922) : const Color(0xFFE7D9D9),
        percent: _percentage!.evaluate(animation),
        color: _color!.evaluate(animation)!,
      ),
      willChange: true,
      child: FadeTransition(
        opacity: _opacityAnimation as Animation<double>,
        child: widget.child,
      ),
    );
  }
}
