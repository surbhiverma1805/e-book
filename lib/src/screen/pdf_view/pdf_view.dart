import 'dart:async';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:ebook/app_route/app_router.dart';
import 'package:ebook/bloc/app_bloc/app_bloc.dart';
import 'package:ebook/model/album_list_resp.dart';
import 'package:ebook/src/screen/flip_page_builder.dart';
import 'package:ebook/src/screen/pdf_view/custom_flip_book/widget/book.dart';
import 'package:ebook/src/screen/pdf_view/custom_flip_book/controller/book_controller.dart';
import 'package:ebook/src/screen/pdf_view/bloc/pdf_viewer_bloc.dart';
import 'package:ebook/src/utils/app_assets.dart';
import 'package:ebook/src/utils/app_colors.dart';
import 'package:ebook/src/utils/extension/space.dart';
import 'package:ebook/src/utils/extension/text_style_decoration.dart';
import 'package:ebook/src/widgets/appbar.dart';
import 'package:ebook/utility/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:share_plus/share_plus.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

class PdfView extends StatefulWidget {
  const PdfView({
    Key? key,
    this.albumName,
    this.galleryImageList,
    this.pin,
    this.frontImage,
  }) : super(key: key);
  final String? albumName;
  final List<GalleryImage>? galleryImageList;
  final String? frontImage;
  final int? pin;

  @override
  State<PdfView> createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  FlipBookController? flipBookController;
  Timer? _timer;
  int index = 0;
  int? totalPage;
  bool? isPlayAgain;
  bool showSlide = false;
  int pageNumber = 0;

  // Creates a new player
  final AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();

  // var pdfViewerBloc = PdfViewerBloc(PdfViewerLoaded());

