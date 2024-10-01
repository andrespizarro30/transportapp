import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_app/common/common_extension.dart';
import 'package:transport_app/common/location_helper.dart';
import 'package:transport_app/common/socket_manager.dart';
import 'package:transport_app/common_widget/icon_title_button.dart';
import 'package:transport_app/common_widget/round_button.dart';
import 'package:transport_app/common_widget/timer_basic.dart';
import 'package:transport_app/common_widget/timer_frame.dart';

import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:transport_app/view/home/support/support_message_view.dart';
import 'package:transport_app/view/home/tip_detail_view.dart';

import '../../common/color_extension.dart';
import '../../common/globs.dart';
import '../../common/service_call.dart';
import '../../cubit/map_requests/map_requests_cubit.dart';
import '../../model/directions_model.dart';

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

class _UserRunRideViewState extends State<UserRunRideView> {
  Position? position = null;
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;
  final initialCameraPosition =
      const CameraPosition(target: LatLng(4.8, -75.7), zoom: 15.0);
  double bottomPaddingOfMap = 0;
  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};
  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  bool isOpen = true;

  Map rideObj = {};

  TextEditingController txtOTP = TextEditingController();
  TextEditingController txtToll = TextEditingController();

  //late MapController controller;

  String timeCount = "...";
  String km = "...";

  double ratingVal = 5.0;

  @override
  void initState() {
    super.initState();

    rideObj = widget.rObj;

    // if(rideObj["booking_status"]<bsStart){
    //   controller = MapController(
    //       initPosition: GeoPoint(
    //           latitude: double.tryParse(rideObj["pickup_lat"].toString()) ?? 0.0,
    //           longitude: double.tryParse(rideObj["pickup_long"].toString()) ?? 0.0
    //       )
    //   );
    // }else{
    //   controller = MapController(
    //       initPosition: GeoPoint(
    //           latitude: double.tryParse(rideObj["drop_lat"].toString()) ?? 0.0,
    //           longitude: double.tryParse(rideObj["drop_long"].toString()) ?? 0.0
    //       )
    //   );
    // }
    //
    // controller.addObserver(this);

    SocketManager.shared.socket?.on("driver_cancel_ride", (data) {
      print("driver_cancel_ride socket get : ${data.toString()}");
      if (data[KKey.status] == "1") {
        if (data[KKey.payload]["booking_id"] == rideObj["booking_id"]) {
          openUserRideCancelPopUp();
        }
      }
    });

    SocketManager.shared.socket?.on("driver_wait_user", (data) {
      print("driver_cancel_ride socket get : ${data.toString()}");
      if (data[KKey.status] == "1") {
        if (data[KKey.payload]["booking_id"] == rideObj["booking_id"]) {
          rideObj["booking_status"] = data[KKey.payload]["booking_status"];
          if (mounted) {
            setState(() {});
          }
        }
      }
    });

    SocketManager.shared.socket?.on("ride_start", (data) {
      print("driver_cancel_ride socket get : ${data.toString()}");
      if (data[KKey.status] == "1") {
        if (data[KKey.payload]["booking_id"] == rideObj["booking_id"]) {
          rideObj["booking_status"] = data[KKey.payload]["booking_status"];
          loadMapRoad();
        }
      }
    });

    SocketManager.shared.socket?.on("ride_stop", (data) {
      print("driver_cancel_ride socket get : ${data.toString()}");
      if (data[KKey.status] == "1") {
        if (data[KKey.payload]["booking_id"] == rideObj["booking_id"]) {
          rideObj["booking_status"] = data[KKey.payload]["booking_status"];
          rideObj["amt"] = data[KKey.payload]["amount"].toString();
          rideObj["tax_amt"] = data[KKey.payload]["tax_amount"];
          rideObj["duration"] = data[KKey.payload]["duration"];
          rideObj["total_distance"] = data[KKey.payload]["total_distance"];
          rideObj["toll_tax"] = data[KKey.payload]["toll_tax"];
          loadMapRoad();
          if (mounted) {
            setState(() {});
          }
          showRideCompletedPopUp();
        }
      }
    });
  }

  void openUserRideCancelPopUp() {
    mdShowAlert("User ride cancel", "Driver cancel ride", isForce: true, () {
      context.pop();
    });
  }

  @override
  void dispose() {
    super.dispose();
    //controller.dispose();
    newGoogleMapController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var showPickUp = rideObj["booking_status"] < bsStart;

    return Scaffold(
        body: BlocConsumer<MapRequestsCubit, MapRequestsState>(
        listener: (context, state) {
          if(state is MapRequestsDirectionsSuccess){
            drawRoad(state.routes);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              GoogleMap(
                padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
                mapType: MapType.normal,
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: true,
                polylines: polylineSet,
                markers: markersSet,
                circles: circlesSet,
                initialCameraPosition: initialCameraPosition,
                onMapCreated: (GoogleMapController controller) {
                  _controllerGoogleMap.complete(controller);
                  newGoogleMapController = controller;

                  loadMapRoad();

                  setState(() {
                    bottomPaddingOfMap = 265.0;
                  });
                },
              ),
              if (rideObj["booking_status"] != bsComplete)
                Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (rideObj["booking_status"] == bsWaitUser)
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
                                  topRight: Radius.circular(10)),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    offset: Offset(0, -5))
                              ]),
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
                                    fontWeight: FontWeight.w800),
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
                                  topRight: Radius.circular(10)),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    offset: Offset(0, -5))
                              ]),
                          child: Column(children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        setState(() {
                                          isOpen = !isOpen;
                                        });
                                      },
                                      icon: isOpen
                                          ? const Icon(
                                              Icons.arrow_drop_down,
                                              size: 30,
                                            )
                                          : const Icon(
                                              Icons.arrow_drop_up,
                                              size: 30,
                                            )),
                                  Text(
                                    "$timeCount min",
                                    style: TextStyle(
                                        color: TColor.primaryText,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800),
                                  ),
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(17.5),
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            rideObj["image"] as String? ?? "",
                                        width: 35,
                                        height: 35,
                                        fit: BoxFit.contain,
                                      )),
                                  Text(
                                    "$km km",
                                    style: TextStyle(
                                        color: TColor.primaryText,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800),
                                  ),
                                  Icon(Icons.phone),
                                ],
                              ),
                            ),
                            Text(
                              "${statusName()} a ${rideObj["name"] ?? ""}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: TColor.secondaryText, fontSize: 18),
                            ),
                            if (isOpen)
                              SizedBox(
                                height: 8,
                              ),
                            if (isOpen)
                              const Divider(
                                height: 0.5,
                                endIndent: 20,
                                indent: 20,
                              ),
                            if (isOpen)
                              SizedBox(
                                height: 8,
                              ),
                            if (isOpen)
                              Padding(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              rideObj["image"] as String? ?? "",
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.contain,
                                        )),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                rideObj["name"] as String? ?? "",
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700),
                                              ),
                                              Text(
                                                statusText(),
                                                style: TextStyle(
                                                    color: statusColor(),
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w700),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "${rideObj["mobile_code"] as String? ?? ""} ${rideObj["mobile"] as String? ?? ""}",
                                                style: TextStyle(
                                                  color: TColor.secondary,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                (rideObj["payment_type"] ?? 1) ==
                                                        1
                                                    ? "COD"
                                                    : "Online",
                                                style: TextStyle(
                                                    color: TColor.secondary,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w700),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            if (isOpen)
                              const Divider(
                                height: 0.5,
                                endIndent: 20,
                                indent: 20,
                              ),
                            if (isOpen)
                              SizedBox(
                                height: 8,
                              ),
                            if (isOpen)
                              Padding(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              rideObj["icon"] as String? ?? "",
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.contain,
                                        )),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${rideObj["brand_name"] as String? ?? ""} - ${rideObj["model_name"] as String? ?? ""} - ${rideObj["series_name"] as String? ?? ""}",
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "No Plate: ${rideObj["car_number"] as String? ?? ""}",
                                                style: TextStyle(
                                                  color: TColor.secondaryText,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              if (rideObj["booking_status"] <=
                                                  bsWaitUser)
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
                            if (isOpen)
                              const Divider(
                                height: 0.5,
                                endIndent: 20,
                                indent: 20,
                              ),
                            if (isOpen)
                              SizedBox(
                                height: 8,
                              ),
                            if (isOpen)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconTitleButton(
                                      title: "Chat",
                                      icon: Icon(
                                          CupertinoIcons.chat_bubble_text_fill),
                                      onPress: () {
                                        context.push(SupportMessageView(
                                          uObj: {
                                            "user_id": rideObj["driver_id"],
                                            "name": rideObj["name"],
                                            "image": rideObj["image"]
                                          },
                                        ));
                                      }),
                                  SizedBox(height: 15),
                                  IconTitleButton(
                                      title: "Mensaje",
                                      icon: Icon(Icons.message),
                                      onPress: () {}),
                                  SizedBox(height: 15),
                                  IconTitleButton(
                                      title: "Cancelar",
                                      icon: Icon(Icons.cancel),
                                      onPress: () async {
                                        await showModalBottomSheet(
                                            backgroundColor: Colors.transparent,
                                            barrierColor: Colors.transparent,
                                            isScrollControlled: true,
                                            context: context,
                                            builder: (builder) {
                                              return Stack(
                                                alignment: Alignment.bottomCenter,
                                                children: [
                                                  BackdropFilter(
                                                    filter: ImageFilter.blur(
                                                        sigmaX: 5, sigmaY: 5),
                                                    child: Container(
                                                      color: Colors.black38,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 15),
                                                    decoration: const BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(10),
                                                                topRight: Radius
                                                                    .circular(
                                                                        10)),
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color:
                                                                  Colors.black12,
                                                              blurRadius: 10,
                                                              offset:
                                                                  Offset(0, -5))
                                                        ]),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          "Cancelar a ${rideObj["name"] ?? ""}?",
                                                          style: TextStyle(
                                                              color: TColor
                                                                  .primaryText,
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800),
                                                        ),
                                                        const SizedBox(
                                                          height: 15,
                                                        ),
                                                        RoundButton(
                                                            title: "SI, CANCELAR",
                                                            buttonType:
                                                                RoundButtonType
                                                                    .red,
                                                            onPressed: () {
                                                              context.pop();
                                                              apiCancelRide();
                                                              //context.push(const ReasonsView());
                                                            }),
                                                        const SizedBox(
                                                          height: 15,
                                                        ),
                                                        RoundButton(
                                                            title: "NO",
                                                            buttonType:
                                                                RoundButtonType
                                                                    .boarded,
                                                            onPressed: () {
                                                              context.pop();
                                                            })
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              );
                                            });
                                      })
                                ],
                              ),
                            if (isOpen)
                              const SizedBox(
                                height: 15,
                              ),
                          ])),
                    ])
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
                                  topRight: Radius.circular(10)),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    offset: Offset(0, -5))
                              ]),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    "How was your ride?",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: TColor.primaryText, fontSize: 18),
                                  ),
                                ),
                                Text(
                                  rideObj["name"] as String? ?? "",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: TColor.primaryText,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w800),
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
                                  itemPadding:
                                      EdgeInsets.symmetric(horizontal: 4.0),
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
                                    title: "RATE RIDER",
                                    onPressed: () {
                                      apiSubmitRate();
                                      //context.push(const TipDetailView());
                                    },
                                  ),
                                )
                              ])),
                    ]),
              SafeArea(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: InkWell(
                        onTap: () {
                          context.pop();
                        },
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 25),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(color: Colors.black26, blurRadius: 10)
                                ]),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                    showPickUp
                                        ? Icons.location_history_rounded
                                        : Icons.emoji_transportation,
                                    size: 40,
                                    color: TColor.primary),
                                SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Text(
                                    rideObj[showPickUp
                                            ? "pickup_address"
                                            : "drop_address"] as String? ??
                                        "",
                                    style: TextStyle(
                                        color: TColor.primaryText, fontSize: 15),
                                  ),
                                ),
                              ],
                            )),
                      ))
                ],
              ))
            ],
          );
        },
    ));
  }

  void setMarkers(LatLng origPos, LatLng destPos) {
    Marker origLocationMarker = Marker(
        markerId: MarkerId("pickUpMarker"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        infoWindow: InfoWindow(
            //title: address!.placeName,
            snippet: "Partida"),
        position: origPos);

    Marker destLocationMarker = Marker(
        markerId: MarkerId("destinyMarker"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
            //title: result!.name!,
            snippet: "Llegada"),
        position: destPos);

    markersSet.clear();

    setState(() {
      markersSet.add(origLocationMarker);
      markersSet.add(destLocationMarker);
    });
  }

  LatLng origPos = LatLng(0, 0);
  LatLng destPos = LatLng(0, 0);

  void getDirection() async {
    context.read<MapRequestsCubit>().getDirections(origPos, destPos, context);
  }

  void loadMapRoad() async {
    if (rideObj["booking_status"] < bsStart) {
      origPos = LatLng(double.tryParse(rideObj["lati"].toString()) ?? 0.0,
          double.tryParse(rideObj["longi"].toString()) ?? 0.0);
      destPos = LatLng(double.tryParse(rideObj["pickup_lat"].toString()) ?? 0.0,
          double.tryParse(rideObj["pickup_long"].toString()) ?? 0.0);

      getDirection();
    } else {
      origPos = LatLng(double.tryParse(rideObj["lati"].toString()) ?? 0.0,
          double.tryParse(rideObj["longi"].toString()) ?? 0.0);
      destPos = LatLng(double.tryParse(rideObj["drop_lat"].toString()) ?? 0.0,
          double.tryParse(rideObj["drop_long"].toString()) ?? 0.0);

      getDirection();
    }

    if (mounted) {
      setState(() {});
    }
  }

  void drawRoad(List<Routes> res) {
    print("DIRECTIONS");
    print(res![0].overviewPolyline!.toJson().toString());

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodePolylinePointsResult =
        polylinePoints.decodePolyline(res![0].overviewPolyline!.points!);

    pLineCoordinates.clear();

    if (decodePolylinePointsResult.isNotEmpty) {
      decodePolylinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
          polylineId: PolylineId("polylineId"),
          color: Colors.blueAccent,
          jointType: JointType.round,
          points: pLineCoordinates,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.squareCap,
          geodesic: true);

      polylineSet.add(polyline);
    });

    setMarkers(origPos, destPos);

    double dur =
        double.tryParse(res[0].legs![0].duration!.value.toString()) ?? 0.0;
    timeCount = (dur / 60.0).toStringAsFixed(1);
    double dist =
        double.tryParse(res[0].legs![0].distance!.value.toString()) ?? 0.0;
    km = (dist / 1000).toStringAsFixed(1);

    boundMap();
  }

  void boundMap() async {
    LatLngBounds latLngBounds;

    if (origPos.latitude > destPos.latitude &&
        origPos.longitude > destPos.longitude) {
      latLngBounds = LatLngBounds(southwest: destPos, northeast: origPos);
    } else if (origPos.longitude > destPos.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(origPos.latitude, destPos.longitude),
          northeast: LatLng(destPos.latitude, origPos.longitude));
    } else if (origPos.latitude > destPos.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(destPos.latitude, origPos.longitude),
          northeast: LatLng(origPos.latitude, destPos.longitude));
    } else {
      latLngBounds = LatLngBounds(southwest: origPos, northeast: destPos);
    }

    newGoogleMapController
        ?.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));
  }

  void apiCancelRide() {
    Globs.showHUD();
    ServiceCall.post({
      "booking_id": rideObj["booking_id"].toString(),
      "booking_status": rideObj["booking_status"].toString()
    }, isTokenApi: true, SVKey.svUserRideCancel,
        withSuccess: (responseObj) async {
      Globs.hideHUD();
      if (responseObj[KKey.status] == "1") {
        mdShowAlert(
            Globs.appName, responseObj[KKey.message] as String? ?? MSG.success,
            () {
          context.pop();
        });
      } else {
        mdShowAlert(Globs.appName,
            responseObj[KKey.message] as String? ?? MSG.fail, () {});
      }
    }, failure: (error) async {
      Globs.hideHUD();
      mdShowAlert(Globs.appName, error.toString(), () {});
    });
  }

  void apiSubmitRate() {
    Globs.showHUD();
    ServiceCall.post({
      "booking_id": rideObj["booking_id"].toString(),
      "rating": ratingVal.toString(),
      "comment": "good"
    }, isTokenApi: true, SVKey.svRideRating, withSuccess: (responseObj) async {
      Globs.hideHUD();
      if (responseObj[KKey.status] == "1") {
        mdShowAlert(
            Globs.appName, responseObj[KKey.message] as String? ?? MSG.success,
            () {
          context.pop();
        });
      } else {
        mdShowAlert(Globs.appName,
            responseObj[KKey.message] as String? ?? MSG.fail, () {});
      }
    }, failure: (error) async {
      Globs.hideHUD();
      mdShowAlert(Globs.appName, error.toString(), () {});
    });
  }

  String statusName() {
    switch (rideObj["booking_status"]) {
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

  String statusText() {
    switch (rideObj["booking_status"]) {
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

  Color statusColor() {
    switch (rideObj["booking_status"]) {
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

  void showRideCompletedPopUp() async {
    var taxAmt = double.tryParse(rideObj["tax_amt"] ?? "0.0") ?? 0.0;
    var tollAmt = double.tryParse(rideObj["toll_tax"] ?? "0.0") ?? 0.0;
    var payableAmt = double.tryParse(rideObj["amt"] ?? "0.0") ?? 0.0;
    var totalAmt = payableAmt - tollAmt - taxAmt;

    await showModalBottomSheet(
        backgroundColor: Colors.transparent,
        barrierColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
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
                        topRight: Radius.circular(10))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Ride Completed",
                      style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 20,
                          fontWeight: FontWeight.w800),
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
                              color: TColor.primaryText, fontSize: 20),
                        ),
                        Text(
                          (rideObj["payment_type"] ?? 1) == 1
                              ? "COD"
                              : "ONLINE",
                          style: TextStyle(
                              color: TColor.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Distance",
                          style: TextStyle(
                              color: TColor.primaryText, fontSize: 17),
                        ),
                        Text(
                          "${(double.tryParse(rideObj["total_distance"].toString() ?? "0.0") ?? 0.0).toStringAsFixed(2)} Km",
                          style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 17,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Duration:",
                          style: TextStyle(
                              color: TColor.primaryText, fontSize: 17),
                        ),
                        Text(
                          rideObj["duration"] ?? "00:00",
                          style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 17,
                              fontWeight: FontWeight.w700),
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
                              color: TColor.primaryText, fontSize: 17),
                        ),
                        Text(
                          "+\$${totalAmt.toStringAsFixed(2)}",
                          style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 17,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tax Amount:",
                          style: TextStyle(
                              color: TColor.primaryText, fontSize: 17),
                        ),
                        Text(
                          "+\$${taxAmt.toStringAsFixed(2)}",
                          style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 17,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Toll Tax:",
                          style: TextStyle(
                              color: TColor.primaryText, fontSize: 17),
                        ),
                        Text(
                          "+\$${tollAmt.toStringAsFixed(2)}",
                          style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 17,
                              fontWeight: FontWeight.w700),
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
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Payable Amount:",
                          style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 20,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          "\$${payableAmt.toStringAsFixed(2)}",
                          style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 20,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    RoundButton(
                        title: "Yes, Accept toll tax",
                        buttonType: RoundButtonType.primary,
                        onPressed: () {
                          context.pop();
                        }),
                    const SizedBox(
                      height: 15,
                    ),
                    RoundButton(
                        title: "No",
                        buttonType: RoundButtonType.red,
                        onPressed: () {
                          context.pop();
                        })
                  ],
                ),
              )
            ],
          );
        });
  }
}
