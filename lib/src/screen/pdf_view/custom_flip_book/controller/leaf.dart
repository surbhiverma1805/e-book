import 'package:flutter/cupertino.dart';

class Leaf extends ChangeNotifier {
  late final AnimationController animationController;
  late final CurvedAnimation animation;
  final int index;
  final int indexOf;
  late final List<int> pages;
  //bool get isCover => false;
  bool get isCover => isFirst || isLast;
  bool get isFirst => index == 0;
  bool get isLast => index == indexOf - 1;
  bool get isTurned => animationController.value == 1;
  bool get isTurning => animationController.value != 0;

  Duration? animationDuration;

  Leaf(
      {required this.index,

        required this.indexOf,
        required TickerProvider vsync})
      : super() {
    animationController = AnimationController(
      vsync: vsync,
      duration: animationDuration ?? const Duration(milliseconds: 800),
      // duration: const Duration(milliseconds: 800),
    );
    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOutQuad,
      reverseCurve: Curves.easeInQuad,
    );

    pages = [index * 2, index * 2 + 1];
    print("leaf pages $animationDuration");
  }

  Future<void> animateTo(
      int page, {
        required Duration duration,
        required Curve curve,
      }) async {
    animationDuration = duration;
    if (isTurned) {
      if (page < pages.first) {
        return animationController.reverse();
      }
    } else {
      if (page > pages.last) {
        return animationController.forward();
      }
    }
  }
}
