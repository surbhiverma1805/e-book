import 'package:ebook/src/widgets/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget itemWidget({required String image, double? height, double? width,}) {
  return Container(
    width: width ?? 130.h,
    height: height ?? 150.h,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: const Color(0xFF212122),
      // borderRadius: BorderRadius.
      // circular(10.r),
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(5.r),
        bottomRight: Radius.circular(4.r),
        topLeft: Radius.circular(2.r),
      ),
      /*   border: Border(
                right: BorderSide(color: Colors.red),

              )*/
    ),
    child: Stack(
      children: [
        Container(
          margin: EdgeInsets.only(right: 8.w), // ***
          decoration: BoxDecoration(
            color: const Color(0xFF212122),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(5.r),
              bottomRight: Radius.circular(4.r),
              topLeft: Radius.circular(2.r),
            ),
            // borderRadius: BorderRadius.circular(8.r),
            boxShadow: const [
              BoxShadow(
                  color: Colors.white,
                  blurRadius: 3,
                  spreadRadius: 3,
                  offset: Offset(3.5, 3.5))
            ],
          ),
          child: AppLocalFileImage(
            imageUrl: image,
            fit: BoxFit.cover,
            width: ((width ?? 150.h) + 30),
            height: (height ?? 150.h) + 30,
            // radius: 20.r,
          ),
          /*  child: Image.asset(
              AppAssets.image1,
              width: 150.h,
              height: 150.h,
              fit: BoxFit.cover,
            ),*/
        ),
        Positioned(
          left: 8.w,
          child: Container(
            height: (height ?? 150.h) + 30,
            width: 1.w,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: const [
                BoxShadow(
                    color: Colors.white38,
                    blurRadius: 1,
                    spreadRadius: 0,
                    offset: Offset(0, 1.5))
              ],
            ),
          ),
        ),
      ],
    ),
  );
}