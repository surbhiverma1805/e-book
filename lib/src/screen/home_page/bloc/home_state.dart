part of 'home_bloc.dart';

abstract class HomeState {}

class HomeInitialState extends HomeState {}

class HomeLoadedState extends HomeState {
  List<PhotoBook>? photoBookList;
  bool? isLoading;
  List<AlbumData>? albumData;
  List<AllAlbum>? allAlbumList;

  HomeLoadedState({
    this.photoBookList,
    this.isLoading = false,
    this.albumData,
    this.allAlbumList,
  });

  HomeLoadedState copyWith({
    List<PhotoBook>? photoBookList,
    bool? isLoading,
    List<AlbumData>? albumData,
    List<AllAlbum>? allAlbumList,
  }) =>
      HomeLoadedState(
        photoBookList: photoBookList ?? this.photoBookList,
        isLoading: isLoading ?? this.isLoading,
        albumData: albumData ?? this.albumData,
        allAlbumList: allAlbumList ?? this.allAlbumList,
      );
}