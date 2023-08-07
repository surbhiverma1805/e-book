import 'package:ebook/src/screen/pdf_view/turn_page/src/turn_direction.dart';
import 'package:ebook/src/screen/pdf_view/turn_page/src/turn_page_transition.dart';
import 'package:ebook/src/screen/pdf_view/turn_page/ui/first_page.dart';
import 'package:ebook/src/screen/pdf_view/turn_page/ui/home_page.dart';
import 'package:ebook/src/screen/pdf_view/turn_page/ui/second_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Routes {
  const Routes();

  static const home = '/';
  static const first = '/first';
  static const second = '/second';

  static GoRouter routes({String? initialLocation}) {
    return GoRouter(
      initialLocation: initialLocation ?? home,
      //redirect: (state)  => null,
      routes: [
        GoRoute(
          path: home,
          builder: (context, state) => const HomePageView(),
        ),
        GoRoute(
          path: first,
          builder: (context, state) => const FirstPage(),
        ),
        GoRoute(
          path: second,
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const SecondPage(),
            transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
                ) =>
                TurnPageTransition(
                  animation: animation,
                  overleafColor: Colors.blueAccent,
                  animationTransitionPoint: 0.5,
                  direction: TurnDirection.rightToLeft,
                  child: child,
                ),
          ),
        ),
      ],
      errorBuilder: (context, state) => const Scaffold(),
    );
  }
}