import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:amiibo_network/screen/detail_page.dart';
import 'package:amiibo_network/screen/home_screen.dart';
import 'package:amiibo_network/screen/settings_screen.dart';
import 'package:amiibo_network/screen/splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

GoRouter createRouter({
  String initial = '/',
  bool routerNeglect = true,
  bool debugLogDiagnostics = kDebugMode,
  List<NavigatorObserver>? observers,
}) {
  return GoRouter(
    debugLogDiagnostics: debugLogDiagnostics,
    errorBuilder: (_, __) => const Material(),
    routerNeglect: routerNeglect,
    initialLocation: initial,
    observers: observers,
    routes: [
      GoRoute(
        name: 'splash',
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        name: 'home',
        path: '/home',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: const HomeScreen(),
            transitionsBuilder: (_, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        name: 'amiibo_details',
        path: '/amiibo/:id',
        builder: (context, state) => ProviderScope(
          overrides: [
            keyAmiiboProvider
                .overrideWithValue(int.parse(state.pathParameters['id']!))
          ],
          child: const DetailPage(),
        ),
      ),
      GoRoute(
        name: 'settings',
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
}
