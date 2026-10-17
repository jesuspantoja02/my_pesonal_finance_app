import 'package:flutter/material.dart';

/// Logo oficial de Google (cuatro colores).
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 48;
    canvas.scale(s, s);

    final blue = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    final green = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill;
    final yellow = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill;
    final red = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill;

    final bluePath = Path()
      ..moveTo(46.16, 24.55)
      ..cubicTo(46.16, 22.91, 46.02, 21.33, 45.76, 19.82)
      ..lineTo(24, 19.82)
      ..lineTo(24, 28.82)
      ..lineTo(36.42, 28.82)
      ..cubicTo(35.88, 31.71, 34.26, 34.16, 31.81, 35.78)
      ..lineTo(31.81, 41.09)
      ..lineTo(39.2, 41.09)
      ..cubicTo(43.54, 37.11, 46.16, 31.27, 46.16, 24.55)
      ..close();
    canvas.drawPath(bluePath, blue);

    final greenPath = Path()
      ..moveTo(24, 47)
      ..cubicTo(30.16, 47, 35.35, 44.92, 39.2, 41.09)
      ..lineTo(31.81, 35.78)
      ..cubicTo(29.91, 37.06, 27.17, 37.82, 24, 37.82)
      ..cubicTo(18.07, 37.82, 13.04, 33.88, 11.24, 28.45)
      ..lineTo(3.62, 28.45)
      ..lineTo(3.62, 33.93)
      ..cubicTo(7.45, 41.55, 15.13, 47, 24, 47)
      ..close();
    canvas.drawPath(greenPath, green);

    final yellowPath = Path()
      ..moveTo(11.24, 28.45)
      ..cubicTo(10.78, 27.17, 10.52, 25.8, 10.52, 24.36)
      ..cubicTo(10.52, 22.93, 10.78, 21.56, 11.24, 20.28)
      ..lineTo(11.24, 14.8)
      ..lineTo(3.62, 14.8)
      ..cubicTo(2.18, 17.67, 1.36, 20.91, 1.36, 24.36)
      ..cubicTo(1.36, 27.82, 2.18, 31.06, 3.62, 33.93)
      ..lineTo(11.24, 28.45)
      ..close();
    canvas.drawPath(yellowPath, yellow);

    final redPath = Path()
      ..moveTo(24, 10.91)
      ..cubicTo(27.55, 10.91, 30.7, 12.13, 33.2, 14.51)
      ..lineTo(39.69, 8.02)
      ..cubicTo(35.31, 3.95, 30.07, 1.73, 24, 1.73)
      ..cubicTo(15.13, 1.73, 7.45, 7.18, 3.62, 14.8)
      ..lineTo(11.24, 20.28)
      ..cubicTo(13.04, 14.85, 18.07, 10.91, 24, 10.91)
      ..close();
    canvas.drawPath(redPath, red);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AppleLogo extends StatelessWidget {
  const AppleLogo({super.key, this.size = 22, this.color = Colors.white});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.apple, size: size + 2, color: color);
  }
}
