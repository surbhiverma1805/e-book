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
  final bool? isSlider;
  final bool? isFirstImage;

  PdfViewerShareEvent({
    this.url,
    this.isSlider,
    this.isFirstImage,
  });
}
