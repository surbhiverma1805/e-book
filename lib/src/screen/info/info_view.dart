import 'package:ebook/model/album_detail_resp.dart';
import 'package:ebook/src/functions/call.dart';
import 'package:ebook/src/utils/extension/space.dart';
import 'package:ebook/src/utils/extension/text_style_decoration.dart';
import 'package:ebook/src/widgets/app_images.dart';
import 'package:ebook/src/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfoView extends StatefulWidget {
  const InfoView({
    Key? key,
    this.detail,
  }) : super(key: key);
  final Detail? detail;

  @override
  State<InfoView> createState() => _InfoViewState();
}

class _InfoViewState extends State<InfoView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      appBar: NewAppBar(
        isLeading: true,
        title: "Info",
        centerInTitle: true,
        onTap: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              20.toSpace(),
              studioLogo(widget.detail?.studioImage),
              30.toSpace(),
              Container(
                color: Colors.grey.shade300,
                margin: EdgeInsets.symmetric(horizontal: 10.w),
                padding: EdgeInsets.symmetric(
                  horizontal: 15.w,
                  vertical: 12.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    infoWidget(
                      title1: widget.detail?.studioName?.toUpperCase(),
                      style1: const TextStyle().semiBold.copyWith(
                            fontSize: 18.sp,
                            color: Colors.black87,
                          ),
                      title2: widget.detail?.studioName?.toUpperCase(),
                      style2: const TextStyle().medium.copyWith(
                            fontSize: 14.sp,
                            color: Colors.black54,
                          ),
                    ),
                    5.toSpace(),
                    divider(),
                    5.toSpace(),
                    InkWell(
                      onTap: () => widget.detail?.studioContactNo?.isNotEmpty ?? false
                        ? call(widget.detail?.studioContactNo)
                      : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          infoWidget(
                            title1: "Mobile",
                            style1: const TextStyle().medium.copyWith(
                                  fontSize: 14.sp,
                                  color: Colors.black87,
                                ),
                            title2: widget.detail?.studioContactNo,
                            style2: const TextStyle().medium.copyWith(
                                  fontSize: 16.sp,
                                  color: Colors.black54,
                                ),
                          ),
                          widget.detail?.studioContactNo?.isNotEmpty ?? false
                              ? Icon(
                            Icons.phone,
                            color: Colors.black54,
                            size: 35.sp,
                          )
                          : const SizedBox(),
                        ],
                      ),
                    ),
                    5.toSpace(),
                    InkWell(
                      onTap: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          infoWidget(
                            title1: "Email",
                            style1: const TextStyle().medium.copyWith(
                              fontSize: 14.sp,
                              color: Colors.black87,
                            ),
                            title2: "",
                            style2: const TextStyle().medium.copyWith(
                              fontSize: 16.sp,
                              color: Colors.black54,
                            ),
                          ),
                          Icon(
                            Icons.mail,
                            color: Colors.black54,
                            size: 35.sp,
                          ),
                        ],
                      ),
                    ),
                    5.toSpace(),
                    divider(),
                    5.toSpace(),
                    infoWidget(
                      title1: "Address",
                      style1: const TextStyle().medium.copyWith(
                            fontSize: 14.sp,
                            color: Colors.black87,
                          ),
                      title2: widget.detail?.studioAddress,
                      style2: const TextStyle().medium.copyWith(
                            fontSize: 16.sp,
                            color: Colors.black54,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget studioLogo(String? studioImg) {
    return Container(
     // radius: 46.r,
    //  backgroundColor: Colors.greenAccent,
      //clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.symmetric(
        horizontal: 5.h,
        vertical: 5.h,
      ),
      decoration: BoxDecoration(
        color: Colors.green,
       shape: BoxShape.circle,
        // borderRadius: BorderRadius.circular(70.r),
        border: Border.all(color: Colors.white,),
        //borderRadius: BorderRadius.circular(50.r)
      ),
      child: AppLocalFileImage(
        imageUrl: studioImg ?? "",
       radius: 70.r,
        fit: BoxFit.fill,
        height: 120.h,
        width: 120.h,
      ),
    );
  }

  Widget infoWidget({
    String? title1,
    String? title2,
    TextStyle? style1,
    TextStyle? style2,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title1 ?? "N/A",
          style: style1 ?? const TextStyle(),
        ),
        5.toSpace(),
        Text(
          title2 ?? "N/A",
          style: style2 ?? const TextStyle(),
        ),
      ],
    );
  }

  Widget divider() {
    return const Divider(
      color: Colors.black54,
    );
  }
}
