import 'package:ebook/src/screen/pdf_view/page_curl/page_curl.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  Widget _buildContainer(String text, {Color color = Colors.teal}) => Container(
    alignment: Alignment.center,
    color: color,
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white),
    ),
  );

  final double heightOfCards = 200;

  double get widthOfCards => 691 * heightOfCards / 1056;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white.withAlpha(200),
    appBar: AppBar(
      title: Text('Curling a page... virtually'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          /* horizontal */
          PageCurl(
            back: _buildContainer('This is BACK'),
            front: _buildContainer(
              'This is FRONT',
              color: Colors.blueGrey,
            ),
            size: const Size(200, 150),
          ),

          /* vertical */
          PageCurl(
            vertical: true,
            back: Image.asset(
              'assets/images/image1.jpeg',
              height: heightOfCards,
              width: widthOfCards,
            ),
            front: Image.asset(
              'assets/images/image2.jpeg',
              height: heightOfCards,
              width: widthOfCards,
            ),
            size: Size(widthOfCards, heightOfCards),
          ),
        ],
      ),
    ),
  );
}