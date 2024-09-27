import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class IconTitleButton extends StatelessWidget {

  final String title;
  final Icon icon;
  final VoidCallback onPress;

  const IconTitleButton({super.key, required this.title, required this.icon, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Column(
        children: [
          icon,
          const SizedBox(height: 8,),
          Text(
            title,
            style: TextStyle(
                color: TColor.primaryText,
                fontSize: 16
            ),
          ),
          const SizedBox(height: 8,),
        ],
      ),
    );
  }
}
