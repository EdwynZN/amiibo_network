import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:flutter/services.dart';

class MarkdownReader extends StatelessWidget {
  final String title;
  final String file;
  const MarkdownReader({Key key, this.title, @required this.file}): super(key: key);

  Future<String> get _localFile => rootBundle.loadString('assets/text/$file.md');

  _launchURL(String url, BuildContext ctx) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Scaffold.of(ctx, nullOk: true)?.showSnackBar(SnackBar(content: Text('Could not launch $url')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final S translate = S.of(context);
    return AlertDialog(
      title: Text(title),
      titlePadding: const EdgeInsets.all(12),
      contentPadding: EdgeInsets.zero,
      content: Scrollbar(
          child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: FutureBuilder(
                  future: _localFile,
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot){
                    if(snapshot.hasError)
                      return Center(child: Text(translate.markdownError));
                    if(snapshot.hasData)
                      return MarkdownBody(
                        data: snapshot.data,
                        styleSheetTheme: MarkdownStyleSheetBaseTheme.platform,
                        onTapLink: (url) => _launchURL(url, context),
                      );
                    return const SizedBox.shrink();
                  }
              )
          )
      ),
      actions: <Widget>[
        FlatButton(
          textColor: Theme.of(context).accentColor,
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
          onPressed: () async {
            Navigator.of(context).maybePop();
          },
        ),
      ],
    );
  }
}
