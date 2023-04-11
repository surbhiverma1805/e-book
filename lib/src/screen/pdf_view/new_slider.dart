import 'dart:math';

import 'package:flutter/material.dart';

class PageTurnEffectPainter extends CustomPainter {
  final Color color;
  final double angle;
  final Widget child;

  PageTurnEffectPainter({required this.color, required this.angle, required this.child});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final clipRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final clipPath = Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.right, rect.top)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..close()
      ..addRect(clipRect)
      ..close();
    canvas.clipPath(clipPath);

    final textSpan = TextSpan(
      style: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      children: [
        TextSpan(text: 'Page ${Random().nextInt(100)}\n'),
        TextSpan(text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'),
      ],
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 32);

    final textOffset = Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2);
    final textRect = textOffset & textPainter.size;
    final textPath = Path()
      ..moveTo(textOffset.dx + textPainter.width, textOffset.dy)
      ..lineTo(textOffset.dx + textPainter.width, textOffset.dy + textPainter.height)
      ..lineTo(textOffset.dx, textOffset.dy + textPainter.height)
      ..close();
    final textMask = Path.combine(PathOperation.intersect, textPath, Path()..addRect(rect));

    final paint = Paint()..color = color;
    canvas.drawPath(textMask, paint);

    if (angle > 0) {
      final turnRect = Rect.fromLTRB(rect.left, rect.top, rect.left + rect.width / 2, rect.bottom);
      final turnClipPath = Path()
        ..moveTo(turnRect.left, turnRect.top)
        ..lineTo(turnRect.right, turnRect.top)
        ..lineTo(turnRect.right, turnRect.bottom)
        ..lineTo(turnRect.left, turnRect.bottom)
        ..close()
        ..addPath(textPath, Offset.zero)
        ..close();
      canvas.clipPath(turnClipPath);

      final turnMatrix = Matrix4.identity()
        ..setEntry(3, 2, 0.002)
        ..rotateY(angle);
      final turnOffset = Offset(rect.width / 2, 0);
      final turnRectOffset = turnRect.center.translate(-turnOffset.dx, -turnOffset.dy);
      canvas.transform(turnMatrix.storage);
      canvas.translate(turnOffset.dx - turnRectOffset.dx, turnOffset.dy - turnRectOffset.dy);

      paint..shader = LinearGradient(
        colors: [color.withOpacity(0.5), color.withOpacity(0.0)],
        stops: [0.0, 1.0],
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
      ).createShader(turnRect);
      canvas.drawRect(turnRect, paint);

      canvas.translate(-turnOffset.dx + turnRectOffset.dx, -turnOffset.dy + turnRectOffset.dy);
      canvas.transform(turnMatrix.storage..insert(0, 1.0));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
