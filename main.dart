import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';

final Color aliveColor = new Color.fromARGB(255, 50, 255, 100);
final Color deadColor = new Color.fromARGB(255, 240, 240, 240);
final Color uiColor = Colors.lightBlue;
final TargetPlatform platform = TargetPlatform.android;

void main() {
  runApp(GameOfLife());
}

class GOLPainter extends CustomPainter {
  static const xRes = 100;
  static const yRes = 100;
  double cWidth, cHeight;

  List<List<bool>> hiddenMat1 = new List<List<bool>>(xRes);
  List<List<bool>> hiddenMat2 = new List<List<bool>>(xRes);
  List<List<bool>> cells;

  GOLPainter(double width, double height) {
    cWidth = width / xRes;
    cHeight = height / yRes;
    cells = hiddenMat1;

    for (var i = 0; i < xRes; i++) {
      hiddenMat1[i] = new List<bool>(yRes);
      hiddenMat2[i] = new List<bool>(yRes);
      for (var j = 0; j < yRes; j++) hiddenMat1[i][j] = new Random().nextBool();
    }
  }

  void update() {
    List<List<bool>> next = (cells == hiddenMat1 ? hiddenMat2 : hiddenMat1);
    for (var i = 0; i < xRes; i++)
      for (var j = 0; j < yRes; j++) {
        int nCount = countNeighbours(i, j);
        next[i][j] = !cells[i][j] && nCount == 3 ||
            cells[i][j] && nCount >= 2 && nCount <= 3;
      }
    cells = next;
  }

  int countNeighbours(int x, int y) {
    int count = 0;
    for (var i = x - 1; i <= x + 1; i++)
      for (var j = y - 1; j <= y + 1; j++) {
        if (cells[(i + xRes) % xRes][(j + yRes) % yRes]) count++;
      }
    count -= (cells[x][y] ? 1 : 0);
    return count;
  }

  @override
  void paint(Canvas canvas, Size size) {
    update();
    for (var i = 0; i < xRes; i++)
      for (var j = 0; j < yRes; j++) {
        drawCell(canvas, i * cWidth, j * cHeight, cells[i][j]);
      }
  }

  @override
  bool shouldRepaint(GOLPainter oldDelegate) {
    return true;
  }

  // Draw a small circle representing a seed centered at (x,y).
  void drawCell(Canvas canvas, num x, num y, bool cellState) {
    var paint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.fill
      ..color = (cellState ? aliveColor : deadColor);
    canvas.drawRect(Offset(x, y) & Size(cWidth, cHeight), paint);
  }
}

class GameOfLife extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GameOfLifeState();
  }
}

class _GameOfLifeState extends State<GameOfLife> {
  static const width = 800.0;
  static const height = 800.0;
  Timer timer;

  @override
  Widget build(BuildContext context) {
    timer = new Timer.periodic(Duration(seconds: 2), (Timer t) => setState((){}));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData().copyWith(
        platform: platform,
        brightness: Brightness.dark,
        sliderTheme: SliderThemeData.fromPrimaryColors(
          primaryColor: uiColor,
          primaryColorLight: uiColor,
          primaryColorDark: uiColor,
          valueIndicatorTextStyle: DefaultTextStyle.fallback().style,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(title: Text("THA GAME OF SURVIVAL")),
        body: Container(
          constraints: BoxConstraints.expand(),
          decoration:
              BoxDecoration(border: Border.all(color: Colors.transparent)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent)),
                child: SizedBox(
                  width: width,
                  height: height,
                  child: CustomPaint(
                    painter: GOLPainter(width, height),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
