import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:transport_app/common/common_extension.dart';
import 'package:transport_app/common/location_helper.dart';
import 'package:transport_app/common/socket_manager.dart';
import 'package:transport_app/common_widget/icon_title_button.dart';
import 'package:transport_app/common_widget/round_button.dart';
import 'package:transport_app/common_widget/timer_basic.dart';
import 'package:transport_app/common_widget/timer_frame.dart';
import 'package:transport_app/view/home/reasons_view.dart';

import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:transport_app/view/home/support/support_message_view.dart';
import 'package:transport_app/view/home/tip_detail_view.dart';


import '../../common/color_extension.dart';
import '../../common/globs.dart';
import '../../common/service_call.dart';

class UserRunRideView extends StatefulWidget {

  final Map rObj;

  const UserRunRideView({super.key, required this.rObj});

  @override
  State<UserRunRideView> createState() => _UserRunRideViewState();
}

const bsPending = 0;
const bsAccept = 1;
const bsGoUser = 2;
const bsWaitUser = 3;
const bsStart = 4;
const bsComplete = 5;
const bsCancel = 6;

class _UserRunRideViewState extends State<UserRunRideView> with OSMMixinObserver {

  bool isOpen = true;

  Map rideObj = {};

  TextEditingController txtOTP = TextEditingController();
  TextEditingController txtToll = TextEditingController();

  //1=Accept ride
  //2=Start
  //3=Complete

  late MapController controller;

  String timeCount = "...";
  String km = "...";

  double ratingVal = 5.0;

  @override
  void initState() {
    super.initState();

    rideObj = widget.rObj;

    if(rideObj["booking_status"]<bsStart){
      controller = MapController(
          initPosition: GeoPoint(
              latitude: double.tryParse(rideObj["pickup_lat"].toString()) ?? 0.0,
              longitude: double.tryParse(rideObj["pickup_long"].toString()) ?? 0.0
          )
      );
    }else{
      controller = MapController(
          initPosition: GeoPoint(
              latitude: double.tryParse(rideObj["drop_lat"].toString()) ?? 0.0,
              longitude: double.tryParse(rideObj["drop_long"].toString()) ?? 0.0
          )
      );
    }

    controller.addObserver(this);

    SocketManager.shared.socket?.on("driver_cancel_ride", (data){
      print("driver_cancel_ride socket get : ${data.toString()}");
      if(data[KKey.status] == "1"){
        if(data[KKey.payload]["booking_id"] == rideObj["booking_id"]){
          openUserRideCancelPopUp();
        }
      }
    });

    SocketManager.shared.socket?.on("driver_wait_user", (data){
      print("driver_cancel_ride socket get : ${data.toString()}");
      if(data[KKey.status] == "1"){
        if(data[KKey.payload]["booking_id"] == rideObj["booking_id"]){
          rideObj["booking_status"] = data[KKey.payload]["booking_status"];
          if(mounted){
            setState(() {});
          }
        }
      }
    });

    SocketManager.shared.socket?.on("ride_start", (data){
      print("driver_cancel_ride socket get : ${data.toString()}");
      if(data[KKey.status] == "1"){
        if(data[KKey.payload]["booking_id"] == rideObj["booking_id"]){
          rideObj["booking_status"] = data[KKey.payload]["booking_status"];
          loadMapRoad();
        }
      }
    });

    SocketManager.shared.socket?.on("ride_stop", (data){
      print("driver_cancel_ride socket get : ${data.toString()}");
      if(data[KKey.status] == "1"){
        if(data[KKey.payload]["booking_id"] == rideObj["booking_id"]){
          rideObj["booking_status"] = data[KKey.payload]["booking_status"];
          rideObj["amt"] = data[KKey.payload]["amount"].toString();
          rideObj["tax_amt"] = data[KKey.payload]["tax_amount"];
          rideObj["duration"] = data[KKey.payload]["duration"];
          rideObj["total_distance"] = data[KKey.payload]["total_distance"];
          rideObj["toll_tax"] = data[KKey.payload]["toll_tax"];
          loadMapRoad();
          if(mounted){
            setState(() {});
          }
          showRideCompletedPopUp();
        }
      }
    });

  }

