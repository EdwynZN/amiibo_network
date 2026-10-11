import 'package:amiibo_network/entity/amiibo_info/model/amiibo_user_collection_attributes.dart';
import 'package:amiibo_network/entity/amiibo_info/model/amiibo_info.dart';
import 'package:amiibo_network/page/detail/widget/amiibo_button_toggle.dart';
import 'package:amiibo_network/page/home/controller/select_provider.dart';
import 'package:amiibo_network/page/home/model/selection.dart';
import 'package:amiibo_network/shared/utils/amiibo_asset_util.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class const AnimatedSelection({
  super.key,
  required final AmiiboInfo amiibo,
  final bool ignore = false,
}) extends StatefulHookConsumerWidget {
  @override
  ConsumerState<AnimatedSelection> createState() => _AnimatedSelectionState();
}

class _AnimatedSelectionState<T extends AnimatedSelection>
    extends ConsumerState<T> {
  void _onTap(int key, bool isLongPress, String? assetPath) {
    if (isLongPress) {
      ref.read(selectProvider.notifier).onLongPress(key);
    } else {
      context.push('/amiibo/$key', extra: assetPath);
    }
  }

  void _onLongPress(int key) =>
      ref.read(selectProvider.notifier).onLongPress(key);

  @override
  Widget build(BuildContext context) {
    final amiibo = widget.amiibo;
    final id = widget.amiibo.id;
    final select = ref.watch(
      selectProvider.select<Selection>(
        (cb) => Selection(activated: cb.isNotEmpty, selected: cb.contains(id)),
      ),
    );
    final theme = Theme.of(context);
    Color color = theme.scaffoldBackgroundColor;
    InteractiveInkFeatureFactory splashFactory =
        InkSparkle.constantTurbulenceSeedSplashFactory;
    if (select.selected) {
      splashFactory = NoSplash.splashFactory;
      color = ElevationOverlay.applySurfaceTint(
        theme.colorScheme.secondary,
        theme.cardTheme.surfaceTintColor,
        12.0,
      );
    }

    final bool disable = widget.ignore || select.activated;
    final isWishActive = amiibo.userAttributes is WishedUserAttributes;
    const size = Size.square(48.0);
    final buttons = Padding(
      padding: const .fromLTRB(4, 0, 4, 4),
      child: Row(
        mainAxisSize: .max,
        mainAxisAlignment: .center,
        crossAxisAlignment: .stretch,
        children: [
          OwnButton(
            amiiboId: id,
            isLock: disable,
            size: size,
            attributes: amiibo.userAttributes,
          ),
          const Gap(4.0),
          WishButton(
            amiiboId: id,
            isLock: disable,
            size: size,
            isActive: isWishActive,
          ),
        ],
      ),
    );

    final asset = amiiboAsset(amiibo.image);

    return Card(
      elevation: 6.0,
      margin: .zero,
      color: color,
      shadowColor: Colors.black12,
      borderOnForeground: true,
      clipBehavior: .antiAlias,
      child: InkWell(
        splashColor: theme.colorScheme.tertiaryContainer,
        splashFactory: splashFactory,
        onTap: () => _onTap(id, select.activated, asset),
        onLongPress: widget.ignore ? null : () => _onLongPress(id),
        child: Column(
          mainAxisAlignment: .end,
          textBaseline: .alphabetic,
          children: [
            Flexible(
              child: Padding(
                padding: const .fromLTRB(8, 8, 8, 8),
                child: Hero(
                  placeholderBuilder: (context, size, child) {
                    final Color color = theme.brightness == .dark
                        ? Colors.white24
                        : Colors.black54;
                    return ColorFiltered(
                      colorFilter: .mode(color, .srcIn),
                      child: child,
                    );
                  },
                  transitionOnUserGestures: true,
                  tag: asset,
                  child: Image.asset(
                    asset,
                    fit: .contain,
                    alignment: .bottomCenter,
                  ),
                ),
              ),
            ),
            AnimatedOpacity(
              duration: .new(milliseconds: 200),
              opacity: select.selected ? 0 : 1,
              child: SizedBox(height: 32, child: buttons),
            ),
          ],
        ),
      ),
    );
  }
}

