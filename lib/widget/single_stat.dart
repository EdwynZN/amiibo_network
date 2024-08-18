import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/model/stat.dart';
import 'package:amiibo_network/resources/resources.dart';
import 'package:amiibo_network/riverpod/preferences_provider.dart';
import 'package:amiibo_network/utils/stat_utils.dart';
import 'package:amiibo_network/utils/theme_extensions.dart';
import 'package:amiibo_network/widget/linear_stat_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SingleStat extends HookConsumerWidget {
  final Stat stat;

  const SingleStat({
    Key? key,
    required this.stat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final preference = theme.extension<PreferencesExtension>()!;
    final translate = S.of(context);
    final isPercentage =
        ref.watch(personalProvider.select((p) => p.usePercentage));
    final showOwnerDetails = ref.watch(ownTypesCategoryProvider);

    final Widget? values = useMemoized(
      () {
        final total = Chip(
          label: Text(
            stat.total.toString(),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          avatar: const ImageIcon(
            AssetImage('assets/collection/icon_1.webp'),
            size: 16.0,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 6.0,
            vertical: 4.0,
          ),
          visualDensity: const VisualDensity(
            horizontal: 4.0,
            vertical: -1.0,
          ),
        );
        final Widget ownedContainer = _StatContainer(
          indicatorColor: preference.ownContainer,
          title: translate.owned,
          subtitle: isPercentage
              ? StatUtils.parseStat(
                  stat.owned,
                  stat.total,
                  usePercentage: isPercentage,
                )
              : stat.owned.toString(),
        );
        final List<Widget> ownerDetailsList = showOwnerDetails && stat.owned > 0
          ? [
            _StatContainer(
              assetIcon: NetworkIcons.lockedBoxSelected,
              indicatorColor: preference.ownPrimary,
              title: translate.boxed,
              subtitle: stat.boxed.toString(),
            ),
            _StatContainer(
              assetIcon: NetworkIcons.openBoxSelected,
              indicatorColor: preference.ownPrimary,
              title: translate.unboxed,
              subtitle: stat.unboxed.toString(),
            ),
          ]
          : const [];
        final Widget wishedContainer = _StatContainer(
          indicatorColor: preference.wishContainer,
          title: translate.wished,
          subtitle: isPercentage
              ? StatUtils.parseStat(
                  stat.wished,
                  stat.total,
                  usePercentage: isPercentage,
                )
              : stat.wished.toString(),
        );

        return Wrap(
          alignment: WrapAlignment.start,
          runAlignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 6.0,
          spacing: 8.0,
          children: [
            total,
            ownedContainer,
            wishedContainer,
            ...ownerDetailsList,
          ],
        );
      },
      [
        isPercentage,
        showOwnerDetails,
        translate,
        preference,
        theme.disabledColor,
        stat,
      ],
    );

    return Card(
      color: theme.colorScheme.surface,
      elevation: 6.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 24,
              width: double.infinity,
              child: FittedBox(
                alignment: Alignment.center,
                child: Text(
                  stat.name,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.fade,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            if (stat.owned != 0 || stat.wished != 0)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AnimatedLineProgress(
                  showEmptyColor: false,
                  owned: stat.owned,
                  total: stat.total,
                  wished: stat.wished,
                ),
              )
            else ...[
              const Gap(8.0),
            ],
            if (values != null) values,
          ],
        ),
      ),
    );
  }
}

class _StatContainer extends StatelessWidget {
  final Color indicatorColor;
  final String title;
  final String subtitle;
  final String? assetIcon;

  const _StatContainer({
    // ignore: unused_element
    super.key,
    required this.indicatorColor,
    required this.title,
    required this.subtitle,
    this.assetIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Text.rich(
        TextSpan(
          children: [
            WidgetSpan(
              child: assetIcon == null
                  ? Icon(Icons.circle, size: 12.0, color: indicatorColor)
                  : ImageIcon(
                      AssetImage(assetIcon!),
                      size: 12.0,
                      color: indicatorColor,
                    ),
              alignment: PlaceholderAlignment.middle,
              baseline: TextBaseline.alphabetic,
            ),
            const WidgetSpan(
              child: SizedBox(width: 4.0),
              alignment: PlaceholderAlignment.middle,
              baseline: TextBaseline.ideographic,
            ),
            TextSpan(text: title),
            TextSpan(
              text: ' $subtitle',
              style: TextStyle(
                fontSize: 12.0,
                color: theme.colorScheme.onSurface.withOpacity(0.72),
                fontFeatures: const [
                  FontFeature.tabularFigures(),
                ],
              ),
            ),
          ],
        ),
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
        maxLines: 1,
      ),
    );
  }
}

class StatChip extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final Color foregroundColor;

  const StatChip({
    super.key,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(title),
      avatar: Icon(Icons.add),
      side: BorderSide(color: backgroundColor),
      color: WidgetStatePropertyAll(Theme.of(context).colorScheme.surface),
      elevation: 12.0,
      surfaceTintColor: backgroundColor,
      labelStyle: TextStyle(
        color: foregroundColor,
        fontWeight: FontWeight.bold,
        fontFeatures: [
          FontFeature.tabularFigures(),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 2.0,
        horizontal: 8.0,
      ),
      visualDensity: const VisualDensity(vertical: -1.0, horizontal: 4.0),
    );
  }
}
