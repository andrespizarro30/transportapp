import 'package:flutter/material.dart';
import 'package:transport_app/common_widget/title_subtiltle_cell.dart';
import 'package:transport_app/common_widget/title_subtitle_row.dart';

import '../common/color_extension.dart';

class PriceListView extends StatelessWidget {

  final Map dObj;

  const PriceListView({super.key, required this.dObj});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 15,),
        Container(
          color: TColor.lightGray,
          height: 0.5,
          width: double.infinity,
        ),
        Row(
          children: [
            Expanded(
                child: TitleSubtitleCell(
                  title: dObj["trips"],
                  subTitle: "Trips",
                )
            ),
            Container(
              height: 80,
              width: 0.5,
              color: TColor.lightGray,
            ),
            Expanded(
                child: TitleSubtitleCell(
                  title: dObj["hrs"],
                  subTitle: "Online Hours",
                )
            ),
            Container(
              height: 80,
              width: 0.5,
              color: TColor.lightGray,
            ),
            Expanded(
                child: TitleSubtitleCell(
                  title: dObj["cash_trip"],
                  subTitle: "Cash Trip",
                )
            )
          ],
        ),
        Container(
          width: double.infinity,
          height: 0.5,
          color: TColor.lightGray,
        ),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 20),
              child: Column(
                children: [
                  TitleSubtitleRow(title: "Trip fares", subTitle: dObj["trip_fares"], color: TColor.secondaryText,),
                  TitleSubtitleRow(title: "Fee", subTitle: dObj["fee"], color: TColor.secondaryText,),
                  TitleSubtitleRow(title: "+ Tax", subTitle: dObj["tax"], color: TColor.secondaryText,),
                  TitleSubtitleRow(title: "+ Tolls", subTitle: dObj["tolls"], color: TColor.secondaryText,),
                  TitleSubtitleRow(title: "+ Surge", subTitle: dObj["surge"], color: TColor.secondaryText,),
                  TitleSubtitleRow(title: "Discount (-)", subTitle: dObj["discount"], color: TColor.secondaryText,),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TitleSubtitleRow(title: "Total Earnings", subTitle: dObj["total"], color: TColor.primary,fontWeight: FontWeight.w800,),
                  )
                ],
              ),
            ),
            SizedBox(height: 8,),
          ],
        )
      ],
    );
  }
}
