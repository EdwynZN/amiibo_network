import 'package:amiibo_network/affiliation_product/domain/repository/affiliation_repository.dart';
import 'package:amiibo_network/affiliation_product/domain/model/affiliation_link.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'affiliation_repository_local.g.dart';

@Riverpod(keepAlive: true)
AffiliationRepository affiliationRepository(AffiliationRepositoryRef ref) {
  return const AffiliationRepositoryLocal();
}

class AffiliationRepositoryLocal implements AffiliationRepository {
  const AffiliationRepositoryLocal();

  @override
  Future<List<AffiliationLink>> links() async {
    return _affiliatedDomains.map((a) {
      final map = Map<String, dynamic>.from(a);
      map['link'] = map.remove('amazonLink')! + '/';
      map['countryName'] = (map.remove('translation')! as Map)['en'];
      return AffiliationLink.fromJson(map);
    }).toList();
  }
}

const _affiliatedDomains = [
  {
    "amazonLink": "https://amazon.ae",
    "countryCode": "ae",
    "translation": {
      "en": "UAE",
      "es": "Emiratos Árabes Unidos",
      "fr": "Émirats arabes unis"
    },
  },
  {
    "amazonLink": "https://amazon.ca",
    "countryCode": "ca",
    "translation": {"en": "Canada", "es": "Canadá", "fr": "Canada"},
  },
  {
    "amazonLink": "https://amazon.cn",
    "countryCode": "cn",
    "translation": {"en": "China", "es": "China", "fr": "Chine"},
  },
  {
    "amazonLink": "https://amazon.co.jp",
    "countryCode": "jp",
    "translation": {"en": "Japan", "es": "Japón", "fr": "Japon"},
  },
  {
    "amazonLink": "https://amazon.co.uk",
    "countryCode": "uk",
    "translation": {
      "en": "United Kingdom",
      "es": "Reino Unido",
      "fr": "Royaume-Uni"
    },
  },
  {
    "amazonLink": "https://amazon.com",
    "countryCode": "us",
    "translation": {
      "en": "United States",
      "es": "Estados Unidos",
      "fr": "États-Unis"
    },
  },
  {
    "amazonLink": "https://amazon.com.au",
    "countryCode": "au",
    "translation": {"en": "Australia", "es": "Australia", "fr": "Australie"},
  },
  {
    "amazonLink": "https://amazon.com.be",
    "countryCode": "be",
    "translation": {"en": "Belgium", "es": "Bélgica", "fr": "Belgique"},
  },
  {
    "amazonLink": "https://amazon.com.br",
    "countryCode": "br",
    "translation": {"en": "Brazil", "es": "Brasil", "fr": "Brésil"},
  },
  {
    "amazonLink": "https://amazon.com.tr",
    "countryCode": "tr",
    "translation": {"en": "Türkiye", "es": "Turquía", "fr": "Turquie"},
  },
  {
    "amazonLink": "https://amazon.com.mx",
    "countryCode": "mx",
    "translation": {"en": "Mexico", "es": "México", "fr": "Mexique"},
  },
  {
    "amazonLink": "https://amazon.de",
    "countryCode": "de",
    "translation": {"en": "Germany", "es": "Alemania", "fr": "Allemagne"},
  },
  {
    "amazonLink": "https://amazon.es",
    "countryCode": "es",
    "translation": {"en": "Spain", "es": "España", "fr": "Espagne"},
  },
  {
    "amazonLink": "https://amazon.eg",
    "countryCode": "eg",
    "translation": {"en": "Egypt", "es": "Egipto", "fr": "Égypte"},
  },
  {
    "amazonLink": "https://amazon.fr",
    "countryCode": "fr",
    "translation": {"en": "France", "es": "Francia", "fr": "France"},
  },
  {
    "amazonLink": "https://amazon.in",
    "countryCode": "in",
    "translation": {"en": "India", "es": "India", "fr": "Inde"},
  },
  {
    "amazonLink": "https://amazon.it",
    "countryCode": "it",
    "translation": {"en": "Italy", "es": "Italia", "fr": "Italie"},
  },
  {
    "amazonLink": "https://amazon.nl",
    "countryCode": "nl",
    "translation": {
      "en": "Netherlands",
      "es": "Países Bajos",
      "fr": "Pays-Bas"
    },
  },
  {
    "amazonLink": "https://amazon.pl",
    "countryCode": "pl",
    "translation": {"en": "Poland", "es": "Polonia", "fr": "Pologne"},
  },
  {
    "amazonLink": "https://amazon.sa",
    "countryCode": "sa",
    "translation": {
      "en": "Saudi Arabia",
      "es": "Arabia Saudita",
      "fr": "Arabie Saoudite"
    },
  },
  {
    "amazonLink": "https://amazon.se",
    "countryCode": "se",
    "translation": {"en": "Sweden", "es": "Suecia", "fr": "Suède"},
  },
  {
    "amazonLink": "https://amazon.sg",
    "countryCode": "sg",
    "translation": {"en": "Singapore", "es": "Singapur", "fr": "Singapour"},
  },
];
