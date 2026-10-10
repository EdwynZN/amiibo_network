import 'package:amiibo_network/app/state/lock_provider.dart';
import 'package:amiibo_network/app/state/preferences_provider.dart';
import 'package:amiibo_network/app/state/theme/service/theme_mode_scheme_repository.dart';
import 'package:amiibo_network/app/configuration/amiibo_info_configuration/configuration.dart';
import 'package:amiibo_network/entity/amiibo_info/model/amiibo_user_collection_attributes.dart';
import 'package:amiibo_network/feature/collection/application/input/update_collection_input.dart';
import 'package:amiibo_network/feature/collection/infrastructure/configuration/configuration.dart';
import 'package:amiibo_network/page/detail/widget/owned_bottom_sheet.dart';
import 'package:amiibo_network/shared/generated/l10n.dart';
import 'package:amiibo_network/shared/utils/theme_extensions.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

Future<UserAttributes?> _ownedBottomSheet(
  BuildContext context,
  UserAttributes userAttributes,
) {
  final theme = Theme.of(context);
  final ({int boxed, int opened}) values = switch (userAttributes) {
    OwnedUserAttributes(boxed: final boxed, opened: final opened) => (
      boxed: boxed,
      opened: opened,
    ),
    _ => (boxed: 0, opened: 0),
  };
  return showModalBottomSheet<UserAttributes>(
    context: context,
    backgroundColor: theme.colorScheme.surface,
    useSafeArea: false,
    elevation: 4.0,
    enableDrag: false,
    constraints: const BoxConstraints(maxWidth: 400.0),
    isScrollControlled: true,
    builder: (context) => OwnedButtomSheet(
      initialBoxed: values.boxed,
      initialUnboxed: values.opened,
    ),
  );
}

class Buttons extends ConsumerWidget {
  const Buttons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = ref.watch(keyAmiiboProvider);
    final asyncAmiibo = ref.watch(detailAmiiboProvider(key));
    final isLock = ref.watch(lockProvider);
    final value = asyncAmiibo.asData?.value;
    return Row(
      mainAxisAlignment: .center,
      children: <Widget>[
        OwnButton(
          amiiboId: value?.id,
          attributes: value?.details.userAttributes,
          isLock: isLock,
        ),
        const Gap(24.0),
        WishButton(
          amiiboId: value?.id,
          isActive: value?.details.userAttributes is WishedUserAttributes,
          isLock: isLock,
        ),
      ],
    );
  }
}

class WishButton extends ConsumerWidget {
  const WishButton({
    required this.amiiboId,
    required this.isActive,
    required bool isLock,
    this.size = const .square(40.0),
    super.key,
  }) : isLock = isLock || amiiboId == null;

  final bool isLock;
  final int? amiiboId;
  final Size size;
  final bool isActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S translate = S.of(context);
    final preferencesPalette = Theme.of(context)
        .extension<PreferencesExtension>()!;
    final color = preferencesPalette.wishContainer.withValues(alpha: 0.24);
    return IconButton(
      style: const ButtonStyle(tapTargetSize: .shrinkWrap),
      isSelected: isActive,
      icon: const Icon(Icons.favorite_border_outlined),
      selectedIcon: const Icon(iconWished),
      color: preferencesPalette.wishPalette.shade70,
      constraints: .tight(size),
      iconSize: 20.0,
      splashRadius: 20.0,
      tooltip: translate.wishTooltip,
      splashColor: color,
      highlightColor: color,
      onPressed: isLock
          ? null
          : () {
              final useCase = ref.read(updateCollectionUseCaseProvider);
              useCase(
                UpdateCollectionInput(
                  amiibos: [
                    .new(
                      id: amiiboId!,
                      attributes: isActive ? const .none() : .wished(),
                    ),
                  ],
                  bundles: const [],
                ),
              );
            },
    );
  }
}

class OwnButton extends ConsumerWidget {
  OwnButton({
    required this.amiiboId,
    required this.attributes,
    required bool isLock,
    this.size = const .square(40.0),
    super.key,
  }) : isLock = isLock || amiiboId == null || attributes == null,
       isActive = attributes != null && attributes is OwnedUserAttributes;

  final bool isLock;
  final int? amiiboId;
  final Size size;
  final bool isActive;
  final UserAttributes? attributes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S translate = S.of(context);
    final preferencesPalette = Theme.of(context)
        .extension<PreferencesExtension>()!;
    final color = preferencesPalette.ownContainer.withValues(alpha: 0.24);
    return IconButton(
      style: const ButtonStyle(tapTargetSize: .shrinkWrap),
      isSelected: isActive,
      icon: const Icon(Icons.bookmark_outline_outlined),
      selectedIcon: const Icon(iconOwned),
      color: preferencesPalette.ownPalette.shade70,
      constraints: BoxConstraints.tight(size),
      iconSize: 20.0,
      splashRadius: 20.0,
      tooltip: translate.ownTooltip,
      splashColor: color,
      highlightColor: color,
      onPressed: isLock
          ? null
          : () async {
              final showOwnerCategories = ref.read(ownTypesCategoryProvider);
              final CollectionAttributes newAttributes;
              if (showOwnerCategories) {
                final userAttributes = await _ownedBottomSheet(
                  context,
                  attributes!,
                );
                if (userAttributes == null) return;
                if (userAttributes case OwnedUserAttributes()) {
                  newAttributes = .owned(
                    boxed: userAttributes.boxed,
                    opened: userAttributes.opened,
                  );
                } else {
                  newAttributes = const .none();
                }
              } else {
                final bool newValue = !isActive;
                newAttributes = newValue ? .owned() : const .none();
              }

              final useCase = ref.read(updateCollectionUseCaseProvider);
              useCase(
                UpdateCollectionInput(
                  amiibos: [.new(id: amiiboId!, attributes: newAttributes)],
                  bundles: const [],
                ),
              );
            },
    );
  }
}
