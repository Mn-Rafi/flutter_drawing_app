import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Canvas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Canvas'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Offset?> points = [];
  late Color brushColor;
  late double brushSize;

  int? startPosition;
  int? endPosition;

  List<List<int>> undoPositions = [];

  @override
  void initState() {
    super.initState();
    brushColor = Colors.black;
    brushSize = 2.0;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  Color.fromRGBO(138, 35, 135, 1.0),
                  Color.fromRGBO(233, 64, 87, 1.0),
                  Color.fromRGBO(242, 113, 33, 1.0),
                ])),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: width * 0.8,
                  height: height * 0.7,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 5.0,
                            spreadRadius: 1.0)
                      ]),
                  child: GestureDetector(
                    onPanDown: (details) {
                      startPosition = points.length;
                      this.setState(() {
                        points.add(details.localPosition);
                      });
                    },
                    onPanUpdate: (details) {
                      this.setState(() {
                        points.add(details.localPosition);
                      });
                    },
                    onPanEnd: (details) {
                      endPosition = points.length;
                      this.setState(() {
                        points.add(null);
                      });
                      if (startPosition != null && endPosition != null)
                        undoPositions.add([startPosition!, endPosition!]);
                      startPosition = null;
                      endPosition = null;
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CustomPaint(
                        painter:
                            MyCustomPainter(points, brushColor, brushSize),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: width * 0.8,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 5.0,
                            spreadRadius: 1.0)
                      ]),
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {}, icon: Icon(Icons.color_lens)),
                      IconButton(
                          onPressed: () {
                            if (undoPositions.isNotEmpty) {
                              this.setState(() {
                                points.replaceRange(undoPositions.last[0],
                                    undoPositions.last[1], []);
                              });
                              undoPositions.removeLast();
                            }
                          },
                          icon: Icon(
                            Icons.undo,
                            color: undoPositions.isNotEmpty
                                ? Colors.black
                                : Colors.grey,
                          )),
                      IconButton(
                          onPressed: () {
                            this.setState(() {
                              points.clear();
                              undoPositions.clear();
                            });
                          },
                          icon: Icon(
                            Icons.layers_clear,
                            color: undoPositions.isNotEmpty
                                ? Colors.black
                                : Colors.grey,
                          ))
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final List<Offset?> points;
  final Color brushColor;
  final double brushSize;

  MyCustomPainter(this.points, this.brushColor, this.brushSize);

  @override
  void paint(Canvas canvas, Size size) {
    Paint background = Paint()..color = Colors.white;
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, background);
    Paint paint = Paint();
    paint.color = brushColor;
    paint.strokeWidth = brushSize;
    paint.isAntiAlias = true;
    paint.strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawPoints(PointMode.points, [points[i]!], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
