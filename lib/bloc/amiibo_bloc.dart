import 'package:amiibo_network/service/service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:amiibo_network/model/amiibo_local_db.dart';
import 'package:dash/dash.dart';

class AmiiboBloc extends Bloc{
  static final _service = Service();
  static String _searchFilter = 'amiiboSeries';
  final _amiiboFetcherDB = BehaviorSubject<AmiiboLocalDB>();
  final _filter = PublishSubject<String>();
  final _updateAmiiboDB = PublishSubject<AmiiboLocalDB>()
    ..listen((amiibos) => _service.update(amiibos));

  Observable<String> get filter => _filter.stream;

  Observable<AmiiboLocalDB> get allAmiibosDB => _amiiboFetcherDB.stream;

  Observable<bool> get findNew => _amiiboFetcherDB.stream
    .flatMap((x) => Observable.fromIterable(x.amiibo)
      .firstWhere((x) => x.brandNew?.isEven ?? true, orElse: () => null)
      .asObservable()
    )
    .map((x) => x != null ? true : false);

  fetchAllAmiibosDB() async{
    AmiiboLocalDB amiiboDB = await _service.fetchAllAmiiboDB();
    _amiiboFetcherDB.sink.add(amiiboDB);
  }

  Future<List<String>> listOfGames() => _service.fetchDistinct();

  fetchByName(String name) async{
    final AmiiboLocalDB amiiboDB = await _service.fetchByCategory('name', '%$name%');
    _amiiboFetcherDB.sink.add(amiiboDB);
  }

  resetPagination(String name, bool search) async{
    _searchFilter = search ? 'name' : 'amiiboSeries';
    await _fetchByCategory(name);
    _filter.sink.add(name);
  }

  _fetchByCategory(String name) async{
    AmiiboLocalDB amiiboDB;
    switch(name){
      case 'All':
        amiiboDB = await _service.fetchAllAmiiboDB();
        break;
      case 'New':
        amiiboDB = await _service.findNew();
        break;
      case 'Owned':
        amiiboDB = await _service.fetchByCategory('owned', '%1%');
        break;
      case 'Wishlist':
        amiiboDB = await _service.fetchByCategory('wishlist', '%1%');
        break;
      default:
        amiiboDB = await _service.fetchByCategory(_searchFilter, '%$name%');
        break;
    }
    _amiiboFetcherDB.sink.add(amiiboDB);
  }

  updateAmiiboDB({AmiiboDB amiibo, AmiiboLocalDB amiibos}) async{
    amiibos ??= AmiiboLocalDB(amiibo: [amiibo]);
    _updateAmiiboDB.sink.add(amiibos);
  }
  
  cleanBrandNew(String category) async{
    _service.cleanNew(category, _searchFilter)
      .then((_) => _fetchByCategory(category));
  }

  @override
  dispose() {
    _amiiboFetcherDB.close();
    _filter.close();
    _updateAmiiboDB.close();
  }

  static Bloc instance() => AmiiboBloc();
}