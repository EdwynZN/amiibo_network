import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsDetail extends StatelessWidget {
  final String title;
  const SettingsDetail({Key key, this.title}): super(key: key);

  Future<String> get _localFile => rootBundle.loadString('assets/text/$title.md');

  _launchURL(String url, BuildContext ctx) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Scaffold.of(ctx).showSnackBar(SnackBar(content: Text('Could not launch $url')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text(title),),
        body: FutureBuilder(
          future: _localFile,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot){
            if(snapshot.hasData)
              return Markdown(
                data: snapshot.data,
                styleSheetTheme: MarkdownStyleSheetBaseTheme.platform,
                onTapLink: (url) => _launchURL(url, context),
              );
            return const SizedBox.shrink();
          }
        )
      )
    );
  }
}