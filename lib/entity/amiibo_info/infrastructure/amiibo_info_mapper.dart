import 'package:amiibo_network/entity/amiibo_info/model/amiibo_detail_info.dart';
import 'package:amiibo_network/entity/amiibo_info/model/amiibo_info.dart';
import 'package:amiibo_network/entity/amiibo_info/model/amiibo_user_collection_attributes.dart';
import 'package:amiibo_network/shared/data/drift_sqlite/model/amiibo_collection_drift_dto.dart';

extension AmiibroInfoDetailDriftMapper on AmiiboCollectionDetailDriftDto {
  AmiiboDetailInfo toAmiiboInfo() {
    UserAttributes userAttributes = const .none();
    final (int opened, int boxed) = (this.opened, this.boxed);
    if (opened > 0 || boxed > 0) {
      userAttributes = .owned(boxed: boxed, opened: opened);
    } else if (wishlist) {
      userAttributes = .wished();
    }

    return AmiiboDetailInfo(
      id: key,
      details: .new(
        nfcId: nfcId,
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
        cardNumber: cardNumber,
      ),
      bundles: List.unmodifiableOf(
        bundles.map((e) {
          UserAttributes userAttributes = const .none();
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
