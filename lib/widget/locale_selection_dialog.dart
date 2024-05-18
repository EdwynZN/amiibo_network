import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/model/result.dart';
import 'package:amiibo_network/riverpod/preferences_provider.dart';
import 'package:amiibo_network/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LocaleDialog extends HookConsumerWidget {
  const LocaleDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = MaterialLocalizations.of(context);
    final S translate = S.of(context);
    final selectedLocale = ref.watch(localeProvider);
    final ValueNotifier<String?> state = useState(selectedLocale?.languageCode);
    return AlertDialog(
      title: Text(translate.appearance),
      scrollable: true,
      alignment: Alignment.center,
      content: ListBody(
        children: [
          for (final locale in S.delegate.supportedLocales)
            RadioListTile<String?>(
              value: locale.languageCode,
              groupValue: state.value,
              onChanged: (value) => state.value = value,
            ),
          RadioListTile<String?>(
            value: null,
            groupValue: state.value,
            onChanged: (value) => state.value = value,
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text(localizations.cancelButtonLabel.capitalize()),
          onPressed: Navigator.of(context).pop,
        ),
        ElevatedButton(
          child: Text(localizations.saveButtonLabel.capitalize()),
          onPressed: () async =>
              Navigator.of(context).pop(Result<String?>(state.value)),
        ),
      ],
    );
  }
}
