import 'dart:async';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:ebook/src/screen/pdf_view/custom_flip_book/widget/book.dart';
import 'package:ebook/src/utils/app_assets.dart';
import 'package:ebook/src/utils/extension/text_style_decoration.dart';
import 'package:ebook/src/widgets/app_images.dart';
import 'package:ebook/utility/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'pdf_view/custom_flip_book/controller/book_controller.dart';
import 'dart:math';

class AlbumView extends StatefulWidget {
  const AlbumView({
    Key? key,
    this.frontImage,
    this.backImage,
    this.imageList,
    this.isSlideShow,
  }) : super(key: key);

  final String? frontImage, backImage;
  final List<String>? imageList;
  final bool? isSlideShow;

  /// List of images will be use to show album

  @override
  State<AlbumView> createState() => _AlbumViewState();
}

const double _MinNumber = 0.008;

double _clampMin(double v) {
  if (v < _MinNumber && v > -_MinNumber) {
    if (v >= 0) {
      v = _MinNumber;
    } else {
      v = -_MinNumber;
    }
  }
  return v;
}

class _AlbumViewState extends State<AlbumView>
    with SingleTickerProviderStateMixin {
  String? frontImage, backImage;
  List<String>? imageList;

  FlipBookController? flipBookController;
  int totalPages = 0;

  int pageNumber = 0;
  int index = 0;

  // Creates a new player
  final AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();
  Timer? _timer;

  late AnimationController _controller;
  late Animation _animation;
  AnimationStatus _status = AnimationStatus.dismissed;

  @override
  void initState() {
    frontImage = widget.frontImage;
    backImage = widget.backImage;
    imageList = widget.imageList;
    int listLen = imageList?.length ?? 0;
    totalPages = listLen ~/ 2 == 0 ? listLen : (imageList?.length ?? 0) - 1;
    if ((imageList?.length ?? 0) ~/ 2 != 0) {
      //imageList.removeAt(listLen);
      imageList?.removeLast();
      print("len list init1 ${imageList?.length}/// $imageList");
    }
    print("len list init ${imageList?.length}/// $imageList");
    flipBookController =
        FlipBookController(initialPage: 0, totalPages: totalPages);

    /// initialize _controller, _animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutQuad,
      reverseCurve: Curves.easeInQuad,
    );
    /*  _animation = Tween(end: 1.0, begin: 0.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        _status = status;
      });*/
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    print("slide show : ${widget.isSlideShow}");
    if (widget.isSlideShow ?? false) {
      slideShow(totalPages);
    }
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void slideShow(
      int totalPage) async {
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
      debugPrint("____index val : $index : ${imageList?.length}");
      if (index > totalPage) {
        debugPrint('Cancel timer');
        index = 0;
        timer.cancel();
        _timer!.cancel();
        await Future.delayed(const Duration(seconds: 2));
        flipBookController?.animateTo(-1,
            duration: const Duration(microseconds: 0), curve: Curves.linear);
        //flipBookController?.isCenterAlign = true;
        assetsAudioPlayer.stop();
       // isPlayAgain = true;
        flipBookController?.currentIndex = -1;
        await Future.delayed(const Duration(seconds: 4));
        Navigator.pop(context);
       // pdfViewerBloc.add(SlideShowEvent(isSlider: false));
        //pdfViewerBloc.add(SlideShowEvent(isSlider: false));
      }
    });
  }

  stopSlideShow(BuildContext context) async{
    _timer!.cancel();
    assetsAudioPlayer.pause();
    flipBookController?.animateTo(-1,
        duration: const Duration(seconds: 1), curve: Curves.easeInOutQuad);
    flipBookController?.currentIndex = -1;
    await Future.delayed(const Duration(seconds: 4));
    print("back back");
   // pdfViewerBloc.add(SlideShowEvent(isSlider: false));
    // BlocProvider.of<PdfViewerBloc>(context)
    //     .add(SlideShowEvent(isSlider: false));
    //_timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w,),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Text(
                "BACK",
                style: const TextStyle().semiBold.copyWith(
                      fontSize: 14.sp,
                      color: Colors.white,
                    ),
              ),
            ),
            listImage(context, totalPages),
            /*Container(height: 100,
            child:  Transform(
              alignment: FractionalOffset.centerLeft,
              transform: Matrix4.rotationY(pi),
              child: _animation.value <= 0.5
                  ? InkWell(
                onTap: () {
                  setState(() {
                    _controller.forward();
                  });
                },
                child: frontImageWidget(context,
                    frontImage: frontImage,
                    backImage: backImage,
                    imageList: imageList),
              )
                  : InkWell(
                onTap: () {
                  setState(() {
                    _controller.reverse();
                  });
                },
                child: Container(
                    color: Colors.deepOrange,
                    width: 240,
                    height: 300,
                    child: const Center(
                        child: Text(
                          '?',
                          style: TextStyle(fontSize: 100, color: Colors.white),
                        ))),
              ),
            ),)*/
          /*  Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(pi * _animation.value),
                child: _animation.value <= 0.5
                ? GestureDetector(
                    onHorizontalDragStart: (details) {
                      setState(() {
                        _controller.forward();
                      });
                    },
                    child: frontImageWidget(context, frontImage: frontImage))
                    : const SizedBox.shrink()),
            _animation.value >=0.5
            ? listImage(context, totalPages)
                : const SizedBox.shrink(),*/
            /* Stack(
              children: [

              ],
            ),*/
          ],
        ),
      ),
    ));
  }

  Widget frontImageWidget(
    context, {
    String? frontImage,
    String? backImage,
    List<String>? imageList,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: 150.h, right: 18.h, top: 30.h),
      child: Container(
        height: Utility.getHeight(context: context) * 0.7,
        width: Utility.getWidth(context: context) * 0.4,
        clipBehavior: Clip.antiAlias,
        alignment: Alignment.center,
        //margin: EdgeInsets.only(left: 0.h,right: 20.h),
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
                      imageUrl: frontImage ?? "",
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
    );
  }

  Widget listImage(
    context,
    int? totalPages,
  ) {
    print("len list $totalPages");
    Size size = MediaQuery.of(context).size;
    return Container(
      height: MediaQuery.of(context).orientation == Orientation.landscape
          ? Utility.getHeight(context: context) * 0.7
          : Utility.getHeight(context: context) * 0.45,
      width: Utility.getWidth(context: context),
      // margin: EdgeInsets.symmetric(
      //   vertical: 8.h,
      // ),
      // margin: EdgeInsets.all(4.h),
      child: FlipBook.builder(
        pageSize: Size(
            size.width / 2,
            MediaQuery.of(context).orientation == Orientation.landscape
                ? Utility.getHeight(context: context) * 0.7
                : Utility.getHeight(context: context) * 0.2),
        // showPreNextBtn:
        // (state.isSlider ?? false) ? false : true,
        padding: const EdgeInsets.only(left: 30, right: -60),
        pageBuilder: (ctx, pageSize, pageIndex, semanticPageName) {
          /* pageNumber =
              flipBookController?.currentLeaf.index ?? 0;*/
          return flipBookWidget(
            context: context,
            pageIndex: pageIndex,
            galleryImageList: imageList,
            imageList: imageList,
            size: Size(Utility.getWidth(context: context),
                Utility.getHeight(context: context)),
          );
        },
        controller: flipBookController,
        totalPages: totalPages,
        onPageChanged: (i) {
          debugPrint("on page changed : $i");
        },
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
                ),
              ),
            ),
          ],
        ),
        /*Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(File(imageList![pageIndex]), scale: 0.5),
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
            //image: AssetImage(imageList[pageIndex]), fit: BoxFit.cover),
          ),
          //child: Image.file(File(imageList![pageIndex]), fit: BoxFit.cover,),
        ),*/
      ],
    );

