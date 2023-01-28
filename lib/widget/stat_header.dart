import 'dart:math' as math;
import 'dart:ui';

import 'package:amiibo_network/enum/amiibo_category_enum.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/model/stat.dart';
import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:amiibo_network/riverpod/query_provider.dart';
import 'package:amiibo_network/riverpod/stat_provider.dart';
import 'package:amiibo_network/widget/linear_stat_widget.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SliverStatsHeader extends SliverPersistentHeaderDelegate {
  final bool hideOptional;

  const SliverStatsHeader({this.hideOptional = true});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final appbarTheme = AppBarTheme.of(context);
    final _elevation = appbarTheme.elevation ?? 0.0;
    final firstColor = appbarTheme.backgroundColor ?? Colors.white;
    final bool isScrolledUnder =
        overlapsContent || shrinkOffset > maxExtent - minExtent;
    final Color _color = ElevationOverlay.applySurfaceTint(
      firstColor,
      appbarTheme.surfaceTintColor,
      isScrolledUnder
          ? _elevation * 2.0 > 4.0
              ? _elevation * 2.0
              : 4.0
          : _elevation,
    );
    final Widget child = Container(
      height: math.max(minExtent, maxExtent - shrinkOffset),
      padding: const EdgeInsets.fromLTRB(6.0, 6.0, 6.0, 0.0),
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.20, 0.50, 1.0],
          colors: [
            _color,
            _color.withOpacity(0.75),
            _color.withOpacity(0.25),
          ],
        ),
      ),
      child: Visibility(
        visible: hideOptional,
        child: const _LinearStat(),
      ),
    );
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 3.0,
          sigmaY: 3.0,
          tileMode: TileMode.decal,
        ),
        child: child,
      ),
    );
  }

  @override
  double get maxExtent => kToolbarHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}

class _LinearStat extends ConsumerWidget {
  const _LinearStat({
    // ignore: unused_element
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statList = ref.watch(statHomeProvider.select((s) => s.valueOrNull));
    if (statList == null || statList == const Stat()) {
      return const SizedBox();
    }
    final int total = statList.total;
    final int owned = statList.owned;
    final int wished = statList.wished;
    if (total == 0 && owned == 0 && wished == 0) {
      return const SizedBox();
    }
    final category = ref.watch(
      queryProvider.notifier.select((value) => value.search.category),
    );
    final stats = ref.watch(statProvider);
    final usePercentage = stats.isPercentage;
    final String ownedStat;
    final String wishedStat;
    if (usePercentage) {
      ownedStat = stats.statLabel(owned, total);
      wishedStat = stats.statLabel(wished, total);
    } else {
      ownedStat = owned.toString();
      wishedStat = wished.toString();
    }
    final translate = S.of(context);
    final theme = Theme.of(context);
    final ownedText = translate.owned;
    final wishedText = translate.wished;
    final style = theme.textTheme.labelLarge;
    return Container(
      constraints: BoxConstraints.loose(const Size.fromWidth(360.0)),
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              category == AmiiboCategory.Wishlist
                  ? const Spacer()
                  : Expanded(
                      child: Text(
                        '$ownedStat $ownedText',
                        style: style,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                    ),
              Expanded(
                child: Text(
                  statList.total.toString(),
                  style: style,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
              ),
              category == AmiiboCategory.Owned
                  ? const Spacer()
                  : Expanded(
                      child: Text(
                        '$wishedStat $wishedText',
                        style: style,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                    ),
            ],
          ),
          const SizedBox(height: 4.0),
          AnimatedLineProgress(
            size: const Size(360.0, 8.0),
            owned: owned,
            total: total,
            wished: wished,
          ),
        ],
      ),
    );
  }
}
