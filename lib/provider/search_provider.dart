import 'package:amiibo_network/service/service.dart';
import 'package:rxdart/rxdart.dart';

class SearchProvider{
  final _service = Service();
  final _searchFetcher = PublishSubject<String>();

  Stream<List<String>> get search => _searchFetcher.stream
    .debounceTime(const Duration(milliseconds: 500))
    .asyncMap((x) => x.isEmpty ? null : _service.searchDB(x));

  searchValue(String s) => _searchFetcher.sink.add(s);

  dispose() => _searchFetcher.close();
}