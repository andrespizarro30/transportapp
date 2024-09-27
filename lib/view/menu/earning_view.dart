import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:transport_app/common_widget/price_list_view.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../common/color_extension.dart';

class EarningView extends StatefulWidget {
  const EarningView({super.key});

  @override
  State<EarningView> createState() => _EarningViewState();
}

class _EarningViewState extends State<EarningView> with SingleTickerProviderStateMixin {

  TabController? controller;

  int touchedIndex = 0;

  Map todayObj = {
    "trips": "15",
    "hrs": "8:30",
    "cash_trip": "\$22.48",
    "trip_fares": "\$40.25",
    "fee": "\$20.00",
    "tax": "\$400.50",
    "tolls": "\$400.50",
    "surge": "\$300.50",
    "discount": "\$400.50",
    "total": "\$400.50",
  };

  Map weekObj = {
    "trips": "45",
    "hrs": "38:30",
    "cash_trip": "\$88.48",
    "trip_fares": "\$160.25",
    "fee": "\$80.00",
    "tax": "\$800.50",
    "tolls": "\$800.50",
    "surge": "\$800.50",
    "discount": "\$800.50",
    "total": "\$2400.50",
  };

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
  }

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
        title: Text("Earning",
          style: TextStyle(
              color: TColor.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w800
          ),
        ),
      ),
      body: Column(
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
              unselectedLabelStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800
              ),
              tabs: [
                Tab(text: "TODAY",),
                Tab(text: "WEEKLY",)
              ]
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
                            "Wed, 09 Sep 2024",
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
                                "150.500",
                                style: TextStyle(
                                    color: TColor.primaryText,
                                    fontSize:  25,
                                  fontWeight: FontWeight.w800
                                ),
                              )
                            ],
                          ),
                          PriceListView(dObj: todayObj)
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
                          const SizedBox(height: 30,),
                          Text(
                            "Wed, 09 Sep 2024",
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
                                "150.500",
                                style: TextStyle(
                                    color: TColor.primaryText,
                                    fontSize:  25,
                                    fontWeight: FontWeight.w800
                                ),
                              )
                            ],
                          ),
                          Container(
                            height: context.heigth * 0.3,
                            child: BarChart(
                              BarChartData(
                                barTouchData: BarTouchData(
                                  touchTooltipData: BarTouchTooltipData(
                                    tooltipHorizontalAlignment: FLHorizontalAlignment.right,
                                    tooltipMargin: 10,
                                    getTooltipItem: (group, groupIndex, rod, rodIndex){
                                      String weekDay;
                                      switch(group.x){
                                        case 0:
                                          weekDay = "Sunday - ${rod.toY-1}";
                                          break;
                                        case 1:
                                          weekDay = "Lunes - ${rod.toY-1}";
                                          break;
                                        case 2:
                                          weekDay = "Martes - ${rod.toY-1}";
                                          break;
                                        case 3:
                                          weekDay = "Miercoles - ${rod.toY-1}";
                                          break;
                                        case 4:
                                          weekDay = "Jueves - ${rod.toY-1}";
                                          break;
                                        case 5:
                                          weekDay = "Viernes - ${rod.toY-1}";
                                          break;
                                        case 6:
                                          weekDay = "Sabado - ${rod.toY-1}";
                                          break;
                                        default:
                                          throw Error();
                                      }
                                      return BarTooltipItem(
                                          '$weekDay\n',
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
                          PriceListView(dObj: weekObj)
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

    Widget text;
    switch(value.toInt()){
      case 0:
        text = Text(
          'D',
          style: style,
        );
        break;

      case 1:
        text = Text(
          'L',
          style: style,
        );
        break;

      case 2:
        text = Text(
          'M',
          style: style,
        );
        break;

      case 3:
        text = Text(
          'X',
          style: style
        );
        break;

      case 4:
        text = Text(
          'J',
          style: style,
        );
        break;

      case 5:
        text = Text(
          'V',
          style: style,
        );
        break;

      case 6:
        text = Text(
          'S',
          style: style,
        );
        break;

      default:
        text = Text(
          '',
          style: style,
        );
        break;
    }

    return SideTitleWidget(
        child: text,
        space: 16,
        axisSide: meta.axisSide);

  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (index){
    switch(index){
      case 0:
        return makeGroupData(0, 5, TColor.primary, isTouched: index == touchedIndex);
      case 1:
        return makeGroupData(1, 10.5, TColor.primary, isTouched: index == touchedIndex);
      case 2:
        return makeGroupData(2, 5, TColor.primary, isTouched: index == touchedIndex);
      case 3:
        return makeGroupData(3, 7, TColor.primary, isTouched: index == touchedIndex);
      case 4:
        return makeGroupData(4, 15, TColor.primary, isTouched: index == touchedIndex);
      case 5:
        return makeGroupData(5, 5.5, TColor.primary, isTouched: index == touchedIndex);
      case 6:
        return makeGroupData(6, 8.5, TColor.primary, isTouched: index == touchedIndex);
      default:
        return makeGroupData(6, 8.5, TColor.primary, isTouched: index == touchedIndex);
    }
  });

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
            toY: isTouched ? y + 1 : y,
            color: isTouched ? barColor : TColor.lightGray,
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

}
