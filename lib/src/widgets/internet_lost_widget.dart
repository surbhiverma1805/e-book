import 'package:ebook/src/utils/extension/text_style_decoration.dart';
import 'package:ebook/utility/constants.dart';
import 'package:flutter/material.dart';

class InternetLostWidget extends StatelessWidget {
  const InternetLostWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(children: [
          const Icon(
            Icons.wifi_off,
            size: 50,
          ),
          Text(
            Constants.noInternet,
            style: const TextStyle().bold,
          ),
        ]),
      ),
    );
  }
}
