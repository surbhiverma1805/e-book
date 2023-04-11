import 'package:ebook/src/screen/en_page_builder.dart';
import 'package:ebook/src/screen/flip_page_builder.dart';
import 'package:flip_book/flip_book.dart';
import 'package:flutter/material.dart';

class BookView extends StatefulWidget {
  const BookView({Key? key}) : super(key: key);

  @override
  State<BookView> createState() => _BookViewState();
}

class _BookViewState extends State<BookView> {
  FlipBookController flipBookController = FlipBookController(totalPages: 9);
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    int listLength = imageList.length - 1;
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: FlipBook.builder(
                pageBuilder: flipPageBuilder,
                //addAutomaticKeepAlives: true,
                totalPages: listLength,
                onPageChanged: (i) {
                  print("on page changed : $i");
                },
                controller: flipBookController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
