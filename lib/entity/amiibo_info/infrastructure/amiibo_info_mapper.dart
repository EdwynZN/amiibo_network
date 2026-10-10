import 'package:amiibo_network/entity/amiibo_info/model/amiibo.dart';
import 'package:amiibo_network/entity/amiibo_info/model/amiibo_detail_info.dart';
import 'package:amiibo_network/entity/amiibo_info/model/amiibo_info.dart';
import 'package:amiibo_network/shared/data/drift_sqlite/model/amiibo_collection_drift_dto.dart';
import 'package:amiibo_network/shared/data/drift_sqlite/model/drift_joined_amiibo_preferences.dart';

extension AmiibroInfoDetailDriftMapper on AmiiboCollectionDetailDriftDto {
  AmiiboDetailInfo toAmiiboInfo() {
    UserCollectionAttributes userAttributes = const .none();
    final (int opened, int boxed) = (this.opened, this.boxed);
    if (opened > 0 || boxed > 0) {
      userAttributes = .owned(boxed: boxed, opened: opened);
    } else if (wishlist) {
      userAttributes = .wished();
    }

    return AmiiboDetailInfo(
      id: key,
      details: .new(
        amiiboSeries: amiiboSeries,
        character: character,
        gameSeries: gameSeries,
        name: name,
        userAttributes: userAttributes,
        type: type,
        images: List.unmodifiableOf(images),
        na: na,
        au: au,
        eu: eu,
        jp: jp,
      ),
      bundles: List.unmodifiableOf(
        bundles.map((e) {
          UserCollectionAttributes userAttributes = const .none();
          final (int opened, int boxed) = (e.opened, e.boxed);
          if (opened > 0 || boxed > 0) {
            userAttributes = .owned(boxed: boxed, opened: opened);
          } else if (e.wishlist) {
            userAttributes = .wished();
          }
          return AmiiboBundleMetadata(
            id: e.id,
            name: e.name,
            amiiboIds: List.unmodifiableOf(e.amiiboIds),
            images: List.unmodifiableOf(e.images),
            userAttributes: userAttributes,
          );
        }),
      ),
    );
  }
}

extension AmiibroInfoDriftMapper on AmiiboCollectionDriftDto {
  AmiiboInfo toAmiiboInfo() {
    UserAttributes userAttributes = const .none();
    CollectionType type = .none;
    final (int opened, int boxed) = (this.opened, this.boxed);
    if (opened > 0 || boxed > 0) {
      type = .owned;
      userAttributes = .owned(boxed: boxed, opened: opened);
    } else if (wishlist) {
      type = .wished;
      userAttributes = .wished();
    }

    return AmiiboInfo(
      id: key,
      name: name,
      image: image,
      series: amiiboSeries,
      userAttributes: userAttributes,
      collection: type,
    );
  }
}
