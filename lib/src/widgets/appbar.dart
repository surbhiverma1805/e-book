import 'package:ebook/src/utils/extension/text_style_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leadingIcon;

  const CustomAppBar(
      {super.key, required this.title, this.actions, this.leadingIcon});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leadingIcon,
      title: Text(
        title,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle().bold.copyWith(
              color: Colors.white,
              fontSize: 18.sp,
            ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}
