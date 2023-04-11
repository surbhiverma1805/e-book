import 'dart:async';
import 'dart:io';

import 'package:ebook/bloc/app_bloc/app_bloc.dart';
import 'package:ebook/model/album_list_resp.dart';
import 'package:ebook/src/screen/flip_page_builder.dart';
import 'package:ebook/src/screen/pdf_view/bloc/pdf_viewer_bloc.dart';
import 'package:ebook/src/utils/app_colors.dart';
import 'package:ebook/src/widgets/app_images.dart';
import 'package:ebook/src/widgets/appbar.dart';
import 'package:ebook/utility/constants.dart';
import 'package:flip_book/flip_book.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final String? pin, frontImage;

  @override
  State<PdfView> createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  FlipBookController? flipBookController;
  Timer? _timer;
  int index = 0;
  int? totalPage;

  @override
  void initState() {
    super.initState();
    flipBookController =
        FlipBookController(initialPage: 0, totalPages: 34);
   // flipBookController?.isFullScreen = true;
    flipBookController?.toggleFullScreen();
  }

  void slideShow(BuildContext context) {
    Timer.periodic(const Duration(seconds: 2), (timer) {
      _timer = timer;
      //print(timer.tick);
      /*if (flipBookController?.initialPage == 0) {
        flipBookController?.toggleFullScreen();
      }*/
      flipBookController!.animateTo(index,
          duration: const Duration(seconds: 3), curve: Curves.bounceInOut);
      index++;
      debugPrint(
          "____index val : $index : ${imageList.length}");
      if (index > 34) {
        debugPrint('Cancel timer');
        index = 0;
        timer.cancel();
        _timer!.cancel();
        BlocProvider.of<PdfViewerBloc>(context)
            .add(PdfViewerShareEvent(isSlider: false, isFirstImage: false));
      }
    });
  }

  stopSlideShow(BuildContext context) {
    _timer!.cancel();
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
          pin: widget.pin,
          frontImage: widget.frontImage,
          isInternetAvail: isInternetAvail,
        )),
      child: BlocConsumer<PdfViewerBloc, PdfViewerState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is PdfViewerLoaded) {
              totalPage = state.imageList?.length;
              print("loading ${state.isLoading}");
              return Scaffold(
                backgroundColor: Colors.white,
                appBar: CustomAppBar(
                  title: "Slider",
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
                bottomNavigationBar: state.isLoading ?? false
                    ? const SizedBox.shrink()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          state.isSlider ?? false
                              ? playStopButton(
                                  btnName: Constants.stopSlideShow,
                                  iconName: Icons.stop,
                                  onPressed: () {
                                    stopSlideShow(context);
                                  },
                                )
                              : playStopButton(
                                  btnName: Constants.slideShow,
                                  iconName: Icons.play_arrow,
                                  onPressed: () {
                                    slideShow(context);
                                    BlocProvider.of<PdfViewerBloc>(context).add(
                                        PdfViewerShareEvent(isSlider: true));
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
                    : Column(
                        children: [
                          Expanded(
                              // child: state.isSlider ?? false
                              child: state.isSlider ?? false
                                ? FlipBook.builder(
                                      pageBuilder: (context, pageSize ,
                                          pageIndex, semanticPageName) {
                                        print("page index $pageIndex : $pageSize $size");
                                        return flipBookWidget(
                                          pageIndex: pageIndex,
                                          galleryImageList:
                                              state.galleryImageList,
                                          imageList: state.imageList,
                                          size: pageSize,
                                        );
                                      },
                                      controller: flipBookController,
                                      totalPages: state.imageList?.length ?? 10,
                                      // totalPages: state.galleryImageList
                                      //         ?.length ??
                                      //     0,
                                      onPageChanged: (i) {
                                        debugPrint("on page changed : $i");
                                      },
                                    )
                                  : state.isFirstImage ?? false
                                      ? AppLocalFileImage(
                                          imageUrl: state.frontImage ?? "",
                                          fit: BoxFit.contain,
                                        )
                                      : AppLocalFileImage(
                                          imageUrl: state.frontImage ?? "",
                                          fit: BoxFit.contain,
                                        )
                              /* : Image.asset(
                                      AppAssets.image6,
                                      width:
                                          MediaQuery.of(context).size.width,
                                      fit: BoxFit.contain,
                                    ),*/
                              )
                        ],
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
  Widget pageBody = const SizedBox.shrink();

  /*  bg = AppCachedNetworkImage(
          imageUrl:
              "${ApiMethods.imageBaseUrl}${galleryImageList?[index].imageName}",
          fit: BoxFit.contain,
        );*/

  /*bg = Container(
            height: MediaQuery.of(context).size.height,
            width: 300,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(imageList[pageIndex]), fit: BoxFit.cover),
              ),
            );*/
  /* switch (pageIndex) {
  case 0:
  bg = Column(
  children: [
  Expanded(
  child: Container(
  height: size?.height ?? 500,
  width: size?.width ?? 300,
  decoration: BoxDecoration(
  image: DecorationImage(
  image: NetworkImage(
  "${ApiMethods.imageBaseUrl}${galleryImageList?[index].imageName}")
  //image: AssetImage(imageList[pageIndex]), fit: BoxFit.cover),
  ),
  )),
  ),
  ],
  );
  break;

  case 1:
  bg = Container(
  height: MediaQuery.of(context).size.height,
  width: MediaQuery.of(context).size.width,
  decoration: BoxDecoration(
  image: DecorationImage(
  image: AssetImage(imageList[pageIndex]),
  fit: BoxFit.cover,
  ),
  ),
  );
  break;

  case 2:
  bg = Container(
  height: MediaQuery.of(context).size.height,
  width: MediaQuery.of(context).size.width,
  decoration: BoxDecoration(
  image: DecorationImage(
  image: AssetImage(imageList[pageIndex]), fit: BoxFit.cover),
  ),
  );
  break;

  case 3:
  bg = Container(
  height: MediaQuery.of(context).size.height,
  width: MediaQuery.of(context).size.width,
  decoration: BoxDecoration(
  image: DecorationImage(
  image: AssetImage(imageList[pageIndex]),
  fit: BoxFit.cover,
  ),
  ),
  );
  break;

  case 4:
  bg = Container(
  height: MediaQuery.of(context).size.height,
  width: MediaQuery.of(context).size.width,
  decoration: BoxDecoration(
  image: DecorationImage(
  image: AssetImage(imageList[pageIndex]), fit: BoxFit.cover),
  ),
  );
  break;

  case 5:
  bg = Container(
  height: MediaQuery.of(context).size.height,
  width: MediaQuery.of(context).size.width,
  decoration: BoxDecoration(
  image: DecorationImage(
  image: AssetImage(imageList[pageIndex]), fit: BoxFit.cover),
  ),
  );
  break;

  default:
  pageBody = Container(
  height: MediaQuery.of(context).size.height,
  width: MediaQuery.of(context).size.width,
  color: Colors.white,
  child: const Text("Last page"),
  );
  }*/

  Widget flipBookWidget({
    required int pageIndex,
    List<GalleryImage>? galleryImageList,
    List<String>? imageList,
    Size? size,
  }) {
    return Center(
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: pageIndex == 0
                  ? const EdgeInsets.all(20.0)
                  : EdgeInsets.zero,
              height: 781.1,
              width: pageIndex == 0 ? 392.7 : 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(File(imageList![pageIndex])),
                  fit: BoxFit.cover,
                ),
                // image: AssetImage(imageList[pageIndex]), fit: BoxFit.cover),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

