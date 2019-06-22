import 'package:flutter/material.dart';
import 'package:amiibo_network/screen/home_page.dart';
import 'package:amiibo_network/screen/splash_screen.dart';
import 'package:amiibo_network/widget/route_transitions.dart';
import 'package:amiibo_network/service/service.dart';
import 'package:amiibo_network/themes.dart';

void main() async {
  runApp(AmiiboNetwork(SplashScreen()));
  //if(!(await Service().compareLastUpdate() ?? true)) runApp(AmiiboNetwork(SplashScreen()));
  //else runApp(AmiiboNetwork(HomePage()));
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
      home: firstPage,
    );
  }
}