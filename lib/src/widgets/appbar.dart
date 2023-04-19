import 'package:flutter/material.dart';

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
      title: Text(title),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}
