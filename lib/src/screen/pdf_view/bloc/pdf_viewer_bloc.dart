import 'dart:async';
import 'dart:io';

import 'package:ebook/model/album_list_resp.dart';
import 'package:ebook/utility/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'pdf_viewer_state.dart';

part 'pdf_viewer_event.dart';

class PdfViewerBloc extends Bloc<PdfViewerEvent, PdfViewerState> {
  PdfViewerBloc() : super(PdfViewerInitial()) {
    on<PdfViewerInitialEvent>(_onPdfViewerInitialEvent);
    on<PdfViewerShareEvent>(_onPdfViewerShareEvent);
  }

  PdfViewerLoaded get _lastState => state as PdfViewerLoaded;

  FutureOr<void> _onPdfViewerInitialEvent(
      PdfViewerInitialEvent event, Emitter<PdfViewerState> emit) async {
    //emit(PdfViewerLoaded(isLoading: true));
    emit(PdfViewerLoaded(isLoading: true));
    List<String>? imageList = [];
    var dirPath = "${await Utility.getSavedDir()}/${event.albumName}";

    print("here");
    if (!(await Utility.dirDownloadFileExists(dirName: dirPath))) {
      await Directory(dirPath).create();
      print("directory");
    }

    event.galleryImageList?.forEach(
          (image) async {
        await Utility.saveDownloadedImageToLocal(
          imageName: image.imageName,
          albumName: event.albumName,
        );
      },
    );

    imageList = await Utility.getDownloaded(
        imgList: event.galleryImageList, postTitle: event.albumName);
    imageList?.forEach((element) {
      print("img : $element");
    });
    debugPrint("surbhi ${imageList?[0] ?? "hello"} ${imageList?.length}");

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
              imageName: image.imageName,
              albumName: event.albumName,
            );
          },
        );
      }
    }
  }

  Future<void> _onPdfViewerShareEvent(
      PdfViewerShareEvent event, Emitter<PdfViewerState> emit) async {
    /*Share.share(event.url ?? "");
    emit(_lastState);*/
    emit(_lastState.copyWith(
      isSlider: event.isSlider,
      isFirstImage: event.isFirstImage,
    ));
  }
}