  void openUserRideCancelPopUp(){
    mdShowAlert("User ride cancel", "Driver cancel ride", isForce: true, () {
      context.pop();
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var showPickUp = rideObj["booking_status"] < bsStart;

    return Scaffold(
      body: Stack(
        children: [
          OSMFlutter(
            controller:controller,
            osmOption: OSMOption(
                enableRotationByGesture: false,
                zoomOption: const ZoomOption(
                  initZoom: 15,
                  minZoomLevel: 3,
                  maxZoomLevel: 19,
                  stepZoom: 1.0,
                ),
                staticPoints: [

                ],
                roadConfiguration: const RoadOption(
                  roadColor: Colors.blueAccent,
                ),
                markerOption: MarkerOption(
                    defaultMarker: const  MarkerIcon(
                      icon: Icon(
                        Icons.person_pin_circle,
                        color: Colors.blue,
                        size: 56,
                      ),
                    )
                ),
                showDefaultInfoWindow: false
            ),
          ),

          if(rideObj["booking_status"] != bsComplete)
            Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if(rideObj["booking_status"] == bsWaitUser)
                  //Status arrived
                    Container(
                      width: 200,
                      height: 110,
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, -5)
                            )
                          ]
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          TimerFrame(
                            inverted: true,
                            description: '',
                            timer: TimerBasic(
                              format: CountDownTimerFormat.minutesSeconds,
                              inverted: true,
                              minutes: 1,
                              seconds: 0,
                            ),
                          ),
                          Text(
                            "Esperando al usuario",
                            style: TextStyle(
                                color: TColor.secondary,
                                fontSize: 16,
                                fontWeight: FontWeight.w800
                            ),
                          ),
                        ],
                      ),
                    ),
                  // if(rideObj["booking_status"] == bsStart)
                  //   //Status started
                  //   Container(
                  //     width: 200,
                  //     height: 110,
                  //     margin: const EdgeInsets.all(10),
                  //     padding: const EdgeInsets.symmetric(vertical: 2),
                  //     decoration: const BoxDecoration(
                  //         color: Colors.white,
                  //         borderRadius: BorderRadius.only(
                  //             topLeft: Radius.circular(10),
                  //             topRight: Radius.circular(10)
                  //         ),
                  //         boxShadow: [
                  //           BoxShadow(
                  //               color: Colors.black12,
                  //               blurRadius: 10,
                  //               offset: Offset(0, -5)
                  //           )
                  //         ]
                  //     ),
                  //     child: Column(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       mainAxisSize: MainAxisSize.max,
                  //       children: [
                  //         TimerFrame(
                  //           inverted: true,
                  //           description: '',
                  //           timer: TimerBasic(
                  //             format: CountDownTimerFormat.minutesSeconds,
                  //             inverted: true,
                  //             minutes: 2,
                  //             seconds: 0,
                  //           ),
                  //         ),
                  //         Text(
                  //           "Llegada a destino",
                  //           style: TextStyle(
                  //               color: TColor.secondary,
                  //               fontSize: 16,
                  //               fontWeight: FontWeight.w800
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, -5)
                            )
                          ]
                      ),
                      child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                      onPressed: (){
                                        setState(() {
                                          isOpen = !isOpen;
                                        });
                                      },
                                      icon: isOpen ?
                                      const Icon(Icons.arrow_drop_down,size: 30,) :
                                      const Icon(Icons.arrow_drop_up,size: 30,)
                                  ),
                                  Text(
                                    "$timeCount min",
                                    style: TextStyle(
                                        color: TColor.primaryText,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(17.5),
                                      child: CachedNetworkImage(
                                        imageUrl: rideObj["image"] as String? ?? "",
                                        width: 35,
                                        height: 35,
                                        fit: BoxFit.contain,
                                      )
                                  ),
                                  Text(
                                    "$km km",
                                    style: TextStyle(
                                        color: TColor.primaryText,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800
                                    ),
                                  ),
                                  Icon(Icons.phone),
                                ],
                              ),
                            ),
                            Text(
                              "${statusName()} a ${rideObj["name"] ?? ""}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: TColor.secondaryText,
                                  fontSize: 18
                              ),
                            ),

                            if(isOpen)
                              SizedBox(
                                height: 8,
                              ),
                            if(isOpen)
                              const Divider(height: 0.5,endIndent: 20,indent: 20,),
                            if(isOpen)
                              SizedBox(
                                height: 8,
                              ),

                            if(isOpen)
                              Padding(
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                      child: CachedNetworkImage(
                                        imageUrl: rideObj["image"] as String? ?? "",
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.contain,
                                      )
                                  ),
                                  const SizedBox(width: 15,),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              rideObj["name"] as String? ?? "",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700
                                              ),
                                            ),
                                            Text(
                                              statusText(),
                                              style: TextStyle(
                                                  color: statusColor(),
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "${rideObj["mobile_code"] as String? ?? ""} ${rideObj["mobile"] as String? ?? ""}",
                                              style: TextStyle(
                                                  color: TColor.secondary,
                                                  fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              (rideObj["payment_type"] ?? 1) == 1 ? "COD" : "Online",
                                              style: TextStyle(
                                                color: TColor.secondary,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),

                            if(isOpen)
                              const Divider(height: 0.5,endIndent: 20,indent: 20,),
                            if(isOpen)
                              SizedBox(
                                height: 8,
                              ),

                            if(isOpen)
                              Padding(
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                children: [
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: CachedNetworkImage(
                                        imageUrl: rideObj["icon"] as String? ?? "",
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.contain,
                                      )
                                  ),
                                  const SizedBox(width: 15,),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${rideObj["brand_name"] as String? ?? ""} - ${rideObj["model_name"] as String? ?? ""} - ${rideObj["series_name"] as String? ?? ""}",
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "No Plate: ${rideObj["car_number"] as String? ?? ""}",
                                              style: TextStyle(
                                                  color: TColor.secondaryText,
                                                  fontSize: 14,
                                              ),
                                            ),
                                            if(rideObj["booking_status"]<=bsWaitUser)
                                              Text(
                                                "OTP Code: ${rideObj["otp_code"] as String? ?? ""}",
                                                style: TextStyle(
                                                    color: TColor.secondaryText,
                                                    fontSize: 14,
                                                ),
                                              )
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),

                            if(isOpen)
                              const Divider(height: 0.5,endIndent: 20,indent: 20,),
                            if(isOpen)
                              SizedBox(
                                height: 8,
                              ),
                            if(isOpen)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconTitleButton(title: "Chat",icon: Icon(CupertinoIcons.chat_bubble_text_fill),onPress: (){
                                    context.push(SupportMessageView(
                                      uObj: {
                                        "user_id" : rideObj["driver_id"],
                                        "name" : rideObj["name"],
                                        "image" : rideObj["image"]
                                      },
                                    ));
                                  }),
                                  SizedBox(height: 15),
                                  IconTitleButton(title: "Mensaje",icon: Icon(Icons.message),onPress: (){

                                  }),
                                  SizedBox(height: 15),
                                  IconTitleButton(
                                      title: "Cancelar",
                                      icon: Icon(Icons.cancel),
                                      onPress: () async{
                                        await showModalBottomSheet(
                                            backgroundColor: Colors.transparent,
                                            barrierColor: Colors.transparent,
                                            isScrollControlled: true,
                                            context: context,
                                            builder: (builder){
                                              return Stack(
                                                alignment: Alignment.bottomCenter,
                                                children: [
                                                  BackdropFilter(
                                                    filter: ImageFilter.blur(sigmaX: 5,sigmaY: 5),
                                                    child: Container(
                                                      color: Colors.black38,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                                    decoration: const BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.only(
                                                            topLeft: Radius.circular(10),
                                                            topRight: Radius.circular(10)
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color: Colors.black12,
                                                              blurRadius: 10,
                                                              offset: Offset(0, -5)
                                                          )
                                                        ]
                                                    ),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          "Cancelar a ${rideObj["name"] ?? ""}?",
                                                          style: TextStyle(
                                                              color: TColor.primaryText,
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.w800
                                                          ),
                                                        ),
                                                        const SizedBox(height: 15,),
                                                        RoundButton(
                                                            title: "SI, CANCELAR",
                                                            buttonType: RoundButtonType.red,
                                                            onPressed: (){
                                                              context.pop();
                                                              apiCancelRide();
                                                              //context.push(const ReasonsView());
                                                            }
                                                        ),
                                                        const SizedBox(height: 15,),
                                                        RoundButton(
                                                            title: "NO",
                                                            buttonType: RoundButtonType.boarded,
                                                            onPressed: (){
                                                              context.pop();
                                                            }
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              );
                                            }
                                        );
                                      }
                                  )
                                ],
                              ),
                            if(isOpen)
                              const SizedBox(
                                height: 15,
                              ),
                          ]
                      )

                  ),
                ]
            )
          else
            Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      width: context.width,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, -5)
                            )
                          ]
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "How was your ride?",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: TColor.primaryText,
                                    fontSize: 18
                                ),
                              ),
                            ),
                            Text(
                              rideObj["name"] as String? ?? "",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: TColor.primaryText,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            RatingBar.builder(
                              initialRating: ratingVal,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                ratingVal = rating;
                                setState(() {});
                              },
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: RoundButton(
                                title:"RATE RIDER",
                                onPressed: (){
                                  apiSubmitRate();
                                  //context.push(const TipDetailView());
                                },
                              ),
                            )

                          ]
                      )

                  ),
                ]
            ),
          SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                      child: InkWell(
                        onTap: (){
                          context.pop();
                        },
                        child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 25),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10
                                  )
                                ]
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(showPickUp ? Icons.location_history_rounded : Icons.emoji_transportation,size: 40,color: TColor.primary),
                                SizedBox(width: 8,),
                                Expanded(
                                  child: Text(
                                    rideObj[showPickUp ? "pickup_address" : "drop_address"] as String? ?? "",
                                    style: TextStyle(
                                        color: TColor.primaryText,
                                        fontSize: 15
                                    ),
                                  ),
                                ),
                              ],
                            )
                        ),
                      )
                  )
                ],
              )
          )
        ],
      ),
    );
  }

  void addMarker() async{

    await controller.setMarkerOfStaticPoint(
        id: "pickup",
        markerIcon: MarkerIcon(
            iconWidget: Icon(Icons.car_crash,size: 40,color: TColor.primary)
        )
    );

    await controller.setMarkerOfStaticPoint(
        id: "dropoff",
        markerIcon: MarkerIcon(
            iconWidget: Icon(Icons.location_history_rounded,size: 40,color: TColor.primary)
        )
    );

    loadMapRoad();

  }

  void loadMapRoad()async{

    if(rideObj["booking_status"] < bsStart){
      await controller.setStaticPosition([GeoPoint(
          latitude: double.tryParse(rideObj["lati"].toString()) ?? 0.0,
          longitude: double.tryParse(rideObj["longi"].toString()) ?? 0.0
      )], "pickup");

      await controller.setStaticPosition([GeoPoint(
          latitude: double.tryParse(rideObj["pickup_lat"].toString()) ?? 0.0,
          longitude: double.tryParse(rideObj["pickup_long"].toString()) ?? 0.0
      )], "dropoff");

      var roadInfo = await controller.drawRoad(
          GeoPoint(
              latitude: double.tryParse(rideObj["lati"].toString()) ?? 0.0,
              longitude: double.tryParse(rideObj["longi"].toString()) ?? 0.0
          ),
          GeoPoint(
              latitude: double.tryParse(rideObj["pickup_lat"].toString()) ?? 0.0,
              longitude: double.tryParse(rideObj["pickup_long"].toString()) ?? 0.0
          ),
          roadType: RoadType.car,
          roadOption: const RoadOption(roadColor: Colors.blueAccent,roadBorderWidth: 4)
      );

      timeCount = ((roadInfo.duration ?? 0.0)/60.0).toStringAsFixed(1);
      km = ((roadInfo.distance ?? 0.0)).toStringAsFixed(1);

    }else{
      await controller.setStaticPosition([GeoPoint(
          latitude: double.tryParse(rideObj["drop_lat"].toString()) ?? 0.0,
          longitude: double.tryParse(rideObj["drop_long"].toString()) ?? 0.0
      )], "dropoff");

      var roadInfo = await controller.drawRoad(
          GeoPoint(
              latitude: double.tryParse(rideObj["lati"].toString()) ?? 0.0,
              longitude: double.tryParse(rideObj["longi"].toString()) ?? 0.0
          ),
          GeoPoint(
              latitude: double.tryParse(rideObj["drop_lat"].toString()) ?? 0.0,
              longitude: double.tryParse(rideObj["drop_long"].toString()) ?? 0.0
          ),
          roadType: RoadType.car,
          roadOption: const RoadOption(roadColor: Colors.blueAccent,roadBorderWidth: 4)
      );

      timeCount = ((roadInfo.duration ?? 0.0)/60.0).toStringAsFixed(1);
      km = ((roadInfo.distance ?? 0.0)).toStringAsFixed(1);

    }

    if(mounted){
      setState(() {});
    }

  }

  @override
  Future<void> mapIsReady(bool isReady) async{
    if(isReady){
      addMarker();
    }
  }

  void apiCancelRide(){
    Globs.showHUD();
    ServiceCall.post(
        {
          "booking_id" : rideObj["booking_id"].toString(),
          "booking_status" : rideObj["booking_status"].toString()
        },
        isTokenApi: true,
        SVKey.svUserRideCancel,
        withSuccess: (responseObj)async{
          Globs.hideHUD();
          if(responseObj[KKey.status]=="1"){
            mdShowAlert(Globs.appName, responseObj[KKey.message] as String? ?? MSG.success, () {
              context.pop();
            });
          }else{
            mdShowAlert(Globs.appName, responseObj[KKey.message] as String? ?? MSG.fail, () { });
          }
        },
        failure: (error)async{
          Globs.hideHUD();
          mdShowAlert(Globs.appName, error.toString(),(){});
        }
    );
  }

  void apiSubmitRate(){
    Globs.showHUD();
    ServiceCall.post(
        {
          "booking_id" : rideObj["booking_id"].toString(),
          "rating" : ratingVal.toString(),
          "comment" : "good"
        },
        isTokenApi: true,
        SVKey.svRideRating,
        withSuccess: (responseObj)async{
          Globs.hideHUD();
          if(responseObj[KKey.status]=="1"){
            mdShowAlert(Globs.appName, responseObj[KKey.message] as String? ?? MSG.success, () {
              context.pop();
            });
          }else{
            mdShowAlert(Globs.appName, responseObj[KKey.message] as String? ?? MSG.fail, () { });
          }
        },
        failure: (error)async{
          Globs.hideHUD();
          mdShowAlert(Globs.appName, error.toString(),(){});
        }
    );
  }

  String statusName(){
    switch(rideObj["booking_status"]){
      case 2:
        return "On way Driver";
      case 3:
        return "Waiting Driver";
      case 4:
        return "Ride Started with";
      case 5:
        return "Ride Complete with";
      case 6:
        return "Ride Cancel";
      case 7:
        return "No Driver Found";
      default:
        return "Finding Driver Near By";
    }
  }

  String statusText(){
    switch(rideObj["booking_status"]){
      case 2:
        return "On way";
      case 3:
        return "Waiting";
      case 4:
        return "Started";
      case 5:
        return "Completed";
      case 6:
        return "Cancel";
      case 7:
        return "No Drivers";
      default:
        return "Pending";
    }
  }

  Color statusColor(){
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

  void showRideCompletedPopUp() async{

    var taxAmt = double.tryParse(rideObj["tax_amt"] ?? "0.0") ?? 0.0;
    var tollAmt = double.tryParse(rideObj["toll_tax"] ?? "0.0") ?? 0.0;
    var payableAmt = double.tryParse(rideObj["amt"] ?? "0.0") ?? 0.0;
    var totalAmt = payableAmt - tollAmt - taxAmt;

    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      isScrollControlled:  true,
      context: context,
      builder: (context){
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5,sigmaY: 5),
              child: Container(
                color: Colors.black38,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10)
                )
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Ride Completed",
                    style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 20,
                      fontWeight: FontWeight.w800
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Payment mode:",
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 20
                        ),
                      ),
                      Text(
                        (rideObj["payment_type"] ?? 1) == 1 ? "COD" : "ONLINE",
                        style: TextStyle(
                          color: TColor.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Distance",
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 17
                        ),
                      ),
                      Text(
                        "${(double.tryParse(rideObj["total_distance"].toString() ?? "0.0") ?? 0.0).toStringAsFixed(2)} Km",
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 17,
                          fontWeight: FontWeight.w700
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Duration:",
                        style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 17
                        ),

                      ),
                      Text(
                        rideObj["duration"] ?? "00:00",
                        style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 17,
                            fontWeight: FontWeight.w700
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Amount",
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 17
                        ),
                      ),
                      Text(
                        "+\$${totalAmt.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 17,
                          fontWeight: FontWeight.w700
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tax Amount:",
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 17
                        ),
                      ),
                      Text(
                        "+\$${taxAmt.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 17,
                          fontWeight: FontWeight.w700
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Toll Tax:",
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 17
                        ),
                      ),
                      Text(
                        "+\$${tollAmt.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 17,
                          fontWeight: FontWeight.w700
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 90,
                        height: 2,
                        color: TColor.primaryText,
                      )
                    ],
                  ),
                  const SizedBox(height: 15,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Payable Amount:",
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 20,
                          fontWeight: FontWeight.w700
                        ),
                      ),
                      Text(
                        "\$${payableAmt.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 20,
                          fontWeight: FontWeight.w700
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15,),
                  RoundButton(
                      title: "Yes, Accept toll tax",
                      buttonType: RoundButtonType.primary,
                      onPressed: (){
                        context.pop();
                      }
                  ),
                  const SizedBox(height: 15,),
                  RoundButton(
                      title: "No",
                      buttonType: RoundButtonType.red,
                      onPressed: (){
                        context.pop();
                      }
                  )
                ],
              ),
            )
          ],
        );
      }
    );

  }

}
