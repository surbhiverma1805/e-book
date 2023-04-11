import 'package:ebook/my_app.dart';
import 'package:ebook/src/screen/flip_book_controllers.dart';
import 'package:ebook/src/screen/flip_book_view.dart';
import 'package:flip_book/flip_book.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

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
