import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:transport_app/common/common_extension.dart';

import '../common/color_extension.dart';

class SupportUserRow extends StatelessWidget {

  final Map uObj;
  final VoidCallback onPressed;

  const SupportUserRow({super.key, required this.onPressed, required this.uObj});

  @override
  Widget build(BuildContext context) {

    var baseCount = uObj["base_count"] as int? ?? 0;

    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: TColor.bg,
          borderRadius: BorderRadius.circular(20)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.asset(
                "assets/images/u1.png",
                width: 50,
                height: 50,
              ),
            ),
        
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  uObj["name"] as String? ?? "",
                  style: TextStyle(
                      color: TColor.primaryText,
                      fontWeight: FontWeight.w700,
                      fontSize: 13
                  ),
                ),
                Text(
                  uObj["message"] as String? ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 14
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  (uObj["created_date"] as String? ?? "").timeAgo(),
                  style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 13
                  ),
                ),
                if(baseCount>0)
                  Container(
                    constraints: BoxConstraints(minWidth: 20, minHeight: 10),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                        color: TColor.primary,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Text(
                      baseCount.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: TColor.bg,
                          fontSize: 11,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                  )
              ],
            )
          ],
        ),
      ),
    );
  }
}