  @override
  void initState() {
    super.initState();
    flipBookController = FlipBookController(
        initialPage: 0,
        totalPages: widget.pin == 0 ? (totalPage ?? 0) : (widget.pin ?? 0));
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer!.cancel();
    }
    assetsAudioPlayer.dispose();
  }

  void slideShow(
      int totalPage, BuildContext context, PdfViewerBloc pdfViewerBloc) async {
    index = flipBookController?.currentLeaf.index ?? 0;
    assetsAudioPlayer.open(
      Audio(AppAssets.audio2),
      loopMode: LoopMode.single,
      volume: 100.0,
      autoStart: false,
    );
    assetsAudioPlayer.play();
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      _timer = timer;
      flipBookController?.animateNext(
          duration: const Duration(seconds: 4), curve: Curves.easeInOutQuad);
      // flipBookController!.animateTo(index,
      //     duration: const Duration(seconds: 4), curve: Curves.bounceInOut);
      //flipBookController?.isCenterAlign = false;
      index += 2;
      debugPrint("____index val : $index : ${imageList.length}");
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
        isPlayAgain = true;
        flipBookController?.currentIndex = -1;
        pdfViewerBloc.add(SlideShowEvent(isSlider: false));
        //pdfViewerBloc.add(SlideShowEvent(isSlider: false));
      }
    });
  }

  stopSlideShow(BuildContext context, PdfViewerBloc pdfViewerBloc) {
    _timer!.cancel();
    assetsAudioPlayer.pause();
    flipBookController?.animateTo(-1,
        duration: const Duration(seconds: 1), curve: Curves.easeInOutQuad);
    flipBookController?.currentIndex = -1;
    pdfViewerBloc.add(SlideShowEvent(isSlider: false));
    // BlocProvider.of<PdfViewerBloc>(context)
    //     .add(SlideShowEvent(isSlider: false));
    //_timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocConsumer<AppBloc, AppState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is InternetLostState) {
            return pdfView(
                isInternetAvail: false, size: size, context: context);
          } else {
            return pdfView(isInternetAvail: true, size: size, context: context);
          }
        });
  }

  Widget pdfView(
      {bool? isInternetAvail, required Size size, required context}) {
    return BlocProvider(
      create: (context) => PdfViewerBloc()
        ..add(PdfViewerInitialEvent(
          albumName: widget.albumName,
          galleryImageList: widget.galleryImageList,
          frontImage: widget.frontImage,
          isInternetAvail: isInternetAvail,
        )),
      child: BlocConsumer<PdfViewerBloc, PdfViewerState>(
          listener: (context, state) {
        if (state is PdfViewerLoaded) {
          if (state.isLoading == false) {}
        }
      }, builder: (context, state) {
        var pdfViewerBloc = BlocProvider.of<PdfViewerBloc>(context);
        if (state is PdfViewerLoaded) {
          totalPage = state.imageList?.length;
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: CustomAppBar(
              leadingIcon: IconButton(
                onPressed: () {
                  assetsAudioPlayer.stop();
                  flipBookController?.dispose();
                  Future.delayed(const Duration(seconds: 1), () {
                    AppRoutes.router.goNamed(AppRoutes.homeView);
                  });
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
              title: widget.albumName ?? Constants.unknown,
              actions: [
                state.isLoading ?? false
                    ? const SizedBox.shrink()
                    : WidgetAnimator(
                        atRestEffect: WidgetRestingEffects.size(),
                        child: IconButton(
                          onPressed: () {
                            print("share__");
                            //pdfViewerBloc.add(PdfViewerShareEvent(url: ""));
                            Share.share("First text to share");
                          },
                          icon: const Icon(
                            Icons.share,
                            color: Colors.white,
                          ),
                        ),
                      )
              ],
            ),
            bottomNavigationBar: state.isLoading ?? false
                ? const SizedBox.shrink()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      state.isSlider ?? false
                          ? playStopButton(
                              btnName: Constants.stopSlideShow,
                              iconName: Icons.stop,
                              onPressed: () {
                                stopSlideShow(context, pdfViewerBloc);
                              })
                          : playStopButton(
                              btnName: Constants.slideShow,
                              iconName: Icons.play_arrow,
                              onPressed: () {
                                slideShow(
                                    totalPage ?? 0, context, pdfViewerBloc);
                                pdfViewerBloc
                                    .add(SlideShowEvent(isSlider: true));
                                // BlocProvider.of<PdfViewerBloc>(context)
                                //     .add(SlideShowEvent(isSlider: true));
                              },
                            ),
                    ],
                  ),
            body: state.isLoading ?? false
                ? const Center(
                    child: SpinKitChasingDots(
                      color: cyanColor,
                      size: 50.0,
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        MediaQuery.of(context).orientation ==
                                Orientation.landscape
                            ? const SizedBox.shrink()
                            : 80.toSpace(),
                        Container(
                          height: MediaQuery.of(context).orientation ==
                                  Orientation.landscape
                              ? size.height * 0.62
                              : size.height * 0.45,
                          width: size.width,
                          margin: EdgeInsets.symmetric(
                            vertical: 8.h,
                          ),
                          child: FlipBook.builder(
                            pageSize: Size(
                                size.width / 2,
                                MediaQuery.of(context).orientation ==
                                        Orientation.landscape
                                    ? size.height * 0.6
                                    : size.height * 0.3),
                            showPreNextBtn:
                                (state.isSlider ?? false) ? false : true,
                            padding: const EdgeInsets.only(left: 0, right: 0),
                            pageBuilder:
                                (ctx, pageSize, pageIndex, semanticPageName) {
                              pageNumber =
                                  flipBookController?.currentLeaf.index ?? 0;
                              return flipBookWidget(
                                context: context,
                                pageIndex: pageIndex,
                                galleryImageList: state.galleryImageList,
                                imageList: state.imageList,
                                size: size,
                              );
                            },
                            controller: flipBookController,
                            totalPages:
                                widget.pin == 0 ? totalPage : widget.pin,
                            onPageChanged: (i) {
                              debugPrint("on page changed : $i");
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
    );
  }

  Widget playStopButton({
    IconData? iconName,
    String? btnName,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: () => onPressed(),
      icon: Icon(iconName, color: Colors.white),
      label: Text(
        btnName ?? "",
        style: const TextStyle().semiBold.copyWith(
              color: Colors.white,
            ),
      ),
    );
  }

  Widget prevNextWidget(PdfViewerLoaded state, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          flipBookController?.currentIndex == 0
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
                    flipBookController?.animatePrev();
                    print(
                        "tap prev $pageNumber ${flipBookController?.currentIndex}");
                    // BlocProvider.of<PdfViewerBloc>(context).add(
                    //     NextPrevButtonEvent(
                    //         pageNumber: (state.pageNumber ?? 0) - 1));
                  },
                ),
          // state.pageNumber == ((totalPage ?? 0) ~/ 2)
          pageNumber == (((flipBookController?.totalPages ?? 0) ~/ 2) - 2)
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
                    flipBookController?.animateNext();
                    setState(() {
                      pageNumber = flipBookController?.currentLeaf.index ?? 0;
                    });
                    print("tap next ${flipBookController?.currentIndex}");
                    /* BlocProvider.of<PdfViewerBloc>(context).add(
                        NextPrevButtonEvent(
                            pageNumber: (state.pageNumber ?? 0) + 1));*/
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

  Widget bg = const SizedBox.shrink();

  //Widget pageBody = const SizedBox.shrink();

  Widget pageBG = Column(
    children: [
      Expanded(
          child: Container(
        color: Colors.white,
        height: 600.h,
        width: 1000.w,
      )),
    ],
  );

  Widget imageWidget = Center(
    child: Text(
      "Loading...",
      style: const TextStyle().bold.copyWith(
            color: Colors.white,
            fontSize: 24.sp,
          ),
    ),
  );

  Widget flipBookWidget({
    required int pageIndex,
    List<GalleryImage>? galleryImageList,
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
