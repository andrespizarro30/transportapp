import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class TitleSubtitleRow extends StatelessWidget {

  final String title;
  final String subTitle;
  final Color? color;
  final FontWeight? fontWeight;

  const TitleSubtitleRow({super.key, required this.title, required this.subTitle, this.color, this.fontWeight});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: color ?? TColor.primaryText,
                fontSize: 15,
                fontWeight: fontWeight ?? FontWeight.w400
            ),
          ),
          Text(
            subTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: color ?? TColor.primaryText,
                fontSize: 15,
                fontWeight: fontWeight ?? FontWeight.w600
            ),
          )
        ],
      ),
    );
  }
}
