import 'package:amiibo_network/riverpod/analytics._provider.dart';
import 'package:amiibo_network/routes/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final initialScreen = Provider<String>((_) => '/splash');

final routerProvider = Provider<GoRouter>((ref) {
  final initial = ref.watch(initialScreen);
  final analytics = ref.watch(analyticsProvider);
  final router = createRouter(
    debugLogDiagnostics: kDebugMode,
    initial: initial,
    routerNeglect: true,
    observers: [analytics.navigatorObserver],
  );
  return router;
}, name: 'GoRouter');
