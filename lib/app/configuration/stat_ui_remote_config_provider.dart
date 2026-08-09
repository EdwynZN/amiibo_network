import 'package:amiibo_network/shared/data/remote_config/constants/remote_constant_key.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stat_ui_remote_config_provider.g.dart';

@riverpod
bool remoteOwnedCategory(Ref ref) =>
    FirebaseRemoteConfig.instance.getBool(RemoteKey.ownedCategories);
