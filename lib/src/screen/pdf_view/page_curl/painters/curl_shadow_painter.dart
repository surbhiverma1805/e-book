import 'dart:math' as math;
import 'package:ebook/src/screen/pdf_view/page_curl/models/vector_2d.dart';
import 'package:flutter/material.dart';

class CurlShadowPainter extends CustomPainter {
  Vector2D mA, mD, mE, mF;

  CurlShadowPainter({
    required this.mA,
    required this.mD,
    required this.mE,
    required this.mF,
  });

  Path getShadowPath(int t) {
    Path path = Path();
    /*path.moveTo(mA.x - t, mA.y);
    path.lineTo(mD.x, math.max(0, mD.y - t));
    path.lineTo(mE.x, mE.y - t);*/

   /* path.moveTo(mA.x, mA.y - t);
    path.lineTo(math.max(mD.x - t , 0), mD.y);
    path.lineTo(mE.x - t, mE.y);*/
    if (mF.x < 0) {
      //print("if ${mF.x}");
      path.lineTo(-t.toDouble(), mF.y - t);
      //path.lineTo(mD.x - t, -t.toDouble());
    } else {
      //print("else  ${mF.x}");
     path.lineTo(mF.x - t, mF.y - t);
      //path.lineTo(mF.x - t, mF.y - t);
    }
    path.moveTo(mA.x - t, mA.y);

    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (mF.x != 0.0) {
      // only draw shadow when pulled
      final double shadowElev = 6.0;
      canvas.drawShadow(
        getShadowPath(shadowElev.toInt()),
        Colors.black,
        shadowElev,
        true,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}