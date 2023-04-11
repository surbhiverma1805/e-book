import 'package:ebook/model/photobook.dart';
import 'package:ebook/src/screen/image_viewer/bloc/image_viewer_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ImageViewer extends StatelessWidget {
  const ImageViewer({Key? key, required this.photoBook, required this.pin, this.imagePath}) : super(key: key);

  final PhotoBook photoBook;
  final String pin;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Container();
   /* return BlocProvider(
      create: (context) => ImageViewerBloc().add(ImageViewerInitialEvent()),
      child: BlocConsumer<ImageViewerBloc, ImageViewerState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Container();
        },
      ),
    );*/
    return const Placeholder();
  }
}
