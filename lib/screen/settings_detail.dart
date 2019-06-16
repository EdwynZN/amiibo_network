import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsDetail extends StatelessWidget {
  final String title;
  const SettingsDetail({Key key, this.title}): super(key: key);

  Future<String> get _localFile => rootBundle.loadString('assets/text/$title.txt');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
      appBar: AppBar(title: Text(title),),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: FutureBuilder(
          future: _localFile,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot){
            if(snapshot.hasData)
              return Container(
                child: Text('${snapshot.data}',
                  overflow: TextOverflow.clip,
                  textAlign: TextAlign.justify,
                  style: TextStyle(height: 1.5, fontWeight: FontWeight.w500),
                ),
              );
            else return const SizedBox();
          }
        )
      )
    );
  }
}