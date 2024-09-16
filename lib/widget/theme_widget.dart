import 'package:amiibo_network/riverpod/theme_provider.dart';
import 'package:amiibo_network/utils/tablet_utils.dart';
import 'package:flutter/material.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ThemeButton extends ConsumerWidget {
  final bool openDialog;

  const ThemeButton({this.openDialog = false});

  static Future<void> dialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierColor: Colors.black12,
      builder: (BuildContext context) => const _DialogTheme(),
    );
  }

  Widget _selectWidget(ThemeMode? value, Color? color) {
    switch (value) {
      case ThemeMode.light:
        return const Icon(
          Icons.wb_sunny,
          key: Key('Light'),
          color: Colors.orangeAccent,
        );
      case ThemeMode.dark:
        return const Icon(
          Icons.brightness_3,
          key: Key('Dark'),
          color: Colors.amber,
        );
      case ThemeMode.system:
      default:
        return Icon(
          Icons.brightness_auto,
          key: Key('Auto'),
          color: color,
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = Theme.of(context);
    final ThemeMode? themeMode = ref.watch(
      themeProvider.select<ThemeMode?>((value) => value.preferredMode),
    );
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: const CircleBorder(),
        color: ElevationOverlay.applySurfaceTint(
          themeData.scaffoldBackgroundColor,
          themeData.colorScheme.primary,
          12.0,
        ),
      ),
      child: InkResponse(
        splashFactory: InkSparkle.splashFactory,
        containedInkWell: true,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            reverseDuration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeInOutBack,
            switchOutCurve: Curves.easeOutBack,
            transitionBuilder: (child, animation) {
              return RotationTransition(
                turns: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: _selectWidget(themeMode, themeData.colorScheme.onSurface),
          ),
        ),
        onLongPress: openDialog ? () => dialog(context) : null,
        onTap: () async => ref.read(themeProvider).toggleThemeMode(),
      ),
    );
  }
}

class _DialogTheme extends ConsumerWidget {
  // ignore: unused_element
  const _DialogTheme({super.key});

  static const double _circleSize = 55.0; // diameter of the CircleAvatar
  //Maximum width of the dialog minus the internal horizontal Padding
  static const BoxConstraints _constraint = const BoxConstraints(maxWidth: 416);

