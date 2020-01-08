import 'package:flutter/material.dart';
import 'package:amiibo_network/provider/theme_provider.dart';
import 'package:provider/provider.dart';

class ThemeButton extends StatelessWidget{
  final bool openDialog;

  const ThemeButton({this.openDialog = false});

  static Future<void> dialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        final ThemeProvider theme = Provider.of<ThemeProvider>(context);
        return SimpleDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Color Theme', style: Theme.of(context).textTheme.display1,),
              ThemeButton()
            ],
          ),
          titlePadding: const EdgeInsets.all(15),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text('Ligh Theme', style: Theme.of(context).textTheme.display1,),
            ),
            Wrap(
              children: <Widget>[
                for(MaterialColor color in Colors.primaries)
                  GestureDetector(
                      onTap: () => theme.lightTheme(Colors.primaries.indexOf(color)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                            backgroundColor: color,
                            radius: 32,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: theme.lightOption == Colors.primaries.indexOf(color) ?
                              Icon(Icons.star, size: 24, color: Colors.white70,) : const SizedBox(),
                            )
                        ),
                      )
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text('Dark Theme', style: Theme.of(context).textTheme.display1,),
            ),
            Wrap(
              children: <Widget>[
                GestureDetector(
                    onTap: () => theme.darkTheme(0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                          backgroundColor: Colors.blueGrey[800],
                          radius: 32,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: theme.darkOption == 0 ?
                            Icon(Icons.star, size: 24, color: Colors.white70,) : const SizedBox(),
                          )
                      ),
                    )
                ),
                GestureDetector(
                    onTap: () => theme.darkTheme(1),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: 32,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: theme.darkOption == 1 ?
                            Icon(Icons.star, size: 24, color: Colors.white70,) : const SizedBox(),
                          )
                      ),
                    )
                ),
                GestureDetector(
                    onTap: () => theme.darkTheme(2),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                          backgroundColor: Colors.black,
                          radius: 32,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: theme.darkOption == 2 ?
                            Icon(Icons.star, size: 24, color: Colors.white70,) : const SizedBox(),
                          )
                      ),
                    )
                ),
              ],
            ),
          ],
        );
      }
    );
  }

  Widget _selectWidget(String value){
    switch(value){
      case 'Light':
        return const Icon(Icons.wb_sunny, color: Colors.orangeAccent,);
      case 'Dark':
        return const Icon(Icons.brightness_3, color: Colors.amber);
      default:
        return const Icon(Icons.brightness_auto);
    }
  }

  void changeTheme(BuildContext context, String strTheme){
    switch(strTheme){
      case 'Light':
        Provider.of<ThemeProvider>(context, listen: false).themeDB('Dark');
        break;
      case 'Dark':
        Provider.of<ThemeProvider>(context, listen: false).themeDB('Auto');
        break;
      default:
        Provider.of<ThemeProvider>(context, listen: false).themeDB('Light');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<ThemeProvider, String>(
      builder: (context, strTheme, _) {
        return InkResponse(
          radius: 18,
          splashFactory: InkRipple.splashFactory,
          highlightColor: Colors.transparent,
          splashColor: Theme.of(context).primaryColorDark,
          child: _selectWidget(strTheme),
          onLongPress: openDialog ? () => dialog(context) : null,
          onTap: () => changeTheme(context, strTheme),
        );
      },
      selector: (context, theme) => theme.savedTheme,
    );
  }
}

class ThemeDialog extends StatelessWidget {
  const ThemeDialog({Key key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeProvider theme = Provider.of<ThemeProvider>(context);
    return SimpleDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text('Color Theme', style: Theme.of(context).textTheme.display1,),
          ThemeButton()
        ],
      ),
      titlePadding: const EdgeInsets.all(15),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text('Ligh Theme', style: Theme.of(context).textTheme.display1,),
        ),
        Wrap(
          children: <Widget>[
            for(MaterialColor color in Colors.primaries)
              GestureDetector(
                  onTap: () => theme.lightTheme(Colors.primaries.indexOf(color)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                        backgroundColor: color,
                        radius: 32,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: theme.lightOption == Colors.primaries.indexOf(color) ?
                          Icon(Icons.star, size: 24, color: Colors.white70,) : const SizedBox(),
                        )
                    ),
                  )
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text('Dark Theme', style: Theme.of(context).textTheme.display1,),
        ),
        Wrap(
          children: <Widget>[
            GestureDetector(
                onTap: () => theme.darkTheme(0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                      backgroundColor: Colors.blueGrey[800],
                      radius: 32,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: theme.darkOption == 0 ?
                        Icon(Icons.star, size: 24, color: Colors.white70,) : const SizedBox(),
                      )
                  ),
                )
            ),
            GestureDetector(
                onTap: () => theme.darkTheme(1),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 32,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: theme.darkOption == 1 ?
                        Icon(Icons.star, size: 24, color: Colors.white70,) : const SizedBox(),
                      )
                  ),
                )
            ),
            GestureDetector(
                onTap: () => theme.darkTheme(2),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                      backgroundColor: Colors.black,
                      radius: 32,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: theme.darkOption == 2 ?
                        Icon(Icons.star, size: 24, color: Colors.white70,) : const SizedBox(),
                      )
                  ),
                )
            ),
          ],
        ),
      ],
    );
  }
}