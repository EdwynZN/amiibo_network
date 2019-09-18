import 'package:flutter/material.dart';
import 'package:amiibo_network/widget/switch_joycon.dart';
import 'package:flutter/services.dart';
import 'package:amiibo_network/service/service.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
  with SingleTickerProviderStateMixin {
  static final _service = Service();
  AnimationController _animationController;

  Future<bool> get updateDB async {
    bool result = await _service.createDB();
    await _animationController.forward().whenComplete(
      () => _animationController.value = 0);
    return result;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
      animationBehavior: AnimationBehavior.preserve)
    ..repeat();
  }

  @override
  dispose(){
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _size = MediaQuery.of(context).orientation == Orientation.portrait ?
      MediaQuery.of(context).size.height : MediaQuery.of(context).size.width;
    return SafeArea(
      child: Material(
        type: MaterialType.canvas,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchIcon(controller: _animationController.view, height: _size),
            Container(
              color: Colors.black,
              padding: EdgeInsets.all(5),
              width: _size/3,
              height: _size/4,
              alignment: Alignment.center,
              child: FutureBuilder<bool>(
                future: updateDB,
                builder: (ctx, snapshot){
                  int key = 0;
                  Widget _child = const CircularProgressIndicator(backgroundColor: Colors.black);
                  String _text = "Just a second . . .";
                  if(snapshot.hasData){
                    key = 1;
                    _text = snapshot.data ? 'WELCOME' : 'Couldn\'t Update 😢';
                    _child = Image.asset('assets/images/icon_app.png', fit: BoxFit.fitWidth);
                    _animationController.forward().whenCompleteOrCancel(() =>
                      Navigator.pushReplacementNamed(context, '/home')
                    );
                  }
                  return AnimatedSwitcher(duration: const Duration(seconds: 3),
                    switchOutCurve: Curves.easeOutBack,
                    switchInCurve: Curves.easeInExpo,
                    child: ScreenAnimation(
                      key: ValueKey<int>(key),
                      child: _child,
                      text: _text
                    )
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
  final Widget child;
  final String text;

  ScreenAnimation({Key key, this.child, this.text}) : super(key : key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(flex: 3, child: Center(child: child)),
        Expanded(child: Center(
          child: Text(text, style: TextStyle(color: Colors.white)))
        )
      ],
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
  }) : animation = SwitchAnimation(controller: controller, delay: isLeft ? 0.1 : 0.6),
    super(key: key);

  @override
  Widget build(BuildContext context){
    return AnimatedBuilder(
      animation: controller,
      child: CustomPaint(
        size: Size(height/11.3, height/4),
        painter: SwitchJoycon(isLeft: isLeft,
        color: Theme.of(context).brightness == Brightness.light ?
          null : Theme.of(context).primaryColor)
      ),
      builder: (_, Widget child) {
        return FractionalTranslation(
          translation: animation.translation.value,
          child: child
        );
      }
    );
  }
}

class SwitchAnimation {
  SwitchAnimation({@required this.controller, @required this.delay}) :

  translation = TweenSequence<Offset>([
      TweenSequenceItem<Offset>(
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: Offset(0.0, -0.5),
        ),
        weight: 37.5
      ),
      TweenSequenceItem<Offset>(
          tween: ConstantTween<Offset>(Offset(0.0,-0.5)),
          weight: 25
      ),
      TweenSequenceItem<Offset>(
        tween: Tween<Offset>(
          begin: Offset(0.0, -0.5),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 37.5
      ),
    ])
    .animate(CurvedAnimation(
      parent: controller,
      curve: Interval(
        delay, 0.4 + delay
      ),
    )
  );

  final AnimationController controller;
  final double delay;
  final Animation<Offset> translation;
}