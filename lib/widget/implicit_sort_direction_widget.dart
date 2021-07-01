import 'package:amiibo_network/enum/sort_enum.dart';
import 'package:flutter/material.dart';

class ImplicitDirectionIconButton extends ImplicitlyAnimatedWidget {
  final SortBy direction;
  final double angle;

  const ImplicitDirectionIconButton({
    Key? key,
    Duration duration = kTabScrollDuration,
    Curve curve = Curves.linear,
    this.direction = SortBy.ASC,
  })  : angle = direction == SortBy.DESC ? 0.5 : 0,
        super(
          key: key,
          duration: duration,
          curve: curve,
        );

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() =>
      _ImplicitDirection();
}

class _ImplicitDirection
    extends ImplicitlyAnimatedWidgetState<ImplicitDirectionIconButton> {
  Tween<double>? _progress;

  @override
  void forEachTween(visitor) {
    _progress = visitor(_progress, widget.angle,
        (value) => Tween<double>(begin: value as double)) as Tween<double>;
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _progress!.animate(animation),
      child: const Icon(Icons.arrow_upward_outlined),
    );
  }
}