// ignore_for_file: avoid_print

import 'dart:math';

import 'dart:ui' as ui;
import 'package:ebook/src/screen/pdf_view/custom_flip_book/widget/book.dart';
import 'package:ebook/src/screen/pdf_view/custom_flip_book/controller/book_controller.dart';
import 'package:ebook/src/screen/pdf_view/custom_flip_book/controller/leaf.dart';
import 'package:ebook/src/screen/pdf_view/custom_flip_book/widgets_ext/multi_animated_builder.dart';
import 'package:ebook/src/screen/pdf_view/page_curl/models/touch_event.dart';
import 'package:ebook/src/screen/pdf_view/page_curl/models/vector_2d.dart';
import 'package:ebook/src/screen/pdf_view/turn_page/src/turn_direction.dart';
import 'package:ebook/src/utils/app_colors.dart';
import 'package:ebook/src/utils/extension/space.dart';
import 'package:ebook/src/utils/extension/text_style_decoration.dart';
import 'package:ebook/src/widgets/app_vertical_text.dart';
import 'package:ebook/utility/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

enum Direction { backward, forward }

const fastDx = 500;

class FlipBookState extends State<FlipBook>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<FlipBook> {
  Leaf? currentLeaf;
  Leaf? oldLeaf;
  Size _bgSize = const Size(0, 0);
  Direction? _direction;
  double _delta = 0;
  Size _coverSize = const Size(0, 0);
  Size _leafSize = const Size(0, 0);
  late double _startingPos;
  late FlipBookController controller;

  //final turnController = TurnPageController();

  /// For curl effect
  /* vector points used to define current clipping paths */
  late Vector2D mA, mB, mC, mD, mE, mF, mOldF, mOrigin;

  /* vectors that are corners of the entire polygon */
  late Vector2D mM, mN, mO, mP;

  /* pointer used to move */
  late Vector2D mMovement;

  /* finger position */
  late Vector2D mFinger;

  /* movement pointer from the last frame */
  late Vector2D mOldMovement;

  /* paint curl edge */
  late Paint curlEdgePaint;

  /* The initial offset for x and y axis movements */
  late int mInitialEdgeOffset;

  /* Maximum radius a page can be flipped, by default it's the width of the view */
  late double mFlipRadius;

  /* used to control touch input blocking */
  bool bBlockTouchInput = false;

  /* tRUE if the user moves the pages */
  late bool bUserMoves;

  /* if TRUE we are currently auto-flipping */
  late bool bFlipping;

  /* px / draw call */
  int mCurlSpeed = 60;

  /* enable input after the next draw event */
  bool bEnableInputAfterDraw = false;

  double abs(double value) {
    if (value < 0) return value * -1;
    return value;
  }

  double get height => widget.pageSize.height;

  double get width => widget.pageSize.width;

  void doPageCurl() {
    int w = width.toInt();
    int h = height.toInt();

    // F will follow the finger, we add a small displacement
    // So that we can see the edge
    mF.x = w - mMovement.x + 0.1;
    mF.y = h - mMovement.y + 0.1;

    // Set min points
    if (mA.x == 0) {
      mF.x = math.min(mF.x, mOldF.x);
      mF.y = math.max(mF.y, mOldF.y);
    }

    // Get diffs
    double deltaX = w - mF.x;
    double deltaY = h - mF.y;

    double bh = math.sqrt(deltaX * deltaX + deltaY * deltaY) / 2;
    double tangAlpha = deltaY / deltaX;
    double alpha = math.atan(deltaY / deltaX);
    double _cos = math.cos(alpha);
    double _sin = math.sin(alpha);

    mA.x = w - (bh / _cos);
    mA.y = h.toDouble();

    mD.x = w.toDouble();
    // bound mD.y
    mD.y = math.min(h - (bh / _sin), height);

    mA.x = math.max(0, mA.x);
    if (mA.x == 0) {
      mOldF.x = mF.x;
      mOldF.y = mF.y;
    }

    // Get W
    mE.x = mD.x;
    mE.y = mD.y;

    // bouding corrections
    if (mD.y < 0) {
      mD.x = w + tangAlpha * mD.y;

      mE.x = w + math.tan(2 * alpha) * mD.y;

      // modify mD to create newmD by cleaning y value
      Vector2D newmD = Vector2D(mD.x, 0);
      double l = w - newmD.x;

      mE.y = -math.sqrt(abs(math.pow(l, 2).toDouble() -
          math.pow((newmD.x - mE.x), 2).toDouble()));
    }
  }

  void resetClipEdge() {
    // set base movement
    mMovement.x = mInitialEdgeOffset.toDouble();
    mMovement.y = mInitialEdgeOffset.toDouble();
    mOldMovement.x = 0;
    mOldMovement.y = 0;

    mA = Vector2D(0, 0);
    mB = Vector2D(width, height);
    mC = Vector2D(width, 0);
    mD = Vector2D(0, 0);
    mE = Vector2D(0, 0);
    mF = Vector2D(0, 0);
    mOldF = Vector2D(0, 0);

    // The movement origin point
    mOrigin = Vector2D(width, 0);
  }

  @override
  void initState() {
    super.initState();
    widget.controller.animating;
    controller = widget.controller;
    controller.setVsync(this);
    init();
  }

  /* @override
  void didUpdateWidget(FlipBook oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pageDelegate != oldWidget.pageDelegate) {
      _resolveImage();
    }
  }*/

  void init() {
    // init main variables
    // mM = Vector2D(0, 0);
    // mN = Vector2D(0, height);
    // mO = Vector2D(width, height);
    // mP = Vector2D(width, 0);
    mM = Vector2D(0, 0);
    mN = Vector2D(0, height);
    mO = Vector2D(width, height);
    mP = Vector2D(width, 0);

    mMovement = Vector2D(0, 0);
    mFinger = Vector2D(0, 0);
    mOldMovement = Vector2D(0, 0);

    // create the edge paint
    curlEdgePaint = Paint();
    curlEdgePaint.isAntiAlias = true;
    curlEdgePaint.color = Colors.white;
    curlEdgePaint.style = PaintingStyle.fill;

    // mUpdateRate = 1;
    mInitialEdgeOffset = 0;

    // other initializations
    mFlipRadius = width;

    resetClipEdge();
    doPageCurl();
  }

