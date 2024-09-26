import 'package:amiibo_network/affiliation_product/domain/repository/affiliation_repository.dart';
import 'package:amiibo_network/affiliation_product/domain/model/affiliation_link.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'affiliation_repository_local.g.dart';

@riverpod
AffiliationRepository affiliationRepository(AffiliationRepositoryRef ref) {
  return const AffiliationRepositoryLocal();
}

class AffiliationRepositoryLocal implements AffiliationRepository {
  const AffiliationRepositoryLocal();

  @override
  Future<List<AffiliationLink>> links() async {
    return _amazonDomains.map((a) {
      final map = {
        'link': 'https://www.${a['amazon_domain']}/',
        'countryCode': a['country_code'],
        'countryName': a['country_name'],
      };
      return AffiliationLink.fromJson(map);
    }).toList();
  }
}

const _amazonDomains = [
  {"amazon_domain": "amazon.ae", "country_code": "ae", "country_name": "UAE"},
  {
    "amazon_domain": "amazon.ca",
    "country_code": "ca",
    "country_name": "Canada"
  },
  {"amazon_domain": "amazon.cn", "country_code": "cn", "country_name": "China"},
  {
    "amazon_domain": "amazon.co.jp",
    "country_code": "jp",
    "country_name": "Japan"
  },
  {
    "amazon_domain": "amazon.co.uk",
    "country_code": "uk",
    "country_name": "United Kingdom"
  },
  {
    "amazon_domain": "amazon.com",
    "country_code": "us",
    "country_name": "United States"
  },
  {
    "amazon_domain": "amazon.com.au",
    "country_code": "au",
    "country_name": "Australia"
  },
  {
    "amazon_domain": "amazon.com.be",
    "country_code": "be",
    "country_name": "Belgium"
  },
  {
    "amazon_domain": "amazon.com.br",
    "country_code": "br",
    "country_name": "Brasil"
  },
  {
    "amazon_domain": "amazon.com.tr",
    "country_code": "tr",
    "country_name": "Turkey"
  },
  {
    "amazon_domain": "amazon.com.mx",
    "country_code": "mx",
    "country_name": "Mexico"
  },
  {
    "amazon_domain": "amazon.de",
    "country_code": "de",
    "country_name": "Germany"
  },
  {"amazon_domain": "amazon.es", "country_code": "es", "country_name": "Spain"},
  {"amazon_domain": "amazon.eg", "country_code": "eg", "country_name": "Egypt"},
  {
    "amazon_domain": "amazon.fr",
    "country_code": "fr",
    "country_name": "France"
  },
  {"amazon_domain": "amazon.in", "country_code": "in", "country_name": "India"},
  {"amazon_domain": "amazon.it", "country_code": "it", "country_name": "Italy"},
  {
    "amazon_domain": "amazon.nl",
    "country_code": "nl",
    "country_name": "Netherlands"
  },
  {
    "amazon_domain": "amazon.pl",
    "country_code": "pl",
    "country_name": "Poland"
  },
  {
    "amazon_domain": "amazon.sa",
    "country_code": "sa",
    "country_name": "Saudi Arabia"
  },
  {
    "amazon_domain": "amazon.se",
    "country_code": "se",
    "country_name": "Sweden"
  },
  {
    "amazon_domain": "amazon.sg",
    "country_code": "sg",
    "country_name": "Singapore"
  }
];
