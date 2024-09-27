import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class IconTitleSubtitleButton extends StatelessWidget {

  final String title;
  final String subTitle;
  final Icon icon;
  final VoidCallback onPress;

  const IconTitleSubtitleButton({super.key, required this.title, required this.subTitle, required this.icon, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){

      },
      child: Column(
        children: [
          icon,
          const SizedBox(height: 8,),
          Text(
            title,
            style: TextStyle(
                color: TColor.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w800
            ),
          ),
          const SizedBox(height: 8,),
          Text(
            subTitle,
            style: TextStyle(
                color: TColor.secondaryText,
                fontSize: 16,
                fontWeight: FontWeight.w800
            ),
          )
        ],
      ),
    );
  }
}