  bool get isLTR => widget.direction == TextDirection.ltr;

  Matrix4 getScaleMatrix() {
    return Matrix4.diagonal3Values(
      1.0,
      1.0,
      1.0,
    );
  }

  Offset getOffset() {
    double xOffset = -abs(height - mF.y);
    double yOffset = -abs(height - mF.x);
    /* double xOffset = mF.x;
    double yOffset = -abs(height - mF.y);
*/
    return Offset(xOffset, yOffset);
  }

  double getAngle() {
    double displaceInY = mA.x - mF.x;
    if (displaceInY == 149.99998333333335) displaceInY = 0;

    double displaceInX = height - mF.y;
    if (displaceInY < 0) displaceInY = 0;

    double angle = math.atan(displaceInX / displaceInY);
    if (angle.isNaN) angle = 0.0;

    if (angle < 0) angle = angle + math.pi;

    print("asngle $angle");
    return angle;
  }

// /*  void _resolveImage() {
//     ImageStream? newStream =
//     widget.image.resolve(createLocalImageConfiguration(context));
//     assert(newStream != null);
//     _updateSourceStream(newStream);
//   }
//
//   void _handleImageFrame(ImageInfo imageInfo, bool synchronousCall) {
//     setState(() => _imageInfo = imageInfo);
//   }
//
//   // Updates _imageStream to newStream, and moves the stream listener
//   // registration from the old stream to the new stream (if a listener was
//   // registered).
//   void _updateSourceStream(ImageStream? newStream) {
//     if (_imageStream?.key == newStream?.key) return;
//
//     if (_isListeningToStream) _imageStream?.removeListener(_imageListener);
//
//     _imageStream = newStream;
//     if (_isListeningToStream) _imageStream?.addListener(_imageListener);
//   }
//
//   void _listenToStream() {
//     if (_isListeningToStream) return;
//     _imageStream?.addListener(_imageListener);
//     _isListeningToStream = true;
//   }
//
//   void _stopListeningToStream() {
//     if (!_isListeningToStream) return;
//     _imageStream?.removeListener(_imageListener);
//     _isListeningToStream = false;
//   }*/

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final controller = widget.controller;
    final orientation = MediaQuery.of(context).orientation;
    print("orientation $orientation");
    /*return Row(
      children: [
        prevNextButtonInLandscape(
          iconData: Icons.arrow_back_ios,
          showPrevButton: widget.showPreNextBtn,
          isFirstOrLast: controller.currentIndex == -1,
          onTap: () {
            print(
                "prevb index : ${controller.currentIndex} /// ${(((controller.totalPages ?? 0) ~/ 2) - 1)}");
            controller.animatePrev();
            setState(() {
              controller.currentIndex =
              controller.currentLeaf.index - 1 == 0
                  ? -1
                  : controller.currentLeaf.index - 1;
            });
          },
        ),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              //newBookWidget(),
              bookWidgetLayout(),
            ],
          ),
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
    );*/
    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              //newBookWidget(),
              bookWidgetLayout(),
              controller.isSlideShow ?? true
                  ? const SizedBox()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        prevNextButtonInLandscape(
                          iconData: Icons.arrow_back_ios,
                          showPrevButton: widget.showPreNextBtn,
                          isFirstOrLast: controller.currentIndex == -1,
                          onTap: () {
                            print(
                                "prevb index : ${controller.currentIndex} /// ${(((controller.totalPages ?? 0) ~/ 2) - 1)}");
                            setState(() {
                              controller.currentIndex =
                                  controller.currentLeaf.index - 1 == 0
                                      ? -1
                                      : controller.currentLeaf.index - 1;
                            });
                            controller.animatePrev();
                          },
                          padding: EdgeInsets.only(
                            left: 8.h,
                          ),
                        ),
                        prevNextButtonInLandscape(
                            iconData: Icons.arrow_forward_ios,
                            showPrevButton: widget.showPreNextBtn,
                            isFirstOrLast: controller.currentIndex ==
                                ((controller.totalPages ~/ 2) - 1),
                            onTap: () async {
                              controller.currentIndex =
                                  controller.currentLeaf.index;
                              controller.animateNext();
                              await Future.delayed(
                                  const Duration(milliseconds: 1600));
                              controller.isLastCenterAlign =
                                  controller.currentIndex ==
                                          ((controller.totalPages ~/ 2) - 1)
                                      ? true
                                      : false;
                              setState(() {});
                            },
                            padding: EdgeInsets.only(left: 4.h)),
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
          color: Colors.black,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              if (controller.currentIndex == -1) {
                controller.animateNext();
                _startingPos = 0;
                setState(() {});
              } else if (controller.currentIndex ==
                      ((controller.totalPages ~/ 2) - 1) &&
                  controller.currentLeaf
                      .isLast /* && controller.isLastCenterAlign == false*/) {
                controller.animatePrev();
                // await Future.delayed(const Duration(milliseconds: 1200));
                controller.isLastCenterAlign = false;
                debugPrint(
                    "cur index : ${controller.currentLeaf.index}, ${controller.currentIndex}");
                controller.currentIndex = controller.currentLeaf.index - 1;
                debugPrint(
                    "cur index +: ${controller.currentLeaf.index}, ${controller.currentIndex}");
                setState(() {
                  //controller.isLastCenterAlign = true;
                });
              }
            },
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
                    /* Container(
                      color: Colors.black,
                      //padding: EdgeInsets.symmetric(vertical: 6.h,),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          1.toSpace(),
                          Transform.translate(
                            offset: Offset(_coverSize.width, 0),
                            child: Transform(
                              transform: Matrix4.identity()..rotateY(pi),
                              child: Transform(
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY((pi)),
                                alignment: isLTR
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  color: Colors.black,
                                  child: AppVerticalText("WELCOME",
                                      MediaQuery.of(context).orientation),
                                ),
                              ),
                            ),
                          ),
                          1.toSpace(),
                          Container(
                            color: Colors.black,
                            child: AppVerticalText(
                                "THANKYOU", MediaQuery.of(context).orientation),
                          ),
                          1.toSpace(),
                        ],
                      ),
                    ),*/
                    //Container(color: const Color(0xff515151)),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ...controller.leaves
                            .where(
                                (leaf) => leaf.animationController.value > 0.5)
                            .map((leaf) => leafBuilder(context, leaf))
                      ],
                    ),
                    /*  Stack(
                                            children: [
                                              Transform(
                                                transform: getScaleMatrix(),
                                                alignment: Alignment.center,
                                                child: ClipPath(
                                                  clipper: CurlBackSideClipper(mA: mA, mD: mD, mE: mE, mF: mF),
                                                  clipBehavior: Clip.antiAlias,
                                                  child: Transform.translate(
                                                    offset: getOffset(),
                                                    child: Transform.rotate(
                                                      alignment: Alignment.bottomLeft,
                                                      angle: getAngle(),
                                                      child: Stack(
                                                        alignment: Alignment.center,
                                                        children: [
                                                          ...controller.leaves
                                                              .where((leaf) =>
                                                          leaf.animationController.value > 0.5)
                                                              .map((leaf) => leafBuilder(context, leaf))
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              ClipPath(
                                                clipper: CurlBackgroundClipper(
                                                  mA: mA,
                                                  mD: mD,
                                                  mE: mE,
                                                  mF: mF,
                                                  mM: mM,
                                                  mN: mN,
                                                  mP: mP,
                                                ),
                                                clipBehavior: Clip.antiAlias,
                                                child: Stack(
                                                  children: [
                                                    Stack(
                                                      alignment: Alignment.center,
                                                      children: [
                                                        ...controller.leaves.reversed
                                                            .where((leaf) =>
                                                        leaf.animationController.value < 0.5)
                                                            .map((leaf) => leafBuilder(context, leaf)),
                                                      ],
                                                    ),
                                                    CustomPaint(
                                                      painter: CurlShadowPainter(mA: mA, mD: mD, mE: mE, mF: mF),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),*/
                    //),

                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ...controller.leaves.reversed
                            .where((leaf) =>
                                leaf.animationController.value < 0.5)
                            .map(
                              (leaf) => leafBuilder(context, leaf),
                          /*CustomPaint(
                                foregroundPainter: _OverleafPainter(
                                  animation: leaf.animation,
                                  color: Colors.grey.shade400,
                                  animationTransitionPoint: 0.1,
                                  direction: TurnDirection.rightToLeft,
                                ),
                                child: ClipPath(
                                  clipper: _PageTurnClipper(
                                    animation: leaf.animation,
                                    animationTransitionPoint: 0.1,
                                    direction: TurnDirection.rightToLeft,
                                  ),
                                  child: Align(
                                    widthFactor: leaf.animation.value,
                                    child: Stack(
                                      children: [
                                        leafBuilder(context, leaf),
                                      ],
                                    ),
                                  ),
                                ),
                              )*/
                            ),
                      ],
                      /*  Stack(
                                      children: [
                                        Transform(
                                          transform: getScaleMatrix(),
                                          alignment: Alignment.center,
                                          child: ClipPath(
                                            clipper: CurlBackSideClipper(mA: mA, mD: mD, mE: mE, mF: mF),
                                            clipBehavior: Clip.antiAlias,
                                            child: Transform.translate(
                                              offset: getOffset(),
                                              child: Transform.rotate(
                                                alignment: Alignment.bottomLeft,
                                                angle: getAngle(),
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    ...controller.leaves
                                                        .where((leaf) =>
                                                    leaf.animationController.value > 0.5)
                                                        .map((leaf) => leafBuilder(context, leaf))
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        ClipPath(
                                          clipper: CurlBackgroundClipper(
                                            mA: mA,
                                            mD: mD,
                                            mE: mE,
                                            mF: mF,
                                            mM: mM,
                                            mN: mN,
                                            mP: mP,
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: Stack(
                                            children: [
                                              Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  ...controller.leaves.reversed
                                                      .where((leaf) =>
                                                  leaf.animationController.value < 0.5)
                                                      .map((leaf) => leafBuilder(context, leaf)),
                                                ],
                                              ),
                                              CustomPaint(
                                                painter: CurlShadowPainter(mA: mA, mD: mD, mE: mE, mF: mF),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),*/

                      // ),
                    ),
                  ]),

              /*  builder: (_, __) => Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.diagonal3Values(
                        1.0,
                        1.0,
                        1.0,
                      ),
                      child: Container(
                        height: _coverSize.height,
                        width: Utility.getWidth(context: context),
                        child: Stack(
                          children: [
                            ClipPath(
                              clipper: CurlBackgroundClipper(
                                mA: mA,
                                mD: mD,
                                mE: mE,
                                mF: mF,
                                mM: mM,
                                mN: mN,
                                mP: mP,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                children: [
                                  Container(
                                    color: Colors.blueGrey,
                                    width: Utility.getWidth(context: context),
                                    child: Stack(
                                        clipBehavior: Clip.none,
                                        fit: StackFit.expand,
                                        children: [
                                          Container(
                                            color: Colors.black,
                                            //padding: EdgeInsets.symmetric(vertical: 6.h,),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                1.toSpace(),
                                                AppVerticalText(
                                                    "WELCOME",
                                                    MediaQuery.of(context)
                                                        .orientation),
                                                1.toSpace(),
                                                AppVerticalText(
                                                    "THANKYOU",
                                                    MediaQuery.of(context)
                                                        .orientation),
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
                                                      leaf.animationController
                                                          .value >
                                                      0.5)
                                                  .map((leaf) => leafBuilder(
                                                      context, leaf))
                                            ],
                                          ),
                                          Stack(
                                            clipBehavior: Clip.none,
                                            alignment: Alignment.center,
                                            fit: StackFit.expand,
                                            children: [
                                              ...controller.leaves.reversed
                                                  .where((leaf) =>
                                                      leaf.animationController
                                                          .value <
                                                      0.5)
                                                  .map((leaf) => leafBuilder(
                                                      context, leaf)),
                                            ],
                                          ),
                                          */
              /*  Stack(
                                          children: [
                                            Transform(
                                              transform: getScaleMatrix(),
                                              alignment: Alignment.center,
                                              child: ClipPath(
                                                clipper: CurlBackSideClipper(mA: mA, mD: mD, mE: mE, mF: mF),
                                                clipBehavior: Clip.antiAlias,
                                                child: Transform.translate(
                                                  offset: getOffset(),
                                                  child: Transform.rotate(
                                                    alignment: Alignment.bottomLeft,
                                                    angle: getAngle(),
                                                    child: Stack(
                                                      alignment: Alignment.center,
                                                      children: [
                                                        ...controller.leaves
                                                            .where((leaf) =>
                                                        leaf.animationController.value > 0.5)
                                                            .map((leaf) => leafBuilder(context, leaf))
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            ClipPath(
                                              clipper: CurlBackgroundClipper(
                                                mA: mA,
                                                mD: mD,
                                                mE: mE,
                                                mF: mF,
                                                mM: mM,
                                                mN: mN,
                                                mP: mP,
                                              ),
                                              clipBehavior: Clip.antiAlias,
                                              child: Stack(
                                                children: [
                                                  Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      ...controller.leaves.reversed
                                                          .where((leaf) =>
                                                      leaf.animationController.value < 0.5)
                                                          .map((leaf) => leafBuilder(context, leaf)),
                                                    ],
                                                  ),
                                                  CustomPaint(
                                                    painter: CurlShadowPainter(mA: mA, mD: mD, mE: mE, mF: mF),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),*/
              /*
                                        ]),
                                  ),
                                  CustomPaint(
                                    painter: CurlShadowPainter(
                                        mA: mA, mD: mD, mE: mE, mF: mF),
                                  ),
                                ],
                              ),
                            ),
                            Transform(
                                transform: getScaleMatrix(),
                                alignment: Alignment.center,
                                child: ClipPath(
                                  clipper: CurlBackSideClipper(
                                      mA: mA, mD: mD, mE: mE, mF: mF),
                                  clipBehavior: Clip.antiAlias,
                                  child: Transform.translate(
                                    offset: getOffset(),
                                    child: Transform.rotate(
                                      angle: getAngle(),
                                      alignment: Alignment.bottomLeft,
                                      child: Image.asset(
                                        AppAssets.image1,
                                        height: height,
                                        width: width,
                                      ),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),*/
            ),
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
    EdgeInsetsGeometry? padding,
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
                      child: Container(
                        height: 40.h,
                        width: 50.h,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade300),
                        alignment: Alignment.center,
                        padding: padding ?? EdgeInsets.all(4.h),
                        child: Icon(
                          iconData,
                          color: Colors.white,
                          size: 30.sp,
                        ),
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
    // print(
    //     "build1 ${controller.currentIndex == ((controller.totalPages ~/ 2) - 1)} /// ${leaf.index} // ${leaf.indexOf}");
