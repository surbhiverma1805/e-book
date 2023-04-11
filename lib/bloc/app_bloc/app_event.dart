part of 'app_bloc.dart';

abstract class AppEvent {}

class AppInitEvent extends AppEvent {}

class AppLoadingEvent extends AppEvent {}

class InternetLossEvent extends AppEvent {}

class InternetGainEvent extends AppEvent {}