import 'dart:async';
import 'dart:io';

import 'package:ebook/model/album_list_resp.dart';
import 'package:ebook/utility/utility.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

part 'pdf_viewer_state.dart';

part 'pdf_viewer_event.dart';

class PdfViewerBloc extends Bloc<PdfViewerEvent, PdfViewerState> {
  PdfViewerBloc() : super(PdfViewerInitial()) {
  //PdfViewerBloc(PdfViewerState pdfViewerInitial) : super(pdfViewerInitial) {
    on<PdfViewerInitialEvent>(_onPdfViewerInitialEvent);
    on<PdfViewerShareEvent>(_onPdfViewerShareEvent);
    on<SlideShowEvent>(_onSlideShowEvent);
    on<NextPrevButtonEvent>(_onNextPrevButtonEvent);
  }

  PdfViewerLoaded get _lastState => state as PdfViewerLoaded;

  FutureOr<void> _onPdfViewerInitialEvent(
      PdfViewerInitialEvent event, Emitter<PdfViewerState> emit) async {
    emit(PdfViewerLoaded(isLoading: true));
    List<String>? imageList = [];
    String? songName;
    var dirPath = "${await Utility.getSavedDir()}/${event.albumName}";
    // var dirPath =
    //     "${await Utility.getSavedDir()}/${await Utility.localFileName(event.albumName)}";

    if (!(await Utility.dirDownloadFileExists(dirName: dirPath))) {
      await Directory(dirPath).create();
      print("directory");
    }

    if (await Utility.checkInternetConnectivity()) {
      /// Download and save audio in local dir from network
      /*  await Utility.saveDownloadedImageToLocal(
      fileName: event.songName,
      albumName: event.albumName,
    );
*/
      event.galleryImageList?.forEach(
        (image) async {
          await Utility.saveDownloadedImageToLocal(
            fileName: image.imageName,
            albumName: event.albumName,
          );
        },
      );
    }

    /// Get downloaded song from local
    //songName = "${await Utility.getSavedDir()}/${event.songName}";
    imageList = await Utility.getDownloaded(
        imgList: event.galleryImageList, postTitle: event.albumName);
    print("img : ${imageList?[0]}");
    imageList?.forEach((element) {
      // print("img : ${imageList?[0]}");
    });

    if ((imageList?.length ?? 0) % 2 != 0) {
      imageList?.removeLast();
      print("this ${imageList?.length}");
    }
    await Future.delayed(const Duration(seconds: 6));
    //await Future.delayed(const Duration(milliseconds: 9000));
    emit(_lastState.copyWith(
      imageList: imageList,
      isLoading: false,
      galleryImageList: event.galleryImageList,
      frontImage: event.frontImage,
    ));
    return;
    if (Directory(dirPath).listSync().length !=
        event.galleryImageList?.length) {
      print("first if");
      if (!await Utility.checkInternetConnectivity()) {
        print("second if");
        //emit(_lastState.copyWith(isLoading: false));
        Utility.showSnackBar(
            "Please connect to the internet to sync the album");
      } else {
        print("else");
        event.galleryImageList?.forEach(
          (image) async {
            await Utility.saveDownloadedImageToLocal(
              fileName: image.imageName,
              albumName: event.albumName,
            );
          },
        );
      }
    }
  }

  Future<void> _onPdfViewerShareEvent(
      PdfViewerShareEvent event, Emitter<PdfViewerState> emit) async {
    print("data____");
    Share.share("Hello this is my first file which I am sharing",
        subject: "Sharing first document");
    emit(_lastState);
  }

  FutureOr<void> _onSlideShowEvent(
      SlideShowEvent event, Emitter<PdfViewerState> emit) {
    print("yeah");
    emit(_lastState.copyWith(isSlider: event.isSlider));
  }

  FutureOr<void> _onNextPrevButtonEvent(
      NextPrevButtonEvent event, Emitter<PdfViewerState> emit) {
    print("new number : ${event.pageNumber}");
    emit(_lastState.copyWith(pageNumber: event.pageNumber));
  }
}