/*    final firstPageTransformed = Stack(
        children: [
          ClipPath(
            clipper: CurlBackgroundClipper(
              mA: mA,
              mD: mD,
              mE: mE,
              mF: mF,
              mM: mM,
              mN: mN,
              mP: mP,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                widget.pageDelegate.build(context, _coverSize, leaf.pages.first),
                CustomPaint(
                  painter: CurlShadowPainter(mA: mA, mD: mD, mE: mE, mF: mF),
                ),
              ],
            ),
          ),
        ]);*/
    final firstPageTransformed = Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(pi),
        child:
            widget.pageDelegate.build(context, _coverSize, leaf.pages.first));
    // child: widget.pageDelegate.build(context, _leafSize, leaf.pages.first));
    final lastPage =
        widget.pageDelegate.build(context, _coverSize, leaf.pages.last);
    List<Widget> pages = [firstPageTransformed, lastPage];
    final pageMaterial = Align(
      alignment: isLTR ? Alignment.centerRight : Alignment.centerLeft,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
              height: _coverSize.height,
              width: _coverSize.width,
              // height: leaf.isCover ? _coverSize.height : _leafSize.height,
              // width: leaf.isCover ? _coverSize.width : _leafSize.width,
              child: Stack(
                  fit: StackFit.expand,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  children:
                      animationVal < 0.5 ? pages.reversed.toList() : pages)
              //animationVal < 0.5 ? [pages[0]]: pages)));
              // widget.controller.isCenterAlign ? [pages[0]]
              //     : (animationVal < 0.5 ? pages.reversed.toList() : pages)),
              ),
          Positioned(
            right: -110.h,
            child: Transform(
              transform: Matrix4.rotationY(pi),
              child: controller.currentIndex == -1 &&
                      controller.isSlideShow == false
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white38),
                      onPressed: () {
                        controller.animateNext();
                        _startingPos = 0;
                      },
                      child: Text(
                        controller.currentIndex == -1 &&
                                controller.isSlideShow == false
                            ? "CLICK TO VIEW"
                            : "",
                        style: const TextStyle().semiBold.copyWith(
                              fontSize: 20.sp,
                              color: Colors.white,
                            ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          )
        ],
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
        // offset: Offset(_coverSize.width, 0),
        offset: Offset(
            controller.currentIndex == -1
                ? _coverSize.width * 0.4
                : controller.currentIndex ==
                            ((controller.totalPages ~/ 2) - 1) &&
                        controller.isLastCenterAlign
                    ? _coverSize.width * 0.5
                    : _coverSize.width,
            0),
        child: Transform(
          transform: Matrix4.identity()..rotateY(isLTR ? -pi : pi),
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY((isLTR ? -pi : pi) * animationVal),
            alignment: isLTR
                ? controller.currentIndex ==
                            ((controller.totalPages ~/ 2) - 1) &&
                        controller.isLastCenterAlign
                    ? Alignment.center
                    : Alignment.centerRight
                : Alignment.centerLeft,
            /*  child: Stack(
              children: [
                ClipPath(
                    clipper: animationVal < 0.5
                        ? CurlBackgroundClipper(
                            mA: mA,
                            mD: mD,
                            mE: mE,
                            mF: mF,
                            mM: mM,
                            mN: mN,
                            mP: mP,
                          )
                        : null,
                    clipBehavior:
                        animationVal < 0.5 ? Clip.antiAlias : Clip.none,
                    child: Stack(
                      children: [
                        pageMaterial,
                        animationVal < 0.5
                            ? CustomPaint(
                                painter: CurlShadowPainter(
                                    mA: mA, mD: mD, mE: mE, mF: mF),
                              )
                            : Text(""),
                      ],
                    )),
                animationVal < 0.5
                    ? Transform(
                        //transform: getScaleMatrix(),
                        transform: Matrix4.identity()..rotateY(isLTR ? -pi : pi),
                        //alignment: Alignment.center,
                        child: Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY((isLTR ? -pi : pi) * animationVal),
                          alignment: isLTR ? Alignment.centerRight : Alignment.centerLeft,
                          child: ClipPath(
                            clipper: CurlBackSideClipper(
                                mA: mA, mD: mD, mE: mE, mF: mF),
                            clipBehavior: Clip.antiAlias,
                            child: Transform.translate(
                              offset: getOffset(),
                              child: Transform.rotate(
                                alignment: Alignment.bottomLeft,
                                angle: getAngle(),
                                child: Align(
                                  alignment: isLTR
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: SizedBox(
                                      height: _coverSize.height,
                                      width: _coverSize.width,
                                      // height: leaf.isCover ? _coverSize.height : _leafSize.height,
                                      // width: leaf.isCover ? _coverSize.width : _leafSize.width,
                                      child: Stack(
                                          fit: StackFit.expand,
                                          clipBehavior:
                                              Clip.antiAliasWithSaveLayer,
                                          children: animationVal < 0.5
                                              ? pages.reversed.toList()
                                              : pages)
                                      //animationVal < 0.5 ? [pages[0]]: pages)));
                                      // widget.controller.isCenterAlign ? [pages[0]]
                                      //     : (animationVal < 0.5 ? pages.reversed.toList() : pages)),
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                )
                    : Text("Hello"),
              ],
            ),*/
            child: pageMaterial,
        ),
      ),
      //child: pageMaterial,
    ));
  }

  /* Widget leafBuilder2(BuildContext context, Leaf leaf) {
    if ((!leaf.isCover &&
        (leaf.index - controller.currentLeaf.index).abs() >
            widget.bufferSize) ||
        (leaf.isCover &&
            widget.coverAspectRatio.value == widget.leafAspectRatio.value)) {
      return const SizedBox.shrink();
    }
    final animationVal = leaf.animationController.value;
    print("build1 ${leaf.index} // ${leaf.indexOf}");
*/
/*    final firstPageTransformed = Stack(
        children: [
          ClipPath(
            clipper: CurlBackgroundClipper(
              mA: mA,
              mD: mD,
              mE: mE,
              mF: mF,
              mM: mM,
              mN: mN,
              mP: mP,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                widget.pageDelegate.build(context, _coverSize, leaf.pages.first),
                CustomPaint(
                  painter: CurlShadowPainter(mA: mA, mD: mD, mE: mE, mF: mF),
                ),
              ],
            ),
          ),
        ]);*/
  /*
    final firstPageTransformed = Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(pi),
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
              //..rotateY((isLTR ? -pi : pi) * animationVal),
            ..rotateY(-pi * animationVal),
           // alignment: isLTR ? Alignment.centerRight : Alignment.centerLeft,
            alignment: Alignment.centerRight,
            child: Stack(
              children: [
                ClipPath(
                  clipper: CurlBackgroundClipper(
                            mA: mA,
                            mD: mD,
                            mE: mE,
                            mF: mF,
                            mM: mM,
                            mN: mN,
                            mP: mP,
                          ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        pageMaterial,
                        CustomPaint(
                                painter: CurlShadowPainter(
                                    mA: mA, mD: mD, mE: mE, mF: mF),
                              ),
                      ],
                    )),
                Transform(
                        //transform: getScaleMatrix(),
                        transform: Matrix4.identity()..rotateY(isLTR ? -pi : pi),
                        //alignment: Alignment.center,
                        child: Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY((isLTR ? -pi : pi) * animationVal),
                          alignment: isLTR ? Alignment.centerRight : Alignment.centerLeft,
                          child: ClipPath(
                            clipper: CurlBackSideClipper(
                                mA: mA, mD: mD, mE: mE, mF: mF),
                            clipBehavior: Clip.antiAlias,
                            child: Transform.translate(
                              offset: getOffset(),
                              child: Transform.rotate(
                                alignment: Alignment.bottomLeft,
                                angle: getAngle(),
                                child: Align(
                                  alignment: isLTR
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: SizedBox(
                                      height: _coverSize.height,
                                      width: _coverSize.width,
                                      // height: leaf.isCover ? _coverSize.height : _leafSize.height,
                                      // width: leaf.isCover ? _coverSize.width : _leafSize.width,
                                      child: Stack(
                                          fit: StackFit.expand,
                                          clipBehavior:
                                              Clip.antiAliasWithSaveLayer,
                                          children: animationVal < 0.5
                                              ? pages.reversed.toList()
                                              : pages)
                                      //animationVal < 0.5 ? [pages[0]]: pages)));
                                      // widget.controller.isCenterAlign ? [pages[0]]
                                      //     : (animationVal < 0.5 ? pages.reversed.toList() : pages)),
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
           // child: pageMaterial,
          ),
        ),
      ),
      //child: pageMaterial,
    );
  }*/

  Vector2D capMovement(Vector2D point, bool bMaintainMoveDir) {
    // make sure we never ever move too much
    if (point.distance(mOrigin) > mFlipRadius) {
      if (bMaintainMoveDir) {
        // maintain the direction
        print("if b");
        point = mOrigin.sum(point.sub(mOrigin).normalize().mult(mFlipRadius));
      } else {
        print("else  b");
        // change direction
        if (point.x > (mOrigin.x + mFlipRadius))
          point.x = (mOrigin.x + mFlipRadius);
        else if (point.x < (mOrigin.x - mFlipRadius))
          point.x = (mOrigin.x - mFlipRadius);
        point.y = math.sin(math.acos(abs(point.x - mOrigin.x) / mFlipRadius)) *
            mFlipRadius;
      }
    }
    return point;
  }

  void resetMovement() {
    if (!bFlipping) return;

    // No input when flipping
    bBlockTouchInput = true;

    double curlSpeed = mCurlSpeed.toDouble();
    curlSpeed *= -1;

    mMovement.x += curlSpeed;
    mMovement = capMovement(mMovement, false);

    resetClipEdge();
    doPageCurl();

    bUserMoves = true;
    bBlockTouchInput = false;
    bFlipping = false;
    bEnableInputAfterDraw = true;

    setState(() {});
  }

  void handleTouchInput(TouchEvent touchEvent) {
    if (bBlockTouchInput) return;

    if (touchEvent.getEvent() != TouchEventType.END) {
      // get finger position if NOT TouchEventType.END
      mFinger.x = touchEvent.getX()!;
      mFinger.y = touchEvent.getY()!;
    }

    switch (touchEvent.getEvent()) {
      case TouchEventType.END:
        bUserMoves = false;
        bFlipping = true;
        resetMovement();
        break;

      case TouchEventType.START:
        mOldMovement.x = mFinger.x;
        mOldMovement.y = mFinger.y;
        break;

      case TouchEventType.MOVE:
        bUserMoves = true;

        // get movement
        mMovement.x -= mFinger.x - mOldMovement.x;
        mMovement.y -= mFinger.y - mOldMovement.y;
        mMovement = capMovement(mMovement, true);

        // make sure the y value get's locked at a nice level
        if (mMovement.y <= 1) mMovement.y = 1;

        // save old movement values
        mOldMovement.x = mFinger.x;
        mOldMovement.y = mFinger.y;

        doPageCurl();

        setState(() {});
        break;
    }
  }

  void onDragCallback(final details) {
    if (details is DragStartDetails) {
      var x = details.globalPosition.dx - details.localPosition.dx;
      print(
          "**** drag details x = $x , ${details.localPosition} with global position ${details.globalPosition}");
      if (details.localPosition.dy >= 170) {
        print("nothing: ${details.localPosition.dy >= 185}");
        bBlockTouchInput = false;
        handleTouchInput(
            TouchEvent(TouchEventType.START, details.localPosition));
      } else {
        bBlockTouchInput = true;
        print(
            "bloc ${details.localPosition.dy <= 20}  ${details.localPosition.dy >= 185} $bBlockTouchInput");
      }
    }

    if (details is DragEndDetails) {
      handleTouchInput(TouchEvent(TouchEventType.END, null));
    }

    if (details is DragUpdateDetails) {
      if (mD.y > 120 || mA.x > 130) {
        handleTouchInput(
            TouchEvent(TouchEventType.MOVE, details.localPosition));
      }
    }
  }

  void _onDragStart(DragStartDetails details) {
    //onDragCallback(details);
    TouchEvent touchEvent =
        TouchEvent(TouchEventType.START, details.localPosition);
    if (currentLeaf != null || controller.animating) {
      _direction = null;
      _startingPos = 0;
      return;
    }
    // mFinger.x = touchEvent.getX()!;
    // mFinger.y = touchEvent.getY()!;
    // print("if it will come in if :${details.localPosition} with ${
    //     details.globalPosition
    // } ${mFinger.x} and ${mFinger.y}");
    // mOldMovement.x = mFinger.x;
    // mOldMovement.y = mFinger.y;
    // debugPrint("old move : $mOldMovement");
    print("ds1 $_direction // $_startingPos");
    _startingPos = details.globalPosition.dx;
    print("ds12 $_direction // $_startingPos / ${details.globalPosition.dx}");
/*    controller.leaves.where((leaf) {
      if(leaf == currentLeaf) {
        print("leaf = ${leaf == currentLeaf}");
      } else {
        print("= ${leaf == currentLeaf}");
      }
      return true;
    });*/
    // if (controller.leaves.length % 2 == 1) {
    //   print("starting pos after: ${controller.currentLeaf.animationController.value} // $currentLeaf");
    // }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    // TouchEvent touchEvent = TouchEvent(TouchEventType.MOVE, details.localPosition);
    // mFinger.x = touchEvent.getX()!;
    // mFinger.y = touchEvent.getY()!;
    // bUserMoves = true;
    if (controller.animating) {
      return;
    }
    _delta = isLTR
        ? _startingPos - details.globalPosition.dx
        : details.globalPosition.dx - _startingPos;

    // mMovement.x -= isLTR
    // ? mFinger.x - mOldMovement.x
    // : mOldMovement.x = mFinger.x;
    //
    // mMovement.y -= isLTR
    // ? mFinger.y = mOldMovement.y
    // : mOldMovement.y - mFinger.y;
    //
    // debugPrint("move x : ${mMovement.x} : ${mFinger.x} and ${mOldMovement.x}");
    // debugPrint("move y : ${mMovement.y} : ${mFinger.y} and ${mOldMovement.y}");
    print(
        "update : $isLTR $_startingPos ${details.globalPosition.dx} $_delta ${_startingPos - details.globalPosition.dx}");
    if (_delta.abs() > _bgSize.width) return;
    if (_delta == 0) return;
    _direction =
        _direction ?? ((_delta > 0) ? Direction.forward : Direction.backward);
    oldLeaf = currentLeaf;
    switch (_direction!) {
      case Direction.forward:
        final pos = _delta / _bgSize.width;
        // drag overflow
        if (pos > 1 || _delta < 0) {
          return;
        }
        print("drag update $currentLeaf");
        if (currentLeaf == null) {
          if (controller.isClosedInverted) {
            print("11111");
            return;
          } else {
            if (oldLeaf == currentLeaf) {
              print("yes : ${currentLeaf?.index}");
            }
            currentLeaf = controller.currentOrTurningLeaves.item2!;
            if (oldLeaf != currentLeaf) {
              //onDragCallback(details);
              print("no : ${currentLeaf?.index}");
            }
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
          print("22222");
          if (controller.isClosed) {
            print("33333");
            return;
          } else {
            print("44444");
            if (controller.currentIndex == ((controller.totalPages ~/ 2) - 1)) {
              controller.isLastCenterAlign = false;
            }
            currentLeaf = controller.currentOrTurningLeaves.item1!;
          }
        }
        controller.currentOrTurningLeaves.item1!.animationController.value =
            pos;
    }
  }

  void _onDragEnd(DragEndDetails details) async {
    //onDragCallback(details);
    if (currentLeaf == null || controller.animating) {
      print("drag end");
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
          print(
              "y1 : ci= ${controller.currentIndex}, ct= ${(controller.totalPages ~/ 2) - 1} ");
          animate = turningLeafAnimCtrl.forward;
          controller.isLastCenterAlign = false;
          setState(() {
            controller.currentIndex = controller.currentLeaf.index;
          });
          // if (controller.currentIndex == ((controller.totalPages ~/ 2) - 1)) {
          //   await Future.delayed(const Duration(milliseconds: 600));
          //   controller.isLastCenterAlign = true;
          // }
        } else {
          print("y2");
          animate = turningLeafAnimCtrl.reverse;
          controller.isLastCenterAlign = false;
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
            print(
                "y3 : ${controller.currentIndex} and ${controller.currentLeaf.index} and ${controller.currentLeaf.index - 1}");
            controller.isLastCenterAlign = true;
          });
        } else {
          print("y4");
          animate = turningLeafAnimCtrl.forward;
          controller.isLastCenterAlign = false;
          /*   await Future.delayed(const Duration(milliseconds: 1600));
          controller.isLastCenterAlign =
              controller.currentIndex == ((controller.totalPages ~/ 2) - 1)
                  ? true
                  : false;*/
        }
    }
    controller.animating = true;
    _direction = null;
    _startingPos = 0;
    await animate(from: turningLeafAnimCtrl.value);
    print(
        "++++ index : ${turningLeafAnimCtrl.isDismissed}yeh ${currentLeaf?.index} , ${((controller.totalPages ~/ 2) - 1)} , ${turningLeafAnimCtrl.status}");

    /// To align last image
    if (turningLeafAnimCtrl.status == AnimationStatus.completed &&
        controller.currentIndex == ((controller.totalPages ~/ 2) - 1)) {
      await Future.delayed(const Duration(milliseconds: 700));
      print("yaha");
      controller.isLastCenterAlign = true;
      setState(() {});
    }
    controller.animating = false;
    currentLeaf = null;
  }

  @override
  bool get wantKeepAlive => true;
}

