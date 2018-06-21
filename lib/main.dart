import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong/latlong.dart' as latlong;

import 'custommap.dart';

void main() => runApp(MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    ));

class HomePage extends StatefulWidget {
  Size screenSize;
  Offset screenCenter;

  @override
  _HomePageState createState() {
    var homePageState = _HomePageState();

    // geojsonを読み込み
    if (true) {
      // 道路データ
      var start = DateTime.now().millisecondsSinceEpoch;
      Future<String> future = loadAsset("assets/geo_shibuya_lines.geojson");

      future.then((data) {
        homePageState.setState(() {
          homePageState.jsonDataRoads = json.decode(data.toString());
        });
      });
      var end = DateTime.now().millisecondsSinceEpoch;
      print("Load roads: ${end - start}");
    }
    if (true) {
      // 建物データ
      var start = DateTime.now().millisecondsSinceEpoch;
      Future<String> future = loadAsset("assets/geo_shibuya_buildings.geojson");
      future.then((data) {
        homePageState.setState(() {
          homePageState.jsonDataBuildings = json.decode(data.toString());
        });
      });
      var end = DateTime.now().millisecondsSinceEpoch;
      print("Load buildings: ${end - start}");
    }
    return homePageState;
  }

  // geojsonを読み込む
  Future<String> loadAsset(String file) async {
    return await rootBundle.loadString(file);
  }
}

class _HomePageState extends State<HomePage> {
  var jsonDataRoads;
  var jsonDataBuildings;
  Size screenSize;
  Offset screenCenter;
  List<Offset> _roadsPoints = <Offset>[];
  List<Offset> _buildingPoints = <Offset>[];
  List<Path> _pointsBuildings = <Path>[];

  double _scale = 1.0;
  Offset _delta = Offset.zero;

  // 渋谷駅の緯度経度
  latlong.LatLng currentLocation = latlong.LatLng(35.6573151, 139.7024518);
  @override
  Widget build(BuildContext context) {
    // screenSizeを取得
    // TODO orientation変化時の処理
    if (screenSize == null) {
      screenSize = MediaQuery.of(context).size;
    }
    if (screenSize != null && screenCenter == null) {
      screenCenter = screenSize.center(Offset.zero);
    }

    // 道路データの緯度経度を画面描画用に加工
    if (jsonDataRoads != null && _roadsPoints.length == 0) {
      var start = DateTime.now().millisecondsSinceEpoch;
      var coord_len = jsonDataRoads['features'].length;
      for (int j = 0; j < coord_len; j++) {
        var coordinates =
            jsonDataRoads['features'][j]['geometry']['coordinates'];
        var coordinates_len = coordinates.length;
        // Roads Start
        for (int k = 0; k < coordinates_len; k++) {
          var coordinate = coordinates[k];
          for (int i = 0; i < coordinate.length; i++) {
            // 初期位置（渋谷）を画面中央に配置
            Offset _localPosition = Offset(
                (coordinate[0] - currentLocation.longitude) * 300000.0 +
                    screenCenter.dx,
                -(coordinate[1] - currentLocation.latitude) * 300000.0 +
                    screenCenter.dy);
            _roadsPoints = new List.from(_roadsPoints)..add(_localPosition);
          }
        }
        // Roads End
        _roadsPoints.add(null);
      }

      var end = DateTime.now().millisecondsSinceEpoch;
      print("Create Roads List: ${end - start}");
    }

    // 建物データの緯度経度を画面描画用に加工
    if (jsonDataBuildings != null &&
        _pointsBuildings.length == 0 &&
        _buildingPoints.length == 0) {
      var start = DateTime.now().millisecondsSinceEpoch;
      var coordLen = jsonDataBuildings['features'].length;
      for (int j = 0; j < coordLen; j++) {
        var coordinates =
            jsonDataBuildings['features'][j]['geometry']['coordinates'];

        var allLen = coordinates[0].length;
        for (int k = 0; k < allLen; k++) {
          List<Offset> _tmpPoints = <Offset>[];
          var coordSet = coordinates[0][k];
          var coordSetLen = coordinates[0][k].length;
          for (var l = 0; l < coordSetLen; l++) {
            // 初期位置（渋谷）を画面中央に配置
            Offset _localPosition = Offset(
                (coordSet[l][0] - currentLocation.longitude) * 300000.0 +
                    screenCenter.dx,
                -(coordSet[l][1] - currentLocation.latitude) * 300000.0 +
                    screenCenter.dy);
            _buildingPoints = new List.from(_buildingPoints)
              ..add(_localPosition);
            _tmpPoints = new List.from(_tmpPoints)..add(_localPosition);
          }
          _pointsBuildings = new List.from(_pointsBuildings)
            ..add(Path()..addPolygon(_tmpPoints, true));
          _buildingPoints.add(null);
        }
      }
      var end = DateTime.now().millisecondsSinceEpoch;
      print("Create Buildings List: ${end - start}");
    }

    return new Scaffold(
      body: Container(
          child: GestureDetector(
              // onPanUpdateと同時に動かないのでコメントアウト
//              onScaleUpdate: (ScaleUpdateDetails details) {
//                setState(() {
//                  _scale = details.scale;
//                });
//              },
              onPanUpdate: (DragUpdateDetails details) {
                setState(() {
                  _delta = _delta + details.delta;
                });
              },
              child: CustomPaint(
                  painter: CustomMap(
                      scale: _scale,
                      delta: _delta,
                      pointsRoads: _roadsPoints,
                      pointsBuilding: _buildingPoints,
                      pointsBuildings: _pointsBuildings,
                      screenSize: screenSize),
                  size: Size.infinite) // CustomPaint
              ) // GestureDetector
          ), // Container
    ); // Scaffold
  }
}
