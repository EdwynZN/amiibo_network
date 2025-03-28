// ignore_for_file: unused_element

import 'dart:io';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/model/game.dart';
import 'package:amiibo_network/resources/resources.dart';
import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:amiibo_network/riverpod/game_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'dart:math' as math;

class GameListWidget extends ConsumerWidget {
  const GameListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(keyAmiiboProvider);
    final S translate = S.of(context);
    return ref.watch(gameProvider(id)).when(
          skipLoadingOnRefresh: false,
          data: (platforms) {
            final games = <Widget>[
              if (platforms.gamesSwitch != null &&
                  platforms.gamesSwitch!.isNotEmpty)
                _PlatformGameList(
                  games: platforms.gamesSwitch!,
                  title: translate.switch_platform,
                  asset: NetworkIcons.switchPlatform,
                ),
              if (platforms.games3DS != null && platforms.games3DS!.isNotEmpty)
                _PlatformGameList(
                  games: platforms.games3DS!,
                  title: translate.console_3DS_platform,
                  asset: NetworkIcons.dsPlatform,
                ),
              if (platforms.gamesWiiU != null &&
                  platforms.gamesWiiU!.isNotEmpty)
                _PlatformGameList(
                  games: platforms.gamesWiiU!,
                  title: translate.wiiu_platform,
                  asset: NetworkIcons.wiiUPlatform,
                ),
            ];
            if (games.isEmpty) {
              games.add(const _EmptyGames());
            }
            return MultiSliver(children: games);
          },
          loading: () =>
              const SliverToBoxAdapter(child: LinearProgressIndicator()),
          error: (e, _) {
            late final Widget child;
            if (e is DioException) {
              if (e.response != null)
                switch (e.response!.statusCode) {
                  case 404:
                    child = const _EmptyGames();
                    break;
                  default:
                    child = Text(
                      e.response!.statusMessage ?? translate.no_games_found,
                      textAlign: TextAlign.center,
                    );
                    break;
                }
              else if (e.error is SocketException &&
                  (e.error as SocketException).osError != null) {
                child = TextButton(
                  onPressed: () => ref.invalidate(gameProvider(id)),
                  child: Text(translate.socket_exception),
                );
              } else
                child = Text(e.message ?? e.type.name);
            } else if (e is ArgumentError) {
              child =
                  Text(translate.no_games_found, textAlign: TextAlign.center);
            } else if (e is SocketException) {
              child = TextButton(
                onPressed: () => ref.invalidate(gameProvider(id)),
                child: Text(translate.socket_exception),
              );
            } else
              child = Text(e.toString());
            return SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: DefaultTextStyle.merge(
                    style: Theme.of(context).textTheme.headlineMedium,
                    child: child,
                  ),
                ),
              ),
            );
          },
        );
  }
}

class _EmptyGames extends StatelessWidget {
  const _EmptyGames();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          ImageIcon(
            const AssetImage(GameIcons.nintendoSwitch),
            size: 196,
            color: theme.colorScheme.primary,
          ),
          const Gap(12),
          SizedBox(
            width: 340.0,
            child: Text(
              S.of(context).no_games_found,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 24.0,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
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
        final game = games[itemIndex];
        if (!showUsage || game.usage == null || game.usage!.isEmpty)
          return ListTile(
            minVerticalPadding: kMaterialListPadding.vertical,
            title: Text(game.name),
          );
        final bool unique = game.usage!.length == 1;
        final String text = game.usage!.first.use;
        late final Widget subtitle;
        if (unique) {
          subtitle = _Subtitle(subtitle: text);
          return ListTile(
            minVerticalPadding: kMaterialListPadding.vertical,
            title: Text(game.name),
            subtitle: subtitle,
            isThreeLine: true,
          );
        }
        subtitle = _Subtitle(
          subtitle: text,
          count: game.usage!.length - 1,
        );
        return Theme(
          data: theme.copyWith(
            dividerColor: Colors.transparent,
          ),
          child: ExpansionTile(
            title: Text(game.name),
            subtitle: subtitle,
            children: [
              for (AmiiboUsage usage in game.usage!.sublist(1))
                ListTile(
                  dense: true,
                  title: Text(usage.use, style: theme.textTheme.titleSmall),
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
                  style: theme.primaryTextTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
      ),
      style: theme.primaryTextTheme.labelLarge?.copyWith(
        color: theme.colorScheme.onSurface,
        letterSpacing: 0.15,
      ),
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
    // ignore: unused_element_parameter
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
    final Color color;
    final double elevation;
    if (isPinned) {
      elevation = appBarTheme.scrolledUnderElevation ?? 4.0;
      color = ElevationOverlay.applySurfaceTint(
        appBarTheme.backgroundColor ?? theme.primaryColor,
        appBarTheme.surfaceTintColor,
        elevation,
      );
    } else {
      elevation = 2.0;
      color = ElevationOverlay.applySurfaceTint(
        appBarTheme.backgroundColor ?? theme.primaryColor,
        appBarTheme.surfaceTintColor,
        elevation,
      );
    }
    return SizedBox(
      height: math.max(minExtent, maxExtent - shrinkOffset),
      child: AnimatedPhysicalModel(
        duration: kThemeAnimationDuration,
        child: ListTileTheme.merge(
          horizontalTitleGap: 32.0,
          textColor:
              isPinned ? appBarTheme.iconTheme?.color : theme.iconTheme.color,
          iconColor: isPinned
              ? appBarTheme.backgroundColor ?? theme.iconTheme.color
              : theme.iconTheme.color,
          child: ListTile(
            leading: Image.asset(
              asset,
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
        elevation: 0,
        color: color,
        shadowColor: theme.colorScheme.shadow,
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
