import 'package:amiibo_network/data/remote_config/constants/remote_constant_key.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final remoteStatUIProvider = Provider<bool>(
  (_) => FirebaseRemoteConfig.instance.getBool(RemoteKey.statDrawer),
);
