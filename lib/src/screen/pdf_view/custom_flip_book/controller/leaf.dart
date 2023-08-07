import 'package:ebook/src/screen/pdf_view/turn_page/src/turn_page_view.dart';
import 'package:flutter/cupertino.dart';

class Leaf extends ChangeNotifier {
  late final AnimationController animationController;
  late final CurvedAnimation animation;
  //late final TurnAnimationController animation;
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
        required TickerProvider vsync, required int totalPages})
      : super() {
    animationController = AnimationController(
       vsync: vsync,
      duration: animationDuration ?? const Duration(milliseconds: 1600),
      // duration: const Duration(milliseconds: 800),
    );
    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.linear,
      reverseCurve: Curves.linear,
    );
   /* animation = TurnAnimationController(
      vsync: vsync,
      initialPage: 0,
      itemCount: totalPages,
      thresholdValue: 0.3,
      duration: Duration(milliseconds: 300),
    );*/

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
