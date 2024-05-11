import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/model/amiibo.dart';
import 'package:amiibo_network/utils/string_extensions.dart';
import 'package:amiibo_network/widget/detail/user_preferences_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';

class OwnedButtomSheet extends HookWidget {
  const OwnedButtomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final translate = S.of(context);
    final localizations = MaterialLocalizations.of(context);
    final openedTextController = useTextEditingController(text: '1');
    final boxedTextController = useTextEditingController(text: '0');

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ColumnButton(
                textController: openedTextController,
                title: translate.unboxed,
                isDisabled: false,
                width: 96.0,
              ),
              const Gap(12.0),
              ColumnButton(
                textController: boxedTextController,
                title: translate.boxed,
                isDisabled: false,
                width: 96.0,
              ),
            ],
          ),
        ),
        const Gap(16.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(localizations.cancelButtonLabel),
                ),
              ),
              const Gap(24.0),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final newAttributes = UserAttributes.fromOwnedOrEmpty(
                      boxed: int.parse(boxedTextController.text),
                      opened: int.parse(openedTextController.text),
                    );
                    Navigator.of(context).pop(newAttributes);
                  },
                  child: Text(localizations.saveButtonLabel.capitalize()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
