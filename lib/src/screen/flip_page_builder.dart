import 'dart:async';

import 'package:flutter/material.dart';

List<String> imageList = <String>[
  "assets/images/image1.jpeg",
  "assets/images/image2.jpeg",
  "assets/images/image3.jpeg",
  "assets/images/image4.jpeg",
  "assets/images/image5.jpeg",
  "assets/images/image6.jpeg",
  "assets/images/image1.jpeg",
  "assets/images/image2.jpeg",
  "assets/images/image3.jpeg",
];

Widget flipPageBuilder(context, pageSize, pageIndex, semanticPageName) =>
    LayoutBuilder(builder: (context, constraints) {
      Timer? _timer;
      var counter = imageList.length;
      Widget bg = const SizedBox.shrink();
      Widget pageBody = const SizedBox.shrink();
      final pageBG = Column(
        children: [
          Expanded(child: Container(color: Colors.white)),
        ],
      );

      switch (pageIndex) {
        case 0:
          bg = Container(
            height: MediaQuery.of(context).size.height,
            width: 300,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(imageList[pageIndex]), fit: BoxFit.cover),
            ),
          );
          break;

        case 1:
          bg = Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imageList[pageIndex]),
                fit: BoxFit.cover,
              ),
            ),
          );
          break;

        case 2:
          bg = Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(imageList[pageIndex]), fit: BoxFit.cover),
            ),
          );
          break;

        case 3:
          bg = Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imageList[pageIndex]),
                fit: BoxFit.cover,
              ),
            ),
          );
          break;

        case 4:
          bg = Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(imageList[pageIndex]), fit: BoxFit.cover),
            ),
          );
          break;

        case 5:
          bg = Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(imageList[pageIndex]), fit: BoxFit.cover),
            ),
          );
          break;

        default:
          pageBody = Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: const Text("Last page"),
          );
      }
      return Stack(
        children: [bg, pageBody],
      );
    });
