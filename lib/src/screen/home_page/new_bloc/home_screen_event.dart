part of 'home_screen_bloc.dart';

class HomeScreenEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeScreenInitialEvent extends HomeScreenEvent {
  final Detail? albumDetail;

  HomeScreenInitialEvent({this.albumDetail});

  @override
  List<Object?> get props => [albumDetail];
}

class DetailViewEvent extends HomeScreenEvent {
  final List<GalleryImage>? galleryImageList;
  final String? pin;
  final String? frontImage;
  final String? albumName;
  final String? albumSong;

  DetailViewEvent({
    required this.galleryImageList,
    this.pin,
    this.frontImage,
    this.albumName,
    this.albumSong,
  });

  @override
  List<Object?> get props => [
        galleryImageList,
        pin,
        frontImage,
        albumName,
        albumSong,
      ];
}

class AddAlbumEvent extends HomeScreenEvent {
  final String? albumCode;

  AddAlbumEvent({this.albumCode});

  @override
  List<Object?> get props => [albumCode];
}
