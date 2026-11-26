import 'package:amiibo_network/shared/generated/l10n.dart';
import 'package:amiibo_network/shared/resources/resources.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

class const EmptyGames({super.key}) extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const .all(24.0),
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
                fontWeight: .w500,
                color: theme.colorScheme.primary,
              ),
              textAlign: .center,
            ),
          ),
        ],
      ),
    );
  }
}