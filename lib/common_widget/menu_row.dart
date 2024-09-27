
import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class MenuRow extends StatelessWidget {

  final String title;
  final String icon;
  final VoidCallback onPress;

  const MenuRow({super.key, required this.title, required this.icon, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Container(
        color: TColor.lightGray.withOpacity(0.4),
        padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(width: 25),
            Image.asset(icon,width: 30,height: 30,color: TColor.secondaryText,),
            SizedBox(width: 25),
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.w700
                      ),
                    )
                  ],
                )
            )
          ],
        ),
      ),
    );
  }
}
