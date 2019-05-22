import 'package:amiibo_network/service/service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:dash/dash.dart';

class SplashBloc extends Bloc {
  static final _service = Service();

  final _initializeApp = PublishSubject<bool>();

  Observable<bool> get allAmiibosDB => _initializeApp.stream;

  updateApp() async{
    final bool value = await _service.createDB();
    _initializeApp.sink.add(value);
  }

  @override
  dispose() {
    _initializeApp.close();
    return null;
  }

  static Bloc instance() => SplashBloc();
}