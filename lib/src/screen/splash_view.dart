import 'package:ebook/app_route/app_router.dart';
import 'package:ebook/src/screen/home_page/home_screen.dart';
import 'package:ebook/src/utils/extension/text_style_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2)).whenComplete(
      () => AppRoutes.router.pushReplacementNamed(AppRoutes.homeScreen),
      /*Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: ((context) => const Demo())),
          (route) => false,
    )*/
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      body: Center(
        child: Text(
          "PHOTOBOOK",
          style: const TextStyle().bold.copyWith(
                fontSize: 40.sp,
                color: Colors.black54,
              ),
        ),
      ),
    );
  }
}
