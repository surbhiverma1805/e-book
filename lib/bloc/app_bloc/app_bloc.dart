import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_event.dart';

part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final Connectivity _connectivity = Connectivity();

  AppBloc() : super(AppInitState()) {
    on<AppInitEvent>(_onAppInitEvent);
    on<InternetLossEvent>((event, emit) => emit(InternetLostState()));
    on<InternetGainEvent>((event, emit) => emit(AppLoadedState()));
  }

  FutureOr<void> _onAppInitEvent(
      AppInitEvent event, Emitter<AppState> emit) async {
    /// Call initial api here
    await Future.delayed(const Duration(seconds: 2)).whenComplete(() async {
      _connectivity.onConnectivityChanged.listen((event) {
        if (event == ConnectivityResult.mobile ||
            event == ConnectivityResult.wifi) {
          add(InternetGainEvent());
        } else {
          add(InternetLossEvent());
        }
      });
    });
  }

/*  FutureOr<void> _onAppInitEvent(
      AppInitEvent event, Emitter<AppState> emit) async {

    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      emit(AppLoadedState());
    } else{
      emit(InternetLostState());
      // I am connected to a wifi network.
    }
  }

  FutureOr<void> _onInternetGainEvent(InternetGainEvent event, Emitter<AppState> emit) async {
    /// Call initial api here
    await Future.delayed(const Duration(seconds: 2)).whenComplete(() async {
      _connectivity.onConnectivityChanged.listen((event) {
        if (event == ConnectivityResult.mobile ||
            event == ConnectivityResult.wifi) {
          //add(InternetGainEvent());
          emit(InternetLostState());
        } else {
          emit(AppLoadedState());
          //add(InternetLossEvent());
        }
      });
    });
  }*/
}