/*    Widget showImageWidget = const SizedBox.shrink();
    switch (pageIndex) {
      case 0:
        showImageWidget = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(File(imageList![0])),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                    // image: AssetImage(imageList[pageIndex]), fit: BoxFit.cover),
                  ),
                ),
              ),
            ],
          ),
        );
        break;
      case 1:
        showImageWidget = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(File(imageList![1])),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                    // image: AssetImage(imageList[pageIndex]), fit: BoxFit.cover),
                  ),
                ),
              ),
            ],
          ),
        );
        break;
      case 2:
        showImageWidget = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(File(imageList![2])),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                    // image: AssetImage(imageList[pageIndex]), fit: BoxFit.cover),
                  ),
                ),
              ),
            ],
          ),
        );
        break;
      case 3:
        showImageWidget = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(File(imageList![3])),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                    // image: AssetImage(imageList[pageIndex]), fit: BoxFit.cover),
                  ),
                ),
              ),
            ],
          ),
        );
        break;
      case 4:
        showImageWidget = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(File(imageList![4])),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                    // image: AssetImage(imageList[pageIndex]), fit: BoxFit.cover),
                  ),
                ),
              ),
            ],
          ),
        );
        break;
      case 5:
        showImageWidget = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(File(imageList![5])),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                    // image: AssetImage(imageList[pageIndex]), fit: BoxFit.cover),
                  ),
                ),
              ),
            ],
          ),
        );
        break;
      default:
        showImageWidget = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(File(imageList![pageIndex])),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                    // image: AssetImage(imageList[pageIndex]), fit: BoxFit.cover),
                  ),
                ),
              ),
            ],
          ),
        );
    }

    return Stack(
      children: [
        bg,
        showImageWidget,
      ],
    );*/
  }
}
