import 'package:amiibo_network/service/service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:amiibo_network/model/amiibo_local_db.dart';
import 'package:dash/dash.dart';

class AmiiboBloc extends Bloc{
  static final _service = Service();
  final _amiiboSeriesDB = BehaviorSubject<List<String>>();
  final _amiiboFetcherDB = BehaviorSubject<AmiiboLocalDB>();
  final _updateAmiiboDB = PublishSubject<AmiiboLocalDB>()
    ..listen((amiibos) => _service.update(amiibos))
    .onError((f) => print("Error updating DB"));

  Observable<AmiiboLocalDB> get allAmiibosDB => _amiiboFetcherDB.stream;

  Observable<bool> get findNew => _amiiboFetcherDB.stream
    .flatMap((x) => Observable.fromIterable(x.amiibo)
      .firstWhere((x) => x.brandNew?.isEven ?? true, orElse: () => null)
      .asObservable()
    )
    .map((x) => x != null ? true : false);

  Observable<List<String>> get allSeries => _amiiboSeriesDB.stream;

  fetchAllAmiibosDB() async{
    AmiiboLocalDB amiiboDB = await _service.fetchAllAmiiboDB();
    List<String> distinct = await _service.fetchDistinct();
    _amiiboFetcherDB.sink.add(amiiboDB);
    _amiiboSeriesDB.sink.add(distinct);
  }

  fetchByName(String name) async{
    final AmiiboLocalDB amiiboDB = await _service.fetchByCategory('name', '%$name%');
    _amiiboFetcherDB.sink.add(amiiboDB);
  }

  fetchByCategory(String name, [bool search]) async{
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
        amiiboDB = await _service.fetchByCategory(
          search ? 'name' : 'amiiboSeries', '%$name%');
        break;
    }
    _amiiboFetcherDB.sink.add(amiiboDB);
  }

  findBrandNew() async{
    await _service.findNew();
  }

  updateAmiiboDB({AmiiboDB amiibo, AmiiboLocalDB amiibos}) async{
    amiibos ??= AmiiboLocalDB(amiibo: [amiibo]);
    _updateAmiiboDB.sink.add(amiibos);
  }
  
  cleanBrandNew(String category, bool search) async{
    _service.cleanNew(category, search)
      .then((_) => fetchByCategory(category, search));
  }

  @override
  dispose() {
    _amiiboSeriesDB.close();
    _amiiboFetcherDB.close();
    _updateAmiiboDB.close();
  }

  static Bloc instance() => AmiiboBloc();
}