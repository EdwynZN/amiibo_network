import 'dart:math' as math;
import 'dart:ui';

import 'package:amiibo_network/enum/amiibo_category_enum.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/model/stat.dart';
import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:amiibo_network/riverpod/preferences_provider.dart';
import 'package:amiibo_network/riverpod/query_provider.dart';
import 'package:amiibo_network/utils/stat_utils.dart';
import 'package:amiibo_network/widget/linear_stat_widget.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SliverStatsHeader extends SliverPersistentHeaderDelegate {
  final double topPadding;

  const SliverStatsHeader({
    required this.topPadding,
  }) : assert(topPadding >= 0.0);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final appbarTheme = AppBarTheme.of(context);
    final _elevation = appbarTheme.elevation ?? 0.0;
    final firstColor = appbarTheme.backgroundColor ?? Theme.of(context).canvasColor;
    final bool isScrolledUnder =
        overlapsContent || shrinkOffset > maxExtent - minExtent;
    final BoxDecoration decoration;
    final Color _color = ElevationOverlay.applySurfaceTint(
      firstColor,
      appbarTheme.surfaceTintColor,
      isScrolledUnder
          ? (_elevation * 2.0).clamp(0.0, 4.0)
          : _elevation,
    );
    decoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.20, 0.50, 1.0],
        colors: [
          _color,
          _color.withValues(alpha: 0.75),
          _color.withValues(alpha: 0.25),
        ],
      ),
    );
    final Widget child = Container(
      height: math.max(minExtent, maxExtent - shrinkOffset),
      padding: const EdgeInsets.fromLTRB(6.0, 6.0, 6.0, 0.0),
      alignment: Alignment.bottomCenter,
      decoration: decoration,
      child: const _LinearStat(),
    );
    final double sigma = 5.0 * (shrinkOffset / minExtent).clamp(0.15, 1.0);
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: sigma,
          sigmaY: sigma,
          tileMode: TileMode.decal,
        ),
        child: child,
      ),
    );
  }

  @override
  double get maxExtent => minExtent;

  @override
  double get minExtent => 32.0 + topPadding;

  @override
  bool shouldRebuild(SliverStatsHeader oldDelegate) => true;
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
      queryProvider.select((value) => value.categoryAttributes.category),
    );
    final usePercentage =
        ref.watch(personalProvider.select((p) => p.usePercentage));
    final String ownedStat;
    final String wishedStat;
    if (usePercentage) {
      ownedStat =
          StatUtils.parseStat(owned, total, usePercentage: usePercentage);
      wishedStat =
          StatUtils.parseStat(wished, total, usePercentage: usePercentage);
    } else {
      ownedStat = owned.toString();
      wishedStat = wished.toString();
    }
    final translate = S.of(context);
    final theme = Theme.of(context);
    final ownedText = '$ownedStat ${translate.owned}';
    final wishedText = '$wishedStat ${translate.wished}';
    final style = theme.textTheme.labelLarge;
    final Widget title;
    final bool isWishlist = category == AmiiboCategory.Wishlist;
    final bool isOwn = category == AmiiboCategory.Owned;
    if (isWishlist || isOwn) {
      title = Text(
        isWishlist ? wishedText : ownedText,
        style: style,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.clip,
      );
    } else {
      title = Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: Text(
              ownedText,
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
          Expanded(
            child: Text(
              wishedText,
              style: style,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.clip,
            ),
          ),
        ],
      );
    }
    return Container(
      constraints: BoxConstraints.loose(const Size.fromWidth(360.0)),
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          title,
          const SizedBox(height: 2.0),
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
