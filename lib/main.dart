import 'package:flutter/material.dart';
import 'package:amiibo_network/screen/home_page.dart';
import 'package:amiibo_network/screen/splash_screen.dart';
import 'package:amiibo_network/widget/route_transitions.dart';
import 'package:amiibo_network/service/service.dart';
import 'package:amiibo_network/bloc/theme_bloc.dart';
import 'bloc/bloc_provider.dart';
import 'package:flutter/services.dart';

void main() async {
  final List<ThemeData> initialTheme = await $Provider.of<ThemeBloc>().initThemes();
  if(await Service().compareLastUpdate()) runApp(AmiiboNetwork(HomePage(), initialTheme));
  else runApp(AmiiboNetwork(SplashScreen(), initialTheme));
}

class AmiiboNetwork extends StatelessWidget {
  final ThemeBloc _themeBloc = $Provider.of<ThemeBloc>();
  final List<ThemeData> _initialData;
  final Widget firstPage;
  AmiiboNetwork(this.firstPage, this._initialData);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: _initialData,
      stream: _themeBloc.themes,
      builder: (context, AsyncSnapshot<List<ThemeData>> themes){
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themes.data[0],
          darkTheme: themes.data[1],
          onGenerateRoute: Routes.getRoute,
          home: Builder(
            builder: (BuildContext context){
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                  statusBarColor: Theme.of(context).scaffoldBackgroundColor,
                  systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor
                ),
                child: firstPage,
              );
            }
          )
        );
      }
    );
  }
}