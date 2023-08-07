part of 'app_bloc.dart';

class AppState extends Equatable{
  @override
  List<Object?> get props => [];
}

class AppInitState extends AppState {}

class AppLoadedState extends AppState {}

class InternetLostState extends AppState {}