import 'package:flutter/material.dart';

extension TextStyles on TextStyle {
  TextStyle get medium => const TextStyle(
        fontSize: 16,
        fontFamily: 'Medium',
        fontWeight: FontWeight.w500,
      );

  TextStyle get bold => const TextStyle(
        fontSize: 16,
        fontFamily: 'Bold',
        fontWeight: FontWeight.w800,
      );

  TextStyle get regular => const TextStyle(
        fontSize: 16,
        fontFamily: 'Regular',
        fontWeight: FontWeight.w400,
      );

  TextStyle get semiBold => const TextStyle(
        fontSize: 16,
        fontFamily: 'SemiBold',
        fontWeight: FontWeight.w600,
      );

  TextStyle get italic => const TextStyle(
        fontSize: 16,
        fontFamily: 'Italic',
        fontStyle: FontStyle.italic,
      );
}
