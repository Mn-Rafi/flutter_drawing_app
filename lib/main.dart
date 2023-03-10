import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';

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

  bool isInteractiveTransform = false;

  List<List<int>> undoPositions = [];

  void selectColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose Color'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: brushColor,
            onColorChanged: (color) {
              this.setState(() {
                brushColor = color;
              });
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Close'))
        ],
      ),
    );
  }

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
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
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
                  InteractiveViewer(
                    minScale: 0.01,
                    maxScale: 25,
                    child: Container(
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
                      child: !isInteractiveTransform
                          ? GestureDetector(
                              onPanDown: (details) {
                                if (!isInteractiveTransform) {
                                  startPosition = points.length;
                                  this.setState(() {
                                    points.add(details.localPosition);
                                  });
                                }
                              },
                              onPanUpdate: (details) {
                                if (!isInteractiveTransform)
                                  this.setState(() {
                                    points.add(details.localPosition);
                                  });
                              },
                              onPanEnd: (details) {
                                if (!isInteractiveTransform) {
                                  endPosition = points.length;
                                  this.setState(() {
                                    points.add(null);
                                  });
                                  if (startPosition != null &&
                                      endPosition != null)
                                    undoPositions
                                        .add([startPosition!, endPosition!]);
                                  startPosition = null;
                                  endPosition = null;
                                }
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CustomPaint(
                                  painter: MyCustomPainter(
                                      points, brushColor, brushSize),
                                ),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CustomPaint(
                                painter: MyCustomPainter(
                                    points, brushColor, brushSize),
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
                            onPressed: () {
                              selectColor();
                            },
                            icon: Icon(
                              Icons.color_lens,
                              color: brushColor,
                            )),
                        IconButton(
                            onPressed: () {
                              this.setState(() {
                                isInteractiveTransform =
                                    !isInteractiveTransform;
                              });
                            },
                            icon: Icon(
                              Icons.zoom_in_map,
                              color: isInteractiveTransform
                                  ? Colors.red
                                  : Colors.black,
                            )),
                        Expanded(
                            child: Slider(
                          value: brushSize,
                          onChanged: (val) {
                            this.setState(() {
                              brushSize = val;
                            });
                          },
                          min: 1.0,
                          max: 20.0,
                        )),
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
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: width * 0.2,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 5.0,
                              spreadRadius: 1.0)
                        ]),
                    child: IconButton(
                      icon: Icon(Icons.download),
                      onPressed: () async {},
                    ),
                  )
                ],
              ),
            )
          ],
        ),
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
  void paint(Canvas canvas, Size size) async {
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
