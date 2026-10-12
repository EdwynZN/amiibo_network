import 'package:amiibo_network/app/configuration/screenshot_service.dart';
import 'package:amiibo_network/shared/generated/l10n.dart';
import 'package:amiibo_network/shared/service/storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:material_ui/material_ui.dart';

class ScreenshotFabWidget extends ConsumerWidget {
  ScreenshotFabWidget({
    required Animation<double> animation,
    required this.isAmiibo,
  }) : scale = Tween<double>(begin: 0.25, end: 1.0).animate(
         CurvedAnimation(
           parent: animation,
           curve: Interval(0.25, 1.0, curve: Curves.decelerate),
         ),
       ),
       slide = Tween<Offset>(
         begin: const .new(0, 2),
         end: .zero,
       ).animate(CurvedAnimation(parent: animation, curve: Interval(0.0, 1)));

  final bool isAmiibo;
  final Animation<double> scale;
  final Animation<Offset> slide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S translate = S.of(context);
    final theme = Theme.of(context);
    final isLoading = ref.watch(screenshotProvider.select((s) => s.isLoading));
    final Widget child;
    if (isLoading) {
      final color =
          theme.floatingActionButtonTheme.foregroundColor ??
          theme.colorScheme.onSecondaryContainer;
      child = ConstrainedBox(
        constraints: .loose(const .square(24.0)),
        child: LoadingAnimationWidget.inkDrop(color: color, size: 24),
      );
    } else {
      child = const Icon(Icons.save);
    }

    final fab = FloatingActionButton(
      elevation: 0.0,
      child: child,
      tooltip: translate.saveCollection,
      heroTag: 'MenuFAB${isAmiibo ? 'Amiibo' : 'Stats'}',
      onPressed: () async {
        final _screenshotProvider = ref.read(screenshotProvider.notifier);
        final scaffoldState = ScaffoldMessenger.of(context);
        if (!(await permissionGranted(scaffoldState))) return;
        final isLoading = _screenshotProvider.isLoading;
        final message = isLoading
            ? translate.recordMessage
            : translate.savingCollectionMessage;
        scaffoldState
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
        if (isLoading) return;
        if (isAmiibo) {
          await _screenshotProvider.saveAmiibos(context);
        } else {
          await _screenshotProvider.saveStats(context);
        }
      },
    );
    return SlideTransition(
      position: slide,
      child: ScaleTransition(scale: scale, child: fab),
    );
  }
}
