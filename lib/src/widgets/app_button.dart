import 'package:ebook/src/screen/pdf_view/custom_flip_book/controller/book_controller.dart';
import 'package:ebook/src/utils/app_colors.dart';
import 'package:ebook/src/utils/extension/text_style_decoration.dart';
import 'package:ebook/utility/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrevNextButton extends StatefulWidget {
  const PrevNextButton({
    Key? key,
    required this.currentIndex,
    this.flipBookController,
  }) : super(key: key);

  final int currentIndex;
  final FlipBookController? flipBookController;

  @override
  State<PrevNextButton> createState() => _PrevNextButtonState();
}

class _PrevNextButtonState extends State<PrevNextButton> {
  int currentIndex = -1;

  @override
  Widget build(BuildContext context) {
    currentIndex = widget.flipBookController?.currentIndex ?? 0;
    ///first time current index is 0
    /// first time onTap index is 0
    ///  second time onTap index is 1
    ///  last prevTap index is getting 0
    print("btn ${widget.currentIndex} // $currentIndex");
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.flipBookController?.currentIndex == -1
              ? const SizedBox()
              : prevNextButton(
                  childWidget: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                      Text(
                        Constants.prev,
                        style: const TextStyle().semiBold.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                  onTap: () {
                    widget.flipBookController?.animatePrev();
                    setState(() {
                      currentIndex = widget.flipBookController?.currentLeaf.index ?? 0;
                    });
                    print(
                        "tap prev $currentIndex  ==  ${(((widget.flipBookController?.totalPages ?? 0) ~/ 2))} ===${widget.flipBookController?.currentIndex}");
                  },
                ),
          // state.pageNumber == ((totalPage ?? 0) ~/ 2)
          currentIndex ==
                  (((widget.flipBookController?.totalPages ?? 0) ~/ 2) - 1)
              //flipBookController?.currentIndex == (((flipBookController?.totalPages ?? 0) ~/ 2) - 2)
              ? const SizedBox.shrink()
              : prevNextButton(
                  childWidget: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        Constants.next,
                        style: const TextStyle().semiBold.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                    ],
                  ),
                  onTap: () {
                    widget.flipBookController?.animateNext();
                    setState(() {
                      currentIndex =
                          widget.flipBookController?.currentLeaf.index ?? 0;
                    });
                    print("tap next $currentIndex  == ${widget.flipBookController?.currentIndex}");
                  },
                ),
        ],
      ),
    );
  }

  Widget prevNextButton(
      {required Widget childWidget, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(15.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.r),
          color: cyanColor,
        ),
        child: childWidget,
      ),
    );
  }
}
