import 'package:amiibo_network/routes/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = createRouter(
    debugLogDiagnostics: kDebugMode,
    initial: '/',
    routerNeglect: true,
    urlPathStrategy: UrlPathStrategy.path,
  );
  return router;
}, name: 'GoRouter');
