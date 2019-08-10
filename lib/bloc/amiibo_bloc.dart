import 'package:amiibo_network/service/service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:amiibo_network/model/amiibo_local_db.dart';
import 'package:dash/dash.dart';

class AmiiboBloc extends Bloc{
  static final _service = Service();
  String _searchFilter = 'amiiboSeries';
  String _name = 'All';
  Map<String,dynamic> _listOwned;
  final _owned = PublishSubject<Map<String,dynamic>>();
  final _amiiboFetcherDB = BehaviorSubject<AmiiboLocalDB>();
  final _filter = BehaviorSubject<String>();
  final _updateAmiiboDB = PublishSubject<AmiiboLocalDB>()
    ..listen((amiibos) async => await _service.update(amiibos));

  Observable<String> get filter => _filter.stream;

  set setFilter(String value) => _filter.sink.add(value);

  Observable<AmiiboLocalDB> get allAmiibosDB => _amiiboFetcherDB.stream;

  Observable<Map<String,dynamic>> get wished => _owned.stream
    .map((mapOwned) {
      if(mapOwned['Total'] == 0) return null;
      return mapOwned;
  });

  Future<void> fetchAllAmiibosDB() => _fetchByCategory('All');

  Future<List<String>> listOfGames() => _service.fetchDistinct();

  fetchByName(String name) async{
    final AmiiboLocalDB amiiboDB = await _service.fetchByCategory('name', '%$name%');
    _amiiboFetcherDB.sink.add(amiiboDB);
  }

  resetPagination(String name, bool search) async{
    _searchFilter = search ? 'name' : 'amiiboSeries';
    _name = name;
    await _fetchByCategory(name);
    _filter.sink.add('$name | Search Amiibo');
  }

  refreshPagination() async{
    await _fetchByCategory(_name);
    _filter.sink.add('$_name | Search Amiibo');
  }

  set removeFromList(String position) => --_listOwned[position];
  set countOwned(int counter) => counter.isOdd ? ++_listOwned['Owned'] : --_listOwned['Owned'];
  set countWished(int counter) => counter.isOdd ? ++_listOwned['Wished'] : --_listOwned['Wished'];

  updateList() => _owned.sink.add(_listOwned);

  _fetchByCategory(String name) async{
    AmiiboLocalDB amiiboDB;
    switch(name){
      case 'All':
        amiiboDB = await _service.fetchAllAmiiboDB();
        _listOwned = Map<String, dynamic>.from(
          (await _service.fetchSum(all: true)).first);
        break;
      case 'Owned':
        amiiboDB = await _service.fetchByCategory('owned', '%1%');
        _listOwned = Map<String, dynamic>.from(
          (await _service.fetchSum(column: 'owned', name: '%1%')).first);
        break;
      case 'Wishlist':
        amiiboDB = await _service.fetchByCategory('wishlist', '%1%');
        _listOwned = Map<String, dynamic>.from(
          (await _service.fetchSum(column: 'wishlist', name: '%1%')).first);
        break;
      case 'Cards':
        amiiboDB = await _service.fetchByCategory('type', '%Card%');
        _listOwned = Map<String, dynamic>.from(
          (await _service.fetchSum(column: 'type', name: '%Card%')).first);
        break;
      default:
        amiiboDB = await _service.fetchByCategory(_searchFilter,
          _searchFilter == 'name' ? '%$name%' : '%$name');
        _listOwned = Map<String, dynamic>.from(
          (await _service.fetchSum(column: _searchFilter,
          name: _searchFilter == 'name' ? '%$name%' : '%$name')).first);
        break;
    }
    _owned.sink.add(_listOwned);
    _amiiboFetcherDB.sink.add(amiiboDB);
  }

  updateAmiiboDB({AmiiboDB amiibo, AmiiboLocalDB amiibos}) async{
    amiibos ??= AmiiboLocalDB(amiibo: [amiibo]);
    _updateAmiiboDB.sink.add(amiibos);
  }

  @override
  dispose() {
    _owned.close();
    _amiiboFetcherDB.close();
    _filter.close();
    _updateAmiiboDB.close();
  }

  static Bloc instance() => AmiiboBloc();
}