import 'package:amiibo_network/enum/amiibo_category_enum.dart';
import 'package:amiibo_network/model/amiibo.dart';
import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:amiibo_network/riverpod/query_provider.dart';
import 'package:amiibo_network/riverpod/select_provider.dart';
import 'package:amiibo_network/riverpod/service_provider.dart';
import 'package:amiibo_network/utils/theme_extensions.dart';
import 'package:amiibo_network/widget/amiibo_button_toggle.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:amiibo_network/model/selection.dart';

final _singleAmiibo = Provider.autoDispose.family<AsyncValue<Amiibo>, int>(
    (ref, index) =>
        ref.watch(amiiboHomeListProvider).whenData((value) => value[index]),
    name: 'Amiibo index ');

class AnimatedSelection extends StatefulHookConsumerWidget {
  final bool ignore;

  const AnimatedSelection({Key? key, this.ignore = false}) : super(key: key);

  @override
  ConsumerState<AnimatedSelection> createState() => _AnimatedSelectionState();
}

class _AnimatedSelectionState<T extends AnimatedSelection>
    extends ConsumerState<T> {
  void _onDoubleTap(int key) => context.push('/amiibo/$key');

  void _onTap(int key) {
    ref.read(serviceProvider.notifier).shift(key);
  }

  void _onLongPress(int key) => ref.read(selectProvider).onLongPress(key);

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(indexAmiiboProvider);
    final key = ref.watch(keyAmiiboProvider);
    final select = ref.watch(
      selectProvider.select<Selection>(
        (cb) => Selection(
          activated: cb.multipleSelected,
          selected: cb.isSelected(key),
        ),
      ),
    );
    return ref.watch(_singleAmiibo(index)).when(
          loading: () => const Card(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, __) => const Card(),
          data: (amiibo) {
            final theme = Theme.of(context);
            ShapeBorder? cardShape = theme.cardTheme.shape;
            Border? border;
            Color? color;
            final preferencesPalette = theme.extension<PreferencesExtension>()!;
            if (amiibo.wishlist) {
              color = preferencesPalette.wishContainer;
            } else if (amiibo.owned) {
              color = preferencesPalette.ownContainer;
            }
            if (select.selected) {
              final side = BorderSide(
                color: ElevationOverlay.applySurfaceTint(
                  theme.colorScheme.secondary,
                  theme.cardTheme.surfaceTintColor,
                  12.0,
                ),
                width: 4.0,
              );
              border = Border(left: side, right: side, top: side);
              cardShape =
                  cardShape == null ? cardShape ?? border : border + cardShape;
            }

            final hasAttribute = amiibo.wishlist || amiibo.owned;

            return Card(
              elevation: hasAttribute ? 12.0 : 6.0,
              color: hasAttribute ? color : theme.scaffoldBackgroundColor,
              shadowColor: Colors.black12,
              borderOnForeground: true,
              clipBehavior: Clip.antiAlias,
              shape: cardShape,
              child: InkWell(
                splashColor: theme.colorScheme.tertiaryContainer,
                splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
                onDoubleTap: select.activated || widget.ignore
                    ? null
                    : () => _onDoubleTap(key),
                onTap: () {
                  if (widget.ignore) {
                    _onDoubleTap(key);
                  } else if (select.activated) {
                    _onLongPress(key);
                  } else {
                    _onTap(key);
                  }
                },
                onLongPress: widget.ignore ? null : () => _onLongPress(key),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    Flexible(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Hero(
                            placeholderBuilder: (context, size, child) {
                              final Color color =
                                  theme.brightness == Brightness.dark
                                      ? Colors.white24
                                      : Colors.black54;
                              return ColorFiltered(
                                colorFilter:
                                    ColorFilter.mode(color, BlendMode.srcIn),
                                child: child,
                              );
                            },
                            transitionOnUserGestures: true,
                            tag: amiibo.key,
                            child: Image.asset(
                              'assets/collection/icon_${amiibo.key}.webp',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Card(
                      borderOnForeground: true,
                      margin: EdgeInsets.zero,
                      color: select.selected
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.surfaceVariant,
                      elevation: 12.0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(8),
                        ),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(
                          left: 5.0,
                          right: 5.0,
                          bottom: 2.0,
                        ),
                        child: Text(
                          amiibo.name,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: theme.primaryTextTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: select.selected
                                ? theme.colorScheme.onSecondary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
  }
}

class AnimatedSelectedListTile extends AnimatedSelection {
  final Amiibo amiibo;

  const AnimatedSelectedListTile({
    super.key,
    super.ignore,
    required this.amiibo,
  });

  @override
  ConsumerState<AnimatedSelectedListTile> createState() =>
      _AnimatedSelectedListTileState();
}

class _AnimatedSelectedListTileState
    extends _AnimatedSelectionState<AnimatedSelectedListTile> {
  @override
  Widget build(BuildContext context) {
    final useSerie = ref.watch(queryProvider.notifier.select((q) {
      final category = q.search.category;
      return category != AmiiboCategory.FigureSeries &&
          category != AmiiboCategory.CardSeries;
    }));
    final key = widget.amiibo.key;
    final select = ref.watch(
      selectProvider.select<Selection>(
        (cb) => Selection(
          activated: cb.multipleSelected,
          selected: cb.isSelected(key),
        ),
      ),
    );
    final theme = Theme.of(context);

    final asset = Material(
      elevation: select.selected ? 12.0 : 2.0,
      color: theme.colorScheme.background,
      surfaceTintColor: theme.colorScheme.primary,
      type: MaterialType.card,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6.0, 12.0, 6.0, 6.0),
        child: _ListAmiiboAsset(
          amiiboKey: widget.amiibo.key,
          name: widget.amiibo.name,
        ),
      ),
    );

    final info = _AmiiboListInfo.fromAmiibo(
      amiibo: widget.amiibo,
      useSerie: useSerie,
      style: theme.primaryTextTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );

    final bool disable = widget.ignore || select.activated;
    final buttons = Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WishedButton(amiibo: widget.amiibo, isLock: disable),
          const Gap(4.0),
          OwnedButton(amiibo: widget.amiibo, isLock: disable),
        ],
      ),
    );

    return Card(
      elevation: 0.0,
      color: Colors.transparent,
      borderOnForeground: true,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        side: BorderSide(
          color: theme.colorScheme.primary,
          style: BorderStyle.solid,
          width: select.selected ? 3.0 : 0.75,
        ),
      ),
      child: InkWell(
        splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
        onTap: () {
          if (select.activated) {
            _onLongPress(key);
          } else {
            _onDoubleTap(key);
          }
        },
        onLongPress: widget.ignore ? null : () => _onLongPress(key),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(child: asset),
            Expanded(flex: 3, child: info),
            SizedBox(width: 64.0, child: buttons),
          ],
        ),
      ),
    );
  }
}

