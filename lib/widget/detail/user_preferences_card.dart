import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/model/amiibo.dart';
import 'package:amiibo_network/repository/theme_repository.dart';
import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:amiibo_network/riverpod/lock_provider.dart';
import 'package:amiibo_network/riverpod/service_provider.dart';
import 'package:amiibo_network/utils/number_text_input_formatters.dart';
import 'package:amiibo_network/utils/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum _UserPreferenceType { owned, wished }

enum _ButtonEffects { remove, delete, disable }

class PreferencesSliver extends HookConsumerWidget {
  const PreferencesSliver({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amiiboKey = ref.watch(keyAmiiboProvider);
    final amiibo = ref.watch(
      detailAmiiboProvider(amiiboKey).select((value) => value.valueOrNull),
    );
    final isLock = ref.watch(lockProvider.select((value) => value.lock));
    final isDisable = useMemoized(
      () => isLock || amiibo == null,
      [isLock, amiibo],
    );

    final Widget buttons = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _OutlinedPreferencesButton.owned(
            userAttribute: amiibo?.userAttributes,
            onPressed: isLock
                ? null
                : () {
                    if (amiibo == null) return;
                    final bool newValue =
                        amiibo.userAttributes is! OwnedUserAttributes;
                    ref.read(serviceProvider.notifier).updateFromAmiibos(
                      [
                        amiibo.copyWith(
                          userAttributes: newValue
                              ? UserAttributes.owned()
                              : const EmptyUserAttributes(),
                        ),
                      ],
                    );
                  },
          ),
          const Gap(24.0),
          _OutlinedPreferencesButton.wished(
            userAttribute: amiibo?.userAttributes,
            onPressed: isDisable
                ? null
                : () {
                    if (amiibo == null) return;
                    final bool newValue =
                        amiibo.userAttributes is! WishedUserAttributes;
                    ref.read(serviceProvider.notifier).updateFromAmiibos(
                      [
                        amiibo.copyWith(
                          userAttributes: newValue
                              ? const WishedUserAttributes()
                              : const EmptyUserAttributes(),
                        )
                      ],
                    );
                  },
          ),
        ],
      ),
    );

    final ownedKey = ValueKey(
      amiibo == null || amiibo.userAttributes is! OwnedUserAttributes,
    );
    return SliverIgnorePointer(
      ignoring: isDisable,
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Center(
              child: _OutlinedPreferencesButton.wished(
                userAttribute: amiibo?.userAttributes,
                onPressed: isDisable
                    ? null
                    : () {
                        if (amiibo == null) return;
                        final bool newValue =
                            amiibo.userAttributes is! WishedUserAttributes;
                        ref.read(serviceProvider.notifier).updateFromAmiibos(
                          [
                            amiibo.copyWith(
                              userAttributes: newValue
                                  ? const WishedUserAttributes()
                                  : const EmptyUserAttributes(),
                            )
                          ],
                        );
                      },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: Gap(12.0)),
          SliverToBoxAdapter(
            child: _OwnedCard(
              amiiboId: amiiboKey,
              userAttribute: amiibo?.userAttributes,
              isDisable: isDisable,
            ),
          ),
          /* SliverAnimatedPaintExtent(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutCirc,
            child: SliverToBoxAdapter(
              key: ownedKey,
              child: ownedKey.value ? const SizedBox() : const _OwnedCard(),
            ),
          ), */
        ],
      ),
    );
  }
}

class _OwnedCard extends HookConsumerWidget {
  final UserAttributes? userAttribute;
  final int amiiboId;
  final bool isDisable;

