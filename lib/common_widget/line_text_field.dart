import "dart:math";

import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:transport_app/common/color_extension.dart";

class LineTextField extends StatelessWidget {

  final String title;
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool? obscureText;
  final Widget? right;
  final int? minLines;
  final int? maxLines;

  const LineTextField({super.key,
    required this.title,
    required this.hintText,
    required this.controller,
    required this.keyboardType,
    this.obscureText,
    this.right,
    this.minLines = 1,
    this.maxLines = 1
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            color: TColor.placeholder,
            fontSize: 12
          )
        ),
        SizedBox(height: 4,),
        TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText != null && obscureText == true ? true : false,
            minLines: minLines,
            maxLines: maxLines,
            style: TextStyle(
              color: TColor.primaryText,
              fontSize: 16
            ),
            decoration: InputDecoration(
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: hintText,
              suffixIcon: right,
              hintStyle: TextStyle(color: TColor.placeholder, fontSize:  16)
            ),
          ),
          Container(
            color: TColor.lightGray,
            height: 0.5,
            width: double.infinity,
          )
      ],
    );
  }
}