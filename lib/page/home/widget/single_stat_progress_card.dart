import 'package:amiibo_network/app/state/theme/service/theme_mode_scheme_repository.dart';
import 'package:amiibo_network/entity/amiibo_info/model/stat.dart';
import 'package:amiibo_network/page/home/widget/linear_stat_widget.dart';
import 'package:amiibo_network/shared/generated/l10n.dart';
import 'package:amiibo_network/shared/resources/resources.dart';
import 'package:amiibo_network/shared/utils/gap_helper.dart';
import 'package:amiibo_network/shared/utils/theme_extensions.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_ui/material_ui.dart';

class const SingleStatProgressCard(final Stat stat, {super.key})
    extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preference = theme.extension<PreferencesExtension>()!;
    final translate = S.of(context);

    final dividerColor = theme.colorScheme.outline.withValues(alpha: .24);

    final divider = ConstrainedBox(
      constraints: .tightFor(height: 32),
      child: VerticalDivider(color: dividerColor),
    );
    final statWidget = Row(
      crossAxisAlignment: .center,
      mainAxisAlignment: .spaceBetween,
      children: [
        Flexible(
          child: _ColumnStat(
            translate.owned.toUpperCase(),
            value: stat.owned,
            percent: (stat.owned * 100 / stat.total).toInt(),
            color: preference.ownPrimary,
            icon: const Icon(iconOwned),
          ),
        ),
        divider,
        Flexible(
          child: _ColumnStat(
            translate.wished.toUpperCase(),
            value: stat.wished,
            percent: (stat.wished * 100 / stat.total).toInt(),
            color: preference.wishPrimary,
            icon: const Icon(iconWished),
          ),
        ),
        divider,
        Flexible(
          child: _ColumnStat(
            translate.total.toUpperCase(),
            value: stat.total,
            color: theme.primaryColor,
            icon: const ImageIcon(
              AssetImage(NetworkIcons.amiiboImageUnavailable),
            ),
          ),
        ),
      ],
    );

    return Card(
      elevation: 6.0,
      child: Padding(
        padding: allPadding12,
        child: Column(
          crossAxisAlignment: .start,
          children: <Widget>[
            FittedBox(
              alignment: .centerStart,
              child: Text(
                stat.name,
                softWrap: false,
                textAlign: .start,
                overflow: .fade,
                style: const .new(
                  fontSize: 18,
                  letterSpacing: -.5,
                  wordSpacing: -.5,
                  fontWeight: .bold,
                ),
              ),
            ),
            gap4,
            AnimatedLineProgress(
              showEmptyColor: true,
              owned: stat.owned,
              wished: stat.wished,
              total: stat.total,
            ),
            gap8,
            Divider(height: 4, thickness: 1, color: dividerColor),
            statWidget,
          ],
        ),
      ),
    );
  }
}

class const _ColumnStat(
  final String title, {
  required final int value,
  required final Color color,
  final int? percent,
  final Widget? icon,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final titleWidget = IconTheme.merge(
      data: .new(color: color, size: 10),
      child: Row(
        mainAxisSize: .min,
        mainAxisAlignment: .center,
        spacing: 2,
        children: [
          ?icon,
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: .clip,
              style: const .new(
                fontSize: 12,
                letterSpacing: .25,
                fontWeight: .w800,
              ),
            ),
          ),
        ],
      ),
    );

    return FittedBox(
      alignment: .topCenter,
      fit: .contain,
      child: Padding(
        padding: lbrPadding4,
        child: Column(
          mainAxisSize: .min,
          textBaseline: .alphabetic,
          children: [
            titleWidget,
            Text.rich(
              TextSpan(
                text: value.toString(),
                children: [
                  if (percent != null)
                    TextSpan(
                      text: ' ($percent%)',
                      style: const .new(
                        fontSize: 12,
                        letterSpacing: -1,
                        fontWeight: .w300,
                      ),
                    ),
                ],
                style: const .new(fontWeight: .bold),
              ),
              textAlign: .center,
              style: .new(fontSize: 16, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
