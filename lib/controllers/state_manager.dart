import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

class StateManager {
  final progressNotifier = ValueNotifier<double?>(0);

  void startDownloading(String path) async {
    progressNotifier.value = null;

    // const url = 'https://www.ssa.gov/oact/babynames/names.zip';
    final url = path;
    final request = Request('GET', Uri.parse(url));
    final StreamedResponse response = await Client().send(request);

    final contentLength = response.contentLength;
    // final contentLength = double.parse(response.headers['x-decompressed-content-length']);

    progressNotifier.value = 0;

    List<int> bytes = [];

    final file = await _getFile('names.zip');
    response.stream.listen(
      (List<int> newBytes) {
        bytes.addAll(newBytes);
        final downloadedLength = bytes.length;
        progressNotifier.value = downloadedLength / contentLength!;
      },
      onDone: () async {
        // progressNotifier.value = 0;
        await file.writeAsBytes(bytes);
      },
      onError: (e) {
        debugPrint(e);
      },
      cancelOnError: true,
    );
  }

  Future<File> _getFile(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    // return File(join(dir.path, filename));
    return File(dir.path + filename);
  }
}
