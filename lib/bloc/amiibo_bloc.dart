import 'package:amiibo_network/service/service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:amiibo_network/model/amiibo_local_db.dart';
import 'package:dash/dash.dart';

class AmiiboBloc extends Bloc{
  static final _service = Service();
  String _searchFilter = 'amiiboSeries';
  String _name = 'All';
  List<int> _listOwned;
  final _owned = PublishSubject<List<int>>();
  final _amiiboFetcherDB = BehaviorSubject<AmiiboLocalDB>();
  final _filter = PublishSubject<String>();
  final _updateAmiiboDB = PublishSubject<AmiiboLocalDB>()
    ..listen((amiibos) => _service.update(amiibos));

  Observable<String> get filter => _filter.stream;

  Observable<AmiiboLocalDB> get allAmiibosDB => _amiiboFetcherDB.stream;

  Observable<List<String>> get wished => _owned.stream
    .map((list) {
      if(list?.isEmpty ?? true) return null;
      final List<String> data = ['${list[0]} of ${list[2]} owned',
                                 '${list[1]} of ${list[2]} wished'];
      return data;
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
    _filter.sink.add(name);
  }

  refreshPagination() async{
    await _fetchByCategory(_name);
    _filter.sink.add(_name);
  }

  set removeFromList(int position) => --_listOwned[position];
  set countOwned(int counter) => counter.isOdd ? ++_listOwned[0] : --_listOwned[0];
  set countWished(int counter) => counter.isOdd ? ++_listOwned[1] : --_listOwned[1];

  updateList() => _owned.sink.add(_listOwned);

  _fetchByCategory(String name) async{
    AmiiboLocalDB amiiboDB;
    switch(name){
      case 'All':
        amiiboDB = await _service.fetchAllAmiiboDB();
        break;
      case 'Owned':
        amiiboDB = await _service.fetchByCategory('owned', '%1%');
        break;
      case 'Wishlist':
        amiiboDB = await _service.fetchByCategory('wishlist', '%1%');
        break;
      case 'Cards':
        amiiboDB = await _service.fetchByCategory('type', '%Card%');
        break;
      default:
        amiiboDB = await _service.fetchByCategory(_searchFilter, '%$name%');
        break;
    }
    if(amiiboDB?.amiibo?.isNotEmpty ?? false) {
      int owned = 0; int wished = 0;
      amiiboDB.amiibo.forEach((x) {
        if(x?.owned?.isOdd ?? false) owned++;
        if(x?.wishlist?.isOdd ?? false) wished++;
      });
      _listOwned = [owned, wished, amiiboDB.amiibo.length];
    } else _listOwned = null;
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