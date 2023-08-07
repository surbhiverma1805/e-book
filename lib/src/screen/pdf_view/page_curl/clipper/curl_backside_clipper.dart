import 'dart:math' as math;
import 'package:ebook/src/screen/pdf_view/page_curl/models/vector_2d.dart';
import 'package:flutter/material.dart';

class CurlBackSideClipper extends CustomClipper<Path> {
  final Vector2D mA, mD, mE, mF;

  CurlBackSideClipper({
    required this.mA,
    required this.mD,
    required this.mE,
    required this.mF,
  });

  Path createCurlEdgePath() {
    Path path = Path();
   /* path.moveTo(mA.y, mA.x);
    path.lineTo(math.max(mD.x, 0), mD.y);
    path.lineTo(mE.y, mE.x);
    path.lineTo(mF.y, mF.x);
    path.lineTo(mA.y, mA.x);*/
    path.moveTo(mA.x, mA.y);
    path.lineTo(mD.x, math.max(0, mD.y));
    path.lineTo(mE.x, mE.y);
    path.lineTo(mF.x, mF.y);
    path.lineTo(mA.x, mA.y);

    return path;
  }

  @override
  Path getClip(Size size) {
    return createCurlEdgePath();
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return true;
  }
}