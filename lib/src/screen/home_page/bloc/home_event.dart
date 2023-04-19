part of 'home_bloc.dart';

abstract class HomeEvent {}

class HomeInitialEvent extends HomeEvent {
  final bool? isInternetAvail;

  HomeInitialEvent({
    this.isInternetAvail,
  });
}

class AddAlbumEvent extends HomeEvent {}

class GoToPdfViewEvent extends HomeEvent {
  final List<GalleryImage>? galleryImageList;
  final String? pin;
  final String? frontImage;
  final String? albumName;
  final String? albumSong;

  GoToPdfViewEvent({
    required this.galleryImageList,
    this.pin,
    this.frontImage,
    this.albumName,
    this.albumSong,
  });
}
