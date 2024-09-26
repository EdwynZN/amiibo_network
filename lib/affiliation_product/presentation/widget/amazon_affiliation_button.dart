import 'package:amiibo_network/resources/resources.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

/// Amazon branding color
const amazonColor = Color(0xFFFF9900);

class AmazonAffiliationButton extends HookConsumerWidget {
  const AmazonAffiliationButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const amazonColor = Color(0xFFFF9900);
    return ElevatedButton.icon(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((state) {
          final color = ElevatedButtonTheme.of(context)
              .style
              ?.backgroundColor
              ?.resolve(state);
          if (color != null) {
            final int value = Blend.hctHue(
              color.value,
              amazonColor.value,
              0.75,
            );
            return Color(value);
          }
          return color;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((state) {
          final color = ElevatedButtonTheme.of(context)
              .style
              ?.foregroundColor
              ?.resolve(state);
          if (color != null) {
            final int value = Blend.hctHue(
              color.value,
              amazonColor.value,
              0.5,
            );
            return Color(value);
          }
          return color;
        }),
      ),
      onPressed: () {},
      icon: ImageIcon(AssetImage(NetworkIcons.amazon)),
      label: Text('Buy in Amazon'),
    );
  }
}

class AmazonAffiliationIconButton extends HookConsumerWidget {
  const AmazonAffiliationIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = ElevatedButtonTheme.of(context).style;
    return IconButton.filledTonal(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((state) {
          final color = style
              ?.backgroundColor
              ?.resolve(state);
          if (color != null) {
            final int value = Blend.hctHue(color.value,
              amazonColor.value,
              0.15,
            );
            return Color(value);
          }
          return color;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((state) {
          final color = style
              ?.foregroundColor
              ?.resolve(state);
          if (color != null) {
            final int value = Blend.hctHue(
              color.value,
              amazonColor.value,
              0.25,
            );
            return Color(value);
          }
          return color;
        }),
      ),
      onPressed: () {},
      icon: ImageIcon(AssetImage(NetworkIcons.amazon)),
    );
  }
}
