import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/model/amiibo.dart';
import 'package:amiibo_network/model/update_amiibo_user_attributes.dart';
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

enum _ButtonEffects { remove, delete, disable }

class PreferencesSliver extends StatelessWidget {
  const PreferencesSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(child: UserPreferenceCard());
  }
}

class UserPreferenceCard extends HookConsumerWidget {
  // ignore: unused_element
  const UserPreferenceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amiiboKey = ref.watch(keyAmiiboProvider);
    final userAttributes = ref.watch(
      detailAmiiboProvider(amiiboKey)
          .select((value) => value.valueOrNull?.userAttributes),
    );
    final isLock = ref.watch(lockProvider.select((value) => value.lock));
    final isDisable = useMemoized(
      () => isLock || userAttributes == null,
      [isLock, userAttributes == null],
    );

    final translate = S.of(context);
    final theme = Theme.of(context);
    final preferencesPalette = theme.extension<PreferencesExtension>()!;
    final openedTextController = useTextEditingController(text: '0');
    final boxedTextController = useTextEditingController(text: '0');

    /// initialize controllers with attributes
    useEffect(
      () {
        if (userAttributes != null) {
          final ({String boxed, String opened}) values =
              switch (userAttributes) {
            OwnedUserAttributes(
              boxed: final boxed,
              opened: final opened,
            ) =>
              (boxed: boxed.toString(), opened: opened.toString()),
            _ => (boxed: '0', opened: '0'),
          };

          if (openedTextController.text != values.opened) {
            openedTextController.text = values.opened;
          }
          if (boxedTextController.text != values.boxed) {
            boxedTextController.text = values.boxed;
          }
        }
        return;
      },
      [userAttributes, openedTextController, boxedTextController],
    );

    final onChangeOwned = useCallback(
      ({int? boxed, int? opened}) {
        final UserAttributes newAttributes;
        if (boxed != null) {
          newAttributes = UserAttributes.fromOwnedOrEmpty(
            boxed: boxed,
            opened: int.parse(openedTextController.text),
          );
        } else if (opened != null) {
          newAttributes = UserAttributes.fromOwnedOrEmpty(
            boxed: int.parse(boxedTextController.text),
            opened: opened,
          );
        } else {
          return null;
        }
        return ref.read(serviceProvider.notifier).update(
          [
            UpdateAmiiboUserAttributes(
              id: amiiboKey,
              attributes: newAttributes,
            ),
          ],
        );
      },
      [openedTextController, boxedTextController, ref, amiiboKey],
    );

