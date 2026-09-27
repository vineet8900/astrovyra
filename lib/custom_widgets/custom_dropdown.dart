import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:flutter/material.dart';

class CustomDropdownField<T> extends StatefulWidget {
  final String? title;
  final String hintText;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final double height;
  final String? starsign;
  final double outlineBorderRadius;

  const CustomDropdownField({
    Key? key,
    this.title,
    required this.hintText,
    required this.items,
    this.value,
    this.onChanged,
    this.validator,
    this.height = 45,
    this.starsign,
    this.outlineBorderRadius = 4,
  }) : super(key: key);

  @override
  State<CustomDropdownField<T>> createState() => _CustomDropdownFieldState<T>();
}

class _CustomDropdownFieldState<T> extends State<CustomDropdownField<T>> {
  Color borderColor = Colors.grey.shade400;
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Row(
            children: [
              Text(widget.title!, style: CustomStyles.black14500),
              if (widget.starsign != null)
                Text(widget.starsign!,
                    style: const TextStyle(color: Colors.red)),
            ],
          ),
        const SizedBox(height: 5),
        DropdownButtonFormField<T>(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          value: widget.value,
          items: widget.items,
          onChanged: widget.onChanged,
          dropdownColor: Colors.white,
          style: CustomStyles.black14400,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey.shade400,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: CustomStyles.black14400,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            isDense: true,
            fillColor: Colors.white,
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
          validator: (value) {
            String? result = widget.validator?.call(value);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _errorText != result) {
                setState(() {
                  _errorText = result;
                });
              }
            });
            return result;
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
