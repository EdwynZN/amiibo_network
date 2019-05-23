// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bloc_provider.dart';

// **************************************************************************
// BlocProviderGenerator
// **************************************************************************

class $Provider extends Provider {
  static T of<T extends Bloc>() {
    switch (T) {
      case AmiiboBloc:
        {
          return BlocCache.getBlocInstance(
              "AmiiboBloc", () => AmiiboBloc.instance());
        }
      case SplashBloc:
        {
          return BlocCache.getBlocInstance(
              "SplashBloc", () => SplashBloc.instance());
        }
      case SearchBloc:
        {
          return BlocCache.getBlocInstance(
              "SearchBloc", () => SearchBloc.instance());
        }
    }
    return null;
  }

  static void dispose<T extends Bloc>() {
    switch (T) {
      case AmiiboBloc:
        {
          BlocCache.dispose("AmiiboBloc");
          break;
        }
      case SplashBloc:
        {
          BlocCache.dispose("SplashBloc");
          break;
        }
      case SearchBloc:
        {
          BlocCache.dispose("SearchBloc");
          break;
        }
    }
  }
}
