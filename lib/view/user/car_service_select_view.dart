import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:transport_app/common/dbhelpers.dart';
import 'package:transport_app/common_widget/round_button.dart';

import '../../common/appLocalizations .dart';
import '../../common/color_extension.dart';

class CarServiceSelectView extends StatefulWidget {

  final List serviceArr;
  final Function(dynamic) didSelect;

  const CarServiceSelectView({super.key, required this.serviceArr, required this.didSelect});

  @override
  State<CarServiceSelectView> createState() => _CarServiceSelectViewState();
}

class _CarServiceSelectViewState extends State<CarServiceSelectView> {

  int selectIndex = 0;

  List<num> maxValsList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    for (int index = 0; index < widget.serviceArr.length; index++) {
      var cObj = widget.serviceArr[index] as Map? ?? {};
      var estMaxVal = ((cObj["est_price_max"] as double? ?? 0.0) % 100)>0 ? ((cObj["est_price_max"] as double? ?? 0.0) ~/ 100) * 100 + 100 : (cObj["est_price_max"] as double? ?? 0.0);
      maxValsList.add(estMaxVal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(25),
            topLeft: Radius.circular(25)
        ),
        boxShadow: const[
          BoxShadow(color: Colors.black26,blurRadius: 5)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
            child: Text(
              AppLocalizations.of(context).translate('select_car_service'),
              style: TextStyle(
                color: TColor.primaryText,
                fontSize: 17,
                fontWeight: FontWeight.w700
              ),
            ),
          ),
          const SizedBox(height: 15,),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 170,
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context,index){
                  var cObj = widget.serviceArr[index] as Map? ?? {};

                  var estMinVal = ((cObj["est_price_min"] as double? ?? 0.0) % 100)>0 ? ((cObj["est_price_min"] as double? ?? 0.0) ~/ 100) * 100 + 100 : (cObj["est_price_min"] as double? ?? 0.0);
                  var estMaxVal = ((cObj["est_price_max"] as double? ?? 0.0) % 100)>0 ? ((cObj["est_price_max"] as double? ?? 0.0) ~/ 100) * 100 + 100 : (cObj["est_price_max"] as double? ?? 0.0);

                  return InkWell(
                    onTap: (){
                      setState(() {
                        selectIndex = index;
                      });
                    },
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 45),
                              padding: const EdgeInsets.only(left: 90),
                              width: 200,
                              height: 100,
                              decoration: BoxDecoration(
                                  color: selectIndex == index ? Colors.amberAccent : Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                        color: selectIndex == index ? Colors.redAccent : Colors.black26,
                                        blurRadius: 20,
                                      offset: Offset.zero
                                    )
                                  ]
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cObj[DBHelper.service_name],
                                    style: TextStyle(
                                        color: TColor.primaryText,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700
                                    ),
                                  ),
                                  Text(
                                    "\$${estMinVal.toStringAsFixed(0)} - \$${estMaxVal.toStringAsFixed(0)}",
                                    style: TextStyle(
                                        color: TColor.primary,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: CachedNetworkImage(
                                imageUrl: cObj["icon"] as String? ?? "",
                                fit: BoxFit.cover,
                                width: 130,
                                height: 100,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: (){
                                setState(() {
                                  selectIndex = index;
                                  maxValsList[index] = maxValsList[index] - 500;
                                  if(maxValsList[index]<estMinVal){
                                    maxValsList[index] = estMinVal;
                                  }
                                });
                              },
                              child: Text('-500'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  backgroundColor: TColor.primary
                              ),
                            ),
                            SizedBox(width: 20),
                            Text(
                              maxValsList[index].toString(),
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(width: 20), // Spacing between buttons
                            ElevatedButton(
                              onPressed: (){
                                setState(() {
                                  selectIndex = index;
                                  maxValsList[index] = maxValsList[index] + 500;
                                  if(maxValsList[index]>(estMaxVal*2)){
                                    maxValsList[index] = estMaxVal*2;
                                  }
                                });
                              },
                              child: Text('+500'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                backgroundColor: TColor.primary
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
                separatorBuilder: (context,index)=> const SizedBox(width: 15,),
                itemCount: widget.serviceArr.length
            ),
          ),

          const SizedBox(height: 15,),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
            child: RoundButton(
                title: AppLocalizations.of(context).translate('book_ride'),
                onPressed: (){
                  context.pop();
                  widget.serviceArr[selectIndex]["est_price_max"] = maxValsList[selectIndex].toDouble();
                  widget.didSelect(widget.serviceArr[selectIndex] as Map? ?? {});
                }
            ),
          )
        ],
      ),
    );
  }
}
