import 'dart:math';
import 'package:amiibo_network/shared/utils/amiibo_asset_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

class ShimmerCard extends HookWidget {
  final AnimationController listenable;
  final bool isGrid;
  static final Random random = Random();

  ShimmerCard({Key? key, required this.listenable, this.isGrid = true})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color color = theme.colorScheme.primaryContainer;
    final int id = useMemoized(() => random.nextInt(70) + 1);
    final Widget child;
    if (isGrid) {
      child = Column(
        mainAxisAlignment: MainAxisAlignment.end,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Flexible(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset(amiiboAssetFromIndex(id), fit: .contain),
              ),
            ),
          ),
          Container(
            decoration: ShapeDecoration(
              color: Theme.of(context).primaryColorLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
              ),
            ),
            alignment: .center,
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: const Text(''),
          ),
        ],
      );
    } else {
      child = const SizedBox.expand();
    }

    return Card(
      child: AnimatedBuilder(
        child: child,
        animation: listenable,
        builder: (context, child) {
          return ShaderMask(
            blendMode: .srcIn,
            shaderCallback: (bounds) => LinearGradient(
              colors: [color, theme.cardColor, color],
              stops: [0.1, 0.2, 0.4],
              begin: Alignment.centerLeft,
              end: const Alignment(1.0, 0.3),
              tileMode: .repeated,
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