/// CustomClipper that creates the page-turning clipping path.
class _PageTurnClipper extends CustomClipper<Path> {
  const _PageTurnClipper({
    required this.animation,
    required this.animationTransitionPoint,
    this.direction = TurnDirection.leftToRight,
  });

  /// The animation that controls the page-turning effect.
  final Animation<double> animation;

  /// The point at which the page-turning animation behavior changes.
  /// This value must be between 0 and 1 (0 <= animationTransitionPoint < 1).
  final double animationTransitionPoint;

  /// The direction in which the pages are turned.
  final TurnDirection direction;

  /// Creates the clipping path based on the animation progress and direction.
  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    final animationProgress = animation.value;

    final verticalVelocity = 1 / animationTransitionPoint;

    late final double innerTopCornerX;
    late final double innerBottomCornerX;
    late final double outerBottomCornerX;
    late final double foldUpperCornerX;
    late final double foldLowerCornerX;
    switch (direction) {
      case TurnDirection.rightToLeft:
        innerTopCornerX = 0.0;
        innerBottomCornerX = 0.0;
        foldUpperCornerX = width * (1.0 - animationProgress);
        break;
      case TurnDirection.leftToRight:
        innerTopCornerX = width;
        innerBottomCornerX = width;
        foldUpperCornerX = width * animationProgress;
        break;
    }

