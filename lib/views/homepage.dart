import 'package:ebook/globals/constants.dart';
import 'package:ebook/globals/widgets/custom_txtfield.dart';
import 'package:ebook/models/photobook.dart';
import 'package:ebook/views/pdf_viewer.dart';
import 'package:flip_widget/flip_widget.dart';
import 'package:flutter/material.dart';
import 'package:page_flip/page_flip.dart';
import 'dart:math' as math;
import 'package:turn_page_transition/turn_page_transition.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<PhotoBook> ebookList = [
    PhotoBook(
      id: 0,
      title: 'Wedding Album 1',
      url:
          'https://upsc.gov.in/sites/default/files/Spl-Advt-No-51-2023-engl-250223.pdf',
      // image:
      //     'https://5.imimg.com/data5/SELLER/Default/2020/9/JQ/FO/RS/748292/photo-pad-500x500.jpg',
      image:
          'https://www.happywedding.app/blog/wp-content/uploads/2019/11/Make-your-wedding-album-wonderful-with-these-innovative-ideas.jpg',
    ),
    PhotoBook(
        id: 1,
        title: 'Wedding Album 2',
        url:
            'https://cdnbbsr.s3waas.gov.in/s37bc1ec1d9c3426357e69acd5bf320061/uploads/2023/03/2023030640.pdf',
        image:
            'https://alexandra.bridestory.com/image/upload/assets/1b730f52-8f8e-415e-b229-9af310eeb1ee-SJhIdFsb4.jpg'
        // image: 'https://fotoframe.in/wp-content/uploads/2020/09/3-570x335.png',
        ),
    PhotoBook(
        id: 2,
        title: 'Wedding Album 3',
        url: 'https://www.africau.edu/images/default/sample.pdf',
        image:
            'https://www.zookbinders.com/wp-content/uploads/2020/05/Wedding-Album-Design-2.jpg'

        // image:
        //     'https://www.weddingkathmandu.com/public/images/upload/product/pro-photo-books-albun-kathmandu.jpg',
        ),
    PhotoBook(
        id: 3,
        title: 'RAJK1995',
        url:
            'https://firebasestorage.googleapis.com/v0/b/sales-management-7f835.appspot.com/o/chats%2Fdocs%2FRAJK1995%20EAadhaar_xxxxxxxx0469_04122020202107_021396.pdf?alt=media&token=503e14e4-bb33-4807-95da-9eae247eb279',
        image: 'https://www.milkbooks.com/media/10510/josephpaul-cover.jpg'
        // image:
        //     'https://www.weddingkathmandu.com/public/images/upload/product/pro-photo-books-albun-kathmandu.jpg',
        ),
  ];

  var pinController = TextEditingController();

  var formKey = GlobalKey<FormState>();

  double borderRadius = 20;

  final GlobalKey<FlipWidgetState> _flipKey = GlobalKey();

  addAlbum() {
    // showAboutDialog(context: context);
    // showLicensePage(context: context);
    // showSearch(context: context, delegate: TheSearch());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Album:'),
        content: Row(
          children: const [
            Expanded(child: CustomTextField()),
            Text('-'),
            Expanded(child: CustomTextField()),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.download,
              color: Colors.white,
            ),
            label: const Text(
              'Get',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
                // backgroundColor: Colors.black,
                ),
          )
        ],
      ),
    );
  }

  Offset _oldPosition = Offset.zero;
  bool _visible = true;

  final double _MinNumber = 0.008;
  double _clampMin(double v) {
    if (v < _MinNumber && v > -_MinNumber) {
      if (v >= 0) {
        v = _MinNumber;
      } else {
        v = -_MinNumber;
      }
    }
    return v;
  }

  @override
  Widget build(BuildContext context) {
    Size size = const Size(256, 256);
    return Scaffold(
      appBar: AppBar(
        title: const Text(projectName),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addAlbum();
        },
        child: const Icon(Icons.add),
      ),
      // body: SizedBox(
      //   // height: 260,
      //   child: PageFlipWidget(
      //     // key: _controller,
      //     // backgroundColor: Colors.white,
      //     showDragCutoff: false,
      //     lastPage: const Center(child: Text('Last Page!')),
      //     children: ebookList
      //         .map((e) => Center(
      //                 child: Image.network(
      //               e.image,
      //               fit: BoxFit.cover,
      //             )))
      //         .toList(),
      //   ),
      // ),
      // body: GestureDetector(
      //   onTap: () {
      //     Navigator.of(context).push(
      //       // Use TurnPageRoute instead of MaterialPageRoute.
      //       TurnPageRoute(
      //         overleafColor: Colors.grey,
      //         turningPoint: 0.1,
      //         transitionDuration: const Duration(seconds: 2),
      //         builder: (context) => Scaffold(
      //           appBar: AppBar(),
      //           body: Container(
      //             color: Colors.amber,
      //           ),
      //         ),
      //       ),
      //     );
      //   },
      //   onHorizontalDragStart: (details) {
      //     _oldPosition = details.globalPosition;
      //     _flipKey.currentState?.startFlip();
      //   },
      //   onHorizontalDragUpdate: (details) {
      //     Offset off = details.globalPosition - _oldPosition;
      //     double tilt = 1 / _clampMin((-off.dy + 20) / 100);
      //     double percent = math.max(0, -off.dx / size.width * 1.4);
      //     percent = percent - percent / 2 * (1 - 1 / tilt);
      //     _flipKey.currentState?.flip(percent, tilt);
      //   },
      //   onHorizontalDragEnd: (details) {
      //     _flipKey.currentState?.stopFlip();
      //   },
      //   onHorizontalDragCancel: () {
      //     _flipKey.currentState?.stopFlip();
      //   },
      //   child: FlipWidget(
      //     key: _flipKey,
      //     textureSize: size * 2,
      //     child: Container(
      //       color: Colors.amber,
      //       child: const Center(
      //         child: Text("hello"),
      //       ),
      //     ),
      //   ),
      // ),
      body: GridView.builder(
        padding: const EdgeInsets.all(5),
        // separatorBuilder: (context, index) => const Divider(
        //   color: Colors.grey,
        // ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
        ),
        itemCount: ebookList.length,
        itemBuilder: (context, index) => Container(
          // padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.cyan,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: InkWell(
            onTap: () {
              pdfView(ebookList[index]);
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: Image.network(
                      ebookList[index].image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      // height: 40,
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(borderRadius)),
                      ),
                      child: Text(
                        // ebookList[index].split('/').last,
                        ebookList[index].title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
      // // // body: ListView.builder(
      //   // separatorBuilder: (context, index) => const Divider(
      //   //   color: Colors.grey,
      //   // ),
      //   itemCount: ebookList.length,
      //   itemBuilder: (context, index) => ListTile(
      //     onTap: () {
      //       pdfView(ebookList[index]);
      //     },
      //     title: Text(ebookList[index].split('/').last),
      //   ),
      // ),
    );
  }

  Future<dynamic> pdfView(PhotoBook photoBook) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter PIN:'),
        content: Row(
          children: [
            Expanded(
                child: Form(
              key: formKey,
              child: CustomTextField(
                controller: pinController,
                hintText: 'PIN',
                validator: (value) {
                  if (value!.trim().isEmpty) {
                    return 'PIN can not be empty';
                  }
                  return null;
                },
              ),
            )),
            // Text('-'),
            // Expanded(child: CustomTextField()),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PDFViewer(
                    photoBook: photoBook,
                    pin: pinController.text,
                  ),
                ));
              }
            },
            icon: const Icon(
              Icons.download,
              color: Colors.white,
            ),
            label: const Text(
              'Get',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
                // backgroundColor: Colors.black,
                ),
          )
        ],
      ),
    );
  }
}

// class TheSearch extends SearchDelegate<String> {
//   // TheSearch({this.contextPage, this.controller});

//   // BuildContext contextPage;
//   // WebViewController controller;
//   final suggestions1 = ["https://www.google.com"];

//   @override
//   String get searchFieldLabel => "Enter a web address";

//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: Icon(Icons.clear),
//         onPressed: () {
//           query = "";
//         },
//       )
//     ];
//   }

//   @override
//   Widget? buildLeading(BuildContext context) {
//     // TODO: implement buildLeading
//     // throw UnimplementedError();
//     return Icon(Icons.search);
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     // TODO: implement buildResults
//     // throw UnimplementedError();
//     return Icon(Icons.abc);
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     // TODO: implement buildSuggestions
//     // throw UnimplementedError();
//     return Text(suggestions1.first);
//   }
// }
