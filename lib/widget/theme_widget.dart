import 'package:amiibo_network/riverpod/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ThemeButton extends HookConsumerWidget {
  final bool openDialog;

  static const double _circleSize = 55.0; // diameter of the CircleAvatar
  //Maximum width of the dialog minus the internal horizontal Padding
  static const BoxConstraints _constraint = const BoxConstraints(maxWidth: 416);

  const ThemeButton({this.openDialog = false});

  static double _spacing(double width) {
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

  static Future<void> dialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierColor: Colors.black12,
      builder: (BuildContext context) {
        final double spacing = _spacing(MediaQuery.of(context).size.width);
        final S translate = S.of(context);
        final theme = Theme.of(context);
        return SimpleDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                translate.mode,
                style: theme.textTheme.headlineMedium,
              ),
              const ThemeButton(),
            ],
          ),
          titlePadding: const EdgeInsets.all(16),
          contentPadding: const EdgeInsets.all(16),
          children: <Widget>[
            Text(
              translate.lightTheme,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
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
                            child: CircleAvatar(
                              backgroundColor: color,
                              radius: _circleSize / 2,
                              child: AnimatedContainer(
                                duration: kThemeAnimationDuration,
                                decoration: ShapeDecoration(
                                  shape: CircleBorder(
                                      side: BorderSide(
                                    strokeAlign: -1.0,
                                    width: 5.0,
                                    color: theme.brightness == Brightness.light
                                        ? theme.colorScheme.tertiary
                                        : theme.colorScheme.inversePrimary,
                                    style: themeRef.lightOption ==
                                            themeRef.lightColors.indexOf(color)
                                        ? BorderStyle.solid
                                        : BorderStyle.none,
                                  )),
                                ),
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
                  return Wrap(
                    spacing: spacing,
                    runSpacing: 10.0,
                    children: <Widget>[
                      for (Color color in themeRef.darkColors)
                        GestureDetector(
                          onTap: () => themeRef
                              .darkTheme(themeRef.darkColors.indexOf(color)),
                          child: CircleAvatar(
                            backgroundColor: color,
                            radius: _circleSize / 2,
                            child: AnimatedContainer(
                              duration: kThemeAnimationDuration,
                              decoration: ShapeDecoration(
                                shape: CircleBorder(
                                    side: BorderSide(
                                  strokeAlign: -1.0,
                                  width: 5.0,
                                  color: theme.brightness == Brightness.dark
                                      ? theme.colorScheme.inversePrimary
                                      : theme.colorScheme.tertiary,
                                  style: themeRef.darkOption ==
                                          themeRef.darkColors.indexOf(color)
                                      ? BorderStyle.solid
                                      : BorderStyle.none,
                                )),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
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
    final ThemeMode? theme = ref.watch(
        themeProvider.select<ThemeMode?>((value) => value.preferredTheme));
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
            child: _selectWidget(
                theme, Theme.of(context).colorScheme.onSurface),
          ),
        ),
        onLongPress: openDialog ? () => dialog(context) : null,
        onTap: () async => ref.read(themeProvider).toggleThemeMode(),
      ),
    );
  }
}