    final innerTopCorner = Offset(innerTopCornerX, 0.0);
    final foldUpperCorner = Offset(foldUpperCornerX, 0.0);
    final innerBottomCorner = Offset(innerBottomCornerX, height);

    final path = Path()
      ..moveTo(innerTopCorner.dx, innerTopCorner.dy)
      ..lineTo(foldUpperCorner.dx, foldUpperCorner.dy);

    if (animationProgress <= animationTransitionPoint) {
      final foldLowerCornerY = height * verticalVelocity * animationProgress;
      switch (direction) {
        case TurnDirection.rightToLeft:
          outerBottomCornerX = width;
          foldLowerCornerX = width;
          break;
        case TurnDirection.leftToRight:
          outerBottomCornerX = 0.0;
          foldLowerCornerX = 0.0;
          break;
      }
      final outerBottomCorner = Offset(outerBottomCornerX, height);
      final foldLowerCorner = Offset(foldLowerCornerX, foldLowerCornerY);
      path
        ..lineTo(foldLowerCorner.dx, foldLowerCorner.dy)
        ..lineTo(outerBottomCorner.dx, outerBottomCorner.dy)
        ..lineTo(innerBottomCorner.dx, innerBottomCorner.dy)
        ..close();
    } else {
      final progressSubtractedDefault =
          animationProgress - animationTransitionPoint;
      final horizontalVelocity = 1 / (1 - animationTransitionPoint);
      final turnedBottomWidth =
          width * progressSubtractedDefault * horizontalVelocity;

      switch (direction) {
        case TurnDirection.rightToLeft:
          foldLowerCornerX = width - turnedBottomWidth;
          break;
        case TurnDirection.leftToRight:
          foldLowerCornerX = turnedBottomWidth;
          break;
      }

      final foldLowerCorner = Offset(foldLowerCornerX, height);

      path
        ..lineTo(foldLowerCorner.dx, foldLowerCorner.dy) // BottomLeft
        ..lineTo(innerBottomCorner.dx, innerBottomCorner.dy) // BottomRight
        ..close();
    }

