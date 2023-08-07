import 'dart:async';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:ebook/app_route/app_router.dart';
import 'package:ebook/model/album_detail_resp.dart';
import 'package:ebook/src/functions/call.dart';
import 'package:ebook/src/screen/pdf_view/custom_flip_book/controller/book_controller.dart';
import 'package:ebook/src/screen/pdf_view/custom_flip_book/widget/book.dart';
import 'package:ebook/src/screen/pdf_view/custom_flip_book/widget/book_state.dart';
import 'package:ebook/src/utils/app_assets.dart';
import 'package:ebook/src/utils/extension/space.dart';
import 'package:ebook/src/utils/extension/text_style_decoration.dart';
import 'package:ebook/src/widgets/app_images.dart';
import 'package:ebook/utility/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

class DetailsView extends StatefulWidget {
  const DetailsView({
    Key? key,
    this.albumName,
    this.galleryImageList,
    this.listLength,
    this.frontImage,
    this.detail,
  }) : super(key: key);
  final String? albumName;
  final List<String>? galleryImageList;
  final String? frontImage;
  final int? listLength;
  final Detail? detail;

  @override
  State<DetailsView> createState() => _DetailsViewState();
}

class _DetailsViewState extends State<DetailsView>
    with TickerProviderStateMixin {
  FlipBookController? flipBookController;

  late AnimationController animationController;
  late CurvedAnimation animation;

  // Creates a new player
  final AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();
  Timer? _timer;

  int index = 0;

  bool? isSlideShow;

  late double _startingPos;
  double _delta = 0;

  List<String>? albImageList;
  int? len;

  @override
  void initState() {
    super.initState();
    // flipCardController = FlipCardController();
    if ((widget.detail?.albumImage?.length ?? 0) ~/ 2 != 0) {
      widget.detail?.albumImage?.removeLast();
    }
    albImageList = widget.detail?.albumImage;
    albImageList?.insert(0, widget.detail?.frontImage ?? "");
    albImageList?.add(widget.detail?.backImage ?? "");
    len = widget.detail?.albumImage?.length;
    albImageList?.insert(((len ?? 0) - 1), "");
    albImageList?.insert(1, "");
    len = albImageList?.length;
    print("list of len old = ${widget.detail?.albumImage?.length}");
    print("list of len = $len");
    flipBookController =
        FlipBookController(initialPage: 0, totalPages: len ?? 0);
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      // duration: const Duration(milliseconds: 800),
    );
    animation = CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOutQuad,
        reverseCurve: Curves.easeInQuad);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void slideShow(int totalPage) async {
    assetsAudioPlayer.open(
      Audio(AppAssets.audio2),
      loopMode: LoopMode.single,
      volume: 100.0,
      autoStart: true,
    );
    assetsAudioPlayer.play();
    // index = flipBookController?.currentLeaf.index ?? 0;
    index = 0;
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      _timer = timer;
      flipBookController?.animateNext(
          duration: const Duration(seconds: 4), curve: Curves.easeInOutQuad);
      // flipBookController!.animateTo(index,
      //     duration: const Duration(seconds: 4), curve: Curves.bounceInOut);
      //flipBookController?.isCenterAlign = false;
      index += 2;
      //debugPrint("____index val : $index : ${imageList?.length}");
      if (index > totalPage) {
        debugPrint('Cancel timer');
        index = 0;
        timer.cancel();
        _timer!.cancel();
        await Future.delayed(const Duration(seconds: 2));
        flipBookController?.animateTo(-1,
            duration: const Duration(microseconds: 0), curve: Curves.linear);
        //flipBookController?.isCenterAlign = true;
        // assetsAudioPlayer.stop();
        // isPlayAgain = true;
        flipBookController?.currentIndex = -1;
        await Future.delayed(const Duration(seconds: 4));
        assetsAudioPlayer.stop();
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        // pdfViewerBloc.add(SlideShowEvent(isSlider: false));
        //pdfViewerBloc.add(SlideShowEvent(isSlider: false));
      }
    });
  }

  Future<bool> onBackPressed() async {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MediaQuery.of(context).orientation == Orientation.landscape
        ? false
        : true;
  }

  Widget prevNextButtonInLandscape({
    required IconData iconData,
    required bool? showPrevButton,
    required bool isFirstOrLast,
    required VoidCallback onTap,
  }) {
    return MediaQuery.of(context).orientation == Orientation.landscape
        ? showPrevButton ?? false
        ? isFirstOrLast
        ? const SizedBox.shrink()
        : Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.w),
      child: InkWell(
        splashColor: Colors.white70,
        onTap: onTap,
        child: Icon(
          iconData,
          color: Colors.white,
          size: 59.sp,
        ),
      ),
    )
        : const SizedBox.shrink()
        : const SizedBox.shrink();
  }

  void _onDragStart(DragStartDetails details) {
    _startingPos = details.globalPosition.dx;
    print("drag start $_startingPos");
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _delta = _startingPos - details.globalPosition.dx;
    if (_delta == 0) return;
    final pos = _delta / Utility.getWidth(context: context) * 0.5;
    // drag overflow
    if (pos > 1 || _delta < 0) {
      return;
    }
    animationController.value = pos;
    print("drag update $_delta");

  }

  void _onDragEnd(DragEndDetails details) async {
    TickerFuture Function({double? from}) animate;
    final pps = details.velocity.pixelsPerSecond;
    final turningLeafAnimCtrl = animationController;
    if ((pps.dx > fastDx ||
        turningLeafAnimCtrl.value >= 0.5)) {
      animate = turningLeafAnimCtrl.forward;
      //setState(() {
      //controller.currentIndex = controller.currentLeaf.index;
      //});
    } else {
      animate = turningLeafAnimCtrl.reverse;
      // setState(() {
      //   controller.currentIndex = controller.currentLeaf.index;
      // });
    }
    print("drag end ${turningLeafAnimCtrl.value}");
    _startingPos = 0;
    await animate(from: turningLeafAnimCtrl.value);
  }

  @override
  Widget build(BuildContext context) {
    print("list len ${widget.detail?.studioName}");
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.bottom]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.top]);
    }
    return WillPopScope(
      onWillPop: () => onBackPressed(),
      child: Container(
        color: MediaQuery.of(context).orientation == Orientation.portrait
            ? Colors.black54
            : Colors.black,
        child: SafeArea(
          child: Scaffold(
            backgroundColor:
            MediaQuery.of(context).orientation == Orientation.portrait
                ? null
                : Colors.black,
            appBar: MediaQuery.of(context).orientation == Orientation.portrait
                ? AppBar(
              elevation: 6,
              //backgroundColor: Color(0xFF212122),
              centerTitle: true,
              backgroundColor: Colors.black87,
              leading: InkWell(
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: EdgeInsets.only(left: 15.w),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                ),
              ),
              title: Text(
                "Details",
                style: const TextStyle().bold.copyWith(
                  fontSize: 22.sp,
                  color: Colors.white,
                ),
              ),
            )
                : null,
            body: MediaQuery.of(context).orientation == Orientation.portrait
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 5,
                  child: Center(
                    child:firstWidget(
                      studioName: widget.detail?.studioName,
                    ),
                  ),
                ),
                MediaQuery.of(context).orientation == Orientation.portrait
                    ? secondWidget(detail: widget.detail)
                    : const SizedBox.shrink(),
                MediaQuery.of(context).orientation == Orientation.portrait
                    ? thirdWidget(detail: widget.detail)
                    : const SizedBox.shrink(),
              ],
            )
                : SingleChildScrollView(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: () {
                        SystemChrome.setPreferredOrientations([
                          DeviceOrientation.portraitUp,
                          DeviceOrientation.portraitDown,
                        ]);
                        setState(() {
                          flipBookController?.currentIndex = -1;
                          flipBookController?.animateTo(-1,
                              duration: const Duration(microseconds: 0), curve: Curves.linear);
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.only(left: 12.w, top: 15.h),
                        child: Text(
                          "Back",
                          style: const TextStyle().semiBold.copyWith(
                            fontSize: 18.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  20.toSpace(),
                  SizedBox(
                    height: Utility.getHeight(context: context) * 0.8 / 2,
                    width: Utility.getWidth(context: context),
                    child: Row(
                      children: [
                        prevNextButtonInLandscape(
                          iconData: Icons.arrow_back_ios,
                          showPrevButton: flipBookController?.currentIndex == -1 ? false : true,
                          isFirstOrLast: flipBookController?.currentIndex == -1,
                          onTap: () {
                            print(
                                "prevb index : ${flipBookController?.currentIndex} /// ${(((flipBookController?.totalPages ?? 0) ~/ 2) - 1)}");
                            flipBookController?.animatePrev();
                            setState(() {
                              flipBookController?.currentIndex =
                              (flipBookController?.currentLeaf.index ?? 0) - 1 == 0
                                  ? -1
                                  : (flipBookController?.currentLeaf.index ?? 0) - 1;
                            });
                          },
                        ),
                        Expanded(
                          child: FlipBook.builder(
                            pageSize: Size(
                                Utility.getWidth(context: context) * 0.8 / 2,
                                MediaQuery.of(context).orientation ==
                                    Orientation.landscape
                                    ? Utility.getHeight(context: context) * 0.8
                                    : Utility.getHeight(context: context) * 0.2),
                            // showPreNextBtn:
                            // (state.isSlider ?? false) ? false : true,
                            padding: const EdgeInsets.only(left: 30, right: -60),
                            pageBuilder:
                                (ctx, pageSize, pageIndex, semanticPageName) {
                              /* pageNumber =
                                flipBookController?.currentLeaf.index ?? 0;*/
                              return flipBookWidget(
                                context: context,
                                pageIndex: pageIndex,
                                galleryImageList: albImageList,
                                imageList: albImageList,
                                size: Size(Utility.getWidth(context: context),
                                    Utility.getHeight(context: context)),
                              );
                            },
                            controller: flipBookController,
                            totalPages: len,
                            onPageChanged: (i) {
                              debugPrint("on page changed : $i");
                            },
                          ),
                        ),
                        prevNextButtonInLandscape(
                          iconData: Icons.arrow_forward_ios,
                          showPrevButton: flipBookController?.currentIndex ==
                              (((flipBookController?.totalPages ?? 0) ~/ 2) - 1) ? true : false,
                          isFirstOrLast: flipBookController?.currentIndex ==
                              (((flipBookController?.totalPages ?? 0) ~/ 2) - 1),
                          onTap: () {
                            flipBookController?.animateNext();
                            setState(() {
                              flipBookController?.currentIndex = flipBookController?.currentLeaf.index ?? 0;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  /*Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        prevNextButtonInLandscape(
                          iconData: Icons.arrow_back_ios,
                          //showPrevButton: widget.showPreNextBtn,
                          isFirstOrLast: flipBookController?.currentIndex == 1,
                          onTap: () {
                            print("prev index : ${flipBookController?.currentIndex} /// ${(((flipBookController?.totalPages ?? 0)~/ 2) - 1)}");
                            flipBookController?.animatePrev();
                            setState(() {
                              flipBookController?.currentIndex =
                              (flipBookController?.currentLeaf.index ?? 0) - 1 == 0
                                  ? -1
                                  : (flipBookController?.currentLeaf.index ?? 0) - 1;
                            });
                          }, showPrevButton: true,
                        ),
                        2.toSpace(vertically: false),
                        SizedBox(
                           height: Utility.getHeight(context: context) * 0.8,
                          width: Utility.getWidth(context: context) * 0.8,
                          child: FlipBook.builder(
                            pageSize: Size(
                                Utility.getWidth(context: context) * 0.8 / 2,
                                MediaQuery.of(context).orientation == Orientation.landscape
                                    ? Utility.getHeight(context: context) * 0.8
                                    : Utility.getHeight(context: context) * 0.2),
                            // showPreNextBtn:
                            // (state.isSlider ?? false) ? false : true,
                            padding: const EdgeInsets.only(left: 30, right: -60),
                            pageBuilder: (ctx, pageSize, pageIndex, semanticPageName) {
                              */ /* pageNumber =
                          flipBookController?.currentLeaf.index ?? 0;*/ /*
                              return flipBookWidget(
                                context: context,
                                pageIndex: pageIndex,
                                galleryImageList: widget.detail?.albumImage,
                                imageList: widget.detail?.albumImage,
                                size: Size(Utility.getWidth(context: context),
                                    Utility.getHeight(context: context)),
                              );
                            },
                            controller: flipBookController,
                            totalPages: widget.listLength,
                            onPageChanged: (i) {
                              debugPrint("on page changed : $i");
                            },
                          ),
                        ),
                        2.toSpace(vertically: false),
                        prevNextButtonInLandscape(
                          iconData: Icons.arrow_forward_ios,
                          //showPrevButton: widget.showPreNextBtn,
                          showPrevButton: true,
                          isFirstOrLast: flipBookController?.currentIndex ==
                              (((flipBookController?.totalPages ?? 0)~/ 2) - 1),
                          onTap: () {
                            print("nxt index : ${flipBookController?.currentIndex} /// ${(((flipBookController?.totalPages ?? 0)~/ 2) - 1)}");
                            flipBookController?.animateNext();
                            setState(() {
                              flipBookController?.currentIndex = flipBookController?.currentLeaf.index ?? 0;
                            });
                          },
                        ),
                      ],
                    ),
                  ),*/
                  /* Expanded(
                    child: FlipCard(
                      direction: FlipDirection.HORIZONTAL,
                      front: GestureDetector(
                        onHorizontalDragStart: (details) {
                          flipCardController?.toggleCard();
                        },
                        child: Container(
                          height: Utility.getHeight(context: context) * 0.2,
                          width: Utility.getWidth(context: context) * 0.4,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: const Color(0xFF212122),
                            // borderRadius: BorderRadius.
                            // circular(10.r),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(5.r),
                              bottomRight: Radius.circular(4.r),
                              topLeft: Radius.circular(2.r),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 8.w), // ***
                                decoration: BoxDecoration(
                                  color: const Color(0xFF212122),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(5.r),
                                    bottomRight: Radius.circular(4.r),
                                    topLeft: Radius.circular(2.r),
                                  ),
                                  // borderRadius: BorderRadius.circular(8.r),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.white,
                                        blurRadius: 3,
                                        spreadRadius: 3,
                                        offset: Offset(3.5, 3.5))
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: AppLocalFileImage(
                                        imageUrl: widget.frontImage ?? "",
                                        height: Utility.getHeight(context: context) * 0.2,
                                        width: Utility.getWidth(context: context) * 0.8,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                left: 8.w,
                                child: Container(
                                  height: Utility.getHeight(context: context) * 0.2,
                                  width: 1.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(20.r),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.white38,
                                          blurRadius: 1,
                                          spreadRadius: 0,
                                          offset: Offset(0, 1.5))
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      back: Container(
                        height: 400, width: 400,
                        color: Colors.white,
                      ),
                    ),
                  ),*/
                  10.toSpace(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget flipBookWidget({
    required int pageIndex,
    List<String>? galleryImageList,
    List<String>? imageList,
    required Size size,
    required BuildContext context,
  }) {
    debugPrint("++__ $pageIndex");
    return Stack(
      children: [
        Container(
          alignment: Alignment.center,
          color: Colors.black,
          child: Icon(
            Icons.image,
            color: Colors.white38,
            size: 60.sp,
          ),
        ),
        Column(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio:
                MediaQuery.of(context).orientation == Orientation.portrait
                    ? 16.w / 17.h
                    : 3.w / 2.h,
                child: Image(
                  image: FileImage(
                    File(imageList![pageIndex]),
                    scale: 0.5,
                  ),
                  fit: BoxFit.fill,
                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                    return Container(
                      alignment: Alignment.center,
                      color: Colors.white,
                      child: Icon(
                        Icons.image,
                        color: Colors.white,
                        size: 60.sp,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget firstWidget({String? studioName, bool? isShowStudioName}) {
    return Container(
      // color: Colors.white,
      color: MediaQuery.of(context).orientation == Orientation.portrait
          ? Colors.blueGrey
          : Colors.black,
      width: Utility.getWidth(context: context),
      padding: EdgeInsets.only(bottom: 50.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              10.toSpace(),
              Text(
                studioName ?? "",
                style: const TextStyle().semiBold.copyWith(
                  fontSize: 16.sp,
                ),
              ),
              10.toSpace(),
            ],
          ),
          /* Expanded(
            child: itemWidget(
              image: widget.frontImage ?? "",
              height: Utility.getHeight(context: context) * 0.4,
              width: Utility.getWidth(context: context) * 0.6,
            ),*/
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (MediaQuery.of(context).orientation ==
                    Orientation.portrait) {
                  SystemChrome.setPreferredOrientations(
                      [DeviceOrientation.landscapeRight]);
                }
              },
              child: Container(
                height: Utility.getHeight(context: context) * 0.2,
                width: Utility.getWidth(context: context) * 0.7,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFF212122),
                  // borderRadius: BorderRadius.
                  // circular(10.r),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(5.r),
                    bottomRight: Radius.circular(4.r),
                    topLeft: Radius.circular(2.r),
                  ),
                ),
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 8.w), // ***
                      decoration: BoxDecoration(
                        color: const Color(0xFF212122),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(5.r),
                          bottomRight: Radius.circular(4.r),
                          topLeft: Radius.circular(2.r),
                        ),
                        // borderRadius: BorderRadius.circular(8.r),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.white,
                              blurRadius: 3,
                              spreadRadius: 3,
                              offset: Offset(3.5, 3.5))
                        ],
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: AppLocalFileImage(
                              imageUrl: widget.frontImage ?? "",
                              height: Utility.getHeight(context: context) * 0.2,
                              width: Utility.getWidth(context: context) * 0.8,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 8.w,
                      child: Container(
                        height: Utility.getHeight(context: context) * 0.2,
                        width: 1.w,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.white38,
                                blurRadius: 1,
                                spreadRadius: 0,
                                offset: Offset(0, 1.5))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          /* Expanded(
            child: CurlWidget(
              size: Size(
                Utility.getWidth(context: context) * 0.4,
                Utility.getHeight(context: context) * 0.4,
              ),
              vertical: false,
              frontWidget: Container(
                height: Utility.getHeight(context: context) * 0.4,
                width: Utility.getWidth(context: context) * 0.6,
                color: Colors.black38,
                child: Image.asset(
                  AppAssets.image1,
                  fit: BoxFit.cover,
                ),
              ),
              backWidget: Container(
                height: Utility.getHeight(context: context) * 0.4,
                width: Utility.getWidth(context: context) * 0.6,
                color: Colors.black38,
                child: Image.asset(
                  AppAssets.image2,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),*/
        ],
      ),
    );
  }

  Widget secondWidget({Detail? detail}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black87,
            Colors.black12,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: secondSubWidget(
                    iconData: Icons.image_outlined,
                    name: "View",
                    margin: EdgeInsets.only(right: 4.w),
                    onTap: () {
                      print("type");
                      if (MediaQuery.of(context).orientation ==
                          Orientation.portrait) {
                        SystemChrome.setPreferredOrientations(
                            [DeviceOrientation.landscapeRight]);
                      }
                      /*   AppRoutes.router.pushNamed(AppRoutes.albumView, extra: {
                        'front_image': detail?.frontImage,
                        'back_image': detail?.backImage,
                        'image_list': detail?.albumImage,
                      });*/
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: secondSubWidget(
                    iconData: Icons.slideshow,
                    name: "Slide Show",
                    margin: EdgeInsets.only(right: 4.w),
                    onTap: () {
                      print("type");
                      if (MediaQuery.of(context).orientation ==
                          Orientation.portrait) {
                        SystemChrome.setPreferredOrientations(
                            [DeviceOrientation.landscapeRight]);
                      }
                      slideShow(len ?? 0);
                      /*  AppRoutes.router.pushNamed(AppRoutes.albumView, extra: {
                        'front_image': detail?.frontImage,
                        'back_image': detail?.backImage,
                        'image_list': detail?.albumImage,
                        'is_slide_show': true,
                      });*/
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: secondSubWidget(
                    iconData: Icons.share,
                    name: "Share",
                    onTap: () {
                      Share.share(
                          "To view my album ${detail?.studioName} from 'APPNAME' app from Android App store: 'applink\nUse Album Code '${detail?.code}'");
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget secondSubWidget({
    required IconData iconData,
    required String name,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? EdgeInsets.zero,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black12,
              Colors.black87,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3.r)),
              padding: EdgeInsets.all(3.w),
              child: Icon(
                iconData,
                color: Colors.black,
                size: 25.sp,
              ),
            ),
            6.toSpace(),
            Text(
              name,
              softWrap: true,
              style: const TextStyle()
                  .medium
                  .copyWith(color: Colors.white, fontSize: 13.sp),
            )
          ],
        ),
      ),
    );
  }

  Widget thirdWidget({Detail? detail}) {
    return Container(
      color: Colors.grey.shade400.withOpacity(0.6),
      //padding: EdgeInsets.only(left: 8.w),
      child: Row(
        children: [
          Container(
            // radius: 46.r,
            // backgroundColor: Colors.greenAccent,
            margin: EdgeInsets.only(left: 2.w),
            padding: EdgeInsets.symmetric(
              horizontal: 5.h,
              vertical: 5.h,
            ),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(60.r),
              border: Border.all(
                color: Colors.white,
              ),
            ),
            child: AppLocalFileImage(
              imageUrl: detail?.studioImage ?? "",
              fit: BoxFit.cover,
              radius: 60.r,
              height: 80.h,
              width: 80.h,
            ),
          ),
          5.toSpace(vertically: false),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Photography By",
                  style: const TextStyle().medium.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                4.toSpace(),
                /* Text(
                  "N1695QCMJ6IQ-",
                  style: const TextStyle().medium.copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                4.toSpace(),*/
                Text(
                  detail?.studioName ?? "N/A",
                  style: const TextStyle().bold.copyWith(
                    fontSize: 14.sp,
                  ),
                ),
                4.toSpace(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    studioInfo(
                      iconData: Icons.phone,
                      onTap: () {
                        print("contact : ${detail?.studioContactNo}");
                        if (detail?.studioContactNo != null) {
                          call(detail?.studioContactNo);
                        } else {
                          Utility.showToast("Contact number is not avaailable");
                        }
                      },
                    ),
                    10.toSpace(vertically: false),
                    studioInfo(
                      iconData: Icons.info_outline,
                      onTap: () {
                        AppRoutes.router.pushNamed(AppRoutes.infoView, extra: {
                          'detail': detail,
                        });
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
          5.toSpace(vertically: false),
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () {
                AppRoutes.router.pushNamed(AppRoutes.orderView, extra: {
                  'front_image': detail?.frontImage,
                  'studio_name': detail?.studioName,
                });
              },
              child: Container(
                color: Colors.red.shade800,
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                      size: 60.sp,
                    ),
                    5.toSpace(),
                    Text(
                      "ORDER",
                      style: const TextStyle().semiBold.copyWith(
                        fontSize: 12.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget studioInfo({required IconData iconData, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3.r),
            color: Colors.grey.shade700),
        child: Icon(
          iconData,
          color: Colors.white60,
          size: 30.sp,
        ),
      ),
    );
  }
}
