import 'package:ebook/src/screen/download_image.dart';
import 'package:ebook/src/screen/home_page/home_view.dart';
import 'package:ebook/src/screen/pdf_view/pdf_view.dart';
import 'package:ebook/src/screen/pdf_view/pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

///Routes name
///Add new screen here with their path name

class AppRoutes {
  static const String homeView = "/";
  static const String pdfViewerView = "/pdfViewerView";
  static const String pdfView = "/pdfView";
  static const String downloadImage = "/downloadImage";

  static final GoRouter router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: homeView,
        name: homeView,
        builder: (context, state) {
          return HomeView();
        },
      ),
      GoRoute(
        path: pdfViewerView,
        name: pdfViewerView,
        builder: (context, state) {
          var data = state.extra as Map?;
          return PDFViewer(
            photoBook: data?['photo_book'],
            pin: data?['pin'],
          );
        },
      ),
/*      GoRoute(
          path: pdfView,
          name: pdfView,
          pageBuilder: (BuildContext context, GoRouterState state) {
            var data = state.extra as Map?;
            return CustomTransitionPage<void>(
                key: state.pageKey,
                child: PdfView(
                  albumName: data?['album_name'],
                  galleryImageList: data?['gallery_image_list'],
                  pin: data?['list_len'],
                  frontImage: data?['front_image'],
                ),
                transitionDuration: const Duration(milliseconds: 150),
                transitionsBuilder: (BuildContext context,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation,
                    Widget child) {
                  return FadeTransition(
                    opacity:
                        CurveTween(curve: Curves.easeInOut).animate(animation),
                    child: child,
                  );
                });
          }),*/
         GoRoute(
        path: pdfView,
        name: pdfView,
        builder: (context, state) {
          var data = state.extra as Map?;
          return PdfView(
            albumName: data?['album_name'],
            galleryImageList: data?['gallery_image_list'],
            pin: data?['list_len'],
            frontImage: data?['front_image'],
          );
        },
      ),
      GoRoute(
          path: downloadImage,
          name: downloadImage,
          builder: (context, state) {
            return const DownloadImage();
          })
    ],
  );
}