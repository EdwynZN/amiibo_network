import 'package:amiibo_network/bloc/amiibo_bloc.dart';
import 'package:amiibo_network/bloc/splash_bloc.dart';
import 'package:amiibo_network/bloc/search_bloc.dart';
import 'package:dash/dash.dart';
part 'bloc_provider.g.dart';

@BlocProvider.register(AmiiboBloc)
@BlocProvider.register(SplashBloc)
@BlocProvider.register(SearchBloc)
abstract class Provider{}