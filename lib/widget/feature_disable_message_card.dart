import 'package:amiibo_network/generated/l10n.dart';
import 'package:flutter/material.dart';

class FeatureDisableMessageCard extends StatelessWidget {
  const FeatureDisableMessageCard({super.key});

  @override
  Widget build(BuildContext context) {
    final S translate = S.of(context);
    final ThemeData theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: theme.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text.rich(
          TextSpan(
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.ideographic,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Icon(
                    Icons.warning_rounded,
                    size: 16.0,
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
              TextSpan(text: translate.hide_caution),
            ],
          ),
          softWrap: true,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onTertiaryContainer,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