    return path;
  }

  @override
  bool shouldReclip(_PageTurnClipper oldClipper) {
    return true;
  }
}

/// CustomPainter that paints the backside of the pages during the animation.
class _OverleafPainter extends CustomPainter {
  const _OverleafPainter({
    required this.animation,
    required this.color,
    required this.animationTransitionPoint,
    required this.direction,
  });

  /// The animation that controls the page-turning effect.
  final Animation<double> animation;

  /// The color of the backside of the pages.
  final Color color;

  /// The point at which the page-turning animation behavior changes.
  /// This value must be between 0 and 1 (0 <= animationTransitionPoint < 1).
  final double animationTransitionPoint;

  /// The direction in which the pages are turned.
  final TurnDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width/2;
    final height = size.height;
    final animationProgress = animation.value;

    late final double topCornerX;
    late final double bottomCornerX;
    late final double topFoldX;
    late final double bottomFoldX;

    final turnedXDistance = width * animationProgress;

    switch (direction) {
      case TurnDirection.rightToLeft:
        topFoldX = width - turnedXDistance;
        break;
      case TurnDirection.leftToRight:
        topFoldX = turnedXDistance;
        break;
    }
    final topFold = Offset(topFoldX, 0.0);

    final path = Path()..moveTo(topFold.dx, topFold.dy);

