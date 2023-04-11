part of 'pdf_viewer_bloc.dart';

abstract class PdfViewerEvent {}

class PdfViewerInitialEvent extends PdfViewerEvent {
  final String? albumName;
  final List<GalleryImage>? galleryImageList;
  final String? pin;
  final String? frontImage;
  final bool? isInternetAvail;

  PdfViewerInitialEvent({
    this.albumName,
    this.galleryImageList,
    this.pin,
    this.frontImage,
    this.isInternetAvail,
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
