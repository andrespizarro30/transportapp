import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

class RunRideView extends StatefulWidget {
  
  final Map rObj;
  
  const RunRideView({super.key, required this.rObj});

  @override
  State<RunRideView> createState() => _RunRideViewState();
}

const bsPending = 0;
const bsAccept = 1;
const bsGoUser = 2;
const bsWaitUser = 3;
const bsStart = 4;
const bsComplete = 5;
const bsCancel = 6;

class _RunRideViewState extends State<RunRideView> with OSMMixinObserver {

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

    SocketManager.shared.socket?.on("user_cancel_ride", (data) async{
      print("user_cancel_ride socket get : ${data.toString()}");
      if(data[KKey.status] == "1"){
        if(data[KKey.payload]["booking_id"] == rideObj["booking_id"]){
          openUserRideCancelPopUp();
        }
      }
    });

  }

  void openUserRideCancelPopUp(){
    mdShowAlert("User ride cancel", "User cancel ride", isForce: true, () {
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
                            SizedBox(
                              height: 8,
                            ),
                          if(isOpen)
                            const Divider(height: 0.5,endIndent: 20,indent: 20,),
                          if(isOpen)
                            SizedBox(
                              height: 8,
                            ),
                          if(isOpen && rideObj["booking_status"] >= bsWaitUser)
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

                          if(isOpen && rideObj["booking_status"] >= bsWaitUser)
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
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),

                          if(isOpen)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconTitleButton(title: "Chat",icon: Icon(CupertinoIcons.chat_bubble_text_fill),onPress: (){
                                  context.push(SupportMessageView(
                                    uObj: {
                                      "user_id" : rideObj["user_id"],
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
                          if(isOpen)
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                              child: RoundButton(
                                title: rideObj["booking_status"] == bsAccept ? "ARRIVED" :
                                rideObj["booking_status"] == bsWaitUser ? "START" :
                                "COMPLETE",
                                onPressed: () async{
                                  if(rideObj["booking_status"] == bsAccept){
                                    apiAwaitingForUser();
                                  }else
                                  if(rideObj["booking_status"] == bsWaitUser){

                                    await showDialog(
                                        context: context,
                                        barrierColor: const Color(0xff32384D).withOpacity(0),
                                        builder: (builder){
                                          return Dialog(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            child: Container(
                                              padding: const EdgeInsets.all(15),
                                              width: context.width - 50,
                                              height: 250,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Enter OTP",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: TColor.primaryText,
                                                        fontSize: 23,
                                                        fontWeight: FontWeight.w600
                                                    ),
                                                  ),
                                                  Text(
                                                    "Please enter user OTP",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: TColor.secondaryText,
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w600
                                                    ),
                                                  ),
                                                  TextField(
                                                    controller: txtOTP,
                                                    keyboardType: TextInputType.number,
                                                    style: TextStyle(
                                                        color: TColor.primaryText,
                                                        fontSize: 16
                                                    ),
                                                    decoration: InputDecoration(
                                                        enabledBorder: InputBorder.none,
                                                        focusedBorder: InputBorder.none,
                                                        hintText: "----",
                                                        hintStyle: TextStyle(color: TColor.placeholder, fontSize:  16)
                                                    ),
                                                  ),
                                                  const Divider(),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      TextButton(
                                                          onPressed: (){
                                                            context.pop();
                                                          },
                                                          child: Text(
                                                            "Cancelar",
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                                color: Colors.red,
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.w600
                                                            ),
                                                          )
                                                      ),
                                                      TextButton(
                                                          onPressed: (){
                                                            apiRideStart();
                                                            context.pop();
                                                          },
                                                          child: Text(
                                                            "RIDE START",
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                                color: TColor.primary,
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.w600
                                                            ),
                                                          )
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        });

                                  }else
                                  if(rideObj["booking_status"] == bsStart){
                                    await showDialog(
                                        context: context,
                                        barrierColor: const Color(0xff32384D).withOpacity(0.4),
                                        builder: (builder){
                                          return Dialog(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            child: Container(
                                              padding: const EdgeInsets.all(15),
                                              width: context.width - 50,
                                              height: 250,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Ingrese Valor del Peaje",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: TColor.primaryText,
                                                        fontSize: 23,
                                                        fontWeight: FontWeight.w600
                                                    ),
                                                  ),
                                                  Text(
                                                    "Por favor ingrese el valor del peaje",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: TColor.secondaryText,
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w600
                                                    ),
                                                  ),
                                                  TextField(
                                                    controller: txtToll,
                                                    keyboardType: TextInputType.number,
                                                    style: TextStyle(
                                                        color: TColor.primaryText,
                                                        fontSize: 16
                                                    ),
                                                    decoration: InputDecoration(
                                                        enabledBorder: InputBorder.none,
                                                        focusedBorder: InputBorder.none,
                                                        hintText: "\$0",
                                                        hintStyle: TextStyle(color: TColor.placeholder, fontSize:  16)
                                                    ),
                                                  ),
                                                  const Divider(),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      TextButton(
                                                          onPressed: (){
                                                            context.pop();
                                                          },
                                                          child: Text(
                                                            "Cancelar",
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                                color: Colors.red,
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.w600
                                                            ),
                                                          )
                                                      ),
                                                      TextButton(
                                                          onPressed: (){
                                                            context.pop();
                                                            apiRideStop();
                                                          },
                                                          child: Text(
                                                            "DONE",
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                                color: TColor.primary,
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.w600
                                                            ),
                                                          )
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        });
                                  }
                                },
                              ),
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
            iconWidget: Icon(Icons.location_history_rounded,size: 40,color: TColor.primary)
        )
    );

    await controller.setMarkerOfStaticPoint(
        id: "dropoff",
        markerIcon: MarkerIcon(
            iconWidget: Icon(Icons.car_crash,size: 40,color: TColor.primary)
        )
    );

    loadMapRoad();

  }

  void loadMapRoad()async{

    await controller.clearAllRoads();

    if(rideObj["booking_status"] < bsStart){

      await controller.setStaticPosition([GeoPoint(
          latitude: double.tryParse(rideObj["lati"].toString()) ?? 0.0,
          longitude: double.tryParse(rideObj["longi"].toString()) ?? 0.0
      )], "pickup");

      await controller.setStaticPosition([GeoPoint(
          latitude: double.tryParse(rideObj["pickup_lat"].toString()) ?? 0.0,
          longitude: double.tryParse(rideObj["pickup_long"].toString()) ?? 0.0
      )], "pickup");

      var roadInfo = await controller.drawRoad(
          GeoPoint(
              latitude: LocationHelper.shared().lastLocation?.latitude ?? 0.0,
              longitude: LocationHelper.shared().lastLocation?.longitude ?? 0.0
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
              latitude: LocationHelper.shared().lastLocation?.latitude ?? 0.0,
              longitude: LocationHelper.shared().lastLocation?.longitude ?? 0.0
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

  void apiAwaitingForUser(){
    Globs.showHUD();
    ServiceCall.post(
        {
          "booking_id" : rideObj["booking_id"].toString()
        },
        isTokenApi: true,
        SVKey.svDriverWaitUser,
        withSuccess: (responseObj)async{
          Globs.hideHUD();
          if(responseObj[KKey.status]=="1"){
            rideObj = (responseObj[KKey.payload] as Map? ?? {});
            mdShowAlert(Globs.appName, responseObj[KKey.message] as String? ?? MSG.success, () { });
            if(mounted){
              setState(() {});
            }
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

  void apiRideStart(){

    if(txtOTP.text.length != 4){
      mdShowAlert("Error", "Validate the OTP", () { });
      return;
    }

    var startLocation = LocationHelper.shared().lastLocation;

    if(startLocation == null){
      return;
    }

    Globs.showHUD();
    ServiceCall.post(
        {
          "booking_id" : rideObj["booking_id"].toString(),
          "pickup_latitude" : "${startLocation.latitude}",
          "pickup_longitude" : "${startLocation.longitude}",
          "otp_code" : txtOTP.text
        },
        isTokenApi: true,
        SVKey.svRiderStar,
        withSuccess: (responseObj)async{
          Globs.hideHUD();
          if(responseObj[KKey.status]=="1"){
            rideObj = (responseObj[KKey.payload] as Map? ?? {});
            LocationHelper.shared().startRideLocationSave(rideObj["booking_id"] as int? ?? 0,startLocation);
            loadMapRoad();
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

  void apiRideStop(){

    var endLocation = LocationHelper.shared().lastLocation;

    if(endLocation == null){
      return;
    }
    LocationHelper.shared().stopRideLocationSave();
    var locations = LocationHelper.shared().getRideSaveLocationJsonString(rideObj["booking_id"] as int? ?? 0);
    Globs.showHUD();
    ServiceCall.post(
        {
          "booking_id" : rideObj["booking_id"].toString(),
          "drop_latitude" : "${endLocation.latitude}",
          "drop_longitude" : "${endLocation.longitude}",
          "toll_tax" : txtToll.text == "" ? "0" : txtToll.text,
          "ride_location": locations
        },
        isTokenApi: true,
        SVKey.svRideStop,
        withSuccess: (responseObj)async{
          Globs.hideHUD();
          if(responseObj[KKey.status]=="1"){
            rideObj = (responseObj[KKey.payload] as Map? ?? {});
            if(mounted){
              setState(() {});
            }
            mdShowAlert("Ride completed", responseObj[KKey.message] as String? ?? "", () { });
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

  void apiCancelRide(){
    Globs.showHUD();
    ServiceCall.post(
        {
          "booking_id" : rideObj["booking_id"].toString(),
          "booking_status" : rideObj["booking_status"].toString()
        },
        isTokenApi: true,
        SVKey.svRideCancel,
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
          "comment" : "very good"
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
        return "Pickup Up";
      case 3:
        return "Waiting for";
      case 4:
        return "Ride Started with";
      case 5:
        return "Ride Completed with";
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


}
