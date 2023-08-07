import 'dart:ffi';
import 'dart:io';

import 'package:ebook/src/utils/extension/space.dart';
import 'package:ebook/src/utils/extension/text_style_decoration.dart';
import 'package:ebook/src/widgets/app_images.dart';
import 'package:ebook/src/widgets/custom_app_bar.dart';
import 'package:ebook/utility/utility.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderView extends StatefulWidget {
  const OrderView({
    Key? key,
    this.frontImage,
    this.studioName,
  }) : super(key: key);
  final String? frontImage, studioName;

  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  List<String> ddOptionList = ["Album", "Photos", "Photo Shoot"];

  String dropdownValue = "Album";

  @override
  Widget build(BuildContext context) {
    print("name ${widget.studioName}");
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: NewAppBar(
        isLeading: true,
        title: "Order",
        centerInTitle: true,
        onTap: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 22.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              albumImageWidget(),
              18.toSpace(),
              Align(
                alignment: Alignment.center,
                child: Text(
                  widget.studioName?.toUpperCase() ?? "",
                  style: const TextStyle().medium.copyWith(
                    fontSize: 18.sp,
                    color: Colors.black,
                  ),
                ),
              ),
              18.toSpace(),
              header("I want to Place an Order"),
              10.toSpace(),
              orderOptionDD(),
              12.toSpace(),
              header("My contact details are"),
              10.toSpace(),
              contactWidget(
                iconName: Icons.person,
                controller: nameController,
                hintText: "Name",
                inputType: TextInputType.name,
                inputAction: TextInputAction.next,
              ),
              10.toSpace(),
              contactWidget(
                iconName: Icons.email,
                controller: emailController,
                hintText: "Email",
                inputType: TextInputType.emailAddress,
                inputAction: TextInputAction.next,
              ),
              10.toSpace(),
              contactWidget(
                iconName: Icons.phone_android,
                controller: mobileController,
                hintText: "Mobile",
                inputType: TextInputType.phone,
                inputAction: TextInputAction.done,
              ),
              30.toSpace(),
              orderBtn(),
            ],
          ),
        ),
      ),
    );
  }

  Widget albumImageWidget() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: Utility.getHeight(context: context) * 0.25,
        width: Utility.getWidth(context: context) * 0.4,
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
              child: Image.file(
                File(widget.frontImage ?? ""),
                height: Utility.getHeight(context: context) * 0.25,
                width: Utility.getWidth(context: context) * 0.4,
                fit: BoxFit.fill,
              ),
            ),
            Positioned(
              left: 8.w,
              child: Container(
                height: Utility.getHeight(context: context) * 0.25,
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
      ),
    );
  }

  Widget header(String text) {
    return Text(
      text,
      style: const TextStyle().semiBold.copyWith(
            fontSize: 18.sp,
            color: Colors.grey.shade600,
          ),
    );
  }

  Widget orderOptionDD() {
    return Container(
      padding: EdgeInsets.only(left:10.w, right: 5.w, top: 6.h, bottom: 6.h),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(5.r),
      ),
      alignment: Alignment.centerLeft,
      child: DropdownButton(
        value: dropdownValue,
        underline: const SizedBox.shrink(),
        isExpanded: true,
        items: ddOptionList.map((String ddOption) {
          return DropdownMenuItem(value: ddOption, child: Text(ddOption));
        }).toList(),
        onChanged: (val) {
          setState(() {
            dropdownValue = val!;
          });
        },
      ),
    );
  }

  Widget contactWidget({
    required IconData iconName,
    required TextEditingController controller,
    required String hintText,
    required TextInputType inputType,
    required TextInputAction inputAction,
  }) {
    return Row(
      children: [
        Icon(
          iconName,
          color: Colors.grey,
          size: 30.sp,
        ),
        6.toSpace(),
        Expanded(
          child: TextFormField(
            controller: controller,
            style: const TextStyle().regular.copyWith(
                  fontSize: 14.sp,
                  color: Colors.black,
                ),
            maxLines: 1,
            keyboardType: inputType,
            textInputAction: inputAction,
            cursorColor: Colors.black,
            cursorHeight: 6,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle().regular.copyWith(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              disabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget orderBtn() {
    return Align(
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: () {
          String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
          RegExp regExp = RegExp(pattern);
          if (nameController.text.isEmpty) {
            Utility.showToast("Please enter name");
          } else if (emailController.text.isEmpty || !EmailValidator.validate(emailController.text)) {
            Utility.showToast("Please enter correct email");
          }  else if (mobileController.text.isEmpty) {
            Utility.showToast("Phone number can't be empty");
          } else if (!regExp.hasMatch(mobileController.text)) {
            Utility.showToast("Phone number will be only numbers");
          } else {
            Utility.showToast("Yeah!! Ordered Successfully.", bgColor: Colors.green);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade900,
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        ),
        child: Text(
          "ORDER",
          style: const TextStyle().bold.copyWith(
                color: Colors.white,
                fontSize: 18.sp,
              ),
        ),
      ),
    );
  }
}
