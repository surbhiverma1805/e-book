import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

part 'image_viewer_event.dart';
part 'image_viewer_state.dart';

class ImageViewerBloc extends Bloc<ImageViewerEvent, ImageViewerState> {
  ImageViewerBloc() : super(ImageViewerInitial()) {
    on<ImageViewerEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