  const _OwnedCard({
    // ignore: unused_element
    super.key,
    required this.amiiboId,
    required this.userAttribute,
    required this.isDisable,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translate = S.of(context);
    final theme = Theme.of(context);
    final preferencesPalette = theme.extension<PreferencesExtension>()!;
    final openedTextController = useTextEditingController(text: '0');
    final boxedTextController = useTextEditingController(text: '0');
    return _ColumnCardWrapper(
      color: theme.colorScheme.background,
      surfaceTintColor: preferencesPalette.ownPalette,
      borderColor: theme.colorScheme.outlineVariant,
      elevation: 0.0,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            color: preferencesPalette.ownPrimary,
            child: Row(
              children: [
                Icon(iconOwned, color: preferencesPalette.onOwnPrimary),
                const Gap(8.0),
                Text(
                  'Owned',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(color: preferencesPalette.onOwnPrimary),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ColumnButton(
                  textController: openedTextController,
                  title: translate.owned,
                ),
                ColumnButton(
                  textController: boxedTextController,
                  title: translate.ownTooltip,
                ),
                Padding(
                  padding: theme.cardTheme.margin ?? EdgeInsets.zero,
                  child: _OutlinedPreferencesButton.wished(
                    userAttribute: userAttribute,
                    onPressed: isDisable
                    ? null
                    : () {
                        /* if (amiibo == null) return;
                        final bool newValue =
                            amiibo.userAttributes is! WishedUserAttributes;
                        ref.read(serviceProvider.notifier).updateFromAmiibos(
                          [
                            amiibo.copyWith(
                              userAttributes: newValue
                                  ? const WishedUserAttributes()
                                  : const EmptyUserAttributes(),
                            )
                          ],
                        ); */
                      },
                    constraints: const BoxConstraints.tightFor(
                      width: 72.0,
                      height: 140.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlinedPreferencesButton extends StatelessWidget {
  final _UserPreferenceType _preferenceType;
  final UserAttributes? userAttribute;
  final VoidCallback? onPressed;
  final BoxConstraints? constraints;

  const _OutlinedPreferencesButton.wished({
    // ignore: unused_element
    super.key,
    required this.userAttribute,
    required this.onPressed,
    this.constraints,
  }) : _preferenceType = _UserPreferenceType.wished;

  const _OutlinedPreferencesButton.owned({
    // ignore: unused_element
    super.key,
    required this.userAttribute,
    required this.onPressed,
    this.constraints,
  }) : _preferenceType = _UserPreferenceType.owned;

  @override
  Widget build(BuildContext context) {
    final S translate = S.of(context);
    final preferencesPalette =
        Theme.of(context).extension<PreferencesExtension>()!;

    final ({
      bool isActive,
      IconData icon,
      IconData selectedIcon,
      Color color,
      Color highlightColor,
      String tooltip,
    }) attributes = switch (_preferenceType) {
      _UserPreferenceType.wished => (
          isActive: userAttribute is WishedUserAttributes,
          icon: Icons.favorite_border_outlined,
          selectedIcon: iconWished,
          color: preferencesPalette.wishPalette.shade70,
          highlightColor: preferencesPalette.wishContainer,
          tooltip: translate.wishTooltip,
        ),
      _UserPreferenceType.owned => (
          isActive: userAttribute is OwnedUserAttributes,
          icon: Icons.bookmark_outline_outlined,
          selectedIcon: iconOwned,
          color: preferencesPalette.ownPalette.shade70,
          highlightColor: preferencesPalette.ownContainer,
          tooltip: translate.ownTooltip,
        ),
    };

    final color = attributes.highlightColor.withOpacity(0.24);
    return IconButton.outlined(
      style: const ButtonStyle(
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
        ),
      ),
      isSelected: attributes.isActive,
      icon: Icon(attributes.icon),
      selectedIcon: Icon(attributes.selectedIcon),
      color: attributes.color,
      constraints: constraints ??
          const BoxConstraints.tightFor(height: 56.0, width: 120.0),
      iconSize: 24.0,
      splashRadius: 24.0,
      tooltip: attributes.tooltip,
      splashColor: color,
      highlightColor: color,
      onPressed: onPressed,
    );
  }
}

class ColumnButton extends StatelessWidget {
  final String title;
  final TextEditingController textController;

  const ColumnButton({
    super.key,
    required this.title,
    required this.textController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyMedium;
    final preferencesPalette = theme.extension<PreferencesExtension>()!;

    return _ColumnCardWrapper(
      color: theme.colorScheme.background,
      surfaceTintColor: preferencesPalette.ownPalette,
      borderColor: theme.colorScheme.outlineVariant,
      child: ConstrainedBox(
        constraints: const BoxConstraints.tightFor(width: 72.0, height: 140.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              color: preferencesPalette.ownPrimary,
              child: Text(
                title,
                style: theme.textTheme.bodySmall?.merge(
                  TextStyle(color: preferencesPalette.onOwnPrimary),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              style: const ButtonStyle(
                shape: MaterialStatePropertyAll(RoundedRectangleBorder()),
                visualDensity: const VisualDensity(vertical: -2.0),
              ),
              icon: const Icon(Icons.add),
              onPressed: () {
                int value = int.tryParse(textController.text) ?? 0;
                textController.text = '${++value}';
              },
            ),
            const Divider(height: 2.0),
            Expanded(
              child: Center(
                child: TextField(
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  controller: textController,
                  textInputAction: TextInputAction.done,
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style:
                      style?.copyWith(color: preferencesPalette.onOwnContainer),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(
                      3,
                      maxLengthEnforcement:
                          MaxLengthEnforcement.truncateAfterCompositionEnds,
                    ),
                    const NumberInputFormatter(),
                  ],
                ),
              ),
            ),
            const Divider(height: 2.0),
            HookBuilder(
              builder: (context) {
                final effect = useListenableSelector(
                  textController,
                  () {
                    int value = int.tryParse(textController.text) ?? 0;
                    return switch (value) {
                      0 => _ButtonEffects.disable,
                      1 => _ButtonEffects.delete,
                      _ => _ButtonEffects.remove,
                    };
                  },
                );
                final Color? color = effect == _ButtonEffects.delete
                    ? theme.colorScheme.error
                    : null;
                return IconButton(
                  style: const ButtonStyle(
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder()),
                    visualDensity: const VisualDensity(vertical: -2.0),
                  ),
                  highlightColor: color?.withOpacity(0.16),
                  icon: switch (effect) {
                    _ButtonEffects.delete => Icon(Icons.delete, color: color),
                    _ButtonEffects.disable => Icon(Icons.remove_circle_sharp),
                    _ => Icon(Icons.remove),
                  },
                  onPressed: effect == _ButtonEffects.disable
                      ? null
                      : () {
                          int value = int.tryParse(textController.text) ?? 0;
                          if (value <= 0) {
                          } else {
                            textController.text = '${--value}';
                          }
                        },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ColumnCardWrapper extends Card {
  _ColumnCardWrapper({
    required Color borderColor,
    // ignore: unused_element
    super.key,
    super.color,
    super.surfaceTintColor,
    super.elevation = 2.0,
    super.child,
  }) : super.outlined(
          clipBehavior: Clip.hardEdge,
          borderOnForeground: true,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
            side: BorderSide(color: borderColor),
          ),
        );
}
