import 'package:flutter/material.dart';

class CustomMap extends CustomPainter {
  Size screenSize;
  List<Offset> pointsRoads;
  List<Offset> pointsBuilding;
  List<Path> pointsBuildings;
  final bgColor = const Color(0xFFF7F7F7);
  final borderColor = const Color(0xFFCBCBCB);
  final buildingColor = const Color(0xFFEFEFEF);
  double scale = 1.0;
  Offset delta = Offset.zero;

  final Paint paintRoads = Paint()
    ..color = Colors.white
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 3.0;
  final Paint paintBorder = Paint()
    ..color = Colors.black12
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 4.0;

  final Paint paintBuilding = Paint()
    ..color = Color(0xFFEFEFEF)
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 1.0;

  final Paint paintBuildingBorder = Paint()
    ..color = Color(0xFFEFEFEF)
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 1.0;

  CustomMap(
      {this.delta,
      this.scale,
      this.pointsRoads,
      this.pointsBuilding,
      this.pointsBuildings,
      this.screenSize});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(delta.dx, delta.dy);
    canvas.scale(scale, scale);
    canvas.drawColor(bgColor, BlendMode.color);
    // Roads Start
    if (pointsRoads != null && pointsRoads.length > 0) {
      var start = DateTime.now().millisecondsSinceEpoch;
      for (int i = 0; i < pointsRoads.length - 1; i++) {
        if (isInScreen(pointsRoads[i], pointsRoads[i + 1])) {
          canvas.drawLine(pointsRoads[i], pointsRoads[i + 1], paintBorder);
        }
      }
      var end = DateTime.now().millisecondsSinceEpoch;
      print("Draw Roads Border: ${end - start}");

      var start2 = DateTime.now().millisecondsSinceEpoch;
      for (int i = 0; i < pointsRoads.length - 1; i++) {
        if (isInScreen(pointsRoads[i], pointsRoads[i + 1])) {
          canvas.drawLine(pointsRoads[i], pointsRoads[i + 1], paintRoads);
        }
      }
      var end2 = DateTime.now().millisecondsSinceEpoch;
      print("Draw Roads: ${end2 - start2}");
    }
    // Roads End

    // Buildings Start
    var start = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < pointsBuildings.length - 1; i++) {
      canvas.drawPath(pointsBuildings[i], paintBuilding);
    }
    var end = DateTime.now().millisecondsSinceEpoch;
    print("Draw Buildings: ${end - start}");

    if (pointsBuilding != null && pointsBuilding.length > 0) {
      var start = DateTime.now().millisecondsSinceEpoch;
      for (int i = 0; i < pointsBuilding.length - 1; i++) {
        if (isInScreen(pointsBuilding[i], pointsBuilding[i + 1])) {
          canvas.drawLine(
              pointsBuilding[i], pointsBuilding[i + 1], paintBuildingBorder);
        }
      }
      var end = DateTime.now().millisecondsSinceEpoch;
      print("Draw Buildings Border: ${end - start}");
    }
    // Buildings End
  }

  // 描画する点がスクリーン内に含まれるかどうか
  bool isInScreen(Offset first, Offset second) {
    if (first != null && second != null) {
      first = first.scale(scale, scale);
      second = second.scale(scale, scale);
      if ((first.dx > -1 &&
              first.dy > -1 &&
              first.dx < this.screenSize.width &&
              first.dy < this.screenSize.height) ||
          (second.dx > -1 &&
              second.dy > -1 &&
              second.dx < this.screenSize.width &&
              second.dy < this.screenSize.height)) {
        return true;
      }
    }
    return false;
  }

  @override
  bool shouldRepaint(CustomMap oldDelegate) => true;
}
