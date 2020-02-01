//Made with dartpad.dartlang.org <3
import 'dart:async';
import 'package:flutter/material.dart';

final Color cellColor = Colors.lightBlue;
final Color bgColor = new Color.fromARGB(255, 245, 245, 255);
final TargetPlatform platform = TargetPlatform.android;

List<List<bool>> cells;
final xRes = 50;
final yRes = 50;
double cWidth, cHeight;
bool paused = false;

void main() {
  runApp(GameOfLife());
}

class GOLPainter extends CustomPainter {
  List<List<bool>> hiddenMat1 = new List<List<bool>>(xRes);
  List<List<bool>> hiddenMat2 = new List<List<bool>>(xRes);

  GOLPainter(double width, double height) {
    cWidth = width / xRes;
    cHeight = height / yRes;
    cells = hiddenMat1;

    for (var i = 0; i < xRes; i++) {
      hiddenMat1[i] = new List<bool>(yRes);
      hiddenMat2[i] = new List<bool>(yRes);
      for (var j = 0; j < yRes; j++) hiddenMat1[i][j] = false;
    }
  }

  void update() {
    if (paused) return;
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
    canvas.drawRect(Offset(0, 0) & Size(cWidth * xRes, cHeight * yRes),
        Paint()..color = bgColor);
    for (var i = 0; i < xRes; i++)
      for (var j = 0; j < yRes; j++) {
        if (cells[i][j]) drawCell(canvas, i * cWidth, j * cHeight, cells[i][j]);
      }
  }

  @override
  bool shouldRepaint(GOLPainter oldDelegate) {
    return true;
  }

  void drawCell(Canvas canvas, num x, num y, bool cellState) {
    canvas.drawRect(
        Offset(x, y) & Size(cWidth, cHeight), Paint()..color = cellColor);
  }
}

class GameOfLife extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GameOfLifeState();
  }
}

class _GameOfLifeState extends State<GameOfLife> {
  static const width = 700.0;
  static const height = 700.0;
  IconData icon = Icons.pause;
  Timer timer;
  GOLPainter painter = GOLPainter(width, height);
  bool fillMode;

  @override
  void initState() {
    timer = new Timer.periodic(Duration(milliseconds: 100), (Timer t) {
      setState(() {
        painter.update();
      });
    });
    super.initState();
  }

  void _pointerClick(PointerEvent e) {
    fillMode = !cells[e.localPosition.dx ~/ cWidth][e.localPosition.dy ~/ cHeight];
    _pointerDraw(e);
  }

  void _pointerDraw(PointerEvent e) {
    cells[e.localPosition.dx ~/ cWidth][e.localPosition.dy ~/ cHeight] =
        fillMode;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text("Conways Game of Flutter")),
        body: Container(
          constraints: BoxConstraints.expand(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Listener(
                  onPointerMove: _pointerDraw,
                  onPointerDown: _pointerClick,
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: CustomPaint(
                      key: ValueKey(timer.tick),
                      painter: painter,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: new Icon(icon, size: 25.0),
          onPressed: () {
            paused = !paused;
            icon = icon == Icons.pause ? Icons.play_arrow : Icons.pause;
          },
        ),
      ),
    );
  }
}