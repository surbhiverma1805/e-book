import 'package:ebook/src/screen/album_view.dart';
import 'package:ebook/src/screen/home_page/home_screen.dart';
import 'package:ebook/src/screen/details_view.dart';
import 'package:ebook/src/screen/download_image.dart';
import 'package:ebook/src/screen/home_page/home_view.dart';
import 'package:ebook/src/screen/info/info_view.dart';
import 'package:ebook/src/screen/order/order_view.dart';
import 'package:ebook/src/screen/pdf_view/pdf_view.dart';
import 'package:ebook/src/screen/pdf_view/pdf_viewer.dart';
import 'package:ebook/src/screen/splash_view.dart';
import 'package:go_router/go_router.dart';

///Routes name
///Add new screen here with their path name

class AppRoutes {
  static const String splashView = "/";
  static const String homeView = "/homeView";
  static const String homeScreen = "/homeScreen";
  static const String pdfViewerView = "/pdfViewerView";
  static const String pdfView = "/pdfView";
  static const String downloadImage = "/downloadImage";
  static const String detail = "/detail";
  static const String albumView = "/albumView";
  static const String infoView = "/infoView";
  static const String orderView = "/orderView";

  static final GoRouter router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: splashView,
        name: splashView,
        builder: (context, state) {
          return const SplashView();
        },
      ),
      GoRoute(
        path: homeScreen,
        name: homeScreen,
        builder: (context, state) {
          return const HomeScreen();
          //return HomeView();
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
        path: detail,
        name: detail,
        builder: (context, state) {
          var data = state.extra as Map?;
          return DetailsView(
            albumName: data?['album_name'],
            galleryImageList: data?['gallery_image_list'],
            listLength: data?['list_len'],
            frontImage: data?['front_image'],
            detail: data?['detail'],
          );
        },
      ),
      GoRoute(
        path: albumView,
        name: albumView,
        builder: (context, state) {
          var data = state.extra as Map?;
          return AlbumView(
            frontImage: data?['front_image'],
            backImage: data?['back_image'],
            imageList: data?['image_list'],
            isSlideShow: data?['is_slide_show'],
          );
        },
      ),
      GoRoute(
        path: downloadImage,
        name: downloadImage,
        builder: (context, state) {
          return const DownloadImage();
        },
      ),
      GoRoute(
        path: infoView,
        name: infoView,
        builder: (context, state) {
          var data = state.extra as Map?;
          return InfoView(
            detail: data?['detail'],
          );
        },
      ),
      GoRoute(
        path: orderView,
        name: orderView,
        builder: (context, state) {
          var data = state.extra as Map?;
          return OrderView(
            frontImage: data?['front_image'],
            studioName: data?['studio_name'],
          );
        },
      ),
    ],
  );
}
