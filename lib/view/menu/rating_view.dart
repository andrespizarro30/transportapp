import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:transport_app/common_widget/rating_row.dart';

import '../../common/color_extension.dart';

class RatingView extends StatefulWidget {
  const RatingView({super.key});

  @override
  State<RatingView> createState() => _RatingViewState();
}

class _RatingViewState extends State<RatingView> {

  int touchedIndex = -1;
  double degrees = 270;

  List listArray = [
    {
      "rate":4.5,
      "message": "Your service is very good, the expirience that I had was incredible"
    },
    {
      "rate":5.0,
      "message": "Your service is very good, the expirience that I had was incredible"
    },
    {
      "rate":4.0,
      "message": "So so"
    },
    {
      "rate":3.5,
      "message": "N/A"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.bg,
        elevation: 1,
        leading: IconButton(
          onPressed: (){
            context.pop();
          },
          icon: Image.asset("./assets/images/back.png",width: 25,height: 25,),
        ),
        centerTitle: true,
        title: Text("Ratings",
          style: TextStyle(
              color: TColor.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w800
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.maxFinite,
              height: 8,
              color: TColor.lightWhite,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "4.5",
                            style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 25,
                              fontWeight: FontWeight.w800
                            ),
                          ),
                          RatingBar.builder(
                            initialRating: 3,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 20,
                            itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.green,
                            ),
                            onRatingUpdate: (rating) {
                              print(rating);
                            },
                          ),
                          const SizedBox(height: 8,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset("./assets/images/sm_profile.png",width: 25,height: 25,),
                              const SizedBox(width: 15,),
                              Text(
                                "1415 user",
                                style: TextStyle(
                                    color: TColor.secondaryText,
                                    fontSize: 16                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: PieChart(
                            PieChartData(
                                pieTouchData: PieTouchData(
                                    touchCallback: (FlTouchEvent event,pieTouchResponse){
                                      setState(() {
                                        if(!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null){
                                          touchedIndex = -1;
                                          return;
                                        }
                                        touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                      });
                                    }
                                ),
                                borderData: FlBorderData(show: false),
                                sectionsSpace: 4,
                                centerSpaceRadius: 60,
                                startDegreeOffset: degrees,
                                sections: showingSections()
                            )
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            "2547",
                            style: TextStyle(
                                color: TColor.primaryText,
                                fontSize: 18,
                                fontWeight: FontWeight.w800
                            ),
                          ),
                          Text(
                            "Total trips",
                            style: TextStyle(
                                color: TColor.secondaryText,
                                fontSize: 16                                ),
                          )
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 30,bottom: 8),
              width: double.maxFinite,
              height: 15,
              color: TColor.lightWhite,
              child: Text(
                "OCT 24",
                style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w800
                ),
              ),
            ),
            ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index){
                return RatingRow(rObj: listArray[index]);
              },
              separatorBuilder: (context, index)=>const Divider(),
              itemCount: listArray.length
            )
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(2, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 30.0 : 20.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: TColor.primary,
            value: 30,
            title: '30%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: TColor.primary.withOpacity(0.3),
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: TColor.secondary,
            value: 70,
            title: '70%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: TColor.secondary.withOpacity(0.3),
              shadows: shadows,
            ),
          );
        default:
          throw Error();
      }
    });
  }

}