class const AnimatedSelectedListTile({
  super.key,
  super.ignore,
  required super.amiibo,
}) extends AnimatedSelection {
  @override
  ConsumerState<AnimatedSelectedListTile> createState() =>
      _AnimatedSelectedListTileState();
}

class _AnimatedSelectedListTileState
    extends _AnimatedSelectionState<AnimatedSelectedListTile> {
  @override
  Widget build(BuildContext context) {
    final amiibo = widget.amiibo;
    final id = widget.amiibo.id;
    final select = ref.watch(
      selectProvider.select<Selection>(
        (cb) => Selection(activated: cb.isNotEmpty, selected: cb.contains(id)),
      ),
    );
    final theme = Theme.of(context);
    final image = amiiboAsset(amiibo.image);

    final asset = Material(
      elevation: select.selected ? 12.0 : 2.0,
      color: theme.colorScheme.surface,
      surfaceTintColor: theme.colorScheme.primary,
      type: MaterialType.card,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6.0, 12.0, 6.0, 6.0),
        child: _ListAmiiboAsset(amiiboKey: id, name: amiibo.name, asset: image),
      ),
    );

    final info = _AmiiboListInfo(
      name: amiibo.name,
      serie: amiibo.series,
      cardNumber: null,
      style: theme.primaryTextTheme.bodyLarge?.copyWith(
        fontWeight: .bold,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );

    final bool disable = widget.ignore || select.activated;

    final isWishActive = amiibo.userAttributes is WishedUserAttributes;
    final buttons = Padding(
      padding: const .all(4.0),
      child: Column(
        mainAxisSize: .max,
        mainAxisAlignment: .center,
        crossAxisAlignment: .stretch,
        children: [
          OwnButton(
            amiiboId: id,
            isLock: disable,
            attributes: amiibo.userAttributes,
          ),
          const Gap(4.0),
          WishButton(amiiboId: id, isLock: disable, isActive: isWishActive),
        ],
      ),
    );

    return Card(
      elevation: 0.0,
      color: Colors.transparent,
      borderOnForeground: true,
      clipBehavior: .hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: const .all(.circular(12.0)),
        side: BorderSide(
          color: theme.colorScheme.primary,
          style: .solid,
          width: select.selected ? 3.0 : 0.75,
        ),
      ),
      child: InkWell(
        splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
        onTap: () => _onTap(id, select.activated, image),
        onLongPress: widget.ignore ? null : () => _onLongPress(id),
        child: Row(
          mainAxisAlignment: .start,
          textBaseline: .alphabetic,
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

class const _ListAmiiboAsset({
  required final int amiiboKey,
  required final String name,
  required final String asset,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ShaderMask(
      shaderCallback: (rect) {
        return LinearGradient(
          begin: .topCenter,
          end: .bottomCenter,
          colors: const [Colors.black, Colors.transparent],
          stops: const [0.80, 1.0],
        ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
      },
      blendMode: .dstIn,
      child: Hero(
        placeholderBuilder: (context, size, child) {
          final Color color = theme.brightness == .dark
              ? Colors.white24
              : Colors.black54;
          return ColorFiltered(
            colorFilter: ColorFilter.mode(color, .srcIn),
            child: child,
          );
        },
        transitionOnUserGestures: true,
        tag: asset,
        child: Image.asset(
          asset,
          fit: .contain,
          alignment: .center,
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
  final String serie;
  final String? cardNumber;

  const _AmiiboListInfo({
    required this.name,
    required this.serie,
    this.cardNumber,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    const subtitleStyle = TextStyle(fontSize: 14.0);
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Column(
        mainAxisAlignment: .start,
        mainAxisSize: .max,
        crossAxisAlignment: .start,
        children: [
          Text.rich(
            TextSpan(
              text: cardNumber == null ? null : '#${cardNumber!} ',
              children: [TextSpan(text: name)],
            ),
            style: style,
            softWrap: false,
            overflow: .fade,
            maxLines: 1,
          ),
          const Gap(2.0),
          Text(
            serie,
            style: style?.merge(subtitleStyle) ?? subtitleStyle,
            softWrap: false,
            overflow: .fade,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
