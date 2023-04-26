import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final analyticsProvider = Provider<Analytics>((ref) {
  if (kDebugMode) return const Analytics._debug();
  return Analytics();
});

class Analytics {
  const Analytics._debug();

  factory Analytics() = _FirebaseAnalytics;

  NavigatorObserver get navigatorObserver => _NavObserver();

  void logSearch(String searchTerm) {
    debugPrint('search: $searchTerm');
  }

  void logEvent(String name, [Map<String, String>? parameters]) {
    debugPrint('''name: $name
    parameters: $parameters''');
  }
}

class _FirebaseAnalytics implements Analytics {
  FirebaseAnalytics instance = FirebaseAnalytics.instance;

  _FirebaseAnalytics();

  @override
  NavigatorObserver get navigatorObserver => FirebaseAnalyticsObserver(
        analytics: instance,
      );

  void logSearch(String searchTerm) {
    unawaited(instance.logViewSearchResults(searchTerm: searchTerm));
  }

  void logEvent(String name, [Map<String, String>? parameters]) {
    unawaited(instance.logEvent(name: name, parameters: parameters));
  }
}

class _NavObserver extends RouteObserver<ModalRoute<dynamic>> {
  _NavObserver();

  void _sendScreenView(Route<dynamic> route) {
    final settings = route.settings;
    if (settings.name == null) return;
    debugPrint('''name: ${settings.name}
arguments: ${settings.arguments?.toString()}
''');
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _sendScreenView(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _sendScreenView(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _sendScreenView(previousRoute);
    }
  }
}
