import 'dart:io';

import 'package:ebook/bloc/bloc_observer.dart';
import 'package:ebook/my_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

List<Image> imageList = <Image>[
  Image.asset(
    "assets/images/image1.jpeg",
    fit: BoxFit.cover,
  ),
  Image.asset(
    "assets/images/image2.jpeg",
    fit: BoxFit.cover,
  ),
  Image.asset(
    "assets/images/image3.jpeg",
    fit: BoxFit.cover,
  ),
  Image.asset(
    "assets/images/image4.jpeg",
    fit: BoxFit.cover,
  ),
  Image.asset(
    "assets/images/image5.jpeg",
    fit: BoxFit.cover,
  ),
  Image.asset(
    "assets/images/image6.jpeg",
    fit: BoxFit.cover,
  ),
];

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true; }}

void main() {
  //await ScreenUtil.ensureScreenSize();
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = MyBlocObserver();
  HttpOverrides.global = MyHttpOverrides();
  runApp( const MyApp());
  // runApp(FlipbookPage(
  //   images: imageList,
  // ));
}

///access token for git
//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
/*
void main() async {
  ensureInitialized([FlipBookLocales.he]);
  runApp(
    MaterialApp(home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => FlipBookControllers()),
        ],
        builder: (context, _) {
          final app = FlipBookView();
          app.build(context);
          return app;
        }),)
  );
}*/
