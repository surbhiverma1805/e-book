import 'dart:io';

import 'package:ebook/app_route/app_router.dart';
import 'package:ebook/bloc/app_bloc/app_bloc.dart';
import 'package:ebook/model/album_detail_resp.dart';
import 'package:ebook/model/album_list.dart';
import 'package:ebook/model/album_list_resp.dart';
import 'package:ebook/model/all_album.dart';
import 'package:ebook/src/screen/home_page/new_bloc/home_screen_bloc.dart';
import 'package:ebook/src/screen/other/custom_page_curl.dart';
import 'package:ebook/src/utils/app_assets.dart';
import 'package:ebook/src/utils/extension/space.dart';
import 'package:ebook/src/utils/extension/text_style_decoration.dart';
import 'package:ebook/src/widgets/app_images.dart';
import 'package:ebook/src/widgets/custom_txtfield.dart';
import 'package:ebook/utility/constants.dart';
import 'package:ebook/utility/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:path/path.dart' as path;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppBloc appBloc = AppBloc(AppInitState());
  HomeScreenBloc homeScreenBloc = HomeScreenBloc(HomeScreenInitialState());

  final TextEditingController codeController = TextEditingController();

  List<AllAlbum>? allAlbumList = [];
  List<AlbumData>? albumData = [];

  List<Detail?>? albumDetailList = [];
  AlbumList? albumList;
  List<AlbumListElement>? finalAlbList;
  List<String> finalList = [];

  Detail? albumDetail;

  double downloadProgress = 0;
  int contentLength = 0;

  bool? isLoading;

  /// value between 0 - 1 (shows progress, 0=0%, 1=100%)
  /// if null -> infinite spinning
  /// if value goes above 1 -> shows full circle like 1
  /// if 0 -> progress disappears
  double? progress;
  double newProgress = 0.0;

  String status = "";
  int downloadingLength = 0;
  int totalContentLength = 0;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
    homeScreenBloc.add(HomeScreenInitialEvent());
  }

  Future downloadImageList(Detail? albDetail, String? dirPath) async {
/*    setState(() {
      progress = 0;
      status = "Downloading...";
    });*/
    debugPrint("hello ${albDetail?.albumImage?.length}");
    var dir = await Utility.getSavedDir();

    albDetail?.albumImage?.forEach((img) async {
      /*  final request = http.Request('GET', Uri.parse(img));
      final response = await http.Client().send(request);
      contentLength += response.contentLength!;*/
      final downloadedImg = await http.get(Uri.parse(img));

      debugPrint("imag path $img");

      print("exist123 ${!(await Utility.dirDownloadFileExists(
          dirName: dirPath))}");

      /// check if allAlbums sub dir exist or not and if not then create
      if (!(await Utility.dirDownloadFileExists(
          dirName: dirPath))) {
        await Directory(dirPath!)
            .create();
      }
      var file = File(path.join(
          dirPath!,
          img
              .split("/")
              .last));
      //await file.writeAsBytes(request.bodyBytes);
      await file.writeAsBytes(downloadedImg.bodyBytes);
      debugPrint("img --> ${file.path}");
      final bytes = <int>[];
      /*   response.stream.listen(
        (streamedBytes) {
          bytes.addAll(streamedBytes);
          setState(() {
            //downloadProgress += bytes.length / contentLength;
          });
          print("%% $downloadProgress");
          //Utility.showDownloadProgressIndicator(downloadProgress);
        },
        onDone: () async {
          setState(() {
            //downloadProgress = 1;
          });
        },
        cancelOnError: true,
      );*/
    });

    final request = http.Request('GET', Uri.parse(albDetail?.albumPdf ?? ""));
    final response = await http.Client().send(request);
    contentLength += response.contentLength!;
    if (!(await Utility.dirDownloadFileExists(
        dirName: "$dir/${Constants.allAlbums}/${albDetail?.name}/pdf"))) {
      await Directory("$dir/${Constants.allAlbums}/${albDetail?.name}/pdf")
          .create();
    }

    var file = File(path.join(
        "$dir/${Constants.allAlbums}/${albDetail?.name}/pdf",
        "${albDetail?.name}.pdf"));
    final bytes = <int>[];
    response.stream.listen(
          (streamedBytes) {
        bytes.addAll(streamedBytes);
        setState(() {
          downloadProgress += bytes.length / contentLength;
        });
        //Utility.showDownloadProgressIndicator(downloadProgress);
      },
      onDone: () async {
        setState(() {
          //downloadProgress = 1;
        });
      },
      cancelOnError: true,
    );
    debugPrint("tue : ${file.path}");
    /*  setState(() {
      progress = 1;
      status = "Downloaded";
    });*/
  }

  Future _downloadButtonPressed({
    required String url,
    required String folderPath,
    required String filePath,
    int? length,
  }) async {
    /// when download first called it takes a bit of time to communicate with server.
    /// While that is happening, make circle just spin eternally
    setState(() {
      progress = null;
      isLoading = true;
    });

    final request = Request('GET', Uri.parse(url));

    /// calling Client().send() instead of get(url) method.
    /// Reason: send() gives you a stream, and you’re going to listen to the
    /// stream of bytes as it downloads the file from the server
    final StreamedResponse response = await Client().send(request);

    /// response coming from the server contains a header called Content-Length,
    /// which includes the total size of the file in bytes
    final contentLength = response.contentLength;

    /// content length

    /// Now that we have response from server, stop the spinning indicator & set it to 0
    setState(() {
      progress = 0.000001;
      status = "Download Started";
    });

    /// Initialize variable to save the download in.
    /// Array stores the file in memory before you save to storage.
    /// Since the length of this array is the number of bytes that have been
    /// downloaded, use this to track the progress of the download.
    List<int> bytes = [];

    /// place to store the file
    //final file = await _getFile('video.mp4');

    var dir = await Utility.getSavedDir();

    if (!(await Utility.dirDownloadFileExists(dirName: folderPath))) {
      await Directory(folderPath).create();
    }

    var file = File(path.join(filePath));

    response.stream.listen(
          (List<int> newBytes) {
        // update progress
        bytes.addAll(newBytes);
        final downloadedLength = bytes.length;
        setState(() {
          // downloadingLength += bytes.length;
          // totalContentLength += contentLength!;
          // progress = downloadingLength.toDouble() / totalContentLength;
          progress = downloadedLength.toDouble() / (contentLength ?? 1);
          //progress = newProgress / (length ?? 0);
          status = "${((progress ?? 0) * 100).toStringAsFixed(2)} %";
        });
        debugPrint("status: $status");
      },
      onDone: () async {
        // save file
        setState(() {
          progress = 1;
          status = "Download Finished";
          isLoading = false;
        });
        //await file.writeAsBytes(bytes);

        /// file has been downloaded
        /// show success to user
        debugPrint("Download finished");
      },
      onError: (e) {
        /// if user loses internet connection while downloading the file, causes an error.
        /// You can decide what to do about that in onError.
        /// Setting cancelOnError to true will cause the StreamSubscription to get canceled.
        setState(() {
          isLoading = false;
        });
        debugPrint(e);
      },
      cancelOnError: true,
    );
    /*setState(() {
      isLoading = true;
    });*/

    /// using Flutter package "dio":
    //      Dio dio = Dio();
    //      dio.download(urlOfFileToDownload, '$dir/$filename',
    //         onReceiveProgress(received,total) {
    //         setState(() {
    //           int percentage = ((received / total) * 100).floor();
    //         });
    //      });
  }

