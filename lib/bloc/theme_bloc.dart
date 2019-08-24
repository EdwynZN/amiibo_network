import 'package:rxdart/rxdart.dart';
import 'package:dash/dash.dart';
import 'package:amiibo_network/themes.dart';
import 'package:flutter/material.dart';
import 'package:amiibo_network/service/service.dart';

class ThemeBloc extends Bloc{
  final service = Service();
  final _themeStream = BehaviorSubject<String>();
  String _savedTheme;

  Observable<List<ThemeData>> get themes => _themeStream.stream.distinct()
    .map((String x) => _switchTheme(x));

  set theme(String value) => _themeStream.sink.add(value);

  String get savedTheme => _savedTheme;

  Future<List<ThemeData>> initThemes() async {
    _savedTheme = await service.getTheme();
    return _switchTheme(_savedTheme);
  }

   themeDB(String value) async {
    if(value != _savedTheme){
      theme = _savedTheme = value;
      await service.updateTheme(value);
    }
  }

  List<ThemeData> _switchTheme(String theme){
    switch(theme){
      case 'Light':
        return [Themes.light, Themes.light];
      case 'Dark':
        return [Themes.dark, Themes.dark];
      default:
        return [Themes.light, Themes.dark];
    }
  }

  @override
  dispose() {
    _themeStream.close();
  }

  static Bloc instance() => ThemeBloc();
}