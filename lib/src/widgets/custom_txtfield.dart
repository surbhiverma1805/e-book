import 'package:ebook/src/utils/extension/text_style_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final int? maxLength;
  final String? Function(String?)? validator;

  const CustomTextField({
    Key? key,
    this.controller,
    this.hintText,
    this.labelText,
    this.maxLength,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: TextFormField(
        style: const TextStyle().bold.copyWith(
            fontSize: 28.sp, letterSpacing: 5.0, fontWeight: FontWeight.w900),
        controller: controller,
        validator: validator,
        maxLength: maxLength ?? 4,
        cursorColor: Colors.red.shade900,
        textCapitalization: TextCapitalization.characters,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
            counterText: "",
            hintText: hintText,
            hintStyle: const TextStyle()
                .semiBold
                .copyWith(fontSize: 20.sp, letterSpacing: 1.0),
            labelText: labelText,
            border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black)),
            enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black)),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black))),
        onChanged: (val) {
          /*if (val.length == 4) {
            FocusScope.of(context).nextFocus();
          }*/
        },
      ),
    );
  }
}
