part of 'home_screen_bloc.dart';

class HomeScreenState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeScreenInitialState extends HomeScreenState {}

class HomeScreenLoadingState extends HomeScreenState {}

class HomeScreenErrorState extends HomeScreenState {
  final String errorMessage;

  HomeScreenErrorState(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class HomeScreenLoadedState extends HomeScreenState {
  final List<AlbumData>? albumData;
  final List<AllAlbum>? allAlbumList;
  final Detail? albumDetail;

  /// updated requirement
  final AlbumList? albumList;

  HomeScreenLoadedState({
    this.albumData,
    this.allAlbumList,
    this.albumDetail,
    this.albumList,
  });

  @override
  List<Object?> get props => [

        albumData,
        allAlbumList,
        albumDetail,
        albumList,
      ];
}

class ShowDownloading extends HomeScreenState {
  double? percent;

  ShowDownloading(percent);

  @override
  List<Object?> get props => [percent];
}
