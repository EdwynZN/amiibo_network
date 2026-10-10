import 'package:amiibo_network/app/configuration/model/amiibo_category_enum.dart';
import 'package:amiibo_network/app/configuration/query_provider.dart';
import 'package:amiibo_network/shared/generated/l10n.dart';
import 'package:amiibo_network/shared/resources/resources.dart';
import 'package:amiibo_network/shared/utils/empty_page_random.dart';
import 'package:amiibo_network/template/selected_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class const EmptyHome({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final translate = S.of(context);
    final isCustom = ref.watch(
      queryProvider.select<bool>(
        (cb) => cb.categoryAttributes.category == .AmiiboSeries,
      ),
    );
    final Widget child = HookBuilder(
      key: const ValueKey('EmptyMessageBuilder'),
      builder: (context) {
        final messageType = useMemoized(
          () => EmptyPageRandomizer.instance.randomeMessage,
        );
        return Padding(
          padding: const .all(16.0),
          child: Column(
            mainAxisAlignment: .start,
            mainAxisSize: .min,
            children: [
              ImageIcon(
                AssetImage(switch (messageType) {
                  .pokemon => GameIcons.pokemon,
                  .pokeball => GameIcons.pokeball,
                  .mario => GameIcons.superMario,
                  .mushroom => GameIcons.superMarioToad,
                  .pacman => GameIcons.pacman,
                  .pacmanGhost => GameIcons.pacmanGhost,
                  .link => GameIcons.tlozSword,
                }),
                size: 196,
              ),
              const Gap(12),
              Text(
                translate.emptyMessageType(messageType),
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: .w600,
                  height: 1.25,
                ),
                textAlign: .center,
              ),
              if (isCustom) ...[
                const Gap(24.0),
                ElevatedButton.icon(
                  style: theme.textButtonTheme.style?.copyWith(
                    textStyle: WidgetStateProperty.all(
                      theme.textTheme.headlineMedium,
                    ),
                  ),
                  onPressed: () async {
                    final filter = ref.read(queryProvider.notifier);
                    final figures = filter.customFigures.toList();
                    final cards = filter.customCards.toList();
                    bool save =
                        await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) => CustomQueryWidget(
                            translate.category(AmiiboCategory.AmiiboSeries),
                            figures: figures,
                            cards: cards,
                          ),
                        ) ??
                        false;
                    if (save)
                      await ref
                          .read(queryProvider.notifier)
                          .updateCustom(figures, cards);
                  },
                  icon: const Icon(Icons.create_outlined),
                  label: Text(translate.emptyPageAction),
                ),
              ],
            ],
          ),
        );
      },
    );
    return SliverFillRemaining(hasScrollBody: false, child: child);
  }
}

