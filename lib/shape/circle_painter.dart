import 'package:flutter/material.dart';
import 'dart:math';

class CirclePainter extends CustomPainter {
  Paint _paint;
  double _fraction;
  double circleSize = 35;

  CirclePainter(this._fraction) {
    _paint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 10.0
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;
  }

  void paint(Canvas canvas, Size size) {
    var rect = Offset(size.width/2-circleSize/2, size.height/2-circleSize/2) & Size(circleSize, circleSize);

//    var rect = Offset(size.width/4, size.height/4) & Size(size.width*0.5, size.width*0.5);


    canvas.drawArc(rect, -pi / 2, pi * 2 * _fraction, false, _paint);


  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) {
    return oldDelegate._fraction != _fraction;
  }
}