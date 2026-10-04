import 'package:amiibo_network/entity/amiibo_info/model/amiibo.dart';
import 'package:amiibo_network/entity/amiibo_info/model/amiibo_info.dart';
import 'package:amiibo_network/shared/data/drift_sqlite/model/drift_joined_amiibo_preferences.dart';

extension AmiibroInfoModelMapper on AmiiboDriftModel {
  AmiiboInfo toAmiiboInfo() {
    UserAttributes userAttributes = const .none();
    final (int opened, int boxed) = (this.opened, this.boxed);
    if (opened > 0 || boxed > 0) {
      userAttributes = .owned(boxed: boxed, opened: opened);
    } else if (wishlist) {
      userAttributes = .wished();
    }

    return AmiiboInfo(
      id: key,
      name: name,
      image: image,
      series: amiiboSeries,
      userAttributes: userAttributes,
    );
  }
}
