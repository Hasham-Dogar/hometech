part of 'home_page.dart';

class _NavBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF252A4A)
      ..style = PaintingStyle.fill;

    final topY = 20.0;
    final valleyY = size.height + 4;
    final leftFlatEnd = 0.12;
    final rightFlatStart = 0.88;
    final outerRadius = 24.0;
    final cpDepart = 0.18;
    final cpValley = 0.20; // Adjusted to fix overlapping

    final w = size.width;
    final h = size.height;

    final path = Path();
    path.moveTo(0, topY);

    path.lineTo(w * leftFlatEnd, topY);

    path.cubicTo(
      w * (leftFlatEnd + cpDepart),
      topY,
      w * (0.5 - cpValley),
      valleyY,
      w * 0.5,
      valleyY,
    );

    path.cubicTo(
      w * (0.5 + cpValley),
      valleyY,
      w * (rightFlatStart - cpDepart),
      topY,
      w * rightFlatStart,
      topY,
    );

    path.lineTo(w, topY);

    path.arcToPoint(
      Offset(w, h),
      radius: Radius.circular(outerRadius),
      clockwise: true,
    );

    path.lineTo(0, h);

    path.arcToPoint(
      Offset(0, topY),
      radius: Radius.circular(outerRadius),
      clockwise: true,
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
