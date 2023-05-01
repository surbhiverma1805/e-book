// ignore_for_file: avoid_print

import 'dart:math';

import 'package:ebook/src/screen/pdf_view/custom_flip_book/widget/book.dart';
import 'package:ebook/src/screen/pdf_view/custom_flip_book/controller/book_controller.dart';
import 'package:ebook/src/screen/pdf_view/custom_flip_book/controller/leaf.dart';
import 'package:ebook/src/screen/pdf_view/custom_flip_book/widgets_ext/multi_animated_builder.dart';
import 'package:ebook/src/utils/app_colors.dart';
import 'package:ebook/src/utils/extension/space.dart';
import 'package:ebook/src/utils/extension/text_style_decoration.dart';
import 'package:ebook/src/widgets/app_vertical_text.dart';
import 'package:ebook/utility/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

enum Direction { backward, forward }

const fastDx = 500;

class FlipBookState extends State<FlipBook>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<FlipBook> {
  Leaf? currentLeaf;
  Size _bgSize = const Size(0, 0);
  Direction? _direction;
  double _delta = 0;
  Size _coverSize = const Size(0, 0);
  Size _leafSize = const Size(0, 0);
  late double _startingPos;
  late FlipBookController controller;

  @override
  void initState() {
    super.initState();
    widget.controller.animating;
    controller = widget.controller;
    controller.setVsync(this);
  }

  bool get isLTR => widget.direction == TextDirection.ltr;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final controller = widget.controller;
    final orientation = MediaQuery.of(context).orientation;
    print("orientation $orientation");
    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              bookWidgetLayout(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  prevNextButtonInLandscape(
                    iconData: Icons.arrow_back_ios,
                    showPrevButton: widget.showPreNextBtn,
                    isFirstOrLast: controller.currentIndex == -1,
                    onTap: () {
                      controller.animatePrev();
                      setState(() {
                        controller.currentIndex =
                            controller.currentLeaf.index - 1 == 0
                                ? -1
                                : controller.currentLeaf.index - 1;
                      });
                    },
                  ),
                  prevNextButtonInLandscape(
                    iconData: Icons.arrow_forward_ios,
                    showPrevButton: widget.showPreNextBtn,
                    isFirstOrLast: controller.currentIndex ==
                        ((controller.totalPages ~/ 2) - 1),
                    onTap: () {
                      controller.animateNext();
                      setState(() {
                        controller.currentIndex = controller.currentLeaf.index;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        MediaQuery.of(context).orientation == Orientation.portrait
            ? widget.showPreNextBtn
                ? Padding(
                    padding: EdgeInsets.all(10.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        controller.currentIndex == -1
                            ? const SizedBox()
                            : prevNextButtonInPortrait(
                                childWidget: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(
                                      Icons.arrow_back_ios,
                                      color: Colors.white,
                                      size: 16.sp,
                                    ),
                                    Text(
                                      Constants.prev,
                                      style:
                                          const TextStyle().semiBold.copyWith(
                                                color: Colors.white,
                                              ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    controller.currentIndex =
                                        controller.currentLeaf.index - 1 == 0
                                            ? -1
                                            : controller.currentLeaf.index - 1;
                                    //controller.currentLeaf.index;
                                  });
                                  controller.animatePrev();
                                },
                              ),
                        // state.pageNumber == ((totalPage ?? 0) ~/ 2)
                        controller.currentIndex ==
                                (((controller.totalPages) ~/ 2) - 1)
                            //flipBookController?.currentIndex == (((flipBookController?.totalPages ?? 0) ~/ 2) - 2)
                            ? const SizedBox.shrink()
                            : prevNextButtonInPortrait(
                                childWidget: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      Constants.next,
                                      style:
                                          const TextStyle().semiBold.copyWith(
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
                                  controller.animateNext();
                                  setState(() {
                                    controller.currentIndex =
                                        controller.currentLeaf.index;
                                  });
                                },
                              ),
                      ],
                    ),
                  )
                : const SizedBox.shrink()
            : const SizedBox.shrink(),
      ],
    );
  }

