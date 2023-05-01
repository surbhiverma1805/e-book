part of 'pdf_viewer_bloc.dart';

abstract class PdfViewerEvent {}

class PdfViewerInitialEvent extends PdfViewerEvent {
  final String? albumName;
  final List<GalleryImage>? galleryImageList;
  final String? frontImage;
  final bool? isInternetAvail;
  final String? songName;

  PdfViewerInitialEvent({
    this.albumName,
    this.galleryImageList,
    this.frontImage,
    this.isInternetAvail,
    this.songName,
  });
}

class PdfViewerShareEvent extends PdfViewerEvent {
  final String? url;

  PdfViewerShareEvent({
    this.url,
  });
}

class SlideShowEvent extends PdfViewerEvent {
  final bool? isSlider;
  SlideShowEvent({this.isSlider});
}

class NextPrevButtonEvent extends PdfViewerEvent {
  final int pageNumber;
  NextPrevButtonEvent({required this.pageNumber});
}