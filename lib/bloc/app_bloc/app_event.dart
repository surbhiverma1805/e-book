part of 'app_bloc.dart';


class AppEvent extends Equatable{
  @override
  List<Object?> get props => [];
}
class AppInitEvent extends AppEvent {}

class AppLoadingEvent extends AppEvent {}

class InternetLossEvent extends AppEvent {}

class InternetGainEvent extends AppEvent {}