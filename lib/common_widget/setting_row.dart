import 'package:flutter/material.dart';
import 'package:transport_app/common/color_extension.dart';

class SettingRow extends StatelessWidget {

  final String title;
  final String icon;
  final VoidCallback onPressed;

  const SettingRow({super.key, required this.title, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Column(
          children: [
            Row(
              children: [
                Image.asset(icon,width: 30, height: 30,),
                const SizedBox(width: 15,),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 18
                    ),
                  )
                )
              ],
            ),
            Divider(thickness: 3,color: TColor.lightWhite,)
          ],
        ),
      ),
    );
  }
}
