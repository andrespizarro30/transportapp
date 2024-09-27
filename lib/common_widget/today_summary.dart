import 'package:flutter/material.dart';
import 'package:transport_app/common/common_extension.dart';

import '../common/color_extension.dart';

class TodaySummaryView extends StatelessWidget {

  final Map sObj;

  const TodaySummaryView({super.key, required this.sObj});

  @override
  Widget build(BuildContext context) {

    var price = double.tryParse(sObj["amt"].toString()) ?? 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                sObj["start_time"].toString().dataFormat().stringFormat(format: "hh:mm"),
                style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 16
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: TColor.bg,
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Text(
                  sObj["start_time"].toString().dataFormat().stringFormat(format: "aa"),
                  style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 11,
                      fontWeight: FontWeight.w700
                  ),
                ),
              )
            ],
          ),
          const SizedBox(width: 8,),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sObj["pickup_address"] as String? ?? "",
                    maxLines: 1,
                    style: TextStyle(
                        color: TColor.primaryText,
                        fontSize: 16
                    ),
                  ),
                  Text(
                    "Paid by ${sObj["payment_type"] == 1 ? "cash" : "online"}",
                    style: TextStyle(
                        color: TColor.primaryText,
                        fontSize: 15
                    ),
                  )
                ],
              )
          ),
          const SizedBox(width: 8,),
          Text(
            "\$${price.toStringAsFixed(2)}",
            style: TextStyle(
                color: TColor.primaryText,
                fontSize: 15
            ),
          )
        ],
      ),
    );
  }
}
