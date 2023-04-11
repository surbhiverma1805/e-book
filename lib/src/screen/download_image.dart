import 'dart:io';

import 'package:ebook/utility/utility.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;

class DownloadImage extends StatefulWidget {
  const DownloadImage({Key? key}) : super(key: key);

  @override
  State<DownloadImage> createState() => _DownloadImage();
}

class _DownloadImage extends State<DownloadImage> {
  // This is the image file that will be displayed
  // In the beginning, it is null
  File? displayImage;

  // This is the flag to check if the image is downloading
  // If it is true, the screen will show "Downloading..."
  bool _isDownloading = false;

  // URL of the image to download from the internet
  final String _url =
      'https://www.kindacode.com/wp-content/uploads/2022/02/orange.jpeg';

  Future<void> _download() async {
    //Set the flag true
    setState(() {
      _isDownloading = true;
    });
    final response = await http.get(Uri.parse(_url));

    // debugPrint("___response : ${response.body}");
    // Get the image name
    final imageName = path.basename(_url);
    debugPrint("___image name : $imageName");

    final dir = await Utility.getSavedDir();
    //var res = await File("${await Utility.getDir()}/$imageName").exists();
    var res = Directory("${await Utility.getSavedDir()}/abc");
    if (await res.exists()) {
      final dirPath = "$dir/abc";
      final imageFile = File(path.join(dirPath, imageName));
      await imageFile.writeAsBytes(response.bodyBytes);
    } else {
      final dirPath = "$dir/abc";
      await Directory(dirPath).create();
    }

    // Get the document directory path
    final appDir = await path_provider.getApplicationDocumentsDirectory();
    debugPrint("___appDir : $appDir");

    // This is the saved image path
    // You can use it to display the saved image later
    final localPath = path.join(appDir.path, imageName);
    debugPrint("___local path : $localPath");

    // Download the image
    final imageFile = File(localPath);
    await imageFile.writeAsBytes(response.bodyBytes);
    debugPrint("___image file : $imageFile");

    /*setState(() {
      _isDownloading = false;
      displayImage = imageFile;
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Download Image"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _download,
                child: const Text("Download Image"),
              ),
              const SizedBox(height: 25),
              displayImage != null
                  ? Image.file(displayImage!)
                  : Center(
                      child: _isDownloading
                          ? const Text(
                              "Downloding...",
                              style: TextStyle(fontSize: 35),
                            )
                          : const SizedBox.shrink())
            ],
          ),
        ),
      ),
    );
  }
}
