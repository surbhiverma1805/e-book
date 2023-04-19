import 'package:flutter/material.dart';

class FlipbookPage extends StatefulWidget {
  final List<Image> images;

  FlipbookPage({required this.images});

  @override
  _FlipbookPageState createState() => _FlipbookPageState();
}

class _FlipbookPageState extends State<FlipbookPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 0) {
          _pageController.previousPage(
              duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
        } else if (details.delta.dx < 0) {
          _pageController.nextPage(
              duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
        }
      },
      child: PageView(
        controller: _pageController,
        children: widget.images,
      ),
    );
  }
}
