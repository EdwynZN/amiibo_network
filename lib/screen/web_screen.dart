import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class WebViewScreen extends StatelessWidget{
  final String url;
  final String title;
  WebViewScreen({this.url, this.title});

  @override
  Widget build(BuildContext context){
    return SafeArea(
      child: WebviewScaffold(
        clearCache: true,
        clearCookies: true,
        withJavascript: false,
        withLocalStorage: false,
        url: url,
        appBar: AppBar(
          titleSpacing: 12.0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(title,
                softWrap: false,
                overflow: TextOverflow.clip,
                style: Theme.of(context).appBarTheme.textTheme.title),
              Text(url,
                softWrap: false,
                overflow: TextOverflow.clip,
                style: Theme.of(context).appBarTheme.textTheme.subtitle),
            ],
          ),
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.maybePop(context),
          ),
          /*actions: <Widget>[
            Icon(Icons.share),
            SizedBox(child: Icon(Icons.more_vert), width: 48,)
          ],*/
        ),
        initialChild: const SizedBox.expand(),
      ),
    );
  }
}