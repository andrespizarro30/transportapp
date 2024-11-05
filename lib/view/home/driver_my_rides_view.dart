import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:transport_app/common/color_extension.dart';
import 'package:transport_app/common/common_extension.dart';
import 'package:transport_app/view/home/run_ride_view.dart';
import 'package:transport_app/view/home/tip_detail_view.dart';

import '../../common/appLocalizations .dart';
import '../../common/globs.dart';
import '../../common/service_call.dart';

class DriverMyRidesView extends StatefulWidget {
  const DriverMyRidesView({super.key});

  @override
  State<DriverMyRidesView> createState() => _DriverMyRidesViewState();
}

class _DriverMyRidesViewState extends State<DriverMyRidesView> {

  List ridesArr = [];
  double totalAmount = 0.0;
  double driverAmount = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    apiAllRidesList();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          onPressed: (){
            context.pop();
          },
          icon: Image.asset("./assets/images/back.png",width: 25,height: 25,),
        ),
        centerTitle: true,
        title: Text(AppLocalizations.of(context).translate('my_rides'),
          style: TextStyle(
              color: TColor.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w800
          ),
        ),
        actions: [
          TextButton(
              onPressed: (){
                
              }, 
              child: Text(
                "\$${totalAmount.toStringAsFixed(0)}",
                style: TextStyle(
                  color: TColor.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800
                ),
              )
          )
        ],
      ),
      body: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          itemBuilder: (context, index){
            var rObj = ridesArr[index] as Map? ?? {};
            var km = double.tryParse(rObj["total_distance"].toString()) ?? 0.0;
            var rideTotalAmount = double.tryParse(rObj["amount"].toString()) ?? 0.0;
            var driverAmount = double.tryParse(rObj["driver_amt"].toString()) ?? 0.0;
            return InkWell(
              onTap: (){
                context.push(TipDetailView(bObj: rObj));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2)
                    ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CachedNetworkImage(imageUrl: rObj["icon"] as String? ?? "", width: 40, height: 40,fit: BoxFit.contain,),
                        const SizedBox(width: 15,),
                        Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rObj["service_name"] as String? ?? "",
                                  style: TextStyle(
                                      color: TColor.primaryText,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800
                                  ),
                                ),
                                Text(
                                  statusWiseDateTime(rObj),
                                  style: TextStyle(
                                      color: TColor.secondaryText,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800
                                  ),
                                )
                              ],
                            )
                        ),
                        Text(
                          statusText(rObj),
                          style: TextStyle(
                              color: statusColor(rObj),
                              fontSize: 17,
                              fontWeight: FontWeight.w700
                          ),
                        )
                      ],
                    ),
                    const Divider(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              color: TColor.secondary,
                              borderRadius: BorderRadius.circular(10)
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            rObj["pickup_address"] as String? ?? "",
                            maxLines: 3,
                            style: TextStyle(
                                color: TColor.secondaryText,
                                fontSize: 15
                            ),
                          ),
                        ),
                      ],
                    ),
                    if(rObj["booking_status"]>=bsStart)
                      const SizedBox(height: 8,),
                    if(rObj["booking_status"]>=bsStart)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                                color: TColor.primary
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              rObj["drop_address"] as String? ?? "",
                              maxLines: 3,
                              style: TextStyle(
                                  color: TColor.secondaryText,
                                  fontSize: 15
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8,),
                    if(rObj["booking_status"]==bsComplete)
                      Column(
                        children: [
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context).translate('total_distance')+":",
                                style: TextStyle(
                                    color: TColor.primaryText,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700
                                ),
                              ),
                              SizedBox(width: 10,),
                              Text(
                                "${km.toStringAsFixed(2)} Km",
                                style: TextStyle(
                                    color: TColor.secondaryText,
                                    fontSize: 15
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context).translate('duration')+":",
                                style: TextStyle(
                                    color: TColor.primaryText,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700
                                ),
                              ),
                              SizedBox(width: 10,),
                              Text(
                                rObj["duration"].toString(),
                                style: TextStyle(
                                    color: TColor.secondaryText,
                                    fontSize: 15
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context).translate('driver_amount'),
                                style: TextStyle(
                                    color: TColor.primaryText,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700
                                ),
                              ),
                              Text(
                                "\$${driverAmount.toStringAsFixed(2)}",
                                style: TextStyle(
                                    color: TColor.primary,
                                    fontSize: 17
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context).translate('total_amount'),
                                style: TextStyle(
                                    color: TColor.primaryText,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700
                                ),
                              ),
                              Text(
                                "\$${rideTotalAmount.toStringAsFixed(2)}",
                                style: TextStyle(
                                    color: TColor.secondary,
                                    fontSize: 17
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 15,),
          itemCount: ridesArr.length
      ),
    );
  }

  void apiAllRidesList(){
    Globs.showHUD();
    ServiceCall.post(
        {

        },
        SVKey.svDriverAllRides,
        isTokenApi: true,
        withSuccess: (responseObj)async{
          Globs.hideHUD();
          if(responseObj[KKey.status]=="1"){
            var payloadObj = responseObj[KKey.payload] as Map? ?? {};
            ridesArr = payloadObj["ride_list"] as List? ?? [];
            driverAmount = double.tryParse(payloadObj["driver_total"].toString()) ?? 0.0;
            totalAmount = double.tryParse(payloadObj["total"].toString()) ?? 0.0;
            if(mounted){
              setState(() {});
            }
          }else{
            mdShowAlert(AppLocalizations.of(context).translate('error'), responseObj[KKey.message] as String? ?? MSG.fail, () {});
          }
        },
        failure: (error)async{
          Globs.hideHUD();
          mdShowAlert(AppLocalizations.of(context).translate('error'), error.toString() as String? ?? MSG.fail, () {});
        }
    );
  }

  String statusText(Map rideObj){
    switch(rideObj["booking_status"]){
      case 2:
        return AppLocalizations.of(context).translate('on_way');
      case 3:
        return AppLocalizations.of(context).translate('waiting');
      case 4:
        return AppLocalizations.of(context).translate('started');
      case 5:
        return AppLocalizations.of(context).translate('completed');
      case 6:
        return AppLocalizations.of(context).translate('cancel');
      case 7:
        return AppLocalizations.of(context).translate('no_drivers');
      default:
        return AppLocalizations.of(context).translate('pending');
    }
  }

  Color statusColor(Map rideObj){
    switch(rideObj["booking_status"]){
      case 2:
        return Colors.green;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.green;
      case 5:
        return Colors.green;
      case 6:
        return Colors.red;
      case 7:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String statusWiseDateTime(Map rideObj){
    switch(rideObj["booking_status"]){
      case 2:
        return (rideObj["accpet_time"] as String? ?? "").dataFormat().stringFormat(format: "dd MM, yyyy hh:mm a") ?? "";
      case 3:
        return (rideObj["start_time"] as String? ?? "").dataFormat().stringFormat(format: "dd MM, yyyy hh:mm a") ?? "";
      case 4:
        return (rideObj["start_time"] as String? ?? "").dataFormat().stringFormat(format: "dd MM, yyyy hh:mm a") ?? "";
      case 5:
        return (rideObj["stop_time"] as String? ?? "").dataFormat().stringFormat(format: "dd MM, yyyy hh:mm a") ?? "";
      case 6:
        return (rideObj["stop_time"] as String? ?? "").dataFormat().stringFormat(format: "dd MM, yyyy hh:mm a") ?? "";
      case 7:
        return (rideObj["stop_time"] as String? ?? "").dataFormat().stringFormat(format: "dd MM, yyyy hh:mm a") ?? "";
      default:
        return (rideObj["pickup_date"] as String? ?? "").dataFormat().stringFormat(format: "dd MM, yyyy hh:mm a") ?? "";
    }
  }


}