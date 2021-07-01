import 'package:amiibo_network/riverpod/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ThemeButton extends HookWidget {
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
      builder: (BuildContext context) {
        final double spacing = _spacing(MediaQuery.of(context).size.width);
        final S translate = S.of(context);
        return SimpleDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                translate.mode,
                style: Theme.of(context).textTheme.headline4,
              ),
              const ThemeButton(),
            ],
          ),
          titlePadding: const EdgeInsets.all(16),
          contentPadding: const EdgeInsets.all(16),
          children: <Widget>[
            Text(
              translate.lightTheme,
              style: Theme.of(context).textTheme.headline4,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ConstrainedBox(
                constraints: _constraint,
                child: Consumer(
                  builder: (context, watch, child) {
                    final theme = watch(themeProvider);
                    return Wrap(
                      runSpacing: 10.0,
                      spacing: spacing,
                      children: <Widget>[
                        for (MaterialColor color in Colors.primaries)
                          GestureDetector(
                            onTap: () => theme
                                .lightTheme(Colors.primaries.indexOf(color)),
                            child: CircleAvatar(
                                backgroundColor: color,
                                radius: _circleSize / 2,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: theme.lightOption ==
                                          Colors.primaries.indexOf(color)
                                      ? const Icon(
                                          Icons.radio_button_unchecked,
                                          size: _circleSize * 0.9,
                                          color: Colors.white70,
                                        )
                                      : const SizedBox(),
                                )),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Text(
              translate.darkTheme,
              style: Theme.of(context).textTheme.headline4,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: Consumer(
                builder: (context, watch, child) {
                  final theme = watch(themeProvider);
                  return Wrap(
                    spacing: spacing,
                    runSpacing: 10.0,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () => theme.darkTheme(0),
                        child: CircleAvatar(
                            backgroundColor: Colors.blueGrey[800],
                            radius: _circleSize / 2,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: theme.darkOption == 0
                                  ? const Icon(
                                      Icons.radio_button_unchecked,
                                      size: _circleSize * 0.9,
                                      color: Colors.white70,
                                    )
                                  : const SizedBox(),
                            )),
                      ),
                      GestureDetector(
                        onTap: () => theme.darkTheme(1),
                        child: CircleAvatar(
                            backgroundColor: Colors.grey[800],
                            radius: _circleSize / 2,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: theme.darkOption == 1
                                  ? const Icon(
                                      Icons.radio_button_unchecked,
                                      size: _circleSize * 0.9,
                                      color: Colors.white70,
                                    )
                                  : const SizedBox(),
                            )),
                      ),
                      GestureDetector(
                        onTap: () => theme.darkTheme(2),
                        child: CircleAvatar(
                          backgroundColor: Colors.black,
                          radius: _circleSize / 2,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: theme.darkOption == 2
                              ? const Icon(
                                  Icons.radio_button_unchecked,
                                  size: _circleSize * 0.9,
                                  color: Colors.white70,
                                )
                              : const SizedBox(),
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

  Widget _selectWidget(ThemeMode? value) {
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
        return const Icon(
          Icons.brightness_auto,
          key: Key('Auto'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeMode? theme =
        useProvider(themeProvider.select((value) => value.preferredTheme));
    return InkResponse(
      radius: 18,
      splashFactory: InkRipple.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Theme.of(context).indicatorColor,
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
        child: _selectWidget(theme),
      ),
      onLongPress: openDialog ? () => dialog(context) : null,
      onTap: () async => context.read(themeProvider).toggleThemeMode(),
    );
  }
}