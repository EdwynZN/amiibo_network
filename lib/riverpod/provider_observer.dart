import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FirebaseProviderObserver extends ProviderObserver {
  final FirebaseCrashlytics crashlytics;

  FirebaseProviderObserver(this.crashlytics);

  /// A provider emitted an error, be it by throwing during initialization
  /// or by having a [Future]/[Stream] emit an error
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    unawaited(crashlytics.recordError(
      error,
      stackTrace,
      reason: provider.name,
    ));
  }
}
