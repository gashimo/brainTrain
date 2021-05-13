import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';

import 'animatedPathPainter.dart';
import 'path.dart';
import 'dart:math';
import 'package:braintrain/shape/circle.dart';
import 'package:braintrain/shape/sketcher.dart';


void main() => runApp(
  new MaterialApp(
    home: new AnimatedPathDemo(),
  ),
);


class AnimatedPathDemo extends StatefulWidget {
  @override
  _AnimatedPathDemoState createState() => _AnimatedPathDemoState();
}

class _AnimatedPathDemoState extends State<AnimatedPathDemo>
    with SingleTickerProviderStateMixin {

  List<Offset> sketcherpoints = <Offset>[];

  double screendwidth; // = MediaQuery.of(context).size.width;
  double screenhieght; // = MediaQuery.of(context).size.height;

  AnimationController _controller;
  bool playing = false;

  double playgroundhieght = 400;
  double playgroundwidth = 300;


  List<List<bool>> point = [
    [true, true, true],
    [true, false, true],
    [true, true, true]
  ];

  String _mySelection;
  List<Map> _myPaths;
  path currentSelectedPath;

  Future _loadLocalJsonData() async {

    String jsonPaths = await rootBundle.loadString("assets/PathData.json");
    setState(() {
      _myPaths = List<Map>.from(jsonDecode(jsonPaths) as List);
      if (currentSelectedPath==null)
      currentSelectedPath = path.fromMap(_myPaths[0]);

      //print("*******_myCurrencies: $_myCurrencies");
    });
  }

  void _startAnimation() {
    _controller.stop();
    _controller.reset();
    _controller.repeat(
      period: Duration(seconds: 5),
    );
  }

  void _stopAnimation() {
    _controller.stop();

  }


  @override
  Widget build(BuildContext context) {
    return _myPaths == null ? _buildWait(context) : _buildRun(context);
  }


  Widget _buildWait(BuildContext context) {
    return new Scaffold(
      body: new Center(child: CircularProgressIndicator()),
    );
  }
  //Widget build(BuildContext context) {
  Widget _buildRun(BuildContext context) {
    screendwidth = MediaQuery.of(context).size.width;
    screenhieght = MediaQuery.of(context).size.height;

    //playgroundwidth = screendwidth;
    //playgroundhieght = screenhieght;
    final _pathitemsName = _myPaths.map((c) {
      return new DropdownMenuItem<String>(
        value: c["path"].toString(),
        child: new Text(c["path"].toString()),
      );
    }).toList();
    return new Scaffold(
      appBar: new AppBar(title: const Text('Animated Paint')),
      body:
      Center(
        child: Column(
          children: <Widget>[
            new DropdownButton<String>(
              isDense: true,
              hint: new Text("Select Path"),
              value: _mySelection,
              onChanged: (String newValue) {
                setState(() {
                  _loadLocalJsonData();
                  _mySelection = newValue;
                  currentSelectedPath = path.fromMap(_myPaths[int.parse(_mySelection)-1]);
                  updatePoints(currentSelectedPath.pathOrder);
                  sketcherpoints.clear();
                  //pathCode = currentSelectedPath.points.toString();
                });
                print (_mySelection);


                //currentSelectedPath =_myPaths[int.parse(_mySelection)-1];

              },
              items: _pathitemsName,
            ),
          /*  TextField (
              onChanged: (text) {
                pathCode = text;
                pathData =jsonDecode(pathCode);
                //pathCode = pathData['pointsOrder'];
              },
            ),

           */
              Stack(
                //fit: StackFit.expand,
                children: <Widget>[

                  Container(
                   height: playgroundhieght = screenhieght*0.75 -(DropdownButton().itemHeight),
                   width: playgroundwidth = screendwidth*0.8,
//                    color: Colors.yellow,

                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children:[
                            Container(height: playgroundhieght/3, width: playgroundwidth/3,
                                      child: (point[0][0])? Circle():Container() ),
                            Container(height: playgroundhieght/3, width: playgroundwidth/3,
                                      child: (point[0][1])? Circle():Container() ),
                            Container(height: playgroundhieght/3, width: playgroundwidth/3,
                                      child: (point[0][2])? Circle():Container() ),
                             ]
                           ),
                            Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children:[
                                  Container(height: playgroundhieght/3, width: playgroundwidth/3,
                                      child: (point[1][0])? Circle():Container() ),
                                  Container(height: playgroundhieght/3, width: playgroundwidth/3,
                                      child: (point[1][1])? Circle():Container() ),
                                  Container(height: playgroundhieght/3, width: playgroundwidth/3,
                                      child: (point[1][2])? Circle():Container() ),
                                ]
                            ),
                            Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children:[
                                  Container(height: playgroundhieght/3, width: playgroundwidth/3,
                                      child: (point[2][0])? Circle():Container() ),
                                  Container(height: playgroundhieght/3, width: playgroundwidth/3,
                                      child: (point[2][1])? Circle():Container() ),
                                  Container(height: playgroundhieght/3, width: playgroundwidth/3,
                                      child: (point[2][2])? Circle():Container() ),
                                ]
                              ),
                            ]
                          )
                        ),
                  new CustomPaint(
                    foregroundPainter: new AnimatedPathPainter(_controller, currentSelectedPath),

                    child: new SizedBox(
                      // doesn't have to be a SizedBox - could be the Map image
                      width: playgroundwidth,
                      height: playgroundhieght,

                    ),
                  ),

                  GestureDetector(
                    child: Container (
                      height: playgroundhieght,
                      width: playgroundwidth,
                      //margin: EdgeInsets.all(1.0),
                      //alignment: Alignment.center,
                      //                  color: Colors.blueGrey[50],
                      //color: Colors.lightGreenAccent,
                      child: CustomPaint(
                        painter: Sketcher(sketcherpoints),
                      ),
                    ),
                    onPanUpdate: (DragUpdateDetails details) {
                      setState(() {
                        RenderBox box = context.findRenderObject();
                        Offset point = box.globalToLocal(details.globalPosition);
                        point = point.translate(-(screendwidth - playgroundwidth) /2 ,
                                                -(AppBar().preferredSize.height+DropdownButton().itemHeight));

                        sketcherpoints = List.from(sketcherpoints)..add(point);
                      });
                    },
                    onPanEnd: (DragEndDetails details) {
                      sketcherpoints.add(null);
                      showResultDialog(context, checkUserPath().toString());
                      //sketcherpoints.clear();
                    },

                  ),
                      ],
                    ),


          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
          onPressed: (){

              updatePoints(currentSelectedPath.pathOrder);
              _startAnimation();

            if(playing ) {
              setState((){
                playing = false;
              });
              _stopAnimation();
            } else {
              setState((){
                playing = true;
              });
              _startAnimation();
            }
          },
          tooltip: 'Play Animation',
          child: playing?new Icon(Icons.pause):new Icon(Icons.play_arrow)
//        onPressed: _startAnimation,
//        child: new Icon(Icons.play_arrow),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadLocalJsonData();
    _controller = new AnimationController(
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<path> parseJosn(String response) {
    if(response==null){
      return [];
    }
    final parsed =
    json.decode(response.toString()).cast<Map<String, dynamic>>();
    return parsed.map<path>((json) => new path.fromJson(json)).toList();
  }

  void updatePoints (String p) {

    setState(() {
      //updatePoints(pathCode);

      switch (p.toUpperCase()) {
        case "R":
          {
            point[0][0] = false;
            point[0][1] = false;
            point[0][2] = true;
            point[1][0] = false;
            point[1][1] = false;
            point[1][2] = false;
            point[2][0] = true;
            point[2][1] = false;
            point[2][2] = true;
          }
          break;
        case "C":
          {
            point[0][0] = false;
            point[0][1] = true;
            point[0][2] = false;
            point[1][0] = false;
            point[1][1] = false;
            point[1][2] = false;
            point[2][0] = true;
            point[2][1] = false;
            point[2][2] = true;
          }
          break;
        case "L":
          {
            point[0][0] = true;
            point[0][1] = false;
            point[0][2] = false;
            point[1][0] = false;
            point[1][1] = false;
            point[1][2] = false;
            point[2][0] = true;
            point[2][1] = false;
            point[2][2] = true;
          }
          break;
        case "Q":
          {
            point[0][0] = false;
            point[0][1] = true;
            point[0][2] = false;
            point[1][0] = true;
            point[1][1] = false;
            point[1][2] = true;
            point[2][0] = false;
            point[2][1] = true;
            point[2][2] = false;
          }
          break;
      }
    });
  }

  int checkUserPath (){

    int missingPoint = 0;
    int j = 0;


      for (int i = 0; i < currentSelectedPath.points.length; i++){

        if (j>=sketcherpoints.length-1) break;


          while (j<sketcherpoints.length) {

          if (int.parse(currentSelectedPath.points[i]["Sweep"]) <=1 ) break;

          double previousAngle;
          bool sweepDirection = int.parse(currentSelectedPath.points[i]["Sweep"]) > 0 ? true : false;
          bool sweepDirectionCorrect = true;




          if (getPointOnBoard(sketcherpoints[j]).toString() !=
              currentSelectedPath.points[i]["Point"])
/*
            missingPoint = int.parse(currentSelectedPath.points[i]["Point"]);  //point by location
*/
            missingPoint = i+1;  //point by order

          else {
              j+=20;
            double path2PointAngle = getPath2PointAngle (int.parse(currentSelectedPath.points[i]["Point"]), sketcherpoints[j] );
            if ( path2PointAngle == null)    break;
            int z = j;
            while (z>1 && j-z<8){
              z -= 1;
              previousAngle = getPath2PointAngle(
                  int.parse(currentSelectedPath.points[i]["Point"]),
                  sketcherpoints[z]);
              if (sweepDirection)
                path2PointAngle - previousAngle > 0
                    ? sweepDirectionCorrect = true
                    : sweepDirectionCorrect = false;
              else
                path2PointAngle - previousAngle < 0
                    ? sweepDirectionCorrect = true
                    : sweepDirectionCorrect = false;
            }


            if (!sweepDirectionCorrect)
              missingPoint = i+1;  //point by order
            else {
              missingPoint = 0;
              break;
            }
          }

          j++;
        }

      }

    return missingPoint;
  }

  int getPointOnBoard(Offset offset){

    int pointOffset = 0;
    int result = 0;

    int row =0 ; int column = 0;

    if (offset!=null) {
      while (offset.dx > pointOffset + playgroundwidth * column / 3) column++;
      while (offset.dy > pointOffset + playgroundhieght * row / 3) row++;
      result = (row - 1) * 3 + column;
    }
    return result;

  }


  double getPath2PointAngle (int point, Offset offset ) {

    double result;
    Offset pointCenter;
    int r = ((point+2)/3).floor() ;
    int c = 1+(point+2)%3;
    pointCenter = new Offset(((screendwidth - playgroundwidth) /2  + playgroundwidth) * c*0.25,
        ((AppBar().preferredSize.height +playgroundhieght) * r*0.25));

/*
    result = atan ((pointCenter.dy - offset.dy) / (pointCenter.dx - offset.dx));
*/
    if (offset!= null)
    result = atan ((offset.dy - pointCenter.dy) / (offset.dx - pointCenter.dx));



    print(point.toString() + ','+ pointCenter.toString() + ',' +  offset.toString() + ',' + result.toString() );

    return result;

  }

  showResultDialog(BuildContext context, String alertText) {

    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () { Navigator.pop(context);},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: alertText != '0' ? Text("המסלול לא הושלם") : Text("כל הכבוד"),
      content: alertText != '0'? Text("טעות בנקודה " + alertText): Text("השלמת את המסלול בהצלחה") ,
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

/*class Sketcher extends CustomPainter {
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

 */