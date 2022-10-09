import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:amiibo_network/screen/detail_page.dart';
import 'package:amiibo_network/screen/home_screen.dart';
import 'package:amiibo_network/screen/settings_screen.dart';
import 'package:amiibo_network/screen/splash_screen.dart';
import 'package:amiibo_network/screen/stats_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

GoRouter createRouter({
  String initial = '/',
  bool routerNeglect = true,
  UrlPathStrategy? urlPathStrategy = UrlPathStrategy.path,
  bool debugLogDiagnostics = kDebugMode,
}) {
  return GoRouter(
    debugLogDiagnostics: debugLogDiagnostics,
    urlPathStrategy: urlPathStrategy,
    errorBuilder: (_, __) => const Material(),
    routerNeglect: routerNeglect,
    initialLocation: initial,
    routes: [
      GoRoute(
        name: 'splash',
        path: '/',
        builder: (_, __) => const SplashScreen(),
        routes: [
          GoRoute(
            name: 'home',
            path: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            name: 'amiibo_details',
            path: 'amiibo/:id',
            builder: (context, state) => ProviderScope(
              overrides: [
                keyAmiiboProvider.overrideWithValue(int.parse(state.params['id']!))
              ],
              child: const DetailPage(),
            ),
          ),
          GoRoute(
            name: 'stats',
            path: 'stats',
            builder: (context, state) => const StatsPage(),
          ),
          GoRoute(
            name: 'settings',
            path: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
}
