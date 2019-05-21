import 'package:amiibo_network/service/repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:dash/dash.dart';

class SearchBloc extends Bloc{
  static final _repository = Repository();
  final _searchFetcher = PublishSubject<String>();

  Observable<List<String>> get search => _searchFetcher.stream
    .debounce(Duration(milliseconds: 800))
    .asyncMap((x) => x.isEmpty ? null : _repository.searchDB(x))
    .map((x) => x?.toSet()?.toList());

  searchValue(String s) {
    _searchFetcher.sink.add(s);
  }

  @override
  dispose() {
    _searchFetcher.close();
  }

  static Bloc instance() => SearchBloc();
}