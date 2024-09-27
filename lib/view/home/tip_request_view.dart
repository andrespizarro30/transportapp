import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:transport_app/common/common_extension.dart';
import 'package:transport_app/view/home/run_ride_view.dart';

import '../../common/color_extension.dart';
import '../../common/globs.dart';
import '../../common/service_call.dart';
import '../../common/socket_manager.dart';

class TipRequestView extends StatefulWidget {

  final Map bObj;

  const TipRequestView({super.key, required this.bObj});

  @override
  State<TipRequestView> createState() => _TipRequestViewState();
}

class _TipRequestViewState extends State<TipRequestView> with OSMMixinObserver {

  bool isOpen = true;

  late MapController controller;

  @override
  void initState() {
    super.initState();

    controller = MapController(
      initPosition: GeoPoint(
          latitude: double.tryParse(widget.bObj["pickup_lat"].toString()) ?? 0.0,
          longitude: double.tryParse(widget.bObj["pickup_long"].toString()) ?? 0.0
      ),
    );

    controller.addObserver(this);

  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          OSMFlutter(
              controller:controller,
              osmOption: OSMOption(
                enableRotationByGesture: true,
                zoomOption: const ZoomOption(
                  initZoom: 8,
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
              onMapIsReady: (isReady){
                if(isReady){
                  print("Map is ready");
                }
              },
              onLocationChanged: (myLocation){
                print("User location: $myLocation");
              },
              onGeoPointClicked: (location){
                print("Clicked location: $location");
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
                      "${widget.bObj["est_duration"] ?? ""} min",
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
                            color: TColor.primary,
                            borderRadius: BorderRadius.circular(25)
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
                                "15",
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
            iconWidget: Icon(Icons.car_crash,size: 40,color: TColor.secondary)
        )
    );

    await controller.setStaticPosition(
      [
        GeoPoint(
          latitude: double.tryParse(widget.bObj["pickup_lat"].toString()) ?? 0.0,
          longitude: double.tryParse(widget.bObj["pickup_long"].toString()) ?? 0.0
        )
      ], "pickup");

    await controller.setStaticPosition(
        [
          GeoPoint(
            latitude: double.tryParse(widget.bObj["drop_lat"].toString()) ?? 0.0,
            longitude: double.tryParse(widget.bObj["drop_long"].toString()) ?? 0.0
          )
        ], "dropoff");

    loadMapRoad();

  }

  void loadMapRoad()async{
    await controller.drawRoad(
        GeoPoint(
            latitude: double.tryParse(widget.bObj["pickup_lat"].toString()) ?? 0.0,
            longitude: double.tryParse(widget.bObj["pickup_long"].toString()) ?? 0.0
        ),
        GeoPoint(
            latitude: double.tryParse(widget.bObj["drop_lat"].toString()) ?? 0.0,
            longitude: double.tryParse(widget.bObj["drop_long"].toString()) ?? 0.0
        ),
        roadType: RoadType.car,
        roadOption: const RoadOption(roadColor: Colors.blueAccent,roadBorderWidth: 5)
    );
  }

  @override
  Future<void> mapIsReady(bool isReady) async{
    if(isReady){
      addMarker();
    }
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
