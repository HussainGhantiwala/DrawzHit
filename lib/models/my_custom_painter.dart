import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:skribble/models/touch_point.dart';

class MyCustomPainter extends CustomPainter {
  MyCustomPainter({required this.pointsList});
  List<TouchPoints> pointsList;
  List<Offset> offsetPoints = [];

  @override
  void paint(Canvas canvas, Size size) {
    Paint background = Paint()..color = Color(0xFF333333);
    Rect rect = Rect.fromLTRB(0, 0, size.width, size.height);
    canvas.drawRect(
      rect,
      background,
    );
    canvas.clipRect(rect);

    //Logic for points(dots or fullstops) ...if there is a points, we need to display the points.
    //if there in a line we need to connect the points
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        //this is a line
        canvas.drawLine(pointsList[i].points, pointsList[i + 1].points,
            pointsList[i].paint);
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        offsetPoints.clear();
        offsetPoints.add(pointsList[i].points);
        offsetPoints.add(Offset(
            pointsList[i].points.dx + 0.1, pointsList[i].points.dy + 0.1));
        canvas.drawPoints(ui.PointMode.points, offsetPoints,
            pointsList[i].paint); //this will draw points for us
        //This is a point
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
