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
import 'package:ebook/src/utils/extension/text_style_decoration.dart';
import 'package:ebook/src/widgets/appbar.dart';
import 'package:ebook/utility/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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

  // Creates a new player
  final AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    super.initState();
    print("len of image list is ${widget.pin}");
    flipBookController = FlipBookController(
        initialPage: 0,
        totalPages: widget.pin == 0 ? (totalPage ?? 0) : (widget.pin ?? 0));
  }

  @override
  void dispose() {
    super.dispose();
    assetsAudioPlayer.dispose();
  }

  void slideShow(int totalPage) async {
    /*assetsAudioPlayer.open(
      Audio(AppAssets.audio2),
      loopMode: LoopMode.single,
      volume: 100.0,
      autoStart: false,
    );*/
    assetsAudioPlayer.play();
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      _timer = timer;
      flipBookController!.animateTo(index,
          duration: const Duration(microseconds: 2000),
          curve: Curves.bounceInOut);
      flipBookController?.isCenterAlign = false;
      index++;
      debugPrint("____index val : $index : ${imageList.length}");
      if (index > totalPage) {
        debugPrint('Cancel timer');
        index = 0;
        timer.cancel();
        _timer!.cancel();
        await Future.delayed(const Duration(seconds: 4));
        flipBookController?.animateTo(-1,
            duration: const Duration(microseconds: 0), curve: Curves.linear);
        flipBookController?.isCenterAlign = true;
        assetsAudioPlayer.stop();
        isPlayAgain = true;
        // flipBookController?.dispose();
        // BlocProvider.of<PdfViewerBloc>(context)
        //     .add(PdfViewerShareEvent(isSlider: false, isFirstImage: false));
      }
    });
  }

  stopSlideShow(BuildContext context) {
    _timer!.cancel();
    assetsAudioPlayer.pause();
    BlocProvider.of<PdfViewerBloc>(context)
        .add(PdfViewerShareEvent(isSlider: false, isFirstImage: false));
    //_timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    //flipBookController = FlipBookController(totalPages: 34);
    //FlipBookController(totalPages: widget.galleryImageList?.length ?? 0);
    Size size = MediaQuery.of(context).size;
    return BlocConsumer<AppBloc, AppState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is InternetLostState) {
            return pdfView(isInternetAvail: false, size: size);
          } else {
            return pdfView(isInternetAvail: true, size: size);
          }
        });
  }

  Widget pdfView({bool? isInternetAvail, required Size size}) {
    return BlocProvider(
      create: (context) => PdfViewerBloc()
        ..add(PdfViewerInitialEvent(
          albumName: widget.albumName,
          galleryImageList: widget.galleryImageList,
          frontImage: widget.frontImage,
          isInternetAvail: isInternetAvail,
        )),
      child: BlocConsumer<PdfViewerBloc, PdfViewerState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is PdfViewerLoaded) {
              totalPage = state.imageList?.length;
              if (state.isLoading == false) {
                // assetsAudioPlayer.open(
                //   Audio(AppAssets.audio2),
                //   loopMode: LoopMode.single,
                //   volume: 100.0,
                // );
              }
              /*flipBookController = FlipBookController(
                  initialPage: 0, totalPages: totalPage ?? 0);*/
           /*   flipBookController?.animateTo(0,
                  duration: const Duration(seconds: 0), curve: Curves.linear);*/
         /*     assetsAudioPlayer.open(
                Audio(AppAssets.birdsAudio),
                loopMode: LoopMode.single,
                volume: 100.0,
                autoStart: false,
                playInBackground: PlayInBackground.disabledPause,
              );*/
              //slideShow(totalPage ?? 0);
              return Scaffold(
                backgroundColor: Colors.black,
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
                    ),
                  ),
                  title: widget.albumName ?? Constants.unknown,
                  actions: [
                    state.isSlider ?? false
                        ? const SizedBox.shrink()
                        : IconButton(
                            onPressed: () {
                              BlocProvider.of<PdfViewerBloc>(context)
                                  .add(PdfViewerShareEvent(url: ""));
                              //Share.share(widget.photoBook?.url ?? "");
                            },
                            icon: const Icon(Icons.share),
                          )
                  ],
                ),
                bottomNavigationBar: isPlayAgain ?? false
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /*  state.isSlider ?? false
                              ? playStopButton(
                                  btnName: Constants.stopSlideShow,
                                  iconName: Icons.stop,
                                  onPressed: () {
                                    stopSlideShow(context);
                                  },
                                )
                              : */
                          playStopButton(
                            btnName: Constants.playAgain,
                            iconName: Icons.play_arrow,
                            onPressed: () {
                              slideShow(totalPage ?? 0);
                            },
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
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
                          children: [
                            SizedBox(
                              height: size.height * 0.8,
                              child: FlipBook.builder(
                                pageBuilder: (ctx, pageSize, pageIndex,
                                    semanticPageName) {
                                  return GestureDetector(
                                    onTap: () {
                                      if (pageIndex == totalPage || pageIndex == 0) {
                                        print("true___");
                                        flipBookController?.isCenterAlign = true;
                                      }
                                    },
                                    child: flipBookWidget(
                                      context: context,
                                      pageIndex: pageIndex,
                                      galleryImageList: state.galleryImageList,
                                      imageList: state.imageList,
                                      size: size,
                                      lastIndex: totalPage ?? 0,
                                      secondLastIndex: (totalPage ?? 0) - 1,
                                    ),
                                  );
                                  /*Future.delayed(const Duration(seconds: 6),
                                      () {
                                      abcd = flipBookWidget(
                                      context: context,
                                      pageIndex: pageIndex,
                                      galleryImageList: state.galleryImageList,
                                      imageList: state.imageList,
                                      size: size,
                                      lastIndex: totalPage ?? 0,
                                      secondLastIndex: (totalPage ?? 0) - 1,
                                    );
                                      });
                                  return abcd;*/
                                },
                                controller: flipBookController,
                                totalPages:
                                    widget.pin == 0 ? totalPage : widget.pin,
                                onPageChanged: (i) {
                                  debugPrint("on page changed : $i");
                                },
                              ),
                            )
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
      icon: Icon(iconName),
      label: Text(btnName ?? ""),
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
    Size? size,
    required BuildContext context,
    required int lastIndex,
    int? secondLastIndex,
  }) {
    debugPrint("++__ $pageIndex");

    return Column(
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
    );

    /*  return Image.file(
      File(imageList![pageIndex]),
      alignment: Alignment.center,
      fit: BoxFit.cover,
      height: size!.height * 0.5,
      width: size.width * 0.5,
    );*/
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
    /*   return pageIndex == 0
        ? const SizedBox.shrink()
        : Container(
            alignment: Alignment.centerLeft,
            child: Image.asset(
              pageIndex == 0
                  ? AppAssets.image1
                  : pageIndex == 1
                      ? AppAssets.image2
                      : pageIndex == 2
                          ? AppAssets.image3
                          : pageIndex == 3
                              ? AppAssets.image4
                              : pageIndex == 4
                                  ? AppAssets.image5
                                  : AppAssets.image6,
              height: 1000.h,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.fill,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.broken_image,
                size: 60.sp,
                color: Colors.white70,
              ),
            ),
          );*/

    /* switch (pageIndex) {
    case 0 :
      pageBG = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                padding: pageIndex == 0
                    ? const EdgeInsets.all(20.0)
                    : EdgeInsets.zero,
                height: 800.h,
                width: pageIndex == 0 ? 392.7 : 200,
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
    case 1 :
      pageBG = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                padding: pageIndex == 0
                    ? const EdgeInsets.all(20.0)
                    : EdgeInsets.zero,
                height: 800.h,
                width: pageIndex == 0 ? 392.7 : 200,
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
    case 2 :
      pageBG = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                padding: pageIndex == 0
                    ? const EdgeInsets.all(20.0)
                    : EdgeInsets.zero,
                height: 800.h,
                width: pageIndex == 0 ? 392.7 : 200,
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
    default:
      bg = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                padding: pageIndex == 0
                    ? const EdgeInsets.all(20.0)
                    : EdgeInsets.zero,
                height: 800.h,
                width: pageIndex == 0 ? 392.7 : 200,
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
      bg, pageBG
    ],
  );*/
  }
}
