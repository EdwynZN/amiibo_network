import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

class ShimmerCard extends HookWidget {
  final AnimationController listenable;
  static final Random random = Random();

  ShimmerCard({
    Key? key,
    required this.listenable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color color = theme.scaffoldBackgroundColor == Colors.black
        ? Colors.white24
        : Colors.black54;
    final int id = useMemoized(() => random.nextInt(70));
    final Widget child = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        Flexible(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.asset(
                'assets/collection/icon_${id+1}.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Container(
          decoration: ShapeDecoration(
            color: Theme.of(context).primaryColorLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(8),
              ),
            ),
          ),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: const Text(''),
        ),
      ],
    );
    return Card(
      child: AnimatedBuilder(
        child: child,
        animation: listenable,
        builder: (context, child) {
          return ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                color,
                theme.primaryColorDark,
                color,
              ],
              stops: [
                0.1,
                0.2,
                0.4,
              ],
              begin: Alignment.centerLeft,
              end: const Alignment(1.0, 0.3),
              tileMode: TileMode.repeated,
              transform: _SlidingGradientTransform(
                slidePercent: listenable.value,
              ),
            ).createShader(bounds),
            child: child,
          );
        },
      ),
    );
  }
}
