import 'package:ebook/bloc/app_bloc/app_bloc.dart';
import 'package:ebook/model/photobook.dart';
import 'package:ebook/src/screen/flip_page_builder.dart';
import 'package:ebook/src/screen/pdf_view/custom_flip_book/widget/book.dart';
import 'package:ebook/src/screen/pdf_view/custom_flip_book/controller/book_controller.dart';
import 'package:ebook/src/screen/pdf_view/bloc/pdf_viewer_bloc.dart';
import 'package:ebook/src/widgets/appbar.dart';
import 'package:ebook/src/widgets/internet_lost_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PDFViewer extends StatefulWidget {
  final PhotoBook? photoBook;
  final String? pin;
  final String? imagePath;
  final bool? isSlider;

  const PDFViewer(
      {super.key,
      required this.photoBook,
      required this.pin,
      this.imagePath,
      this.isSlider});

  @override
  State<PDFViewer> createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {
  int? pages;

  bool? isSlider;
  bool? isFirstPage = true;

  //bool isReady = false;
  bool isReady = true;
  String filename = '';
  Future<File>? createFileOfPdfUrlApi;
  final progressNotifier = ValueNotifier<double?>(0);

  //final GlobalKey<PageFlipWidgetState> _controller = GlobalKey();

  var defaultPage = 0;

  int index = 0;

  //var pdfViewerController = PdfViewerController();

  FlipBookController flipBookController = FlipBookController(totalPages: 6);

  List<String> imageList = <String>[
    "assets/images/image1.jpeg",
    "assets/images/image2.jpeg",
    "assets/images/image3.jpeg",
    "assets/images/image4.jpeg",
    "assets/images/image5.jpeg",
    "assets/images/image6.jpeg",
  ];

  Future<File> _getFile(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$filename');
  }

  Future<File> createFileOfPdfUrl() async {
    Completer<File> completer = Completer();
    print("Start download file from internet!");
    try {
      // "https://berlin2017.droidcon.cod.newthinking.net/sites/global.droidcon.cod.newthinking.net/files/media/documents/Flutter%20-%2060FPS%20UI%20of%20the%20future%20%20-%20DroidconDE%2017.pdf";
      // final url = "https://pdfkit.org/docs/guide.pdf";
      // const url = "http://www.pdf995.com/samples/pdf.pdf";
      final url = widget.photoBook?.url ?? "";
      filename = url.substring(url.lastIndexOf("/") + 1);
      // var request = await HttpClient().getUrl(Uri.parse(url));
      final request = Request('GET', Uri.parse(url));
      final StreamedResponse response = await Client().send(request);
      // print(response.statusCode);
      final contentLength = response.contentLength;

      progressNotifier.value = 0;

      List<int> bytes = [];

      // var response = await request.close();
      final file = await _getFile(filename);
      debugPrint(file.toString());

      response.stream.listen(
        (List<int> newBytes) {
          bytes.addAll(newBytes);
          final downloadedLength = bytes.length;
          progressNotifier.value = downloadedLength / contentLength!;
        },
        onDone: () async {
          // progressNotifier.value = 0;
          await file.writeAsBytes(bytes);
          isReady = true;
          print("Downloaded");
          setState(() {});
        },
        onError: (e) {
          debugPrint(e);
        },
        cancelOnError: true,
      );
      // var bytes = await consolidateHttpClientResponseBytes(response);
      // var dir = await getApplicationDocumentsDirectory();
      // print("Download files");
      // print("${dir.path}/$filename");
      // File file = File("${dir.path}/$filename");

      // await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      // throw Exception('Error parsing asset file!');
      throw Exception(e);
    }

    return completer.future;
  }

  // final manager = StateManager();
  Timer? _timer;

  slideShow() {
    // var counter = pdfViewerController.pageCount;
    Timer.periodic(const Duration(seconds: 2), (timer) {
      _timer = timer;
      print(timer.tick);
      print("_index  $index ${imageList.length}");
      //pdfViewerController.nextPage();
      //flipBookController.jumpTo(4);
      flipBookController.animateTo(index,
          duration: const Duration(seconds: 3), curve: Curves.bounceInOut);
      /*Navigator.of(context).pushReplacement(
        // Use TurnPageRoute instead of MaterialPageRoute.
        TurnPageRoute(
          opaque: false,
          overleafColor: Colors.black87,
          turningPoint: 0.9,
          fullscreenDialog: false,
          transitionDuration: const Duration(seconds: 2),
          builder: (context) => SliderImage(
            imagePath: imageList[index],
            count: index,
          ),
          // builder: (context) => PDFViewer(
          //     photoBook: widget.photoBook,
          //     pin: widget.pin,
          //     imagePath: imageList[index],
          //     isSlider: false),
          //Image.asset(imageList[index])
        ),
      );*/
      // counter--;
      setState(() {
        index++;
        debugPrint("____index val : $index : ${imageList.length}");
      });
      //SliderWidget(context: context, imageList: imageList,);
      //if (pdfViewerController.pageCount == imageList.length - 1) {
      if (index > imageList.length) {
        print('Cancel timer');
        isSlider = false;
        //_controller.currentState?.goToPage(index);
        timer.cancel();
      }
    });
  }

  stopSlideShow() {
    _timer!.cancel();
  }

  slider() async {
    var i = 0;
    bool flag = true;

    var futureThatStopsIt = Future.delayed(const Duration(seconds: 0), () {
      //flag = false;
    });

    var futureWithTheLoop = () async {
      while (i < 5) {
        debugPrint("____before index : $i");
        i++;
        await Future.delayed(const Duration(seconds: 6));
        //_controller.currentState!.goToPage(i);
        print("going on: $i");
      }
    }();

    await Future.wait([futureThatStopsIt, futureWithTheLoop]);

    print(i);
  }

  @override
  void initState() {
    if (widget.isSlider == true) createFileOfPdfUrlApi = createFileOfPdfUrl();
    // Future.delayed(const Duration(seconds: 4)).whenComplete(() {
    //   setState(() {
    //     defaultPage = 5;
    //   });
    //   print(defaultPage);
    // });

    // manager.startDownloading(widget.path);
    super.initState();
  }

  @override
  void dispose() {
    if (_timer != null) _timer!.cancel();
    flipBookController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppBloc, AppState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is InternetLostState) {
            return const InternetLostWidget();
          } else {
            return BlocProvider(
              create: (context) =>
                  PdfViewerBloc()..add(PdfViewerInitialEvent()),
              child: BlocConsumer<PdfViewerBloc, PdfViewerState>(
                  listener: (context, state) {},
                  builder: (context, state) {
                    return Scaffold(
                        backgroundColor: Colors.red,
                        bottomNavigationBar: isReady
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      //SliderWidget(context: context, imageList: imageList,);
                                      setState(() {
                                        isSlider = true;
                                        isFirstPage = true;
                                      });
                                      slideShow();
                                      //slider();
                                    },
                                    icon: const Icon(Icons.play_arrow),
                                    label: const Text('Slide Show'),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      stopSlideShow();
                                    },
                                    icon: const Icon(Icons.stop),
                                    label: const Text('Stop Slide Show'),
                                  ),
                                ],
                              )
                            : Container(
                                padding: const EdgeInsets.all(20),
                                height: 80,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Downloading album: '),
                                    ValueListenableBuilder<double?>(
                                      valueListenable: progressNotifier,
                                      builder: (context, percent, child) {
                                        return Row(
                                          children: [
                                            Expanded(
                                              child: LinearProgressIndicator(
                                                // strokeWidth: 20,
                                                value: percent,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                                "${((percent ?? 0.00) * 100).toStringAsFixed(2)} %"),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                        // floatingActionButton: FloatingActionButton(onPressed: () {
                        //   showDialog(
                        //     context: context,
                        //     builder: (context) => Dialog(
                        //       child: Center(
                        //         child: SizedBox(
                        //           width: 100,
                        //           height: 100,
                        //           child: ValueListenableBuilder<double?>(
                        //             valueListenable: manager.progressNotifier,
                        //             builder: (context, percent, child) {
                        //               return CircularProgressIndicator(
                        //                 strokeWidth: 20,
                        //                 value: percent,
                        //               );
                        //             },
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   );
                        // }),
                        appBar: isSlider == true
                            ? AppBar()
                            : CustomAppBar(
                                title: filename,
                                actions: [
                                  IconButton(
                                      onPressed: () {
                                        Share.share(
                                            widget.photoBook?.url ?? "");
                                      },
                                      icon: const Icon(Icons.share))
                                ],
                              ),
                        body: Column(
                          children: [
                            Expanded(
                              child: isSlider ?? false
                                  ? FlipBook.builder(
                                      pageSize: MediaQuery.of(context).size,
                                      pageBuilder: flipPageBuilder,
                                      totalPages: 6,
                                      onPageChanged: (i) {
                                        print("on page changed : $i");
                                      },
                                      controller: flipBookController,
                                    )
                                  : Image.asset(
                                      isFirstPage ?? false
                                          ? "assets/images/image1.jpeg"
                                          : "assets/images/image6.jpeg",
                                      width: MediaQuery.of(context).size.width,
                                      fit: BoxFit.contain,
                                    ),
                            ),
                          ],
                        )
                        /*  body: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.60,
                        width: MediaQuery.of(context).size.width ,
                        child: PageFlipWidget(
                          //cutoff: 8,
                          duration: const Duration(seconds: 6),
                          key: _controller,
                          backgroundColor: Colors.white,
                          showDragCutoff: true,
                          lastPage: const Center(child: Text('Last Page!')),
                          children: [
                            for (var i = 0; i < imageList.length ; i++)
                              SliderImage(imagePath: imageList[i]),
                          ],
                        ),
                      ),*/
                        /*body: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: SliderImage(
                          imagePath: imageList[index],
                        ),
                      ),*/
                        //body: SliderWidget(context: context, imageList: imageList,),
                        /* body: FutureBuilder(
                          future: createFileOfPdfUrlApi,
                          builder: (context, AsyncSnapshot<File> snapshot) {
                            if (snapshot.hasData) {
                              // return PspdfkitWidget(
                              //   documentPath: snapshot.data!.path,
                              // );
                              return SfPdfViewer.file(
                                snapshot.data!,
                                controller: pdfViewerController,
                                scrollDirection: PdfScrollDirection.horizontal,
                                pageLayoutMode: PdfPageLayoutMode.single,
                                password: widget.pin,
                              );
                              //   return PDFView(
                              //     filePath: snapshot.data!.path,
                              //     enableSwipe: true,
                              //     swipeHorizontal: true,
                              //     autoSpacing: true,
                              //     pageFling: true,
                              //     defaultPage: defaultPage,
                              //     password: widget.pin,
                              //     // preventLinkNavigation: true,
                              //     // nightMode: true,
                              //     onRender: (page) {
                              //       setState(() {
                              //         pages = page;
                              //         isReady = true;
                              //       });
                              //     },
                              //     onError: (error) {
                              //       print(error.toString());
                              //     },
                              //     onPageError: (page, error) {
                              //       print('$page: ${error.toString()}');
                              //     },
                              //     onViewCreated: (PDFViewController pdfViewController) {
                              //       // _controller.complete(pdfViewController);
                              //     },
                              //     onPageChanged: (page, total) {
                              //       print('page change: $page/$total');
                              //     },
                              //   );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text(snapshot.error.toString()));
                            }
                            return const Loader();
                          }),*/
                        );
                  }),
            );
          }
        });
  }
}

class SliderImage extends StatelessWidget {
  const SliderImage({Key? key, this.imagePath, this.count}) : super(key: key);

  final String? imagePath;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(12.0),
          color: count == 0
              ? Colors.deepPurple
              : count == 1
                  ? Colors.green
                  : count == 2
                      ? Colors.teal
                      : count == 3
                          ? Colors.blue
                          : Colors.cyan,
          child: Image.asset(
            imagePath ?? "",
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
