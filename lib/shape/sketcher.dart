import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Sketcher extends CustomPainter {
  final List<Offset> sketcherpoints;

  Sketcher(this.sketcherpoints);

  @override
  bool shouldRepaint(Sketcher oldDelegate) {
    return oldDelegate.sketcherpoints != sketcherpoints;
  }


  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    for (int i = 0; i < sketcherpoints.length - 1; i++) {
      if (sketcherpoints[i] != null && sketcherpoints[i + 1] != null) {
        canvas.drawLine(sketcherpoints[i], sketcherpoints[i + 1], paint);
      }
    }
  }
}