  double _spacing(double width) {
    /*
    * 80 is the padding of the dialog (40.0 padding horizontal and 24.0 vertical)
    * 32 is the internal padding (contentPadding horizontal 16)
    * */
    final double _dialogWidth = (width - 80.0 - 32.0)
        .floorToDouble()
        .clamp(_constraint.minWidth, _constraint.maxWidth);
    int _circles = (_dialogWidth / _circleSize).floor() + 1;
    double _space =
        (_dialogWidth - (_circles * _circleSize)) / (_circles - 1.0);
    /*
    * Checking if the space between the circles is at least above 10 logical pixels
    * so it has a visually ergonomic look
    * */
    while (_space < 10 && _circles >= 2) {
      --_circles; //trying with one circle less in the row
      _space = (_dialogWidth - (_circles * _circleSize)) / (_circles - 1.0);
      //print('($_dialogWidth - ($_circles * 48.0)) / ($_circles - 1.0) =  $_space');
    }
    return _space.floorToDouble();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double spacing = _spacing(MediaQuery.of(context).size.width);
    final S translate = S.of(context);
    final theme = Theme.of(context);
    final ThemeMode themeMode = ref.watch(
      themeProvider.select<ThemeMode>((value) => value.preferredMode),
    );
    final segmentedModes = SegmentedButton<ThemeMode>(
      emptySelectionAllowed: false,
      multiSelectionEnabled: false,
      showSelectedIcon: false,
      segments: <ButtonSegment<ThemeMode>>[
        ButtonSegment<ThemeMode>(
          value: ThemeMode.light,
          label: Text(translate.themeMode(ThemeMode.light)),
          icon: const Icon(Icons.wb_sunny),
        ),
        ButtonSegment<ThemeMode>(
          value: ThemeMode.dark,
          label: Text(translate.themeMode(ThemeMode.dark)),
          icon: const Icon(Icons.brightness_3),
        ),
        ButtonSegment<ThemeMode>(
          value: ThemeMode.system,
          label: Text(translate.themeMode(ThemeMode.system)),
          icon: const Icon(Icons.brightness_auto),
        ),
      ],
      selected: <ThemeMode>{themeMode},
      onSelectionChanged: (newSelection) {
        ref.read(themeProvider).selectMode(newSelection.first);
      },
    );
    final child = IntrinsicWidth(
      stepWidth: 56.0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 280.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const Gap(8.0),
                  Text(
                    translate.appearance,
                    style: theme.textTheme.headlineMedium,
                  ),
                ],
              ),
              const Gap(16.0),
              Flexible(
                child: SingleChildScrollView(
                  child: ListBody(
                    children: [
                      segmentedModes,
                      const _WallpaperTile(size: _circleSize),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: ConstrainedBox(
                          constraints: _constraint,
                          child: Consumer(
                            builder: (context, ref, child) {
                              final themeRef = ref.watch(themeProvider);
                              return Wrap(
                                runSpacing: 10.0,
                                spacing: spacing,
                                children: <Widget>[
                                  for (Color color in themeRef.lightColors)
                                    GestureDetector(
                                      onTap: () => themeRef.lightTheme(
                                          themeRef.lightColors.indexOf(color)),
                                      child: _ColorCircleAvatar(
                                        color: color,
                                        size: _circleSize,
                                        isDynamic: false,
                                        side: BorderSide(
                                          strokeAlign: -1.0,
                                          width: 5.0,
                                          color: theme.colorScheme.tertiary,
                                          style: themeRef.lightOption ==
                                                  themeRef.lightColors
                                                      .indexOf(color)
                                              ? BorderStyle.solid
                                              : BorderStyle.none,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      Text(
                        translate.darkTheme,
                        style: theme.textTheme.headlineMedium,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                        child: Consumer(
                          builder: (context, ref, child) {
                            final themeRef = ref.watch(themeProvider);
                            final isDynamic = themeRef.useCustom;
                            return Wrap(
                              spacing: spacing,
                              runSpacing: 10.0,
                              children: <Widget>[
                                for (Color color in themeRef.darkColors)
                                  GestureDetector(
                                    onTap: () => themeRef.darkTheme(
                                      themeRef.darkColors.indexOf(color),
                                    ),
                                    child: _ColorCircleAvatar(
                                      color: color,
                                      size: _circleSize,
                                      isDynamic: isDynamic,
                                      side: BorderSide(
                                        strokeAlign: -1.0,
                                        width: 5.0,
                                        color: theme.brightness ==
                                                Brightness.dark
                                            ? theme.colorScheme.inversePrimary
                                            : theme.colorScheme.primary,
                                        style: themeRef.darkOption ==
                                                themeRef.darkColors
                                                    .indexOf(color)
                                            ? BorderStyle.solid
                                            : BorderStyle.none,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    final isTablet = isHorizontalTablet(MediaQuery.of(context).size);

    return isTablet ? Dialog(child: child) : Dialog.fullscreen(child: child);
  }
}

class _ColorCircleAvatar extends ConsumerWidget {
  final Color color;
  final double size;
  final BorderSide side;
  final bool isDynamic;

  const _ColorCircleAvatar({
    // ignore: unused_element
    super.key,
    required this.color,
    required this.size,
    required this.side,
    required this.isDynamic,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isDynamic) {
      return _SelectedMaterialAvatar(color: color, size: size, side: side);
    }
    return CircleAvatar(
      backgroundColor: color,
      radius: size / 2,
      child: AnimatedContainer(
        duration: kThemeAnimationDuration,
        decoration: ShapeDecoration(shape: CircleBorder(side: side)),
      ),
    );
  }
}

class _WallpaperTile extends ConsumerWidget {
  final double? size;

  const _WallpaperTile({
    // ignore: unused_element
    super.key,
    this.size,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallpaperTheme = ref.watch(customSchemesProvider);
    if (wallpaperTheme == null) {
      return const SizedBox();
    }
    final themeRef = ref.watch(themeProvider);
    final theme = Theme.of(context);
    final S translate = S.of(context);
    final bool isSelected = themeRef.useCustom;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: ListTile(
        style: ListTileStyle.list,
        dense: false,
        selected: isSelected,
        onTap: () => themeRef.useCustomScheme(wallpaperTheme),
        minVerticalPadding: 16.0,
        minTileHeight: 84.0,
        leading: _SelectedMaterialAvatar(
          size: size,
          color: wallpaperTheme.light.primaryContainer,
          side: BorderSide(
            strokeAlign: -1.0,
            width: 5.0,
            color: theme.colorScheme.secondary,
            style: themeRef.useCustom ? BorderStyle.solid : BorderStyle.none,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          side: BorderSide(color: theme.colorScheme.secondary, width: 2),
        ),
        selectedTileColor: theme.colorScheme.secondaryContainer,
        selectedColor: theme.colorScheme.onSecondaryContainer,
        textColor: theme.colorScheme.onSurface,
        titleTextStyle: theme.textTheme.titleLarge,
        subtitleTextStyle: theme.textTheme.bodySmall,
        title: Text(translate.use_wallpaper),
        subtitle: Text(translate.use_wallpaper_subtitle),
      ),
    );
  }
}

class _SelectedMaterialAvatar extends StatelessWidget {
  const _SelectedMaterialAvatar({
    // ignore: unused_element
    super.key,
    this.color,
    required this.size,
    required this.side,
  });

  final double? size;
  final Color? color;
  final BorderSide side;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size ?? 48.0,
      child: AnimatedContainer(
        duration: kThemeAnimationDuration,
        decoration: ShapeDecoration(
          color: color,
          shape: StarBorder(
            pointRounding: 0.45,
            points: 8,
            valleyRounding: 0.24,
            innerRadiusRatio: 0.75,
            rotation: 45,
            side: side,
          ),
        ),
      ),
    );
  }
}
