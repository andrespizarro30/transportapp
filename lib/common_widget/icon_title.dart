import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class IconTitle extends StatelessWidget {

  final String title;
  final String icon;
  final double? width;
  final VoidCallback onPress;

  const IconTitle({super.key, required this.title, required this.icon, required this.onPress, this.width = 50});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(icon, width: width,height: width,),
          SizedBox(height: 4,),
          Text(
            title,
            style: TextStyle(
                color: TColor.primaryTextW,
                fontSize: 14,
                fontWeight: FontWeight.w600
            ),
          )
        ],
      ),
    );
  }
}
