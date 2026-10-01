import 'package:flutter/material.dart';

import '../brand/ink.dart';

/// A window, a beam, and a small handset — drawn for the primer.
class RoomSketch extends StatelessWidget {
  const RoomSketch({super.key, this.height = 200});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(painter: _RoomPainter()),
    );
  }
}

class _RoomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final olive = Paint()
      ..color = Pigment.olive
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final clay = Paint()..color = Pigment.clay;

    final frame = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.42),
        width: size.width * 0.46,
        height: size.height * 0.55,
      ),
      const Radius.circular(18),
    );
    canvas.drawRRect(frame, olive);

    final inner = frame.outerRect.deflate(14);
    final beam = Path()
      ..moveTo(inner.left, inner.top + inner.height * 0.18)
      ..lineTo(inner.right, inner.top + inner.height * 0.55)
      ..lineTo(inner.right, inner.top + inner.height * 0.78)
      ..lineTo(inner.left, inner.top + inner.height * 0.42)
      ..close();
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(inner, const Radius.circular(8)));
    canvas.drawPath(beam, clay);
    canvas.restore();

    canvas.drawCircle(
      Offset(inner.left + 28, inner.bottom - 26),
      10,
      Paint()..color = Pigment.clayDeep,
    );

    final phone = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.78, size.height * 0.82),
        width: 28,
        height: 48,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(phone, olive);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
