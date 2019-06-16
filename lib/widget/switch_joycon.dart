import 'package:flutter/material.dart';

class SwitchJoycon extends CustomPainter{
  final Paint joyconPaint;
  final Paint buttonPaint;
  final bool isLeft;

  SwitchJoycon({Color color, @required this.isLeft}):
    buttonPaint = Paint()
      ..color = const Color(0xFF414548)
      ..style = PaintingStyle.fill,
    joyconPaint = Paint()
      ..color = color ?? (isLeft == true ?
        const Color.fromRGBO(0, 195, 227, 1) : Colors.red[300])
      ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final length = size.height;
    joycon(canvas, length);
  }

  void joycon(canvas, length){
    Path rightJoyCon = Path()
      ..addRRect(RRect.fromRectAndCorners(
          Rect.fromPoints(
              Offset.zero,
              Offset(length * 0.35 , length)
          ),
          topLeft: isLeft ? Radius.circular(length*0.25) : Radius.zero,
          bottomLeft: isLeft ? Radius.circular(length*0.25) : Radius.zero,
          topRight: isLeft ? Radius.zero : Radius.circular(length*0.25),
          bottomRight: isLeft ? Radius.zero : Radius.circular(length*0.25)
      ));
    Path joystick = Path()
      ..addOval(Rect.fromCircle(
          center: Offset(length * 0.175, length * (isLeft ? 0.3 : 0.6)),
          radius: length * 0.1
      ));
    canvas.drawPath(rightJoyCon, joyconPaint);
    canvas.drawPath(joystick, buttonPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

/*
class SwitchJoyCon extends StatelessWidget{
  final double height;
  final bool left;
  final Color background;
  final Color border;

  SwitchJoyCon({
    Key key,
    this.height = 100,
    Color color,
    this.border,
    @required this.left,
  }) :  background = color ?? (left == true ? Colors.lightBlue[300] : Colors.red[200]),
        super(key: key);

  @override
  Widget build(BuildContext context){
    return Container(
      height: height,
      width: height*0.40,
      decoration: BoxDecoration(
          border: Border.all(
            width: height*0.05,
            color: border ?? background
          ),
          borderRadius: BorderRadius.horizontal(
            left: left == true ? Radius.circular(this.height*0.25) : Radius.zero,
            right: left == true ? Radius.zero : Radius.circular(this.height*0.25),
          ),
          color: background
      ),
      child: FractionallySizedBox(
        alignment: left == true ? Alignment.topCenter : Alignment.bottomCenter,
        heightFactor: left == true ? 0.6 : 0.8,
        widthFactor: 0.6,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
          ),
        ),
      )
    );
  }
}
*/
