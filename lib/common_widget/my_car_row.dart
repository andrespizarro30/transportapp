import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:transport_app/common/color_extension.dart';

class MyCarRow extends StatelessWidget {

  final Map cObj;
  final VoidCallback onPressed;

  const MyCarRow({super.key, required this.cObj, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${cObj["brand_name"] as String? ?? ""} - ${cObj["model_name"] as String? ?? ""} - ${cObj["series_name"] as String? ?? ""}",
                      style: TextStyle(color: TColor.primaryText,fontSize: 16),
                    ),
                    Text(
                      cObj["car_number"] as String? ?? "",
                      style: TextStyle(color: TColor.secondaryText,fontSize: 15),
                    )
                  ],
                ),
            ),
            SizedBox(width: 8,),

            if(cObj["is_set_running"]==1)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(Icons.pin_drop_outlined, color: TColor.primary, size: 25,),
              ),

            if(cObj["car_image"] != "")
              CachedNetworkImage(imageUrl: cObj["car_image"] as String? ?? "",width: 50,height: 50,fit: BoxFit.cover,)
          ],
        ),
      ),
    );
  }
}
