import 'package:flutter/material.dart';

class TopSection extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    Rect rect = new Rect.fromCircle(
      center: new Offset(165.0, 55.0),
      radius: 180.0,
    );

    final Gradient gradient = new LinearGradient(
      colors: <Color>[
        Colors.greenAccent[400],
        Colors.lightGreenAccent[200],
      ],
      stops: [
        0.4,
        1.0,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    paint.shader = gradient.createShader(rect);
    paint.style = PaintingStyle.fill; // Change this to fill

    var path = Path();

    path.moveTo(0, size.height * 0.8);
    //path.relativeConicTo(x1, y1, x2, y2, w)
    path.cubicTo(size.width * 0.25, size.height * 1, size.width * 0.4,
        size.height * 0.1, size.width, size.height * 0.4);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class BottomSection extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    Rect rect = new Rect.fromCircle(
      center: new Offset(165.0, 55.0),
      radius: 180.0,
    );

    final Gradient gradient = new LinearGradient(
      colors: <Color>[
        Colors.lightGreenAccent.shade700,
        Colors.greenAccent,
      ],
      stops: [
        0.3,
        1.0,
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
    paint.shader = gradient.createShader(rect);
    paint.style = PaintingStyle.fill; // Change this to fill

    var path = Path();

    path.moveTo(0, size.height * 0.8);
    //path.relativeConicTo(x1, y1, x2, y2, w)
    path.cubicTo(size.width * 0.2, size.height * 0.5, size.width * 0.3,
        size.height * 0.1, size.width, size.height * 0.5);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
