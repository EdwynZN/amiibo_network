import 'package:flutter/material.dart';
import 'package:amiibo_network/widget/radial_progression.dart';
import 'package:provider/provider.dart';
import 'package:amiibo_network/provider/stat_provider.dart';
import 'dart:ui' as ui show FontFeature;

class StatWidget extends StatelessWidget{
  final double num;
  final double den;
  final double stat;
  final String text;
  final Widget icon;

  StatWidget({
    @required this.num,
    @required this.den,
    @required this.text,
    @required this.icon,
    Key key})
   : stat = den != 0 ? num / den : 0, super(key: key);

  @override
  Widget build(BuildContext context) {
    return _Radial(
      icon: _AnimatedRadial(
        key: Key(text),
        percentage: stat,
        child: icon,
      ),
      label: Flexible(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Consumer<StatProvider>(
            builder: (ctx, stat, _){
              final String ownedStat = stat.statLabel(num, den);
              return RichText(
                text: TextSpan(
                  text: ownedStat,
                  style: Theme.of(context).textTheme.subhead.copyWith(
                    fontSize: stat.isPercentage ? null : 22,
                    fontFeatures: [
                      if(!stat.isPercentage) ui.FontFeature.enable('frac'),
                      if(stat.isPercentage) ui.FontFeature.tabularFigures()
                    ]
                  ),
                  children: [
                    TextSpan(
                      style: Theme.of(context).textTheme.subhead,
                      text: ' $text'
                    )
                  ]
                ),
              );
            }
          ),
        )
      ),
    );
  }
}

class _Radial extends StatelessWidget{
  final Widget label;
  final Widget icon;
  final MainAxisAlignment mainAxisAlignment;

  _Radial({
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

class _AnimatedRadial extends ImplicitlyAnimatedWidget {
  final Widget child;
  final double percentage;

  _AnimatedRadial({
    Key key,
    @required this.percentage,
    Duration duration = const Duration(milliseconds: 400),
    this.child,
    Curve curve = Curves.linear
  }) : super(duration: duration, curve: curve, key: key);

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() => _AnimatedRadialState();
}

class _AnimatedRadialState extends AnimatedWidgetBaseState<_AnimatedRadial> {
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