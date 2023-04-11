import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ebook/model/album_list_resp.dart';
import 'package:ebook/repository/api_service/api_methods.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

final GlobalKey<ScaffoldMessengerState> snackBarKey =
    GlobalKey<ScaffoldMessengerState>();

class Utility {
  static Future<File> localFile(String? pathName) async {
    final path = await Utility.getSavedDir();
    return File('$path/$pathName');
  }

  static Future<bool> checkInternetConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult ==
    ConnectivityResult.wifi) {
      return true;
    } else {
      return false;
    }
  }

  static showSnackBar(String? message, {Duration? duration}) {
    snackBarKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message ?? ""),
        duration: duration ?? const Duration(seconds: 2),
        behavior: SnackBarBehavior.fixed,
        padding: const EdgeInsets.all(10),
      ),
    );
  }

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
    return externalStorageDirPath;
  }

  static Future<String?> saveDownloadedImageToLocal({
    String? imageName,
    String? albumName,
  }) async {
    File? imageFile;
    var dirPath = "${await Utility.getSavedDir()}/$albumName";
    if (!(await Utility.downloadFileExists("$albumName/$imageName"))) {
      final downloadedImage =
          await http.get(Uri.parse("${ApiMethods.imageBaseUrl}/$imageName"));
      imageFile = File(path.join(dirPath, "$imageName.jpeg"));
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
    imgList?.forEach((img) {
      list.add(File(path.join(dirPath, "${img.imageName}.jpeg")).path);
    });
    return list;
  }
}
