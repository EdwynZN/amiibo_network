import 'package:flutter/material.dart';
import 'package:amiibo_network/screen/home_page.dart';
import 'package:amiibo_network/screen/splash_screen.dart';
import 'package:amiibo_network/widget/route_transitions.dart';
import 'package:amiibo_network/service/service.dart';
import 'package:amiibo_network/themes.dart';
import 'package:flutter/services.dart';

void main() async {
  if(!await Service().compareLastUpdate()) runApp(AmiiboNetwork(SplashScreen()));
  else runApp(AmiiboNetwork(HomePage()));
}

class AmiiboNetwork extends StatelessWidget {
  final Widget firstPage;
  AmiiboNetwork(this.firstPage);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Themes.light,
      darkTheme: Themes.dark,
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
}