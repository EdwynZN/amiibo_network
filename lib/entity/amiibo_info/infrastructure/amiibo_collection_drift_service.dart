import 'package:amiibo_network/app/configuration/model/search_result.dart';
import 'package:amiibo_network/entity/amiibo_info/infrastructure/amiibo_info_mapper.dart';
import 'package:amiibo_network/entity/amiibo_info/model/amiibo_info.dart';
import 'package:amiibo_network/entity/amiibo_info/service/amiibo_collection_query_service.dart';
import 'package:amiibo_network/shared/data/drift_sqlite/model/drift_joined_amiibo_preferences.dart';
import 'package:amiibo_network/shared/data/drift_sqlite/source/amiibo_dao.dart';
import 'package:flutter/foundation.dart';

List<AmiiboInfo> _mapAmiibos(List<AmiiboDriftModel> amiibos) {
  return amiibos.map((e) => e.toAmiiboInfo()).toList();
}

class const DriftAmiiboCollectionQueryService(
  final AmiiboDao _amiiboDao,
) implements AmiiboCollectionQueryService {
  @override
  Future<List<AmiiboInfo>> fetchCollection({Filter? filter}) async {
    final amiibos = await _amiiboDao.fetchAll(
      categoryAttributes:
          filter?.categoryAttributes ??
          const CategoryAttributes(category: .All),
      searchAttributes: filter?.searchAttributes,
      orderBy: filter?.orderBy ?? .NA,
      sortBy: filter?.sortBy ?? .DESC,
      cards: filter?.categoryAttributes.cards ?? const [],
      figures: filter?.categoryAttributes.figures ?? const [],
      hiddenCategories: filter?.hiddenType,
    );

    return await compute(_mapAmiibos, amiibos);
  }

  @override
  Future<AmiiboInfo?> fetchDetail({required int amiiboId}) async {
    final amiibo = await _amiiboDao.fetchByKey(amiiboId);
    return amiibo?.toAmiiboInfo();
  }

  @override
  Stream<List<AmiiboInfo>> fetchStreamCollection({Filter? filter}) async* {
    final amiibos = await _amiiboDao.fetchAllStream(
      categoryAttributes:
          filter?.categoryAttributes ??
          const CategoryAttributes(category: .All),
      searchAttributes: filter?.searchAttributes,
      orderBy: filter?.orderBy ?? .NA,
      sortBy: filter?.sortBy ?? .DESC,
      cards: filter?.categoryAttributes.cards ?? const [],
      figures: filter?.categoryAttributes.figures ?? const [],
      hiddenCategories: filter?.hiddenType,
    );

    yield* amiibos.distinct().asyncMap(
      (amiibos) => compute(_mapAmiibos, amiibos),
    );
  }

  @override
  Stream<AmiiboInfo?> fetchStreamDetail({required int amiiboId}) {
    final amiibo = _amiiboDao.fetchByKeyStream(amiiboId);
    return amiibo.distinct().asyncMap((amiibo) => amiibo?.toAmiiboInfo());
  }
}