    /// UI attribute colors and text from type of userAttributes
    final ({
      Color? surfaceColor,
      String title,
      Color? foregroundTitle,
      IconData icon,
    }) attributes = useMemoized(
      () {
        return switch (userAttributes) {
          OwnedUserAttributes() => (
              surfaceColor: preferencesPalette.ownPrimary,
              title: translate.owned,
              foregroundTitle: preferencesPalette.onOwnPrimary,
              icon: iconOwned,
            ),
          WishedUserAttributes() => (
              surfaceColor: preferencesPalette.wishPrimary,
              title: translate.wished,
              foregroundTitle: preferencesPalette.onWishPrimary,
              icon: iconWished,
            ),
          _ => (
              surfaceColor: null,
              title: '',
              foregroundTitle: null,
              icon: Icons.remove_sharp,
            ),
        };
      },
      [
        userAttributes,
        translate,
        preferencesPalette,
      ],
    );
    return _ColumnCardWrapper(
      color: theme.colorScheme.background,
      surfaceTintColor: attributes.surfaceColor,
      borderColor: theme.colorScheme.outlineVariant,
      elevation: attributes.surfaceColor == null ? 0.0 : 4.0,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            color: attributes.surfaceColor,
            child: Row(
              children: [
                Icon(attributes.icon, color: attributes.foregroundTitle),
                const Gap(8.0),
                Text(
                  attributes.title,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(color: attributes.foregroundTitle),
                ),
                if (userAttributes is! EmptyUserAttributes)
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton.filledTonal(
                        onPressed: () {
                          ref.read(serviceProvider.notifier).update(
                            [
                              UpdateAmiiboUserAttributes(
                                id: amiiboKey,
                                attributes: const EmptyUserAttributes(),
                              ),
                            ],
                          );
                        },
                        icon: const Icon(Icons.clear_outlined),
                        visualDensity: const VisualDensity(
                          vertical: -4.0,
                          horizontal: 2.0,
                        ),
                      ),
                    ),
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
                  title: translate.unboxed,
                  isDisabled: isDisable,
                  onChanged: (value) => onChangeOwned(opened: value),
                ),
                ColumnButton(
                  textController: boxedTextController,
                  title: translate.boxed,
                  isDisabled: isDisable,
                  onChanged: (value) => onChangeOwned(boxed: value),
                ),
                const SizedBox(height: 140.0, child: VerticalDivider()),
                _OutlinedColumnButton(
                  isSelected: userAttributes is WishedUserAttributes,
                  title: translate.wished,
                  onPressed: isDisable
                      ? null
                      : () {
                          if (userAttributes == null) return;
                          final bool newValue =
                              userAttributes is! WishedUserAttributes;
                          ref.read(serviceProvider.notifier).update(
                            [
                              UpdateAmiiboUserAttributes(
                                id: amiiboKey,
                                attributes: newValue
                                    ? const WishedUserAttributes()
                                    : const EmptyUserAttributes(),
                              ),
                            ],
                          );
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlinedColumnButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final bool isSelected;

  const _OutlinedColumnButton({
    // ignore: unused_element
    super.key,
    required this.title,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preferencesPalette = theme.extension<PreferencesExtension>()!;

    return _ColumnCardWrapper(
      color: theme.colorScheme.background,
      surfaceTintColor: onPressed == null
          ? theme.disabledColor
          : preferencesPalette.wishPalette,
      borderColor: theme.colorScheme.outlineVariant,
      child: ConstrainedBox(
        constraints: const BoxConstraints.tightFor(width: 72.0, height: 140.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ContainerTitle(
              title: title,
              background: preferencesPalette.wishPrimary,
              foreground: preferencesPalette.onWishPrimary,
            ),
            Expanded(
              child: IconButton(
                style: const ButtonStyle(
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder()),
                ),
                icon: Icon(Icons.favorite_border_outlined),
                selectedIcon: Icon(iconWished),
                isSelected: isSelected,
                onPressed: onPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ColumnButton extends StatelessWidget {
  final String title;
  final bool isDisabled;
  final TextEditingController textController;
  final ValueChanged<int>? onChanged;
  final double width;

  const ColumnButton({
    super.key,
    required this.title,
    this.onChanged,
    this.isDisabled = false,
    this.width = 72,
    required this.textController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyMedium;
    final preferencesPalette = theme.extension<PreferencesExtension>()!;

    return _ColumnCardWrapper(
      color: theme.colorScheme.background,
      elevation: isDisabled ? 0.0 : 4.0,
      surfaceTintColor:
          isDisabled ? theme.disabledColor : preferencesPalette.ownPalette,
      borderColor: preferencesPalette.ownPrimary,
      child: ConstrainedBox(
        constraints: BoxConstraints.tightFor(
          width: width.clamp(72.0, 140.0),
          height: 140.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ContainerTitle(
              title: title,
              background: preferencesPalette.ownPrimary,
              foreground: preferencesPalette.onOwnPrimary,
            ),
            IconButton(
              style: const ButtonStyle(
                shape: MaterialStatePropertyAll(RoundedRectangleBorder()),
                visualDensity: const VisualDensity(vertical: -2.0),
              ),
              icon: isDisabled
                  ? const Icon(Icons.add_circle_rounded)
                  : const Icon(Icons.add),
              onPressed: isDisabled
                  ? null
                  : () {
                      int value = int.tryParse(textController.text) ?? 0;
                      textController.text = '${++value}';
                      if (onChanged != null) {
                        onChanged!(value);
                      }
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
                  enabled: !isDisabled,
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
                  onChanged: onChanged == null
                      ? null
                      : (value) => onChanged!(int.tryParse(value) ?? 0),
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
                            if (onChanged != null) {
                              onChanged!(value);
                            }
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

class _ContainerTitle extends StatelessWidget {
  final String title;
  final Color background;
  final Color foreground;

  const _ContainerTitle({
    // ignore: unused_element
    super.key,
    required this.title,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      color: background,
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.merge(
              TextStyle(color: foreground),
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