class _ListAmiiboAsset extends StatelessWidget {
  final int amiiboKey;
  final String name;

  const _ListAmiiboAsset({
    // ignore: unused_element
    super.key,
    required this.amiiboKey,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ShaderMask(
      shaderCallback: (rect) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Colors.black, Colors.transparent],
          stops: const [0.80, 1.0],
        ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
      },
      blendMode: BlendMode.dstIn,
      child: Hero(
        placeholderBuilder: (context, size, child) {
          final Color color = theme.brightness == Brightness.dark
              ? Colors.white24
              : Colors.black54;
          return ColorFiltered(
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            child: child,
          );
        },
        transitionOnUserGestures: true,
        tag: amiiboKey,
        child: Image.asset(
          'assets/collection/icon_$amiiboKey.webp',
          fit: BoxFit.contain,
          alignment: Alignment.center,
          semanticLabel: name,
          height: 104.0,
          cacheHeight: 104,
        ),
      ),
    );
  }
}

class _AmiiboListInfo extends StatelessWidget {
  final TextStyle? style;
  final String name;
  final String game;
  final String serie;
  final String? type;
  final String? cardNumber;
  final bool useSerie;

  const _AmiiboListInfo({
    // ignore: unused_element
    super.key,
    required this.name,
    required this.game,
    required this.serie,
    required this.useSerie,
    // ignore: unused_element
    this.cardNumber,
    // ignore: unused_element
    this.type,
    // ignore: unused_element
    this.style,
  });

  _AmiiboListInfo.fromAmiibo({
    // ignore: unused_element
    super.key,
    required Amiibo amiibo,
    required this.useSerie,
    this.style,
  })  : name = amiibo.name,
        game = amiibo.gameSeries,
        serie = amiibo.amiiboSeries,
        type = amiibo.type,
        cardNumber = amiibo.type != 'Card' || amiibo.cardNumber == null
            ? null
            : amiibo.cardNumber.toString();

  @override
  Widget build(BuildContext context) {
    const subtitleStyle = TextStyle(fontSize: 14.0);
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: cardNumber == null ? null : '#${cardNumber!} ',
              children: [
                TextSpan(text: name),
              ],
            ),
            style: style,
            softWrap: false,
            overflow: TextOverflow.fade,
            maxLines: 1,
          ),
          const Gap(2.0),
          Text(
            useSerie ? serie : game,
            style: style?.merge(subtitleStyle) ?? subtitleStyle,
            softWrap: false,
            overflow: TextOverflow.fade,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
