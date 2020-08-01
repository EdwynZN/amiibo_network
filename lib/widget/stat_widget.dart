import 'package:flutter/material.dart';
import 'package:amiibo_network/widget/radial_progression.dart';
import 'package:provider/provider.dart';
import 'package:amiibo_network/provider/stat_provider.dart';
import 'dart:ui' as ui show FontFeature;

class StatWidget extends StatelessWidget {
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
              final String myStat = stat.statLabel(num, den);
              final bool fontFeatureStyle = !stat.isPercentage && StatProvider.isFontFeatureEnable;
              /// Activate fontFeature only if StatMode is Ratio and isFontFeatureEnable is true for this device
              return RichText(
                text: TextSpan(
                  text: myStat,
                  style: Theme.of(context).textTheme.subtitle1.copyWith(
                    fontSize: fontFeatureStyle ? 22 : null,
                    fontFeatures: [
                      if(fontFeatureStyle) ui.FontFeature.enable('frac'),
                      if(!fontFeatureStyle) ui.FontFeature.tabularFigures()
                    ]
                  ),
                  children: [
                    TextSpan(
                      style: Theme.of(context).textTheme.subtitle1,
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
    Duration duration = const Duration(milliseconds: 300),
    this.child,
    Curve curve = Curves.linear
  }) : super(duration: duration, curve: curve, key: key);

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() => _AnimatedRadialState();
}

class _AnimatedRadialState extends AnimatedWidgetBaseState<_AnimatedRadial> {
  Tween<double> _percentage;
  ColorTween _color;
  Tween<double> _opacity;
  Animation<double> _opacityAnimation;

  @override
  void forEachTween(TweenVisitor visitor) {
    Color color =
      widget.percentage == 0.0 ? const Color(0xFF2B2922) :
      widget.percentage <= 0.25 ? Colors.red[300] :
      widget.percentage <= 0.50 ? Colors.yellow[300] :
      widget.percentage <= 0.75 ? Colors.amber[300] :
      widget.percentage < 1.0 ? Colors.lightGreen[300] :
      Colors.green[800];

    _color = visitor(_color, color, (dynamic value) => ColorTween(begin: value));
    _percentage = visitor(_percentage, widget.percentage, (dynamic value) => Tween<double>(begin: value));
    _opacity = visitor(_opacity, widget.percentage == 1 ? 1.0 : 0.0, (dynamic value) => Tween<double>(begin: value));
  }

  @override
  void didUpdateTweens() {
    _opacityAnimation = animation.drive(_opacity);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RadialProgression(
        percent: _percentage.evaluate(animation),
        color: _color.evaluate(animation)
      ),
      willChange: true,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: widget.child,
      )
    );
  }
}