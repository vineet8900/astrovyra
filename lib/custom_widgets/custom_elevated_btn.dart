import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color textColor;
  final double elevation;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;
  final TextStyle textStyle;
  final List<BoxShadow>? boxShadow; // 👈 optional, no default shadow

  const CustomElevatedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.elevation = 2.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.textStyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    this.boxShadow, // 👈 optional (no default)
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      width: 260,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        // 👇 only show shadow if given
        boxShadow: boxShadow,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: textColor,
          backgroundColor: backgroundColor ?? CustomStyles.pinki,
          iconColor: Colors.white,
          elevation:
              2, // disable default elevation so only custom shadow appears
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          textStyle: textStyle,
        ),
        child: Text(text, style: textStyle),
      ),
    );
  }
}

class CustomElevatedButtonRow extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color textColor;
  final double elevation;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;
  final TextStyle textStyle;

  CustomElevatedButtonRow({
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xffFF6038),
    this.textColor = Colors.white,
    this.elevation = 2.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.textStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      width: 230,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: textColor,
          backgroundColor: CustomStyles.bgcolor,
          elevation: elevation,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
          ),
          textStyle: textStyle,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: CustomStyles.black14500,
            ),
            SizedBox(
              width: 10,
            ),
            Icon(
              Icons.arrow_forward,
              size: 20,
            )
          ],
        ),
      ),
    );
  }
}

class CustomOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final TextStyle? textstyle;
  final Color? backgroundColor;
  final Color? bordercolor;
  final double? width;
  final double? height;

  CustomOutlinedButton(
      {required this.text,
      this.onPressed,
      this.backgroundColor,
      this.height,
      this.textstyle,
      this.width,
      this.bordercolor});

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;
    return SizedBox(
      width: width ?? 300,
      height: height ?? 42,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsetsDirectional.zero,
          side: BorderSide(color: bordercolor ?? CustomStyles.pinki, width: 1),
          backgroundColor: isEnabled
              ? (backgroundColor ?? CustomStyles.pinki)
              : Colors.grey.shade200,
          //backgroundColor??CustomStyles.bgcolor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusDirectional.circular(5),
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: textstyle ??
                    (isEnabled
                        ? CustomStyles.black14600.copyWith(color: Colors.white)
                        : CustomStyles.black14600
                            .copyWith(color: Colors.grey.shade600)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OutOfStockStyledButton extends StatelessWidget {
  final double? height;
  final double? width;

  const OutOfStockStyledButton({
    super.key,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 40,
      width: width ?? double.infinity,
      child: Material(
        elevation: 2,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade600,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'out_of_stock'.tr,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
