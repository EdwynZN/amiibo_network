import 'package:freezed_annotation/freezed_annotation.dart';

part 'affiliation_link.freezed.dart';
part 'affiliation_link.g.dart';

@freezed
class AffiliationLink with _$AffiliationLink {
  const factory AffiliationLink({
    required Uri link,
    required String countryCode,
    required String countryName,
  }) = _AffiliationLink;
	
  factory AffiliationLink.fromJson(Map<String, dynamic> json) =>
			_$AffiliationLinkFromJson(json);
}
