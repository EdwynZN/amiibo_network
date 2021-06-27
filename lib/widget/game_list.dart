import 'dart:io';

import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/model/game.dart';
import 'package:amiibo_network/resources/resources.dart';
import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:amiibo_network/riverpod/game_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'dart:math' as math;

class GameListWidget extends ConsumerWidget {
  const GameListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final id = watch(keyAmiiboProvider);
    final S translate = S.of(context);
    return watch(gameProvider(id)).when(
      data: (platforms) {
        return MultiSliver(
          children: [
            if (platforms.games3DS != null && platforms.games3DS!.isNotEmpty)
              _PlatformGameList(
                games: platforms.games3DS!,
                title: translate.console_3DS_platform,
                asset: NetworkIcons.dsPlatform,
              ),
            if (platforms.gamesWiiU != null && platforms.gamesWiiU!.isNotEmpty)
              _PlatformGameList(
                games: platforms.gamesWiiU!,
                title: translate.wiiu_platform,
                asset: NetworkIcons.wiiUPlatform,
              ),
            if (platforms.gamesSwitch != null &&
                platforms.gamesSwitch!.isNotEmpty)
              _PlatformGameList(
                games: platforms.gamesSwitch!,
                title: translate.switch_platform,
                asset: NetworkIcons.switchPlatform,
              ),
          ],
        );
      },
      loading: () => const SliverToBoxAdapter(child: LinearProgressIndicator()),
      error: (e, _) {
        late final Widget child;
        if (e is DioError) {
          if (e.type == DioErrorType.response && e.response != null)
            switch (e.response!.statusCode) {
              case 404:
                child = Text(translate.no_games_found);
                break;
              default:
                child = Text(e.response!.statusMessage ?? translate.no_games_found);
                break;
            }
          else if (e.error is SocketException && e.error.osError != null) {
            child = Text(e.error.osError!.message);
          } else
            child = Text(e.message);
        } else if (e is ArgumentError) {
          child = Text(translate.no_games_found);
        } else if (e is SocketException) {
          child = Text(e.osError?.message ?? e.message);
        } else
          child = Text(e.toString());
        return SliverToBoxAdapter(
          child: Center(
            child: DefaultTextStyle.merge(
              style: Theme.of(context).textTheme.headline4,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _PlatformGameList extends StatelessWidget {
  final List<Game> games;
  final String title;
  final String asset;

  const _PlatformGameList({
    Key? key,
    required this.games,
    required this.title,
    required this.asset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showUsage =
        Localizations.localeOf(context).languageCode.contains('en');
    final delegate = SliverChildBuilderDelegate(
      (context, index) {
        if (index.isOdd)
          return const Divider(
            height: 0.0,
            indent: 16.0,
            endIndent: 16.0,
            thickness: 1.0,
          );
        final int itemIndex = index ~/ 2;
        if (!showUsage || games[itemIndex].usage == null 
          || games[itemIndex].usage!.isEmpty)
          return ListTile(
            minVerticalPadding: kMaterialListPadding.vertical,
            title: Text(games[itemIndex].name),
          );
        final bool unique = games[itemIndex].usage!.length == 1;
        final String text = games[itemIndex].usage!.first.use;
        late final Widget subtitle;
        if (unique) {
          subtitle = _Subtitle(subtitle: text);
          return ListTile(
            minVerticalPadding: kMaterialListPadding.vertical,
            title: Text(games[itemIndex].name),
            subtitle: subtitle,
            isThreeLine: true,
          );
        }
        subtitle = _Subtitle(
          subtitle: text,
          count: games[itemIndex].usage!.length - 1,
        );
        return Theme(
          data: theme.copyWith(
            dividerColor: Colors.transparent,
          ),
          child: ExpansionTile(
            title: Text(games[itemIndex].name),
            subtitle: subtitle,
            children: [
              for (AmiiboUsage usage in games[itemIndex].usage!.sublist(1))
                ListTile(
                  dense: true,
                  title: Text(usage.use, style: theme.textTheme.subtitle2),
                ),
            ],
          ),
        );
      },
      childCount: math.max(0, games.length * 2 - 1),
    );
    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverAnimatedPersistentHeader(
            title: title,
            asset: asset,
          ),
        ),
        SliverList(
          delegate: delegate,
        ),
      ],
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle({
    Key? key,
    required this.subtitle,
    this.count,
  }) : super(key: key);

  final String subtitle;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final S translate = S.of(context);
    final theme = Theme.of(context);
    return Text.rich(
      TextSpan(
        text: subtitle,
        children: count == null
            ? null
            : [
                const TextSpan(text: ' '),
                TextSpan(
                  text: translate.amiibo_usage_count(count!),
                  style: theme.primaryTextTheme.subtitle2?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
      ),
      style: theme.primaryTextTheme.subtitle2,
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
    );
  }
}

class _SliverAnimatedPersistentHeader extends SliverPersistentHeaderDelegate {
  final double _maxExtent;
  final double _minExtent;
  final String title;
  final String asset;

  const _SliverAnimatedPersistentHeader({
    this.vsync,
    required this.title,
    required this.asset,
  })  : _maxExtent = kToolbarHeight,
        _minExtent = kToolbarHeight,
        super();

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    final appBarTheme = AppBarTheme.of(context);
    final bool isPinned = shrinkOffset > maxExtent - minExtent;
    return SizedBox(
      height: math.max(minExtent, maxExtent - shrinkOffset),
      child: AnimatedPhysicalModel(
        duration: kThemeAnimationDuration,
        child: ListTileTheme.merge(
          textColor:
              isPinned ? appBarTheme.iconTheme?.color : theme.iconTheme.color,
          iconColor: isPinned
              ? appBarTheme.color ?? theme.iconTheme.color
              : theme.iconTheme.color,
          child: ListTile(
            leading: Image.asset(asset,
              cacheHeight: 24,
              cacheWidth: 24,
              height: 24,
              width: 24,
              colorBlendMode: BlendMode.srcATop,
              color: isPinned
                  ? appBarTheme.iconTheme?.color
                  : theme.iconTheme.color,
            ),
            title: Text(
              title,
            ),
          ),
        ),
        shape: BoxShape.rectangle,
        animateShadowColor: false,
        elevation: isPinned ? 8.0 : 0.0,
        color: isPinned
            ? AppBarTheme.of(context).backgroundColor ?? theme.primaryColor
            : theme.cardColor,
        shadowColor: theme.shadowColor,
      ),
    );
  }

  @override
  final TickerProvider? vsync;

  @override
  double get maxExtent => _maxExtent;

  @override
  double get minExtent => _minExtent;

  @override
  bool shouldRebuild(_SliverAnimatedPersistentHeader oldDelegate) {
    return asset != oldDelegate.asset && title != oldDelegate.title;
  }
}
