import 'package:freezed_annotation/freezed_annotation.dart';

part 'affiliation_link_read_model.freezed.dart';
part 'affiliation_link_read_model.g.dart';

@freezed
abstract class AffiliationLinkReadModel with _$AffiliationLinkReadModel {
  const factory AffiliationLinkReadModel({
    required Uri link,
    required String countryCode,
    required CountryNameReadModel countryName,
  }) = _AffiliationLinkReadModel;

  factory AffiliationLinkReadModel.fromJson(Map<String, dynamic> json) =>
      _$AffiliationLinkReadModelFromJson(json);

  factory AffiliationLinkReadModel.fromDB(Map<String, dynamic> json) {
    final map = Map<String, dynamic>.from(json);
    map
      ..['link'] = json['affiliation_link.amazon']
      ..['countryName'] = {
        'en': json['country.en'],
        'es': json['country.es'],
        'fr': json['country.fr'],
      }
      ..['countryCode'] = json['country.code'];
    return _$AffiliationLinkReadModelFromJson(map);
  }
}

@freezed
abstract class CountryNameReadModel with _$CountryNameReadModel {
  const CountryNameReadModel._();

  const factory CountryNameReadModel({
    required String en,
    required String es,
    required String fr,
  }) = _CountryNameReadModel;

  String get defaultName => en;

  String localization(String languageCode) {
    return switch (languageCode) {
      'es' => es,
      'fr' => fr,
      _ => defaultName,
    };
  }

  factory CountryNameReadModel.fromJson(Map<String, dynamic> json) =>
      _$CountryNameReadModelFromJson(json);
}
