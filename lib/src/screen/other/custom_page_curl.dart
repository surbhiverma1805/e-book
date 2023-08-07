import 'package:flutter/material.dart';

class CustomPageCurl extends StatefulWidget {
  final Image image;

  final Offset? dragStart;

  final Offset? dragEnd;

  CustomPageCurl({
    required this.image,
    this.dragStart,
    this.dragEnd,
  });

  @override
  _CustomPageCurlState createState() => _CustomPageCurlState();
}

class _CustomPageCurlState extends State<CustomPageCurl>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Offset _curlStart;
  late Offset _curlEnd;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    //_curlStart = Offset.zero;
    _curlStart = Offset(50, 60);
    _curlStart = Offset(50, 60);
    //_curlEnd = Offset.zero;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      _curlStart = details.localPosition;
      _curlEnd = _curlStart;
      _animationController.reset();
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _curlEnd = details.localPosition;
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      _curlStart = Offset.zero;
      _curlEnd = Offset.zero;
      _animationController.forward();
    });
  }

  @override
  build(BuildContext context) {
    _curlStart = Offset(0, -100);
    _curlEnd = Offset(0, -1000);
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onPanStart: _handlePanStart,
          onPanUpdate: _handlePanUpdate,
          onPanEnd: _handlePanEnd,
          child: ClipPath(
            clipper: PageCurlClipper(_curlStart, _curlEnd),
            child: Image(image: widget.image.image),
          ),
        ),
      ),
    );
  }
}

class PageCurlClipper extends CustomClipper<Path> {
  final Offset start;
  final Offset end;

  PageCurlClipper(this.start, this.end);

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height / 2);
    final controlPoint1 = Offset(start.dx, size.height / 2);
    final controlPoint2 = Offset(end.dx, start.dy);
    path.quadraticBezierTo(controlPoint1.dx, controlPoint1.dy,
        (start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
    path.quadraticBezierTo(controlPoint2.dx, controlPoint2.dy, end.dx, end.dy);
    path.lineTo(size.width, size.height);
    path.close();
    return path;

  /*  // Calculate control points based on the corner from which the effect is initiated
    Offset controlPoint1, controlPoint2;
    if (start.dy < size.height/2) {
      // Top corners
      controlPoint1 = Offset(start.dx, 0);
      controlPoint2 = Offset(end.dx, start.dy);
    } else {
      // Bottom corners
      controlPoint1 = Offset(start.dx, size.height);
      controlPoint2 = Offset(end.dx, start.dy);
    }

    path.moveTo(0, size.height);
    path.lineTo(0, size.height/2);
    path.quadraticBezierTo(controlPoint1.dx, controlPoint1.dy, (start.dx + end.dx) /2 , (start.dy + end.dy) /2 );

    path.quadraticBezierTo(controlPoint2.dx, controlPoint2.dy, end.dx, end.dy);

    path.lineTo(size.width, size.height);
    path.close();
    return path;*/
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
