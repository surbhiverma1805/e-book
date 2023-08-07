import 'dart:math' as math;
import 'package:ebook/src/screen/pdf_view/page_curl/models/vector_2d.dart';
import 'package:flutter/material.dart';

class CurlBackgroundClipper extends CustomClipper<Path> {
  Vector2D mA, mD, mE, mF, mM, mN, mP;

  CurlBackgroundClipper({
    required this.mA,
    required this.mD,
    required this.mE,
    required this.mF,
    required this.mM,
    required this.mN,
    required this.mP,
  });

  Path createBackgroundPath() {
    Path path = Path();
    path.moveTo(mM.x, mM.y / 2);
    path.lineTo(mP.x, mP.y);

    path.lineTo(mD.x, math.max(0, mD.y));

    path.lineTo(mA.x, mA.y);
    path.lineTo(mN.x, mN.y);
    if (mF.x < 0) path.lineTo(mF.x, mF.y);
    path.lineTo(mM.x, mM.y);

    return path;
  }

//M (0.0, 0.0) P (200.0, 0.0) D (200.0, 200.0) A (99.999975, 200.0) N (0.0, 200.0) F (0.0, 200.1)
  @override
  Path getClip(Size size) {
    print(
        "CurlBackgroundClipper : M ${mM} P ${mP} D ${mD} A ${mA} N ${mN} F ${mF}");
    return createBackgroundPath();
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return true;
  }
}
