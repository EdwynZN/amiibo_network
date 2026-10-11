import 'package:amiibo_network/app/configuration/router_provider.dart';
import 'package:amiibo_network/app/state/preferences_provider.dart';
import 'package:amiibo_network/app/state/theme/theme_provider.dart';
import 'package:amiibo_network/shared/generated/l10n.dart';
import 'package:amiibo_network/shared/utils/skeletonizer_data_transformer.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class const AmiiboApp({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);
    final Locale? locale = ref.watch(localeProvider);
    return MaterialApp.router(
      localizationsDelegates: [
        S.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: S.delegate.supportedLocales,
      debugShowCheckedModeBanner: false,
      locale: locale,
      theme: theme.light,
      darkTheme: theme.dark,
      themeMode: themeMode,
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      builder: (context, child) => _Builder(child!),
    );
  }
}

class const _Builder(final Widget child) extends HookWidget {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final skeletonData = useMemoized(() => mapToSkeletonizer(theme), [theme]);
    return SkeletonizerConfig(data: skeletonData, child: child);
  }
}