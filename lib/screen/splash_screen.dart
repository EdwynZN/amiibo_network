import 'package:flutter/material.dart';
import 'package:amiibo_network/widget/switch_joycon.dart';
import 'package:amiibo_network/bloc/splash_bloc.dart';
import 'package:amiibo_network/bloc/bloc_provider.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
      with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _opacity;
  double _size;
  final SplashBloc _bloc = $Provider.of<SplashBloc>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
      animationBehavior: AnimationBehavior.preserve)
    ..repeat();
    _opacity = Tween<double>(begin: 0, end: 1)
      .animate(
      AnimationMin(
        Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _animationController,
            curve: Interval(0.0, 0.5, curve: Curves.decelerate)
          )
        ),
        Tween<double>(begin: 1, end: 0).animate(
          CurvedAnimation(parent: _animationController,
            curve: Interval(0.5, 1.0, curve: Curves.decelerate)
          )
        )
      )
    );
    _bloc.updateApp();
  }

  @override
  dispose(){
    $Provider.dispose<SplashBloc>();
    _animationController.dispose();
    super.dispose();
  }

  _completeAnimation() {
    _animationController.forward().then((_) {
      _animationController.value = 0;
      _bloc.finishAnimation();
    });
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).orientation == Orientation.portrait ?
      MediaQuery.of(context).size.height : MediaQuery.of(context).size.width;
    return SafeArea(
      child: Material(
        type: MaterialType.canvas,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SwitchIcon(controller: _animationController.view, height: _size),
            Container(
              color: Colors.black,
              padding: EdgeInsets.all(5),
              width: _size/3,
              height: _size/4,
              alignment: Alignment.center,
              child: StreamBuilder(
                stream: _bloc.allAmiibosDB,
                builder: (_, AsyncSnapshot<bool> snapshot) {
                  if(snapshot.hasData && !_animationController.isAnimating){
                    _animationController.forward().whenCompleteOrCancel(
                      () => Future.delayed(const Duration(milliseconds: 500))
                      .then((_) => Navigator.pushReplacementNamed(context, '/home')));
                    if(!snapshot.data) return ScreenAnimation(
                      opacity: _animationController,
                      child: Text("Couldn't Update :(", style: TextStyle(color: Colors.white70))
                    );
                    else return ScreenAnimation(
                      opacity: _animationController,
                      child: Text("WELCOME", style: TextStyle(color: Colors.white70)),
                    );
                  }
                  else if(snapshot.hasData) _completeAnimation();
                  return Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      const CircularProgressIndicator(backgroundColor: Colors.black),
                      FadeTransition(
                        opacity: _opacity,
                        child: Align(alignment: Alignment.bottomCenter,
                            child: Text("Just a second...", style: TextStyle(color: Colors.white))
                        ),
                      )
                    ],
                  );
                }
              ),
            ),
            SwitchIcon(controller: _animationController.view, isLeft: false, height: _size),
          ]
        ),
      ),
    );
  }
}

class ScreenAnimation extends StatelessWidget{
  final AnimationController opacity;
  final Widget child;

  ScreenAnimation({Key key, this.opacity, this.child}) : super(key : key);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacity,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Image.asset('assets/images/icon_app.png', fit: BoxFit.fitWidth)
          ),
          Expanded(child: Center(child: child))
        ],
      )
    );
  }
}

class SwitchIcon extends StatelessWidget{
  final AnimationController controller;
  final SwitchAnimation animation;
  final bool isLeft;
  final double height;

  SwitchIcon({
    Key key,
    @required this.controller,
    @required this.height,
    this.isLeft = true,
  }) : animation = SwitchAnimation(controller: controller),
        super(key: key);

  @override
  Widget build(BuildContext context){
    return AnimatedBuilder(
      animation: controller,
      child: CustomPaint(
        size: Size(height/11.3, height/4),
        painter: SwitchJoycon(isLeft: isLeft,
        color: MediaQuery.platformBrightnessOf(context) == Brightness.light ?
          null : Theme.of(context).primaryColor)
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