/*  downloadFile(Detail? albDetail) async {
    var dir = await Utility.getSavedDir();
    for (var img in albDetail!.albumImage!) {
      var httpClient = http.Client();
      var request = http.Request('GET', Uri.parse(img));
      var response = httpClient.send(request);

      List<List<int>> chunks = [];
      int downloaded = 0;

      response.asStream().listen((http.StreamedResponse r) {
        r.stream.listen((List<int> chunk) {
          // Display percentage of completion
          debugPrint(
              'downloadPercentage: ${downloaded / r.contentLength! * 100}');

          chunks.add(chunk);
          downloaded += chunk.length;
        }, onDone: () async {
          // Display percentage of completion
          debugPrint(
              'downloadPercentage: ${downloaded / r.contentLength! * 100}');

          /// check if allAlbums sub dir exist or not and if not then create
          if (!(await Utility.dirDownloadFileExists(
              dirName:
                  "$dir/${Constants.allAlbums}/${albDetail.name}/albumImages"))) {
            await Directory(
                    "$dir/${Constants.allAlbums}/${albDetail.name}/albumImages")
                .create();
          }

          // Save the file
          var file = File(path.join(
              "$dir/${Constants.allAlbums}/${albDetail.name}/albumImages",
              img.split("/").last));
          final Uint8List bytes = Uint8List(r.contentLength!);
          int offset = 0;
          for (List<int> chunk in chunks) {
            debugPrint("bytes : $bytes");
            try {
              bytes.setRange(offset, offset + chunk.length, chunk);
            } catch (e) {
              debugPrint("Exception : $e");
            }
            offset += chunk.length;
          }
          await file.writeAsBytes(bytes);
          // return;
        });
      });
    }
  }*/

  void albumOnTap({String? dirPath,
    AlbumListElement? albListElement,
    bool? isInternetAvail}) async {
    var dir = await Utility.getSavedDir();
    if (await Utility.dirDownloadFileExists(dirName: dirPath)) {
      albListElement?.detail?.albumImage?.forEach((element) {
        finalList
            .add(File(path.join("$dirPath/${element
            .split("/")
            .last}")).path);
      });
      debugPrint("all images : $finalList");
      var len = finalList.length % 2 != 0 ? finalList.length - 1 : finalList
          .length;

    /*  Navigator.push(context, MaterialPageRoute(builder: (context)
      =>
          CustomPageCurl(image: Image.asset(AppAssets.image1))
    ));*/
    /// Commenting it for testing some example
     AppRoutes.router.pushNamed(AppRoutes.detail, extra: {
        'album_name': albListElement?.detail?.name,
        'gallery_image_list': finalList,
        'list_len': len,
        'front_image': albListElement?.frontImage,
        'detail': Detail(
          frontImage: albListElement?.frontImage,
          backImage: albListElement?.backImage,
          albumImage: finalList,
          name: albListElement?.detail?.name,
          albumAudio: albListElement?.audioPath,
          studioAddress: albListElement?.detail?.studioAddress,
          studioContactNo: albListElement?.detail?.studioContactNo,
          studioImage: albListElement?.studioImage,
          studioName: albListElement?.detail?.studioName,
          code: albListElement?.detail?.code,
        ),
      });
    } else {
    if (albListElement?.detail?.albumImage?.isNotEmpty ?? false) {
    Utility.showToast(
    "Downloading Images : ${albListElement?.detail?.albumImage?.length}");
    if (isInternetAvail ?? false) {
    downloadImageList(albListElement?.detail, dirPath);
    /* var dir = await Utility.getSavedDir();
        var imgPath =
            "$dir/${Constants.allAlbums}/${albListElement?.detail?.name}/images";
        albListElement?.detail?.albumImage?.forEach((element) async {
          await _downloadButtonPressed(
              url: element,
              folderPath: imgPath,
              filePath: "$imgPath/${element.split("/").last}",
              length: 12);
        });*/

    /// To download pdf
    if (albListElement?.detail?.albumPdf?.isNotEmpty ?? false) {
    var filePath =
    "$dir/${Constants.allAlbums}/${albListElement?.detail?.name}/pdf";
    debugPrint("alb pdf :${albListElement?.detail?.albumPdf}");
    _downloadButtonPressed(
    url: albListElement?.detail?.albumPdf ?? "",
    folderPath: filePath,
    filePath: "$filePath/images.pdf",
    );
    }

    /* homeScreenBloc.add(DetailViewEvent(
                                            galleryImageList:
                                            albumData?[index].galleryImages,
                                            frontImage:
                                            allAlbumList?[index].imageName,
                                            albumName:
                                            allAlbumList?[index].albumName));*/
    } else {
    Utility.showToast(
    "Please connect to internet to load album from server");
    }
    } else {
    Utility.showSnackBar("No images available in this album");
    }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Utility.onExitApp(context).then((value) => value!);
      },
      child: BlocConsumer<AppBloc, AppState>(
        bloc: appBloc,
        listener: (context, state) {
          if (state is InternetLostState) {
            Utility.showToast("No Internet");
          }
        },
        builder: (context, state) {
          if (state is InternetLostState) {
            return homeScreenView(false);
          } else {
            return homeScreenView(true);
          }
        },
      ),
    );
  }

  Widget homeScreenView(bool? isInternetAvail) {
    return Scaffold(
      //backgroundColor: Color(0xE636363A),
      //backgroundColor: const Color(0xFF212122),
      //backgroundColor: Colors.blueGrey,
      //backgroundColor: Colors.grey.shade300,

      /// for divider
      backgroundColor: const Color(0xFF313636),
      appBar: AppBar(
        elevation: 6,
        //backgroundColor: Color(0xFF212122),
        //backgroundColor: Colors.black54,
        // backgroundColor: Colors.blueGrey.shade900,
        backgroundColor: Colors.black,
        title: Container(
          margin: EdgeInsets.only(left: 5.w),
          child: Text(
            Constants.projectName,
            style: const TextStyle().medium.copyWith(
              fontSize: 18.sp,
              color: Colors.white,
            ),
          ),
        ),
      ),
      floatingActionButton: floatingActionBtn(context),
      body: BlocConsumer(
        bloc: homeScreenBloc,
        listener: (context, state) {
          if (state is HomeScreenLoadingState) {
            //Utility.showCustomDialog(context, text: "Please Wait...");
          }
          if (state is HomeScreenLoadedState) {
            //Navigator.pop(Utility.dialogContext ?? context);
            /*if (state.albumDetail != null) {
              //downloadFile(state.albumDetail);
              downloadImageList(state.albumDetail);
            }*/
          }
          if (state is HomeScreenErrorState) {
            Utility.showToast(
              state.errorMessage,
              bgColor: Colors.red,
            );
          }
        },
        builder: (context, state) {
          if (state is HomeScreenLoadingState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitCircle(
                    color: Colors.red,
                    size: 50.sp,
                  ),
                  20.toSpace(),
                  Text(
                    "Please wait...",
                    style: const TextStyle().regular.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }
          if (state is HomeScreenLoadedState) {
            /*   if (state.albumDetail != null) {
              return Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      color: Colors.green,
                      value: downloadProgress,
                    ),
                    Text(
                      downloadProgress.toStringAsFixed(2),
                      style: TextStyle(color: Colors.red, fontSize: 22.sp),
                    ),
                  ],
                ),
              );
            }*/

            int count = 0;
            if (state.albumList?.albumList != null &&
                (state.albumList?.albumList?.isNotEmpty ?? false)) {
              //albumDetailList?.add(state.albumDetail);
              albumList = state.albumList;
              debugPrint("state is ____ ${state.albumList?.albumList?[0].detail
                  ?.albumImage}");
              finalAlbList = albumList?.albumList;
              for (var detail in finalAlbList!) {
                if (detail.detail == null) {
                  count++;
                }
              }

              if (count == finalAlbList?.length) {
                return Center(
                  child: Text(
                    "You don't have any album",
                    style: const TextStyle().medium.copyWith(
                      color: Colors.white,
                      fontSize: 18.sp,
                    ),
                  ),
                );
              }
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  SafeArea(
                      child: Column(
                        children: [
                          15.toSpace(),
                          Expanded(
                            child: GridView.builder(
                              gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 40.h,
                                crossAxisSpacing: 0,
                              ),
                              itemCount: finalAlbList!.length % 2 == 1
                                  ? finalAlbList!.length + 1
                                  : finalAlbList!.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    dividerWidget(context),
                                    finalAlbList!.length % 2 == 1 &&
                                        finalAlbList!.length == index
                                        ? const SizedBox.shrink()
                                        : Positioned(
                                      bottom: 18.h,
                                      child: InkWell(
                                        onTap: () async {
                                          var dir =
                                          await Utility.getSavedDir();
                                          var dirPath =
                                              "$dir/${Constants
                                              .allAlbums}/${finalAlbList?[index]
                                              .detail?.name}/images";
                                          isLoading ?? false
                                              ? null
                                              : albumOnTap(
                                            dirPath: dirPath,
                                            albListElement:
                                            finalAlbList?[index],
                                            isInternetAvail: isInternetAvail,
                                          );
                                          /* if (await Utility.dirDownloadFileExists(
                                                    dirName:
                                                        "$dir/${Constants.allAlbums}/${finalAlbList?[index].detail?.name}/albumImages")) {
                                                  var dirPath =
                                                      "$dir/${Constants.allAlbums}/${finalAlbList?[index].detail?.name}/albumImages";
                                                  finalAlbList?[index]
                                                      .detail
                                                      ?.albumImage
                                                      ?.forEach((element) {
                                                    finalList.add(File(path.join(
                                                            "$dirPath/${finalAlbList?[index].detail?.name}"))
                                                        .path);
                                                  });
                                                  debugPrint("all images : $finalList");
                                                  AppRoutes.router.pushNamed(
                                                      AppRoutes.detail,
                                                      extra: {
                                                        'album_name':
                                                            finalAlbList?[index]
                                                                .detail
                                                                ?.name,
                                                        'gallery_image_list': finalList,
                                                        'list_len': finalList.length,
                                                        'front_image':
                                                            finalAlbList?[index]
                                                                .frontImage,
                                                        'detail': Detail(
                                                          frontImage:
                                                              finalAlbList?[index]
                                                                  .frontImage,
                                                        ),
                                                      });
                                                  // Navigator.of(context)
                                                  //     .push(MaterialPageRoute(
                                                  //     builder: (context) =>
                                                  //         DetailsView(
                                                  //           galleryImageList: finalList,
                                                  //           listLength: finalList.length,
                                                  //           frontImage
                                                  //               : finalAlbList?[index]
                                                  //               .frontImage,)));
                                                } else {
                                                  print("double yeahhh");
                                                  if (isInternetAvail ?? false) {
                                                    await downloadImageList(
                                                        finalAlbList?[index].detail);
                                                    */
                                          /* homeScreenBloc.add(DetailViewEvent(
                                                    galleryImageList:
                                                    albumData?[index].galleryImages,
                                                    frontImage:
                                                    allAlbumList?[index].imageName,
                                                    albumName:
                                                    allAlbumList?[index].albumName));*/ /*
                                                  } else {
                                                    Utility.showSnackBar(
                                                        "Please connect to internet to load album from server");
                                                  }
                                                }*/

                                          ///commented for now
                                          /*   homeScreenBloc.add(DetailViewEvent(
                                                  galleryImageList:
                                                      albumData?[index].galleryImages,
                                                  frontImage:
                                                      allAlbumList?[index].imageName,
                                                  albumName:
                                                      allAlbumList?[index].albumName));*/
                                        },
                                        child: itemWidget(
                                          image:
                                          // albumDetailList?[index]?.frontImage ??
                                          finalAlbList![index]
                                              .frontImage ??
                                              "",
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              },
                            ),
                          )
                        ],
                      )),
                  /* isLoading ?? false
                      ? Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(bottom: 60.h),
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        */
                  /* LinearProgressIndicator(
                        value: progress,
                        ),
                        20.toSpace(),*/
                  /*
                        CircularProgressIndicator(
                          value: progress,
                        ),
                        20.toSpace(),
                        Text(
                          "Please wait data is loading from server",
                          style: const TextStyle().medium.copyWith(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                        20.toSpace(),
                        Text(
                          status,
                          style: const TextStyle().medium.copyWith(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                        */
                  /* Text(
                              "downloading ${downloadProgress.toStringAsFixed(0)}%",
                              style: const TextStyle().medium.copyWith(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                  ),
                            ),*/
                  /*
                      ],
                    ),
                  )
                      : const SizedBox.shrink(),*/

                  isLoading ?? false
                      ? Column(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /* LinearProgressIndicator(
                        value: progress,
                        ),
                        20.toSpace(),*/
                      CircularProgressIndicator(
                        value: progress,
                      ),
                      20.toSpace(),
                      Text(
                        "Please wait data is loading from server",
                        style: const TextStyle().medium.copyWith(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                      20.toSpace(),
                      Text(
                        status,
                        style: const TextStyle().medium.copyWith(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                      /* Text(
                              "downloading ${downloadProgress.toStringAsFixed(0)}%",
                              style: const TextStyle().medium.copyWith(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                  ),
                            ),*/
                    ],
                  )
                      : const SizedBox.shrink()
                ],
              );
            }
          }

          return Center(
            child: Text(
              "You don't have any album",
              style: const TextStyle().medium.copyWith(
                color: Colors.white,
                fontSize: 18.sp,
              ),
            ),
          );
        },
      ),
    );
  }


  Widget oldWidget(bool? isInternetAvail) {
    return BlocConsumer(
      bloc: homeScreenBloc..add(HomeScreenInitialEvent()),
      listener: (context, state) {
        if (state is HomeScreenLoadingState) {
          Utility.showCustomDialog(context, text: "Please Wait...");
        }
        if (state is HomeScreenLoadedState) {
          Navigator.pop(Utility.dialogContext ?? context);
        }
      },
      builder: (context, state) {
        if (state is HomeScreenErrorState) {
          return Center(
            child: Text(state.errorMessage),
          );
        }
        if (state is HomeScreenLoadedState) {
          allAlbumList = state.allAlbumList;
          albumData = state.albumData;
          if (allAlbumList?.isEmpty ?? true) {
            return Center(
              child: Text(
                "You don't have any album",
                style: const TextStyle().medium.copyWith(
                  color: Colors.white,
                  fontSize: 18.sp,
                ),
              ),
            );
          }
          return SafeArea(
            child: Column(
              children: [
                15.toSpace(),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 40.h,
                      crossAxisSpacing: 0,
                    ),
                    itemCount: allAlbumList!.length % 2 == 1
                        ? allAlbumList!.length + 1
                        : allAlbumList!.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          dividerWidget(context),
                          allAlbumList!.length % 2 == 1 &&
                              allAlbumList!.length == index
                              ? const SizedBox.shrink()
                              : Positioned(
                            bottom: 18.h,
                            child: InkWell(
                              onTap: () {
                                homeScreenBloc.add(DetailViewEvent(
                                    galleryImageList:
                                    albumData?[index].galleryImages,
                                    frontImage:
                                    allAlbumList?[index].imageName,
                                    albumName:
                                    allAlbumList?[index].albumName));
                                /*BlocProvider.of<HomeBloc>(context).add(
                                    GoToPdfViewEvent(
                                      galleryImageList:
                                      state.albumData?[index].galleryImages,
                                      // pin: pinController.text.trim(),
                                      frontImage:
                                      state.allAlbumList?[index].imageName,
                                      albumName:
                                      state.allAlbumList?[index].albumName,
                                    ),
                                  );*/
                              },
                              child: itemWidget(
                                image: state
                                    .allAlbumList?[index].imageName ??
                                    "",
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ),
                15.toSpace(),
              ],
            ),
          );
        }
        return const Text("");
      },
    );
  }

  Widget floatingActionBtn(BuildContext context) {
    return InkWell(
      onTap: () => isLoading ?? false ? null : addAlbum(context),
      // onTap: () => Navigator.of(context)
      //     .push(MaterialPageRoute(builder: (context) => const DetailsView())),
      child: Container(
        padding: EdgeInsets.all(6.h),
        margin: EdgeInsets.only(
          right: 10.h,
          bottom: 10.h,
        ),
        decoration: BoxDecoration(
          color: Colors.red.shade900,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 45.sp,
        ),
      ),
    );
  }

  Widget dividerWidget(BuildContext context) {
    const double fillPercent = 50; // fills 56.23% for container from bottom
    const double fillStop = (100 - fillPercent) / 100;
    final List<double> stops = [0.0, fillStop, fillStop, 1.0];
    return Container(
      height: 25.h,
      width: MediaQuery
          .of(context)
          .size
          .width,
      // color: const Color(0xFF212122),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF222626),
            const Color(0xFF222626),
            Colors.blueGrey.shade800,
            Colors.blueGrey.shade800,
            // Color(0xFF393B3B),
            // Color(0xFF393B3B)
          ],
          stops: stops,
          end: Alignment.bottomCenter,
          begin: Alignment.topCenter,
        ),
      ),
    );
  }

  Widget itemWidget({required String image}) {
    return Container(
      width: 130.h,
      height: 150.h,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF212122),
        // borderRadius: BorderRadius.
        // circular(10.r),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(5.r),
          bottomRight: Radius.circular(4.r),
          topLeft: Radius.circular(2.r),
        ),
        /*   border: Border(
                right: BorderSide(color: Colors.red),

              )*/
      ),
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(right: 8.w), // ***
            decoration: BoxDecoration(
              color: const Color(0xFF212122),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(5.r),
                bottomRight: Radius.circular(4.r),
                topLeft: Radius.circular(2.r),
              ),
              // borderRadius: BorderRadius.circular(8.r),
              boxShadow: const [
                BoxShadow(
                    color: Colors.white,
                    blurRadius: 3,
                    spreadRadius: 3,
                    offset: Offset(3.5, 3.5))
              ],
            ),
            child: AppLocalFileImage(
              imageUrl: image,
              fit: BoxFit.fill,
              width: 150.h,
              height: 150.h,
              // radius: 20.r,
            ),
            /*  child: Image.asset(
              AppAssets.image1,
              width: 150.h,
              height: 150.h,
              fit: BoxFit.cover,
            ),*/
          ),
          Positioned(
            left: 8.w,
            child: Container(
              height: 150.h,
              width: 1.w,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.white38,
                      blurRadius: 1,
                      spreadRadius: 0,
                      offset: Offset(0, 1.5))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget emptyWidget(BuildContext context) {
    return Column(
      children: [
        Text(
          "You don't have any album yet.",
          style: const TextStyle().semiBold.copyWith(
            color: Colors.white,
          ),
        ),
        SizedBox(
          width: MediaQuery
              .of(context)
              .size
              .width * 0.3,
          child: ElevatedButton(
            onPressed: () {
              addAlbum(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade900,
              padding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 6.h,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_circle_outline,
                  color: Colors.white,
                ),
                6.toSpace(vertically: false),
                Text(
                  "Add",
                  style: const TextStyle().semiBold.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  addAlbum(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Album:',
                  style: const TextStyle().medium.copyWith(
                    color: Colors.black,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    codeController.clear();
                  },
                  child: Text(
                    'Cancel',
                    style: const TextStyle().medium.copyWith(
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: codeController,
                        maxLength: 12,
                        hintText: "Enter code",
                      ),
                    ),
                    /*   const Text('-'),
                Expanded(child: CustomTextField(controller: controller2,
                  maxLength: 6,),),*/
                  ],
                ),
                10.toSpace(),
                ElevatedButton.icon(
                  onPressed: () {
                    if (codeController.text.isEmpty ||
                        codeController.text.contains(" ")) {
                      Utility.showToast(
                        "Please enter album code",
                        bgColor: Colors.red,
                      );
                    } else {
                      Navigator.pop(context);
                      homeScreenBloc
                          .add(AddAlbumEvent(albumCode: codeController.text));
                      codeController.clear();
                    }
                    /*Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => HomeView()));*/
                  },
                  icon: Icon(
                    Icons.download,
                    color: Colors.white,
                    size: 30.sp,
                  ),
                  label: Text(
                    'GET',
                    style: const TextStyle().medium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.h,
                        vertical: 8.h,
                      )),
                )
              ],
            ),
          ),
    );
  }

  ///demo code
  oldCode() {
    return Column(
      children: [
        50.toSpace(),
        SizedBox(
          height: 150.h,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              dividerWidget(context),
              Positioned(
                bottom: 18.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 150.h,
                      height: 150.h,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: const Color(0xFF212122),
                        // borderRadius: BorderRadius.
                        // circular(10.r),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(5.r),
                          bottomRight: Radius.circular(4.r),
                          topLeft: Radius.circular(2.r),
                        ),
                        /*   border: Border(
                  right: BorderSide(color: Colors.red),

                )*/
                      ),
                      child: Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(right: 8.w),
                            // ***
                            decoration: BoxDecoration(
                              color: const Color(0xFF212122),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(5.r),
                                bottomRight: Radius.circular(4.r),
                                topLeft: Radius.circular(2.r),
                              ),
                              // borderRadius: BorderRadius.circular(8.r),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.white,
                                    blurRadius: 4,
                                    spreadRadius: 4,
                                    offset: Offset(3.5, 3.5))
                              ],
                            ),
                            child: Image.asset(
                              AppAssets.image1,
                              width: 150.h,
                              height: 150.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            left: 8.w,
                            child: Container(
                              height: 150.h,
                              width: 1.w,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(20.r),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.white38,
                                      blurRadius: 1,
                                      spreadRadius: 0,
                                      offset: Offset(0, 1.5))
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    20.toSpace(),
                    Stack(
                      children: [
                        Container(
                          height: 100.h,
                          width: 80.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(6.r),
                                bottomLeft: Radius.circular(6.r)),
                          ),
                        ),
                        Positioned(
                          right: 3,
                          child: Stack(
                            children: [
                              Container(
                                height: 100.h,
                                width: 80.h,
                                decoration: BoxDecoration(
                                  // color: Colors.lightGreen,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(6.r),
                                        bottomLeft: Radius.circular(6.r)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF000000)
                                            .withAlpha(60),
                                        blurRadius: 6.0,
                                        spreadRadius: 0.0,
                                        offset: const Offset(
                                          0.0,
                                          3.0,
                                        ),
                                      ),
                                    ]),
                                child: Image.asset(AppAssets.image1,
                                    fit: BoxFit.cover),
                              ),
                              Positioned(
                                left: 8.w,
                                child: Container(
                                  height: 100.h,
                                  width: 1.h,
                                  color: Colors.white24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 100.h,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              dividerWidget(context),
              Positioned(
                bottom: 18.h,
                child: Stack(
                  children: [
                    Container(
                      height: 100.h,
                      width: 80.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6.r),
                            bottomLeft: Radius.circular(6.r)),
                      ),
                    ),
                    Positioned(
                      right: 3,
                      child: Stack(
                        children: [
                          Container(
                            height: 100.h,
                            width: 80.h,
                            decoration: BoxDecoration(
                              // color: Colors.lightGreen,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(6.r),
                                    bottomLeft: Radius.circular(6.r)),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                    const Color(0xFF000000).withAlpha(60),
                                    blurRadius: 6.0,
                                    spreadRadius: 0.0,
                                    offset: const Offset(
                                      0.0,
                                      3.0,
                                    ),
                                  ),
                                ]),
                            child: Image.asset(AppAssets.image1,
                                fit: BoxFit.cover),
                          ),
                          Positioned(
                            left: 8.w,
                            child: Container(
                              height: 100.h,
                              width: 1.h,
                              color: Colors.white24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        /* Container(
                height: 100.h,
                width: 80.h,
                decoration: BoxDecoration(
                  // color: Colors.lightGreen,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(6.r),
                        bottomLeft: Radius.circular(6.r)
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white,
                        spreadRadius: 2,
                        blurRadius: 2,
                        offset: Offset(4.0, 0),
                      ),
                      BoxShadow(
                        color: Colors.white,
                        spreadRadius: 0,
                        blurRadius: 2,
                        offset: Offset(1.0, 0)
                      )
                     */ /* BoxShadow(
                       // color: Color(0xFF000000).withAlpha(60),
                        color: Color(0xFFFFFFFF).withAlpha(100),
                        blurRadius: 6.0,
                        spreadRadius: 2.0,
                        offset: Offset(
                          0.0,
                          0.0,
                        ),
                      ),*/ /*
                    ]
                ),
                child: Image.asset(AppAssets.image1,fit: BoxFit.cover),
              ),*/

/*
              Container(
                height: 80,width: 80,
                decoration:  BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: Colors.black,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.white,
                      spreadRadius: 1,
                      blurRadius: 0,
                      offset: Offset(4,4), // changes position of shadow
                    ),

                  ],
                ),
                child:  Center(
                  child: Text("1-6 Months",style: TextStyle(color: Colors.white),),

                ),
              ),*/

        10.toSpace(),
        /* Container(
                width: 200,
                height: 200,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                   // borderRadius: BorderRadius.circular(10.r),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(5.r),
                    bottomRight: Radius.circular(4.r),
                    topLeft: Radius.circular(2.r),
                  ),
               */ /*   border: Border(
                    right: BorderSide(color: Colors.red),

                  )*/ /*
                ),
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 8.r), // ***
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(5.r),
                          bottomRight: Radius.circular(4.r),
                          topLeft: Radius.circular(2.r),
                        ),
                        // borderRadius: BorderRadius.circular(8.r),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.white,
                            blurRadius: 4,
                            spreadRadius: 4,
                            offset: Offset(3.5, 3.5)
                          )
                        ],
                      ),
                      child: Image.asset(AppAssets.image1, width: 200,
                        height: 200, fit: BoxFit.cover,),
                    ),
                    Positioned(
                      left: 8.w,
                      child: Container(
                        height: 200.h,
                        width: 1.w,
                        decoration: BoxDecoration(
                          //color: Colors.white24,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.white38,
                                blurRadius: 1,
                                spreadRadius: 0,
                                offset: Offset(1.5, 1.5)
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),*/
        10.toSpace(),
        emptyWidget(context),
      ],
    );
  }
}
