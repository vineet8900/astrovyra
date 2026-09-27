import 'package:astrokavach/custom_widgets/cart_icon.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final String title;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? titleTextStyle;
  final PreferredSizeWidget? bottom;
  bool? automaticallyImplyLeading;

  CustomAppBar({
    this.leading,
    required this.title,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.titleTextStyle,
    this.automaticallyImplyLeading,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 45,
      automaticallyImplyLeading: automaticallyImplyLeading ?? true,
      leading: leading,
      foregroundColor: foregroundColor,
      title: Text(
        title,
        style: titleTextStyle ?? CustomStyles.black16600,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions:
          actions ?? [], // If no actions provided, an empty list will be used
      backgroundColor: backgroundColor ?? Colors.white,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}
