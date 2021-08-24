import 'package:flutter/material.dart';

class TriangleAnchorShape extends CustomPainter {
  Paint? painter;

  TriangleAnchorShape() {
    painter = Paint()
      ..color = Colors.white
      ..shader
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, 0);
    canvas.drawShadow(path, Colors.lightGreen, 4, true);
    canvas.drawPath(path, painter!);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