  Widget bookWidgetContainer() {
    return Container(
      height: widget.pageSize.height,
      width: widget.pageSize.width,
      alignment: Alignment.center,
      child: Directionality(
        textDirection: widget.direction,
        child: Material(
          child: GestureDetector(
            onHorizontalDragStart: _onDragStart,
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            child: MultiAnimatedBuilder(
                animations:
                    controller.leaves.map((leaf) => leaf.animationController),
                builder: (_, __) => Stack(
                        clipBehavior: Clip.none,
                        fit: StackFit.expand,
                        children: [
                          Container(
                            color: Colors.black,
                            //padding: EdgeInsets.symmetric(vertical: 6.h,),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                1.toSpace(),
                                AppVerticalText("WELCOME",
                                    MediaQuery.of(context).orientation),
                                1.toSpace(),
                                AppVerticalText("THANKYOU",
                                    MediaQuery.of(context).orientation),
                                1.toSpace(),
                              ],
                            ),
                          ),
                          //Container(color: const Color(0xff515151)),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              ...controller.leaves
                                  .where((leaf) =>
                                      leaf.animationController.value > 0.5)
                                  .map((leaf) => leafBuilder(context, leaf))
                            ],
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              ...controller.leaves.reversed
                                  .where((leaf) =>
                                      leaf.animationController.value < 0.5)
                                  .map((leaf) => leafBuilder(context, leaf)),
                            ],
                          ),
                        ])),
          ),
        ),
      ),
    );
  }

  Widget bookWidgetLayout() {
    return LayoutBuilder(builder: (context, constraints) {
      _bgSize = Size(constraints.maxWidth, constraints.maxHeight);
      final maxCoverSize = Size((_bgSize.width - widget.padding.horizontal) / 2,
          _bgSize.height - widget.padding.vertical);
      //_coverSize = Size(widget.pageSize.width/2, widget.pageSize.height);
      //_coverSize = Size(size.width/2, size.height);
      print(
          "size_ max $_bgSize - ${widget.padding.h} ${widget.padding.vertical} $maxCoverSize");

      ///size_ max Size(360.0, 506.3) - EdgeInsets.zero 0.0 Size(360/2 =180.0, 506.3)

      _coverSize = Size(widget.pageSize.width, widget.pageSize.height);

      /* _coverSize =
      maxCoverSize.aspectRatio > widget.coverAspectRatio.value
          ? Size(maxCoverSize.height * widget.coverAspectRatio.value,
          maxCoverSize.height)
          : Size(maxCoverSize.width,
          maxCoverSize.width / widget.coverAspectRatio.value);
      print("size_ cover $maxCoverSize > ${widget.coverAspectRatio.value}");*/

      ///size_ cover Size(180.0, 506.3), 506.3 > 0.6825396825396826 => Size(345.56, 506.3) else Size(180.0, 263.9)
      _leafSize = Size(
          _coverSize.width *
              widget.leafAspectRatio.widthFactor /
              widget.coverAspectRatio.widthFactor,
          _coverSize.height *
              widget.leafAspectRatio.heightFactor /
              widget.coverAspectRatio.heightFactor);
      print("size_ leaf $_coverSize lw${widget.leafAspectRatio.widthFactor} "
          "cvr_w ${widget.coverAspectRatio.widthFactor}"
          "l_h ${widget.leafAspectRatio.widthFactor} "
          "cvr_h ${widget.coverAspectRatio.heightFactor}");

      /// size_ leaf Size(180.0, 263.7) lw2.0 cvr_w 2.15l_h 2.0 cvr_h 3.15
      /// leafSize = Size(167.44, 167.43)
      return Directionality(
        textDirection: widget.direction,
        child: Material(
          child: GestureDetector(
            onHorizontalDragStart: _onDragStart,
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            child: MultiAnimatedBuilder(
                animations:
                    controller.leaves.map((leaf) => leaf.animationController),
                builder: (_, __) => Stack(
                        clipBehavior: Clip.none,
                        fit: StackFit.expand,
                        children: [
                          Container(
                            color: Colors.black,
                            //padding: EdgeInsets.symmetric(vertical: 6.h,),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                1.toSpace(),
                                AppVerticalText("WELCOME",
                                    MediaQuery.of(context).orientation),
                                1.toSpace(),
                                AppVerticalText("THANKYOU",
                                    MediaQuery.of(context).orientation),
                                1.toSpace(),
                              ],
                            ),
                          ),
                          //Container(color: const Color(0xff515151)),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              ...controller.leaves
                                  .where((leaf) =>
                                      leaf.animationController.value > 0.5)
                                  .map((leaf) => leafBuilder(context, leaf))
                            ],
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              ...controller.leaves.reversed
                                  .where((leaf) =>
                                      leaf.animationController.value < 0.5)
                                  .map((leaf) => leafBuilder(context, leaf)),
                            ],
                          ),
                        ])),
          ),
        ),
      );
    });
  }

  Widget prevNextButtonInPortrait({
    required Widget childWidget,
    required VoidCallback onTap,
  }) {
    return InkWell(
        splashColor: Colors.cyan.shade100,
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

  Widget prevNextButtonInLandscape({
    required IconData iconData,
    required bool showPrevButton,
    required bool isFirstOrLast,
    required VoidCallback onTap,
  }) {
    return MediaQuery.of(context).orientation == Orientation.landscape
        ? showPrevButton
            ? isFirstOrLast
                ? const SizedBox.shrink()
                : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: InkWell(
                    splashColor: Colors.white70,
                      onTap: onTap,
                      child: Icon(
                        iconData,
                        color: Colors.white,
                        size: 60.sp,
                      ),
                    ),
                )
            : const SizedBox.shrink()
        : const SizedBox.shrink();
  }

  Widget leafBuilder(BuildContext context, Leaf leaf) {
    if ((!leaf.isCover &&
            (leaf.index - controller.currentLeaf.index).abs() >
                widget.bufferSize) ||
        (leaf.isCover &&
            widget.coverAspectRatio.value == widget.leafAspectRatio.value)) {
      return const SizedBox.shrink();
    }
    final animationVal = leaf.animationController.value;
    print("build1 $_coverSize");
    final firstPageTransformed = Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(-pi),
        child:
            widget.pageDelegate.build(context, _coverSize, leaf.pages.first));
    // child: widget.pageDelegate.build(context, _leafSize, leaf.pages.first));
    final lastPage =
        widget.pageDelegate.build(context, _coverSize, leaf.pages.last);
    List<Widget> pages = [firstPageTransformed, lastPage];
    final pageMaterial = Align(
      alignment: isLTR ? Alignment.centerRight : Alignment.centerLeft,
      child: SizedBox(
          height: _coverSize.height,
          width: _coverSize.width,
          // height: leaf.isCover ? _coverSize.height : _leafSize.height,
          // width: leaf.isCover ? _coverSize.width : _leafSize.width,
          child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              children: animationVal < 0.5 ? pages.reversed.toList() : pages)
          //animationVal < 0.5 ? [pages[0]]: pages)));
          // widget.controller.isCenterAlign ? [pages[0]]
          //     : (animationVal < 0.5 ? pages.reversed.toList() : pages)),
          ),
    );
    return Positioned.fill(
      top: widget.padding.top,
      bottom: widget.padding.bottom,
      left: (isLTR ? _coverSize.width : 0) + widget.padding.left,
      right: (isLTR ? 0 : _coverSize.width) + widget.padding.right,
      // left: widget.controller.isCenterAlign
      //     ? 95.w
      //     : ((isLTR ? _coverSize.width : 0) + widget.padding.left),
      // right: widget.controller.isCenterAlign
      //     ? 95.w
      //     : ((isLTR ? 0 : _coverSize.width) + widget.padding.right),
      child: Transform.translate(
        offset: Offset(_coverSize.width, 0),
        child: Transform(
          transform: Matrix4.identity()..rotateY(isLTR ? -pi : pi),
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY((isLTR ? -pi : pi) * animationVal),
            alignment: isLTR ? Alignment.centerRight : Alignment.centerLeft,
            child: pageMaterial,
          ),
        ),
      ),
    );
  }

  void _onDragStart(DragStartDetails details) {
    if (currentLeaf != null || controller.animating) {
      _direction = null;
      _startingPos = 0;
      return;
    }
    _startingPos = details.globalPosition.dx;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (controller.animating) {
      return;
    }
    _delta = isLTR
        ? _startingPos - details.globalPosition.dx
        : details.globalPosition.dx - _startingPos;
    if (_delta.abs() > _bgSize.width) return;
    if (_delta == 0) return;
    _direction =
        _direction ?? ((_delta > 0) ? Direction.forward : Direction.backward);
    switch (_direction!) {
      case Direction.forward:
        final pos = _delta / _bgSize.width;
        // drag overflow
        if (pos > 1 || _delta < 0) {
          return;
        }
        if (currentLeaf == null) {
          if (controller.isClosedInverted) {
            return;
          } else {
            currentLeaf = controller.currentOrTurningLeaves.item2!;
          }
        }
        controller.currentLeaf.animationController.value = pos;
        break;
      case Direction.backward:
        // reverse
        final pos = 1 - (_delta.abs() / _bgSize.width);
        // drag overflow
        if (pos < 0 || _delta > 0) {
          return;
        }
        if (currentLeaf == null) {
          if (controller.isClosed) {
            return;
          } else {
            currentLeaf = controller.currentOrTurningLeaves.item1!;
          }
        }
        controller.currentOrTurningLeaves.item1!.animationController.value =
            pos;
    }
  }

  void _onDragEnd(DragEndDetails details) async {
    if (currentLeaf == null || controller.animating) {
      _direction = null;
      _startingPos = 0;
      return;
    }
    TickerFuture Function({double? from}) animate;
    final pps = details.velocity.pixelsPerSecond;
    final turningLeafAnimCtrl = currentLeaf!.animationController;
    switch (_direction!) {
      case Direction.forward:
        if (((isLTR ? pps.dx < -fastDx : pps.dx > fastDx) ||
            turningLeafAnimCtrl.value >= 0.5)) {
          animate = turningLeafAnimCtrl.forward;
          setState(() {
            controller.currentIndex = controller.currentLeaf.index;
          });
        } else {
          animate = turningLeafAnimCtrl.reverse;
          setState(() {
            controller.currentIndex = controller.currentLeaf.index;
          });
        }
        break;
      case Direction.backward:
        if (((isLTR ? pps.dx > fastDx : pps.dx < -fastDx) ||
            turningLeafAnimCtrl.value <= 0.5)) {
          animate = turningLeafAnimCtrl.reverse;
          setState(() {
            controller.currentIndex = controller.currentLeaf.index - 1;
          });
        } else {
          animate = turningLeafAnimCtrl.forward;
        }
    }
    controller.animating = true;
    _direction = null;
    _startingPos = 0;
    await animate(from: turningLeafAnimCtrl.value);
    controller.animating = false;
    currentLeaf = null;
  }

  @override
  bool get wantKeepAlive => true;
}
