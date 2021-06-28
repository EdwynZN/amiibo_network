import 'package:amiibo_network/model/stat.dart';
import 'package:amiibo_network/repository/theme_repository.dart';
import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;
import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/widget/stat_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SliverStatsHeader extends SliverPersistentHeaderDelegate {
  const SliverStatsHeader();

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final Color _color = Theme.of(context).appBarTheme.color!;
    final S? translate = S.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [
              0.35,
              0.65,
              0.9
            ],
            colors: [
              _color,
              _color.withOpacity(0.75),
              _color.withOpacity(0.0),
            ]),
      ),
      height: math.max(minExtent, maxExtent - shrinkOffset),
      child: Consumer(
        child: const SizedBox(),
        builder: (context, watch, child) {
          return watch(statHomeProvider).maybeWhen(
            data: (statList) {
              if (statList == const Stat()) return child!;
              final double total = statList.total.toDouble();
              final double owned = statList.owned.toDouble();
              final double wished = statList.wished.toDouble();
              if (total == 0 && owned == 0 && wished == 0) return child!;
              return Row(
                children: <Widget>[
                  Expanded(
                    child: StatWidget(
                      numerator: owned,
                      den: total,
                      text: translate!.owned,
                      icon: Icon(iconOwnedDark, color: Colors.green[800]),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: StatWidget(
                      numerator: wished,
                      den: total,
                      text: translate.wished,
                      icon: Icon(Icons.whatshot, color: Colors.amber[800]),
                    ),
                  ),
                ],
              );
            },
            orElse: (() => child!),
          );
        }),
    );
  }

  @override
  double get maxExtent => kToolbarHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}