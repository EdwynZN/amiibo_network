import 'package:amiibo_network/service/service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:dash/dash.dart';

class SearchBloc extends Bloc{
  static final _service = Service();
  final _searchFetcher = PublishSubject<String>();

  Observable<List<String>> get search => _searchFetcher.stream
    .debounce(Duration(milliseconds: 500))
    .asyncMap((x) => x.isEmpty ? null : _service.searchDB(x));

  searchValue(String s) {
    _searchFetcher.sink.add(s);
  }

  @override
  dispose() {
    _searchFetcher.close();
  }

  static Bloc instance() => SearchBloc();
}