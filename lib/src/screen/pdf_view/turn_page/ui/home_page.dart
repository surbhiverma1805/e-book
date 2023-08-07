import 'package:ebook/src/screen/pdf_view/turn_page/src/turn_page_route.dart';
import 'package:ebook/src/screen/pdf_view/turn_page/ui/first_page.dart';
import 'package:ebook/src/screen/pdf_view/turn_page/ui/page_view_page.dart';
import 'package:flutter/material.dart';

class HomePageView extends StatelessWidget {
  const HomePageView({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final ratio = deviceSize.width / deviceSize.height;
    final animationTransitionPoint = ratio < 9 / 16 ? 0.5 : 0.2;

    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Home Page'),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                TurnPageRoute(
                  overleafColor: Colors.grey,
                  animationTransitionPoint: animationTransitionPoint,
                  transitionDuration: const Duration(milliseconds: 300),
                  reverseTransitionDuration: const Duration(milliseconds: 300),
                  builder: (context) => const FirstPage(),
                ),
              ),
              child: const Text('Try TurnPageTransition!'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                TurnPageRoute(
                  overleafColor: Colors.grey,
                  animationTransitionPoint: animationTransitionPoint,
                  transitionDuration: const Duration(milliseconds: 300),
                  builder: (context) => const PageViewPage(),
                ),
              ),
              child: const Text("Let's go TurnPageView!"),
            ),
          ],
        ),
      ),
    );
  }
}
