import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_app/common/common_extension.dart';

import '../../common/color_extension.dart';
import '../../common/globs.dart';
import '../../common/service_call.dart';
import '../../common/socket_manager.dart';
import '../../cubit/map_requests/map_requests_cubit.dart';
import '../../model/directions_model.dart';

class TipRequestView extends StatefulWidget {

  final Map bObj;

  const TipRequestView({super.key, required this.bObj});

  @override
  State<TipRequestView> createState() => _TipRequestViewState();
}

class _TipRequestViewState extends State<TipRequestView> with SingleTickerProviderStateMixin {

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

  late Timer timer;
  int time_left_to_accept = 15;

  late AnimationController colorController;
  late Animation<Color?> colorAnimation;



  @override
  void initState() {
    super.initState();

    SocketManager.shared.socket?.on("user_cancel_ride", (data) async{
      print("user_cancel_ride socket get : ${data.toString()}");
      if(data[KKey.status] == "1"){
        if(data[KKey.payload]["booking_id"] == widget.bObj["booking_id"]){
          context.pop();
        }
      }
    });

    const Duration interval = Duration(seconds: 1);

    timer = Timer.periodic(interval, (Timer timer) {
      setState(() {
        time_left_to_accept -= 1;
      });

      if(time_left_to_accept == 0){
        apiDeclineRide();
      }

    });

    colorController = AnimationController(
      duration: Duration(seconds: 15), // Duration of the animation
      vsync: this,
    );

    colorAnimation = ColorTween(begin: Colors.green, end: Colors.red).animate(colorController)
      ..addListener(() {
        setState(() {});
      });

    colorController.forward();

  }

  @override
  void dispose() {
    timer.cancel();
    colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
                          Text(
                            "${double.parse(widget.bObj["est_duration"]).ceil() ?? "0"} min",
                            style: TextStyle(
                                color: TColor.primaryText,
                                fontSize: 25,
                                fontWeight: FontWeight.w800
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "${widget.bObj["est_total_distance"] ?? ""} KM",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: TColor.secondaryText,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "\$${widget.bObj["amt"] ?? ""}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: TColor.secondaryText,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.star_half_outlined,size: 20,),
                                      const SizedBox(width: 4,),
                                      Text(
                                        "5",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: TColor.secondaryText,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 15),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                            child: Row(
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
                                    "${widget.bObj["pickup_address"] ?? ""}",
                                    style: TextStyle(
                                        color: TColor.secondaryText,
                                        fontSize: 15
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                            child: Row(
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
                                    "${widget.bObj["drop_address"] ?? ""}",
                                    style: TextStyle(
                                        color: TColor.secondaryText,
                                        fontSize: 15
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15,),

                          InkWell(
                            onTap: (){
                              apiAcceptRide();
                            },
                            child: Container(
                              width: double.maxFinite,
                              padding: const EdgeInsets.all(6),
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                  color: colorAnimation.value,
                                  borderRadius: BorderRadius.circular(25),
                                  // gradient: LinearGradient(
                                  //   begin: Alignment.centerRight,
                                  //   end: Alignment.centerLeft,
                                  //   stops: [0.0, colorAnimation.value], // Dynamic stop for the color change
                                  //   colors: [
                                  //     TColor.primary,
                                  //     Colors.red,
                                  //   ],
                                  // ),
                              ),
                              child: Stack(
                                alignment: Alignment.centerRight,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "ACEPTAR",
                                        style: TextStyle(
                                            color: TColor.primaryTextW,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.black12,
                                      borderRadius: BorderRadius.circular(20)
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      time_left_to_accept.toString(),
                                      style: TextStyle(
                                          color: TColor.primaryTextW,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 25,)
                        ],
                      ),

                    )
                  ],
                ),
                SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:[
                              InkWell(
                                onTap: (){
                                  apiDeclineRide();
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
                                        Icon(Icons.close,size: 25,),
                                        SizedBox(width: 8,),
                                        Text(
                                          "No gracias",
                                          style: TextStyle(
                                              color: TColor.primaryText,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800
                                          ),
                                        ),
                                      ],
                                    )
                                ),
                              ),

                            ],
                          ),
                        )
                      ],
                    )
                )
              ],
            );
        },
      ),
    );
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

  void loadMapRoad()async{
    origPos = LatLng(double.tryParse(widget.bObj["pickup_lat"].toString()) ?? 0.0,
        double.tryParse(widget.bObj["pickup_long"].toString()) ?? 0.0);
    destPos = LatLng(double.tryParse(widget.bObj["drop_lat"].toString()) ?? 0.0,
        double.tryParse(widget.bObj["drop_long"].toString()) ?? 0.0);

    getDirection();
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

  void apiAcceptRide(){
    Globs.showHUD();
    ServiceCall.post(
        {
          "booking_id" : widget.bObj["booking_id"].toString(),
          "request_token" : widget.bObj["request_token"].toString()
        },
        SVKey.svDriverRequestAccept,
        isTokenApi: true,
        withSuccess: (responseObj) async{
          Globs.hideHUD();
          if(responseObj[KKey.status] == "1"){
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(responseObj[KKey.message] as String? ?? MSG.success))
            );
            if(mounted){
              setState(() {});
            }
          }else{
            mdShowAlert(Globs.appName, responseObj[KKey.message] as String? ?? MSG.fail,(){

            });
          }
        },
        failure: (error) async{
          Globs.hideHUD();
          mdShowAlert(Globs.appName, error.toString(),(){

          });
        }
    );
  }

  void apiDeclineRide(){
    Globs.showHUD();
    ServiceCall.post(
        {
          "booking_id" : widget.bObj["booking_id"].toString(),
          "request_token" : widget.bObj["request_token"].toString()
        },
        SVKey.svDriverRequestDecline,
        isTokenApi: true,
        withSuccess: (responseObj) async{
          Globs.hideHUD();
          if(responseObj[KKey.status] == "1"){
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(responseObj[KKey.message] as String? ?? MSG.success))
            );
            if(mounted){
              setState(() {});
            }
          }else{
            mdShowAlert(Globs.appName, responseObj[KKey.message] as String? ?? MSG.fail,(){

            });
          }
        },
        failure: (error) async{
          Globs.hideHUD();
          mdShowAlert(Globs.appName, error.toString(),(){

          });
        }
    );
  }

}
