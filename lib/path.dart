import 'dart:convert';

import 'package:braintrain/pathPoint.dart';

class path{

  int pathNumber;
String pathOrder;
List <dynamic> points;


path(
      {this.pathNumber,
        this.pathOrder,
        this.points,});

  factory path.fromJson(Map<String, dynamic> json) {
    return path(
        pathNumber: json["path"] as int,
        pathOrder: json["pointsOrder"] as String,
        points: json["PathPoints"] as List <dynamic>

    );
  }
factory path.fromMap(Map<String, dynamic> json) {
  return path(
      pathNumber: json["path"] as int,
      pathOrder: json["pointsOrder"] as String,
      points: json["PathPoints"] as List <dynamic>

  );
}

}