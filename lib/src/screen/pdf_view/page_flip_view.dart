// import 'package:ebook/src/screen/pdf_view/pdf_viewer.dart';
// import 'package:flutter/material.dart';
// import 'package:page_flip/page_flip.dart';
//
// class PageFlipView extends StatefulWidget {
//   const PageFlipView({Key? key}) : super(key: key);
//
//   @override
//   State<PageFlipView> createState() => _PageFlipViewState();
// }
//
// class _PageFlipViewState extends State<PageFlipView> {
//   final GlobalKey<PageFlipWidgetState> _controller = GlobalKey();
//   var count = 0;
//   List<String> imageList = <String>[
//     "assets/images/image1.jpeg",
//     "assets/images/image2.jpeg",
//     "assets/images/image3.jpeg",
//     "assets/images/image4.jpeg",
//     "assets/images/image5.jpeg",
//     "assets/images/image6.jpeg",
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           ElevatedButton.icon(
//             onPressed: () {
//               //SliderWidget(context: context, imageList: imageList,);
//               //slideShow();
//               slider();
//             },
//             icon: const Icon(Icons.play_arrow),
//             label: const Text('Slide Show'),
//           ),
//           ElevatedButton.icon(
//             onPressed: () {
//               //stopSlideShow();
//             },
//             icon: const Icon(Icons.stop),
//             label: const Text('Stop Slide Show'),
//           ),
//         ],
//       ),
//       body: PageFlipWidget(
//         key: _controller,
//         duration: const Duration(seconds: 10),
//         backgroundColor: Colors.red,
//         showDragCutoff: true,
//         lastPage: Container(
//           color: Colors.white,
//           child: const Center(
//             child: Text('Last Page!'),
//           ),
//         ),
//         children: <Widget>[
//           for (var j = 0; j < imageList.length; j++)
//             SliderImage(
//               imagePath: imageList[count],
//               count: count
//             )
//         ],
//       ),
//     );
//   }
//
//   slider() async {
//     var i = 0;
//     //bool flag = true;
//
//     var futureThatStopsIt = Future.delayed(const Duration(seconds: 0), () {
//       //flag = false;
//     });
//
//     var futureWithTheLoop = () async {
//       while (i < imageList.length) {
//         debugPrint("____before index : $i");
//         i++;
//         setState(() {
//           count = i < imageList.length ? i : 0;
//         });
//         await Future.delayed(const Duration(seconds: 6));
//         //_controller.currentState?.nextPage();
//         _controller.currentState?.reCaptureFlipScreenAgain();
//         //_controller.currentState!.goToPage(i);
//         debugPrint("going on: $i");
//       }
//     }();
//
//     await Future.wait([futureThatStopsIt, futureWithTheLoop]);
//     debugPrint("$i");
//   }
// }
