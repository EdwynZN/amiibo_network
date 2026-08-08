import 'package:amiibo_network/shared/resources/resources.dart';

String amiiboAsset(String? image) =>
    image ?? NetworkIcons.amiiboImageUnavailable;

String amiiboAssetFromIndex(int index) => 'assets/collection/icon_$index.webp';
