import 'dart:convert';

class pathPoint{

  // Point: 1-5 ,
  // Start: degree where to start go arround the point (0 is right),
  // Sweep: how many degrees go around,
  // Radius: the distance from the point (0=small or 1=large)
  String Point,Start,Sweep,Radius;


  pathPoint(
      {this.Point,
        this.Start,
        this.Sweep,
        this.Radius,});



  factory pathPoint.fromJson(Map<String, dynamic> json) {
    return pathPoint(
        Point: json["Point"] as String,
        Start: json["Start"] as String,
        Sweep: json["Sweep"] as String,
        Radius: json["Radius"] as String

    );
  }

}