    if (animationProgress <= animationTransitionPoint) {
      final verticalVelocity = 1 / animationTransitionPoint;
      final turnedYDistance = height * animationProgress * verticalVelocity;

      final W = turnedXDistance;
      final H = turnedYDistance;
      // Intersection of the line connecting (W, 0) & (W, H) and perpendicular line.
      final intersectionX = (W * H * H) / (W * W + H * H);
      final intersectionY = (W * W * H) / (W * W + H * H);

      switch (direction) {
        case TurnDirection.rightToLeft:
          topCornerX = width - 2 * intersectionX;
          bottomFoldX = width;
          break;
        case TurnDirection.leftToRight:
          topCornerX = 2 * intersectionX;
          bottomFoldX = 0.0;
          break;
      }
      final topCorner = Offset(topCornerX, 2 * intersectionY);
      final bottomFold = Offset(bottomFoldX, turnedYDistance);

      path
        ..lineTo(topCorner.dx, topCorner.dy)
        ..lineTo(bottomFold.dx, bottomFold.dy)
        ..close();
    } else if (animationProgress < 1) {
      final horizontalVelocity = 1 / (1 - animationTransitionPoint);
      final progressSubtractedDefault =
          animationProgress - animationTransitionPoint;
      final turnedBottomWidthRate =
          horizontalVelocity * progressSubtractedDefault;

      // Alias that converts values to simple characters. -------
      final w2 = width * width;
      final h2 = height * height;
      final q = animationProgress - turnedBottomWidthRate;
      final q2 = q * q;

      // --------------------------------------------------------

      // Page corner position which is line target point of (W, 0) for the line connecting (W, 0) & (W, H).
      final intersectionX = width * h2 * animationProgress / (w2 * q2 + h2);
      final intersectionY =
          w2 * height * animationProgress * q / (w2 * q2 + h2);

      final intersectionCorrection =
          (animationProgress - q) / animationProgress;

      final turnedBottomWidth =
          width * progressSubtractedDefault * horizontalVelocity;

      switch (direction) {
        case TurnDirection.rightToLeft:
          topCornerX = width - 2 * intersectionX;
          bottomCornerX = width - 2 * intersectionX * intersectionCorrection;
          bottomFoldX = width - turnedBottomWidth;
          break;
        case TurnDirection.leftToRight:
          topCornerX = 2 * intersectionX;
          bottomCornerX = 2 * intersectionX * intersectionCorrection;
          bottomFoldX = turnedBottomWidth;
          break;
      }
      final topCorner = Offset(topCornerX, 2 * intersectionY);
      final bottomCorner = Offset(
        bottomCornerX,
        2 * intersectionY * intersectionCorrection + height,
      );
      final bottomFold = Offset(bottomFoldX, height);

      path
        ..lineTo(topCorner.dx, topCorner.dy)
        ..lineTo(bottomCorner.dx, bottomCorner.dy)
        ..lineTo(bottomFold.dx, bottomFold.dy)
        ..close();
    } else {
      path.reset();
    }

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas
      ..drawPath(path, fillPaint)
      ..drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(_OverleafPainter oldPainter) {
    return true;
  }
}

