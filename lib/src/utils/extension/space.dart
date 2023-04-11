import 'package:flutter/cupertino.dart';

extension Space on int {
  Widget toSpace({bool horizontally = true, bool vertically = true}) {
    assert(horizontally != false || vertically != false);
    return SizedBox(
      width: horizontally ? toDouble() : 0,
      height: vertically ? toDouble() : 0,
    );
  }
}