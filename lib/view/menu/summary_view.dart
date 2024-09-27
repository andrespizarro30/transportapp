import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:transport_app/common/common_extension.dart';
import 'package:transport_app/common_widget/price_list_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:transport_app/common_widget/today_summary.dart';
import 'package:transport_app/common_widget/weekly_summary.dart';

import '../../common/color_extension.dart';
import '../../common/globs.dart';
import '../../common/service_call.dart';
import '../../common_widget/title_subtiltle_cell.dart';
import '../../common_widget/title_subtitle_row.dart';

class SummaryView extends StatefulWidget {
  const SummaryView({super.key});

  @override
  State<SummaryView> createState() => _SummaryViewState();
}

class _SummaryViewState extends State<SummaryView> with SingleTickerProviderStateMixin {

  TabController? controller;

  int touchedIndex = -1;

  Map todayObj = {};
  Map weekObj = {};

  List todayTripsArr = [];

  List weeklyTripsArr = [];

  List weeklyChartArr = [];

  bool isApiData = false;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
    apiDataSummary();
  }

  @override
  Widget build(BuildContext context) {
    
    var todayTotal = double.tryParse(todayObj["total_amt"].toString()) ?? 0.0;
    var todayCashTotal = double.tryParse(todayObj["cash_amt"].toString()) ?? 0.0;
    var todayOnlineTotal = double.tryParse(todayObj["online_amt"].toString()) ?? 0.0;

    var weekTotal = double.tryParse(weekObj["total_amt"].toString()) ?? 0.0;
    var weekCashTotal = double.tryParse(weekObj["cash_amt"].toString()) ?? 0.0;
    var weekOnlineTotal = double.tryParse(weekObj["online_amt"].toString()) ?? 0.0;
    
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
        title: Text("Summary",
          style: TextStyle(
              color: TColor.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w800
          ),
        ),
      ),
      body:!isApiData ?
      Center(child: Text(
        "Loading...",
        style: TextStyle(
            color: TColor.primaryText,
            fontSize: 25,
            fontWeight: FontWeight.w700
        ),
      ),
      ) :
      Column(
        children: [
          const SizedBox(height: 8,),
          TabBar(
              controller: controller,
              indicatorColor: TColor.primary,
              indicatorPadding: const EdgeInsets.symmetric(horizontal: 20),
              labelColor: TColor.primary,
              unselectedLabelColor: TColor.placeholder,
              labelStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800
              ),
              tabs: [
                const Tab(text: "TODAY",),
                const Tab(text: "WEEKLY",)
              ],
              unselectedLabelStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800
              )
          ),
          Container(
            width: double.infinity,
            height: 0.5,
            color: TColor.lightGray,
          ),
          Expanded(
            child: TabBarView(
              controller: controller,
              children: [
                Container(
                  color: TColor.bg,
                  child: SingleChildScrollView(
                    child: Container(
                      color: TColor.bg,
                      child: Column(
                        children: [
                          const SizedBox(height: 30,),
                          Text(
                            DateTime.now().stringFormat(format: "EEE, dd MMM yy"),
                            style: TextStyle(
                                color: TColor.secondaryText
                            ),
                          ),
                          const SizedBox(height: 8,),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "\$",
                                style: TextStyle(
                                    color: TColor.primary,
                                    fontSize:  14,
                                    fontWeight: FontWeight.w800
                                ),
                              ),
                              Text(
                                todayTotal.toStringAsFixed(2),
                                style: TextStyle(
                                    color: TColor.primaryText,
                                    fontSize:  25,
                                    fontWeight: FontWeight.w800
                                ),
                              )
                            ],
                          ),
                          Column(
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
                                        title: (todayObj["trips_count"] as int ?? 0).toString(),
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
                                        title: "\$${todayOnlineTotal.toString()}",
                                        subTitle: "Online Trips",
                                      )
                                  ),
                                  Container(
                                    height: 80,
                                    width: 0.5,
                                    color: TColor.lightGray,
                                  ),
                                  Expanded(
                                      child: TitleSubtitleCell(
                                        title: "\$${todayCashTotal.toString()}",
                                        subTitle: "Cash Trip",
                                      )
                                  )
                                ],
                              ),
                              Container(
                                width: double.maxFinite,
                                height: 50,
                                color: TColor.lightGray,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "TRIPS",
                                  style: TextStyle(
                                      color: TColor.primaryText,
                                      fontSize:  15,
                                      fontWeight: FontWeight.w800
                                  ),
                                ),
                              ),
                              ListView.separated(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                                  itemBuilder: (context,index){
                                    var iObj = todayTripsArr[index] as Map? ?? {};
                                    return Container(
                                      child: TodaySummaryView(sObj: iObj,),
                                    );
                                  },
                                  separatorBuilder: (context, index)=>Divider(indent: 40,),
                                  itemCount: todayTripsArr.length
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  color: TColor.bg,
                  child: SingleChildScrollView(
                    child: Container(
                      color: TColor.bg,
                      child: Column(
                        children: [
                          const SizedBox(height: 40,),
                          Text(
                            DateTime.now().stringFormat(format: "EEE, dd MMM yy"),
                            style: TextStyle(
                                color: TColor.secondaryText
                            ),
                          ),
                          const SizedBox(height: 8,),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "\$",
                                style: TextStyle(
                                    color: TColor.primary,
                                    fontSize:  14,
                                    fontWeight: FontWeight.w800
                                ),
                              ),
                              Text(
                                  weekTotal.toStringAsFixed(2),
                                style: TextStyle(
                                    color: TColor.primaryText,
                                    fontSize:  25,
                                    fontWeight: FontWeight.w800
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 30,),
                          Container(
                            height: context.heigth * 0.3,
                            child: BarChart(
                                BarChartData(
                                    barTouchData: BarTouchData(
                                        touchTooltipData: BarTouchTooltipData(
                                            tooltipHorizontalAlignment: FLHorizontalAlignment.right,
                                            tooltipMargin: 10,
                                            getTooltipItem: (group, groupIndex, rod, rodIndex){
                                              var obj = weeklyChartArr[group.x] as Map? ?? {};
                                              var weekDay = obj["date"].toString().stringFormatToOtherFormat(newFormat: "EEEE");
                                              return BarTooltipItem(
                                                  '$weekDay\n\$${(double.tryParse(obj["total_amt"].toString()) ?? 0.0).toStringAsFixed(2)}',
                                                  TextStyle(
                                                      color: TColor.bg,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 16

                                                  )
                                              );
                                            }
                                        ),
                                        touchCallback: (event, barTouchResponse){
                                          setState(() {
                                            if(!event.isInterestedForInteractions || barTouchResponse == null || barTouchResponse.spot == null){
                                              touchedIndex = -1;
                                              return;
                                            }
                                            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                                          });
                                        }
                                    ),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      rightTitles: const AxisTitles(
                                          sideTitles: SideTitles(showTitles: false)
                                      ),
                                      topTitles: const AxisTitles(
                                          sideTitles: SideTitles(showTitles: false)
                                      ),
                                      bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(showTitles: true,
                                              getTitlesWidget: getTitles,
                                              reservedSize: 38
                                          )
                                      ),
                                      leftTitles: const AxisTitles(
                                          sideTitles: SideTitles(showTitles: false)
                                      ),
                                    ),
                                    borderData: FlBorderData(
                                        show: false
                                    ),
                                    barGroups: showingGroups(),
                                    gridData: const FlGridData(show: false)
                                )
                            ),
                          ),
                          Column(
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
                                        title: (weekObj["trips_count"] as int ?? 0).toString(),
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
                                        title: "\$${weekOnlineTotal.toString()}",
                                        subTitle: "Online Trips",
                                      )
                                  ),
                                  Container(
                                    height: 80,
                                    width: 0.5,
                                    color: TColor.lightGray,
                                  ),
                                  Expanded(
                                      child: TitleSubtitleCell(
                                        title: "\$${weekCashTotal.toString()}",
                                        subTitle: "Cash Trips",
                                      )
                                  )
                                ],
                              ),
                              Container(
                                width: double.maxFinite,
                                height: 50,
                                color: TColor.lightGray,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                alignment: Alignment.center,
                                child: Text(
                                  "TRIPS",
                                  style: TextStyle(
                                      color: TColor.primaryText,
                                      fontSize:  15,
                                      fontWeight: FontWeight.w800
                                  ),
                                ),
                              ),
                              ListView.separated(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                                  itemBuilder: (context,index){
                                    var iObj = weeklyChartArr[index] as Map? ?? {};
                                    return Container(
                                      child: WeeklySummaryView(sObj: iObj,),
                                    );
                                  },
                                  separatorBuilder: (context, index)=>Divider(indent: 40,),
                                  itemCount: weeklyChartArr.length
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget getTitles(double value, TitleMeta meta){

    var style = TextStyle(color: TColor.secondaryText, fontSize: 12);

    var obj = weeklyChartArr[value.toInt()] as Map? ?? {};

    return SideTitleWidget(
        child: Text(
          obj["date"].toString().stringFormatToOtherFormat(newFormat: "EEE")
        ),
        space: 16,
        axisSide: meta.axisSide);

  }
  
  List<BarChartGroupData> showingGroups() => weeklyChartArr.map((e){
    var index = weeklyChartArr.indexOf(e);
    return makeGroupData(index, double.tryParse(e["total_amt"].toString()) ?? 0.0, TColor.primary, isTouched: index == touchedIndex);
  }).toList();
  
  BarChartGroupData makeGroupData(
      int x, double y, Color barColor,{
        bool isTouched = false,
        double width = 40,
        List<int> showToolTips = const []
      }
      ){
    return BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
              toY: isTouched ? y + y*1.1 : y,
              color: isTouched ? barColor : TColor.secondary,
              width: width,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5)
              ),
              borderSide: isTouched ? BorderSide(color: TColor.primary) : BorderSide(color: TColor.secondary, width: 0),
              backDrawRodData: BackgroundBarChartRodData(
                  show: false
              )
          ),

        ]
    );
  }

  void apiDataSummary(){
    Globs.showHUD();
    ServiceCall.post(
        {},
        isTokenApi: true,
        SVKey.svDriverSummary,
        withSuccess: (responseObj)async{
          Globs.hideHUD();
          if(responseObj[KKey.status] == "1"){

            var payloadObj = responseObj[KKey.payload] as Map? ?? {};

            todayObj = payloadObj["today"] as Map? ?? {};
            weekObj = payloadObj["week"] as Map? ?? {};

            todayTripsArr = todayObj["list"] as List? ?? [];
            weeklyTripsArr = weekObj["list"] as List? ?? [];

            weeklyChartArr = (weekObj["chart"] as List? ?? []).reversed.toList();

            isApiData = true;
            if(mounted){
              setState(() {});
            }
          }else{
            mdShowAlert("Error", responseObj[KKey.message] as String? ?? MSG.fail,(){});
          }
        },
        failure: (err)async{
          Globs.hideHUD();
          debugPrint(err.toString());
        }
    );
  }

}
