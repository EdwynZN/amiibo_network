import 'package:flutter/material.dart';
import 'package:amiibo_network/widget/switch_joycon.dart';
import 'package:amiibo_network/bloc/splash_bloc.dart';
import 'package:amiibo_network/bloc/bloc_provider.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen>
      with SingleTickerProviderStateMixin {
  static final lightTheme = SystemUiOverlayStyle.light
    .copyWith(systemNavigationBarColor: Colors.red);
  static final darkTheme = SystemUiOverlayStyle.light
    .copyWith(systemNavigationBarColor: Colors.blueGrey[800]);
  AnimationController _animationController;
  final SplashBloc _bloc = $Provider.of<SplashBloc>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
      animationBehavior: AnimationBehavior.preserve);
  }

  @override
  dispose(){
    $Provider.dispose<SplashBloc>();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        MediaQuery.platformBrightnessOf(context) == Brightness.light ? lightTheme : darkTheme);
    return Material(
      type: MaterialType.canvas,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchIcon(controller: _animationController.view),
          SizedBox(
            width: MediaQuery.of(context).size.height*0.33,
            height: (MediaQuery.of(context).size.height-15)/4,
            child: Container(
              color: Colors.black,
              child: StreamBuilder(
                stream: _bloc.allAmiibosDB,
                builder: (_, AsyncSnapshot<bool> snapshot) {
                  switch(snapshot.connectionState){
                    case ConnectionState.active:
                      if(snapshot.hasData){
                        if(!snapshot.data)
                          return  FlatButton(
                            textColor: Colors.white,
                            splashColor: Theme.of(context).accentColor,
                            highlightColor: Colors.transparent,
                            onPressed: () => {},//_bloc.updateApp(),
                            child: Center(child: Text("Couldn't Update :(", textAlign: TextAlign.center))
                          );
                        else if(snapshot.data){
                          _animationController.forward().whenCompleteOrCancel(
                              () => Navigator.pushReplacementNamed(context, '/home'));
                          return Center(child: Text("WELCOME"));
                        }
                      }
                      return Center(child: LinearProgressIndicator(backgroundColor: Colors.black,));
                    case ConnectionState.waiting:
                      _animationController.repeat();
                      _bloc.updateApp();
                      return Center(child: LinearProgressIndicator(backgroundColor: Colors.black,));
                    default:
                      return Center();
                  }
                }
              ),
            )
          ),
          SwitchIcon(controller: _animationController.view, isLeft: false,),
        ]
      ),
    );
  }
}

class SwitchIcon extends StatelessWidget{
  final AnimationController controller;
  final SwitchAnimation animation;
  final bool isLeft;

  SwitchIcon({
    Key key,
    @required this.controller,
    this.isLeft = true,
  }) :  animation = SwitchAnimation(controller: controller),
        super(key: key);

  @override
  Widget build(BuildContext context){
    return AnimatedBuilder(
      animation: controller,
      child: CustomPaint(
        size: Size(MediaQuery.of(context).size.height/11.3, MediaQuery.of(context).size.height/4),
        painter: SwitchJoycon(isLeft: isLeft,
            color: Theme.of(context).accentColor == Colors.redAccent ? null : Theme.of(context).accentColor)
      ),
      builder: (_, Widget child) {
        return FractionalTranslation(
          translation: isLeft ? animation.translationLeftStart.value +
                                animation.translationLeftEnd.value
                              : animation.translationRightStart.value +
                                animation.translationRightEnd.value,
          child: child
        );
      }
    );
  }
}

class SwitchAnimation {
  SwitchAnimation({@required this.controller}) :

    translationLeftEnd = Tween<Offset>(
      begin: Offset(0.0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.3, 0.5,
          curve: Curves.elasticOut,
        ),
      ),
    ),

    translationLeftStart = Tween<Offset>(
      begin: Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.1, 0.25,
          curve: Curves.linear,
        ),
      ),
    ),

    translationRightStart = Tween<Offset>(
      begin: Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.6, 0.75,
          curve: Curves.linear,
        ),
      ),
    ),

    translationRightEnd = Tween<Offset>(
      begin: Offset(0.0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.85, 1.0,
          curve: Curves.elasticOut,
        ),
      ),
    );

  final AnimationController controller;
  final Animation<Offset> translationLeftStart;
  final Animation<Offset> translationLeftEnd;
  final Animation<Offset> translationRightStart;
  final Animation<Offset> translationRightEnd;
}