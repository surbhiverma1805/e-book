import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension Space on int {
  Widget toSpace({bool horizontally = true, bool vertically = true}) {
    assert(horizontally != false || vertically != false);
    return SizedBox(
      width: horizontally ? toDouble().w : 0,
      height: vertically ? toDouble().h : 0,
    );
  }
}