part of 'app_bloc.dart';

abstract class AppState {}

class AppInitState extends AppState {}

class AppLoadedState extends AppState {}

class InternetLostState extends AppState {}