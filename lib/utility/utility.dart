import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ebook/model/album_list_resp.dart';
import 'package:ebook/repository/api_service/api_methods.dart';
import 'package:ebook/src/utils/app_colors.dart';
import 'package:ebook/src/utils/extension/space.dart';
import 'package:ebook/src/utils/extension/text_style_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

final GlobalKey<ScaffoldMessengerState> snackBarKey =
    GlobalKey<ScaffoldMessengerState>();

class Utility {
  static BuildContext? dialogContext;

  static Future<bool?> onExitApp(context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          children: [
            Text(
              "Do you really want to exit the app?",
              style: const TextStyle().medium.copyWith(
                    color: Colors.black,
                    fontSize: 18.sp,
                  ),
            ),
            20.toSpace(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                5.toSpace(),
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context, true);
                      // exit(0);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.black, width: 3.w),
                      ),
                      child: Text(
                        "Yes",
                        style: const TextStyle().medium.copyWith(
                              color: Colors.black,
                              fontSize: 16.sp,
                            ),
                      ),
                    )),
                GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 15.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.black, width: 3.w),
                      ),
                      child: Text(
                        "No",
                        style: const TextStyle().medium.copyWith(
                              color: Colors.black,
                              fontSize: 16.sp,
                            ),
                      ),
                    )),
                5.toSpace(),
              ],
            )
          ],
        ),
      ),
    );
  }

  static showToast(msg, {Color? bgColor}) => Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: bgColor ?? Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );

  static showDownloadProgressIndicator(double progress, String status) {
    Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(bottom: 60.h),
      child: Column(
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
      ),
    );
  }

  static showCustomDialog(context, {Widget? navigateTo, String? text}) =>
      showGeneralDialog(
          context: context,
          barrierColor: Colors.white.withOpacity(0.8),
          // Background color
          barrierDismissible: false,
          barrierLabel: 'Dialog',
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (dialogCtx, __, ___) {
            dialogContext = dialogCtx;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SpinKitChasingDots(
                  color: Colors.black,
                  size: 50.sp,
                ),
                20.toSpace(),
                Text(
                  text ?? "",
                  style: const TextStyle().medium.copyWith(
                      fontSize: 18.sp,
                      color: Colors.black,
                      decoration: TextDecoration.none),
                ),
              ],
            );
          });

  static double getWidth({required BuildContext context}) {
    return MediaQuery.of(context).size.width;
  }

  static double getHeight({required BuildContext context}) {
    return MediaQuery.of(context).size.height;
  }

  static Future<String?> localFileName(String? fileName) async {
    return fileName?.replaceAll(" ", "_").toLowerCase();
  }

  static Future<File> localFile(String? pathName) async {
    final path = await Utility.getSavedDir();
    return File('$path/$pathName');
  }

  static Future<bool> checkInternetConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      return false;
    }
  }

  static showSnackBar(String? message, {Duration? duration, Color? bgColor}) {
    snackBarKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message ?? ""),
        duration: duration ?? const Duration(seconds: 2),
        behavior: SnackBarBehavior.fixed,
        padding: EdgeInsets.all(10.h),
        backgroundColor: bgColor ?? Colors.black87,
      ),
    );
  }

  /// To check directory is exist or not
  static Future<bool> dirDownloadFileExists(
      {String? dirName, String? fileName}) async {
    var res = dirName != null
        ? await Directory(dirName).exists()
        : await File('${await getSavedDir()}/$fileName').exists();
    if (!res) {
      debugPrint("Dir or file not found $dirName / $fileName");
    } else {
      res;
    }
    return res;
  }

  static Future<bool> downloadFileExists(String fileName) async {
    var res = await File('${await getSavedDir()}/$fileName').exists();
    if (!res) {
      debugPrint("File not found $fileName");
    }
    return res;
  }

  static Future<String?> getSavedDir() async {
    String? externalStorageDirPath;

    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      externalStorageDirPath = directory?.path;
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }
    debugPrint("dir path : $externalStorageDirPath");
    return externalStorageDirPath;
  }

  static Future<String?> saveDownloadedImageToLocal({
    String? fileName,
    String? albumName,
  }) async {
    File? imageFile;
    String? albName = albumName?.replaceAll(" ", "_").toLowerCase();
    print("new album name $albName");
    var dirPath = "${await Utility.getSavedDir()}/$albumName";
    if (!(await Utility.downloadFileExists("$albumName/$fileName"))) {
      final downloadedImage =
          await http.get(Uri.parse("${ApiMethods.imageBaseUrl}/$fileName"));
      imageFile = File(path.join(dirPath, "$fileName.jpeg"));
      await imageFile.writeAsBytes(downloadedImage.bodyBytes);
    }
    return imageFile?.path;
  }

  static Future<List<String>?> getDownloaded(
      {List<GalleryImage>? imgList,
      String? postTitle,
      String? imageName}) async {
    List<String> list = [];
    var dirPath = "${await Utility.getSavedDir()}/$postTitle";
    // var dirPath =
    //     "${await Utility.getSavedDir()}/${await Utility.localFileName(postTitle)}";
    imgList?.forEach((img) {
      list.add(File(path.join(dirPath, "${img.imageName}.jpeg")).path);
    });
    print("get download list $list");
    return list;
  }
}
