import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class BankRow extends StatelessWidget {

  final Map wObj;

  const BankRow({super.key, required this.wObj});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(wObj["icon"],width: 50, height: 50,),
          const SizedBox(width: 8,),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wObj["name"],
                    style: TextStyle(
                        color: TColor.primaryText,
                        fontSize: 16
                    ),
                  ),
                  Text(
                    wObj["number"],
                    style: TextStyle(
                        color: TColor.primaryText,
                        fontSize: 14
                    ),
                  )
                ],
              )
          )
        ],
      ),
    );
  }
}
