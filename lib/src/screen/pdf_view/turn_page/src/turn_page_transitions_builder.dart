import 'package:ebook/src/screen/pdf_view/turn_page/src/turn_direction.dart';
import 'package:ebook/src/screen/pdf_view/turn_page/src/turn_page_transition.dart';
import 'package:flutter/material.dart';

class TurnPageTransitionsBuilder extends PageTransitionsBuilder {
  const TurnPageTransitionsBuilder({
    required this.overleafColor,
    @Deprecated('Use animationTransitionPoint instead') this.turningPoint,
    this.animationTransitionPoint,
    this.direction = TurnDirection.rightToLeft,
  });

  final Color overleafColor;

  /// The point at which the page-turning animation behavior changes.
  /// This value must be between 0 and 1 (0 <= turningPoint < 1).
  @Deprecated('Use animationTransitionPoint instead')
  final double? turningPoint;

  /// The point that behavior of the turn-page-animation changes.
  /// This value must be 0 <= animationTransitionPoint < 1.
  final double? animationTransitionPoint;

  /// The direction in which the pages are turned.
  final TurnDirection direction;

  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    final transitionPoint = animationTransitionPoint ?? turningPoint;

    return TurnPageTransition(
      animation: animation,
      overleafColor: overleafColor,
      animationTransitionPoint: transitionPoint,
      direction: direction,
      child: child,
    );
  }
}