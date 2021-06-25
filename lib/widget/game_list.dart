import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/model/game.dart';
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
                asset: 'ds',
              ),
            if (platforms.gamesWiiU != null && platforms.gamesWiiU!.isNotEmpty)
              _PlatformGameList(
                games: platforms.gamesWiiU!,
                title: translate.wiiu_platform,
                asset: 'wiiu',
              ),
            if (platforms.gamesSwitch != null &&
                platforms.gamesSwitch!.isNotEmpty)
              _PlatformGameList(
                games: platforms.gamesSwitch!,
                title: translate.switch_platform,
                asset: 'switch',
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
                child = Text('No games for this amiibo yet');
                break;
              default:
                child = Text(e.response!.statusMessage ?? '');
                break;
            }
          else
            child = Text(e.message);
        } else if (e is ArgumentError) {
          child = Text('Invalid amiibo data');
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
    final delegate = SliverChildBuilderDelegate(
      (context, index) {
        Widget? subtitle;
        final bool unique =
            Localizations.localeOf(context).languageCode.contains('en') &&
                (games[index].usage == null || games[index].usage!.length == 1);
        if (unique) {
          subtitle = Text(
            games[index].usage!.first.uses,
            style: theme.primaryTextTheme.subtitle2,
            maxLines: 2,
          );
        }
        return DecoratedBox(
          decoration: BoxDecoration(
            border: index == 0
                ? Border()
                : Border(
                    top: BorderSide(
                      color: theme.dividerColor,
                    ),
                  ),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            minVerticalPadding: kMaterialListPadding.vertical,
            title: Text(games[index].name),
            subtitle: subtitle,
            isThreeLine: unique,
          ),
        );
      },
      childCount: games.length,
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
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          sliver: SliverList(
            delegate: delegate,
          ),
        )
      ],
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
            leading: Image.asset(
              'assets/images/$asset.png',
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
