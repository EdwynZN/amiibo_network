import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

SkeletonizerConfigData mapToSkeletonizer(ThemeData theme) {
  final scheme = theme.colorScheme;
  return SkeletonizerConfigData(
    effectResolver: (_) => PulseEffect(
      duration: const .new(seconds: 1, milliseconds: 600),
      lowerBound: .25,
      upperBound: .75,
      from: theme.disabledColor,
      to: theme.highlightColor,
    ),
    containersColor: scheme.primaryContainer,
    textBorderRadius: const .fromHeightFactor(0.25),
  );
}
