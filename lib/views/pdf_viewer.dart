import 'package:ebook/models/photobook.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:ebook/globals/widgets/appbar.dart';
import 'package:ebook/globals/widgets/loader.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:turn_page_transition/turn_page_transition.dart';

class PDFViewer extends StatefulWidget {
  final PhotoBook photoBook;
  final String pin;
  const PDFViewer({super.key, required this.photoBook, required this.pin});

  @override
  State<PDFViewer> createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {
  int? pages;
  bool isReady = false;
  String filename = '';
  Future<File>? createFileOfPdfUrlApi;
  final progressNotifier = ValueNotifier<double?>(0);

  var defaultPage = 0;

  var pdfViewerController = PdfViewerController();

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
      final url = widget.photoBook.url;
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
      // print(counter);
      pdfViewerController.nextPage();
      // Navigator.of(context).push(
      //   // Use TurnPageRoute instead of MaterialPageRoute.
      //   TurnPageRoute(
      //     overleafColor: Colors.grey,
      //     turningPoint: 0.1,
      //     transitionDuration: const Duration(seconds: 2),
      //     builder: (context) =>
      //         PDFViewer(photoBook: widget.photoBook, pin: widget.pin),
      //   ),
      // );
      // counter--;
      if (pdfViewerController.pageCount == pdfViewerController.pageNumber) {
        print('Cancel timer');
        timer.cancel();
      }
    });
  }

  stopSlideShow() {
    _timer!.cancel();
  }

  @override
  void initState() {
    createFileOfPdfUrlApi = createFileOfPdfUrl();
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
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: isReady
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                    onPressed: () {
                      slideShow();
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Slide Show')),
                ElevatedButton.icon(
                    onPressed: () {
                      stopSlideShow();
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop Slide Show')),
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
      appBar: CustomAppBar(
        title: filename,
        actions: [
          IconButton(
              onPressed: () {
                Share.share(widget.photoBook.url);
              },
              icon: const Icon(Icons.share))
        ],
      ),
      body: FutureBuilder(
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
              return Center(child: Text(snapshot.error.toString()));
            }
            return const Loader();
          }),
    );
  }
}
