import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String title;
  String? errortext;
  final IconData? icon;
  final bool? obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String? starsign;
  TextInputType? textInputType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int? maxLength;
  final int? maxline;
  final double? height;
  final ValueChanged<String>? onChanged;
  final Function()? onTap;
  final bool? readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final Color? fillColor;
  /// Corner radius for the outline border (default matches Material ~4).
  final double outlineBorderRadius;

  CustomTextField(
      {this.starsign,
      this.height,
      this.errortext,
      required this.title,
      required this.label,
      this.prefixIcon,
      this.icon,
      this.obscureText = false,
      required this.controller,
      this.maxline,
      this.validator,
      this.textInputType,
      this.suffixIcon,
      this.maxLength,
      this.onChanged,
      this.onTap,
      this.readOnly,
      this.inputFormatters,
      this.focusNode,
      this.fillColor,
      this.outlineBorderRadius = 4});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  Color borderColor = Colors.grey.shade300;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("${widget.title}", style: CustomStyles.black14500),
            Text(widget.starsign ?? '', style: TextStyle(color: Colors.red)),
          ],
        ),
        IntrinsicHeight(
          child: TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            // focusNode: _focusNode,
            keyboardType: widget.textInputType,
            inputFormatters: widget.inputFormatters,
            validator: (value) {
              String? result = widget.validator?.call(value);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    widget.errortext = result;
                  });
                }
              });
              return result;
            },
            style: CustomStyles.black14400,
            controller: widget.controller,
            maxLength: widget.maxLength,
            maxLines: widget.maxline ?? 1,
            readOnly: widget.readOnly ?? false,
            onChanged: widget.onChanged,
            obscureText: widget.obscureText ?? false,
            onTap: widget.onTap,
            decoration: InputDecoration(
              counterText: '',
              suffixIcon: widget.suffixIcon,
              prefixIcon: widget.prefixIcon,
              hintStyle: CustomStyles.grey14400,
              hintText: widget.label,
              filled: true,
              isDense: true,
              fillColor: widget.fillColor ?? Colors.white,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              errorBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(widget.outlineBorderRadius),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(widget.outlineBorderRadius),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(widget.outlineBorderRadius),
                borderSide: BorderSide(color: borderColor),
              ),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(widget.outlineBorderRadius),
                borderSide: BorderSide(color: borderColor),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }
}
