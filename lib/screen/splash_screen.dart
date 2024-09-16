import 'dart:async';
import 'package:amiibo_network/resources/resources.dart';
import 'package:amiibo_network/riverpod/theme_provider.dart';
import 'package:amiibo_network/utils/format_color_on_theme.dart';
import 'package:flutter/material.dart';
import 'package:amiibo_network/widget/switch_joycon.dart';
import 'package:amiibo_network/service/update_service.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late Color? color;
  late AnimationController _animationController;
  late final ThemeMode themeMode;

  Future<bool> get updateDB async {
    final UpdateService updateService = ref.read(updateServiceProvider);
    bool result = await updateService.createDB();
    await _animationController
        .forward()
        .whenComplete(() => _animationController.value = 0);
    return result;
  }

  @override
  void initState() {
    super.initState();
    themeMode = ref.read(themeProvider).preferredMode;
    _animationController = AnimationController(
        duration: Duration(seconds: 3),
        vsync: this,
        animationBehavior: AnimationBehavior.preserve)
      ..repeat();
  }

  @override
  void didChangeDependencies() {
    final mediaBrightness = MediaQuery.of(context).platformBrightness;
    color = colorOnThemeMode(themeMode, mediaBrightness);
    super.didChangeDependencies();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    Size _size = mediaQuery.size;
    return Material(
      type: MaterialType.canvas,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints.loose(
            Size(_size.width, _size.height / 2 - mediaQuery.padding.top),
          ),
          child: AspectRatio(
            aspectRatio: 25 / 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: _SwitchIcon(
                    controller: _animationController.view,
                    color: color,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.white, width: 0.1),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.7,
                    child: HookBuilder(
                      builder: (ctx) {
                        final snapshot = useFuture(
                          updateDB,
                          preserveState: true,
                        );
                        useValueChanged(
                          snapshot.hasData,
                          (_, __) => _animationController
                              .forward()
                              .whenCompleteOrCancel(
                                () => context.replaceNamed('home'),
                              ),
                        );
                        final S translate = S.of(ctx);
                        int key = 0;
                        Widget _child = const CircularProgressIndicator(
                          backgroundColor: Colors.black,
                        );
                        String _text = translate.splashMessage;
                        if (snapshot.hasData) {
                          key = 1;
                          _text = snapshot.data!
                              ? translate.splashWelcome
                              : translate.splashError;
                          _child = Image.asset(
                            NetworkIcons.iconApp,
                            fit: BoxFit.scaleDown,
                            color: color,
                          );
                        }
                        return AnimatedSwitcher(
                          duration: const Duration(seconds: 3),
                          switchOutCurve: Curves.easeOutBack,
                          switchInCurve: Curves.easeInExpo,
                          child: ScreenAnimation(
                            key: ValueKey<int>(key),
                            child: _child,
                            text: _text,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: _SwitchIcon(
                    controller: _animationController.view,
                    isLeft: false,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwitchIcon extends StatelessWidget {
  final bool isLeft;
  final Color? color;
  final Animation<double> controller;

  const _SwitchIcon({
    Key? key,
    required this.controller,
    this.isLeft = true,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SwitchAnimation animation = SwitchAnimation(
      controller: controller as AnimationController,
      delay: isLeft ? 0.1 : 0.6,
    );
    return AnimatedBuilder(
      animation: controller,
      child: CustomPaint(
        child: Container(),
        painter: SwitchJoycon(
          isLeft: isLeft,
          color: color,
        ),
      ),
      builder: (_, child) {
        return FractionalTranslation(
          translation: animation.translation.value,
          child: child,
        );
      },
    );
  }
}

class ScreenAnimation extends StatelessWidget {
  final Widget? child;
  final String? text;

  ScreenAnimation({Key? key, this.child, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      verticalDirection: VerticalDirection.up,
      children: <Widget>[
        Expanded(
          child: FittedBox(
            alignment: Alignment.center,
            fit: BoxFit.scaleDown,
            child: Text(text!, style: TextStyle(color: Colors.white)),
          ),
        ),
        Expanded(flex: 3, child: Center(child: child)),
      ],
    );
  }
}

class SwitchAnimation {
  SwitchAnimation({required this.controller, required this.delay})
      : translation = TweenSequence<Offset>([
          TweenSequenceItem<Offset>(
              tween: Tween<Offset>(
                begin: Offset.zero,
                end: Offset(0.0, -0.5),
              ),
              weight: 37.5),
          TweenSequenceItem<Offset>(
              tween: ConstantTween<Offset>(Offset(0.0, -0.5)), weight: 25),
          TweenSequenceItem<Offset>(
              tween: Tween<Offset>(
                begin: Offset(0.0, -0.5),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.elasticOut)),
              weight: 37.5),
        ]).animate(CurvedAnimation(
          parent: controller,
          curve: Interval(delay, 0.4 + delay),
        ));

  final AnimationController controller;
  final double delay;
  final Animation<Offset> translation;
}