class _PageTurnEffect extends CustomPainter {
  _PageTurnEffect({
    // required this.amount,
    this.amount,
    required this.image,
    this.backgroundColor,
    this.radius = 0.18,
  })  : assert(amount != null && image != null && radius != null),
        super(repaint: amount);

  final Animation<double>? amount;
  final ui.Image image;

  //final image;
  final Color? backgroundColor;
  final double radius;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final pos = amount?.value;
    final movX = (1.0 - (pos ?? 0.0)) * 0.85;
    final calcR = (movX < 0.20) ? radius * movX * 5 : radius;
    final wHRatio = 1 - calcR;
    final hWRatio = image.height / image.width;
    final hWCorrection = (hWRatio - 1.0) / 2.0;

    final w = size.width.toDouble();
    final h = size.height.toDouble();
    final c = canvas;
    final shadowXf = (wHRatio - movX);
    final shadowSigma =
        Shadow.convertRadiusToSigma(8.0 + (32.0 * (1.0 - shadowXf)));
    final pageRect = Rect.fromLTRB(0.0, 0.0, w * shadowXf, h);
    if (backgroundColor != null) {
      c.drawRect(pageRect, Paint()..color = backgroundColor!);
    }
    c.drawRect(
      pageRect,
      Paint()
        ..color = Colors.black54
        ..maskFilter = MaskFilter.blur(BlurStyle.outer, shadowSigma),
    );

    final ip = Paint();
    for (double x = 0; x < size.width; x++) {
      final xf = (x / w);
      final v =
          (calcR * (math.sin(math.pi / 0.5 * (xf - (1.0 - (pos ?? 0.0))))) +
              (calcR * 1.1));
      final xv = (xf * wHRatio) - movX;
      final sx = (xf * image.width);
      final sr = Rect.fromLTRB(sx, 0.0, sx + 1.0, image.height.toDouble());
      final yv = ((h * calcR * movX) * hWRatio) - hWCorrection;
      final ds = (yv * v);
      final dr = Rect.fromLTRB(xv * w, 0.0 - ds, xv * w + 1.0, h + ds);
      c.drawImageRect(image, sr, dr, ip);
    }
  }

  @override
  bool shouldRepaint(_PageTurnEffect oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.amount?.value != amount?.value;
  }
}

class MyCustomPainter extends CustomPainter {
  final ui.Image myBackground;

  const MyCustomPainter(this.myBackground);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(myBackground, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
