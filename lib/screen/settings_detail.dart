import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsDetail extends StatefulWidget {
  final String title;
  const SettingsDetail({Key key, this.title}): super(key: key);

  @override
  State<StatefulWidget> createState() => SettingsDetailState();
}

class SettingsDetailState extends State<SettingsDetail> {
  String _text;

  Future<String> get _localFile async {
    return await rootBundle.loadString('assets/text/${widget.title}.txt');
  }

  @override
  void initState() {
    _localFile.then((value) => setState(() => _text = value));
    super.initState();
  }

  @override
  dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //backgroundColor: Colors.white,
        appBar: AppBar(
          //backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
          centerTitle: true,
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(8),
            child: Text('$_text'),
          ),
        )
    );
  }
}