//import 'dart:js';
import 'dart:math';
import 'dart:ui';

import 'package:braintrain/path.dart';
import 'package:braintrain/pathPoint.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimatedPathPainter extends CustomPainter {
  final Animation<double> _animation;
  //final String pathCode;
  final path pathdata;

  List<List <Rect>> rectPoint;

  List <pathPoint> requestedPath;

  Orientation deviceOrientation;


  AnimatedPathPainter(this._animation, this.pathdata) : super(repaint: _animation);

  Path _createAnyPath(Size size) {
    return Path()
      ..moveTo(0.5 * size.width / 7, 0.5 * size.height / 7)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width / 2, size.height)
      ..quadraticBezierTo(size.width / 2, 100, size.width, size.height);
  }

  Path _createTrainPath(Size size, path trainPath) {

    Map<String, dynamic> pathData = {

      'pointsOrder': '',
      'PathPoints':'',
    };

    //pathData = jsonDecode(trainPath);

    var points = trainPath.points as List;

    requestedPath = points.map<pathPoint>((json) => pathPoint.fromJson(json)).toList();


    num  offsetSmall, offsetLarge, requestedPoint, requestedRadius, heightOffset, widthOffset;
    double sizeLarge, sizeSmall;

    offsetSmall = 20;
    offsetLarge = -15;

    if (size.height>size.width) {
      sizeSmall = (size.width / 3) - (offsetSmall*2); //208
      sizeLarge = (size.width / 3) - (offsetLarge*2); //258
      heightOffset = DropdownButton().itemHeight - 15;
      widthOffset = 0;
    } else {
      sizeSmall = (size.height / 3) - (offsetSmall*2 -20) ; //208
      sizeLarge = (size.height / 3) - (offsetLarge*2); //258
      heightOffset = -5 ;
      widthOffset = DropdownButton().itemHeight +10;

    }



    rectPoint = [
      [(Offset((widthOffset+0 * size.width/3)+offsetSmall, (heightOffset+0 * size.height/3)+offsetSmall) & Size(sizeSmall, sizeSmall)),
      (Offset((widthOffset+1 * size.width/3)+offsetSmall, (heightOffset+0 * size.height/3)+offsetSmall) & Size(sizeSmall, sizeSmall)),
      (Offset((widthOffset+2 * size.width/3)+offsetSmall, (heightOffset+0 * size.height/3)+offsetSmall) & Size(sizeSmall, sizeSmall)),
      (Offset((widthOffset+0 * size.width/3)+offsetSmall, (heightOffset+1 * size.height/3)+offsetSmall) & Size(sizeSmall, sizeSmall)),
      (Offset((widthOffset+1 * size.width/3)+offsetSmall, (heightOffset+1 * size.height/3)+offsetSmall) & Size(sizeSmall, sizeSmall)),
      (Offset((widthOffset+2 * size.width/3)+offsetSmall, (heightOffset+1 * size.height/3)+offsetSmall) & Size(sizeSmall, sizeSmall)),
      (Offset((widthOffset+0 * size.width/3)+offsetSmall, (heightOffset+2 * size.height/3)+offsetSmall) & Size(sizeSmall, sizeSmall)),
      (Offset((widthOffset+1 * size.width/3)+offsetSmall, (heightOffset+2 * size.height/3)+offsetSmall) & Size(sizeSmall, sizeSmall)),
      (Offset((widthOffset+2 * size.width/3)+offsetSmall, (heightOffset+2 * size.height/3)+offsetSmall) & Size(sizeSmall, sizeSmall)),],
      [(Offset((widthOffset+0 * size.width/3)+offsetLarge, (heightOffset+0 * size.height/3)+offsetLarge) & Size(sizeLarge, sizeLarge)),
        (Offset((widthOffset+1 * size.width/3)+offsetLarge, (heightOffset+0 * size.height/3)+offsetLarge) & Size(sizeLarge, sizeLarge)),
        (Offset((widthOffset+2 * size.width/3)+offsetLarge, (heightOffset+0 * size.height/3)+offsetLarge) & Size(sizeLarge, sizeLarge)),
        (Offset((widthOffset+0 * size.width/3)+offsetLarge, (heightOffset+1 * size.height/3)+offsetLarge) & Size(sizeLarge, sizeLarge)),
        (Offset((widthOffset+1 * size.width/3)+offsetLarge, (heightOffset+1 * size.height/3)+offsetLarge) & Size(sizeLarge, sizeLarge)),
        (Offset((widthOffset+2 * size.width/3)+offsetLarge, (heightOffset+1 * size.height/3)+offsetLarge) & Size(sizeLarge, sizeLarge)),
        (Offset((widthOffset+0 * size.width/3)+offsetLarge, (heightOffset+2 * size.height/3)+offsetLarge) & Size(sizeLarge, sizeLarge)),
        (Offset((widthOffset+1 * size.width/3)+offsetLarge, (heightOffset+2 * size.height/3)+offsetLarge) & Size(sizeLarge, sizeLarge)),
        (Offset((widthOffset+2 * size.width/3)+offsetLarge, (heightOffset+2 * size.height/3)+offsetLarge) & Size(sizeLarge, sizeLarge)),]
    ];


    Path path = Path();
    Point controlPoint;
    Point nextDest;
    num nextRadius;
    for (int i=0; i<requestedPath.length;i++){

      requestedPoint = int.parse(requestedPath[i].Point);
      requestedRadius = int.parse(requestedPath[i].Radius);
      path.addArc(rectPoint[requestedRadius][requestedPoint-1], double.parse(requestedPath[i].Start)*pi/180, double.parse(requestedPath[i].Sweep)*pi/180);


      if (i<(requestedPath.length-1)) {
        requestedPoint = int.parse(requestedPath[i+1].Point);
        requestedRadius = int.parse(requestedPath[i+1].Radius);
        requestedRadius == 0 ? nextRadius = sizeSmall/2 : nextRadius = sizeLarge/2 ;
        nextDest = new Point (
            (nextRadius) *
                cos((double.parse(requestedPath[i + 1].Start)) * pi / 180) +
                rectPoint[requestedRadius][requestedPoint - 1].center.dx ,
            (nextRadius) *
                sin((double.parse(requestedPath[i + 1].Start)) * pi / 180) +
                rectPoint[requestedRadius][requestedPoint - 1].center.dy);

        controlPoint = bezierControlPoint(requestedPath[i+1]);

        path.quadraticBezierTo(controlPoint.x, controlPoint.y, nextDest.x, nextDest.y);

      }

    }

    return path;

  }

  Point bezierControlPoint (pathPoint nextPathPoint) {
    Point result;
    int addToStart = 80;  // distance of bezierControlPoint before next point
    Point nextpoint;
    num requestedPoint = int.parse(nextPathPoint.Point);
    num requestedRadius = int.parse(nextPathPoint.Radius);
    nextpoint = new Point(
        (rectPoint[requestedRadius][requestedPoint - 1].width / 2) *
            cos((double.parse(nextPathPoint.Start)) * pi / 180) +
            rectPoint[requestedRadius][requestedPoint - 1].center.dx ,
        (rectPoint[requestedRadius][requestedPoint - 1].width / 2) *
            sin((double.parse(nextPathPoint.Start)) * pi / 180) +
            rectPoint[requestedRadius][requestedPoint - 1].center.dy);

    if (double.parse(nextPathPoint.Start) == 0 || double.parse(nextPathPoint.Start) == 180) {
      double.parse(nextPathPoint.Start) == 0 ?
      double.parse(nextPathPoint.Sweep) > 0 ?
      result = new Point(nextpoint.x, nextpoint.y-addToStart) : result = new Point(nextpoint.x, nextpoint.y+addToStart):

      double.parse(nextPathPoint.Sweep) > 0 ?
      result = new Point(nextpoint.x, nextpoint.y+addToStart) : result = new Point(nextpoint.x, nextpoint.y-addToStart);
    }
    else if (double.parse(nextPathPoint.Start) == 90 || double.parse(nextPathPoint.Start) == 270){
      double.parse(nextPathPoint.Start) == 90 ?
      double.parse(nextPathPoint.Sweep) > 0 ?
      result = new Point(nextpoint.x+addToStart, nextpoint.y) : result = new Point(nextpoint.x-addToStart, nextpoint.y):
      double.parse(nextPathPoint.Sweep) > 0 ?
      result = new Point(nextpoint.x-addToStart, nextpoint.y) : result = new Point(nextpoint.x+addToStart, nextpoint.y);
    }
    else {
      double a = (nextpoint.y -
          rectPoint[requestedRadius][requestedPoint - 1].center.dy) /
          (nextpoint.x -
              rectPoint[requestedRadius][requestedPoint - 1].center.dx);
      double b = nextpoint.y - (-1 / a) * nextpoint.x;

      Point Xs = quadraticEquation(
          (1 +pow((-1/a),2)), (-2 * nextpoint.x - (-2*(-1/a) * (b - nextpoint.y))),
          (pow(nextpoint.x, 2) + pow((b - nextpoint.y),2) - pow((addToStart),2))
      );
      if ((double.parse(nextPathPoint.Start) < 180) &&
          (double.parse(nextPathPoint.Start) >= 0)) {
        nextpoint.x >= Xs.x ? result = new Point(Xs.x, (-1/a) * Xs.x + b) : result =
        new Point(Xs.y, (-1/a) * Xs.y + b);
      } else if ((double.parse(nextPathPoint.Start) < 360) &&
          (double.parse(nextPathPoint.Start) >= 180)) {
        nextpoint.x <= Xs.x ? result = new Point(Xs.x, (-1/a) * Xs.x + b) : result =
        new Point(Xs.y, (-1/a) * Xs.y + b);
      }
    }
    return result;
  }

  Point quadraticEquation (double a, double b, double c) {
    Point result;
    double x1,x2;

    double discriminant = b*b - 4*a*c;

    if (discriminant > 0) {
      x1 = (-b + sqrt(discriminant)) / (2*a);
      x2 = (-b - sqrt(discriminant)) / (2*a);
      result = new Point (x1,x2);
    }

    else if (discriminant == 0) {
      x1 = (-b + sqrt(discriminant)) / (2*a);
      result = new Point (x1,x1);
    }

    else {
      double realPart = -b/(2*a);
      double imaginaryPart =sqrt(-discriminant)/(2*a);
      x1 = realPart + imaginaryPart;
      x2 = realPart - imaginaryPart;
      result = new Point (x1,x2);

    }

    return result;


  }



  @override
  void paint(Canvas canvas, Size size) {
    final animationPercent = this._animation.value;

    print("Painting + ${animationPercent} - ${size}");

    //final path0 = createAnimatedPath(_createAnyPath(size), animationPercent);
    final path = createAnimatedPath(_createTrainPath(size, this.pathdata), animationPercent);

    final Paint paint = Paint();
    paint.color = Colors.amberAccent;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 5.0;

    canvas.drawPath(path, paint);
    //canvas.drawPath(path0, paint);


  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

Path createAnimatedPath(
    Path originalPath,
    double animationPercent,
    ) {
  // ComputeMetrics can only be iterated once!
  final totalLength = originalPath
      .computeMetrics()
      .fold(0.0, (double prev, PathMetric metric) => prev + metric.length);

  final currentLength = totalLength * animationPercent;

  return extractPathUntilLength(originalPath, currentLength);
}

Path extractPathUntilLength(
    Path originalPath,
    double length,
    ) {
  var currentLength = 0.0;

  final path = new Path();

  var metricsIterator = originalPath.computeMetrics().iterator;

  while (metricsIterator.moveNext()) {
    var metric = metricsIterator.current;

    var nextLength = currentLength + metric.length;

    final isLastSegment = nextLength > length;
    if (isLastSegment) {
      final remainingLength = length - currentLength;
      final pathSegment = metric.extractPath(0.0, remainingLength);

      path.addPath(pathSegment, Offset.zero);
      break;
    } else {
      // There might be a more efficient way of extracting an entire path
      final pathSegment = metric.extractPath(0.0, metric.length);
      path.addPath(pathSegment, Offset.zero);
    }

    currentLength = nextLength;
  }

  return path;
}