import 'package:flutter/material.dart';
import 'package:amiibo_network/provider/theme_provider.dart';
import 'package:provider/provider.dart';

class ThemeButton extends StatelessWidget{
  final bool openDialog;

  static const double _circleSize = 55.0; // diameter of the CircleAvatar
  //Maximum width of the dialog minus the internal horizontal Padding
  static const BoxConstraints _constraint = const BoxConstraints(maxWidth: 416);

  const ThemeButton({this.openDialog = false});

  static double _spacing(double width){
    /*
    * 80 is the padding of the dialog (40.0 padding horizontal and 24.0 vertical)
    * 32 is the internal padding (contentPadding horizontal 16)
    * */
    final double _dialogWidth = (width - 80.0 - 32.0).floorToDouble()
      .clamp(_constraint.minWidth, _constraint.maxWidth);
    int _circles = (_dialogWidth / _circleSize).floor() + 1;
    double _space = (_dialogWidth - (_circles * _circleSize)) / (_circles - 1.0);
    /*
    * Checking if the space between the circles is at least above 10 logical pixels
    * so it has a visually ergonomic look
    * */
    while(_space < 10 && _circles >= 2){
      --_circles; //trying with one circle less in the row
      _space = (_dialogWidth - (_circles * _circleSize)) / (_circles - 1.0);
      //print('($_dialogWidth - ($_circles * 48.0)) / ($_circles - 1.0) =  $_space');
    }
    return _space.floorToDouble();
  }

  static Future<void> dialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        final ThemeProvider theme = Provider.of<ThemeProvider>(context);
        final double spacing = _spacing(MediaQuery.of(context).size.width);
        return SimpleDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Color Theme', style: Theme.of(context).textTheme.display1,),
              ThemeButton()
            ],
          ),
          titlePadding: const EdgeInsets.all(16),
          contentPadding: const EdgeInsets.all(16),
          children: <Widget>[
            Text('Ligh Theme', style: Theme.of(context).textTheme.display1,),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ConstrainedBox(
                constraints: _constraint,
                child: Wrap(
                  runSpacing: 10.0,
                  spacing: spacing,
                  children: <Widget>[
                    for(MaterialColor color in Colors.primaries)
                      GestureDetector(
                        onTap: () => theme.lightTheme(Colors.primaries.indexOf(color)),
                        child: CircleAvatar(
                          backgroundColor: color,
                          radius: _circleSize / 2,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: theme.lightOption == Colors.primaries.indexOf(color) ? const
                            Icon(Icons.radio_button_unchecked, size: _circleSize*0.9, color: Colors.white70,) : const SizedBox(),
                          )
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Text('Dark Theme', style: Theme.of(context).textTheme.display1,),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: Wrap(
                spacing: spacing, runSpacing: 10.0,
                children: <Widget>[
                  GestureDetector(
                    onTap: () => theme.darkTheme(0),
                    child: CircleAvatar(
                      backgroundColor: Colors.blueGrey[800],
                      radius: _circleSize / 2,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: theme.darkOption == 0 ? const
                        Icon(Icons.radio_button_unchecked, size: _circleSize*0.9, color: Colors.white70,) : const SizedBox(),
                      )
                    ),
                  ),
                  GestureDetector(
                    onTap: () => theme.darkTheme(1),
                    child:CircleAvatar(
                      backgroundColor: Colors.grey[800],
                      radius: _circleSize / 2,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: theme.darkOption == 1 ? const
                        Icon(Icons.radio_button_unchecked, size: _circleSize*0.9, color: Colors.white70,) : const SizedBox(),
                      )
                    ),
                  ),
                  GestureDetector(
                    onTap: () => theme.darkTheme(2),
                    child: CircleAvatar(
                      backgroundColor: Colors.black,
                      radius: _circleSize / 2,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: theme.darkOption == 2 ? const
                        Icon(Icons.radio_button_unchecked, size: _circleSize*0.9, color: Colors.white70,) : const SizedBox(),
                      )
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _selectWidget(String value){
    switch(value){
      case 'Light':
        return const Icon(Icons.wb_sunny, key: Key('Light'), color: Colors.orangeAccent,);
      case 'Dark':
        return const Icon(Icons.brightness_3, key: Key('Dark'), color: Colors.amber);
      default:
        return const Icon(Icons.brightness_auto, key: Key('Auto'),);
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
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            reverseDuration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeInOutBack,
            switchOutCurve: Curves.easeOutBack,
            transitionBuilder: (child, animation){
              return RotationTransition(
                turns: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                )
              );
            },
            child: _selectWidget(strTheme),
          ),
          onLongPress: openDialog ? () => dialog(context) : null,
          onTap: () => changeTheme(context, strTheme),
        );
      },
      selector: (context, theme) => theme.savedTheme,
    );
  }
}