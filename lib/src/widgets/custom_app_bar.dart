import 'package:ebook/src/utils/extension/text_style_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NewAppBar extends StatelessWidget implements PreferredSizeWidget{
  const NewAppBar({
    Key? key,
    this.title,
    this.isLeading,
    this.centerInTitle,
    this.elevation,
    this.bgColor,
    this.actions,
    this.onTap,
  }) : super(key: key);
  final String? title;
  final bool? isLeading;
  final bool? centerInTitle;
  final double? elevation;
  final Color? bgColor;
  final List<Widget>? actions;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: bgColor ?? Colors.black,
      centerTitle: centerInTitle,
      leading: isLeading ?? false
        ? InkWell(
        onTap: onTap ?? () => Navigator.pop(context),
        child: Padding(
          padding: EdgeInsets.only(left: 15.w),
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
      )
      : const SizedBox.shrink(),
      title: Text(title ?? "",
        style: const TextStyle().bold.copyWith(
          fontSize: 22.sp,
          color: Colors.white,
        ),
      ),
      actions: actions ?? [],
    );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;

}
