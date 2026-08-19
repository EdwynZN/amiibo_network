import 'package:amiibo_network/app/configuration/analytics_provider.dart';
import 'package:amiibo_network/shared/routes/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router_provider.g.dart';

@Riverpod(keepAlive: true)
class InitialScreen extends _$InitialScreen {
  @override
  String build() => '/splash';

  set change(String value) {
    state = value;
  }
}

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final initial = ref.watch(initialScreenProvider);
  final analytics = ref.watch(analyticsProvider);
  final router = createRouter(
    debugLogDiagnostics: kDebugMode,
    initial: initial,
    routerNeglect: true,
    observers: [analytics.navigatorObserver],
  );
  return router;
}
