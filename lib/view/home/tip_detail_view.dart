import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:transport_app/common/common_extension.dart';
import 'package:transport_app/common_widget/title_subtitle_row.dart';

import '../../common/color_extension.dart';
import '../../common/globs.dart';
import '../../common/service_call.dart';

class TipDetailView extends StatefulWidget {

  final Map bObj;

  const TipDetailView({super.key, required this.bObj});

  @override
  State<TipDetailView> createState() => _TipDetailViewState();
}

class _TipDetailViewState extends State<TipDetailView> with OSMMixinObserver {

  bool isOpen = true;

  late MapController controller;

  Map bookinObj = {

  };

  bool isApiData = false;

  @override
  void initState() {
    super.initState();

    apiDetail();

    controller = MapController(
      initPosition: GeoPoint(latitude: 4.8103487, longitude: -75.7598604),
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

    var taxAmt = double.tryParse(bookinObj["tax_amt"].toString()) ?? 0.0;
    var tollAmt = double.tryParse(bookinObj["toll_tax"].toString()) ?? 0.0;
    var payableAmt = double.tryParse(bookinObj["amt"].toString()) ?? 0.0;
    var totalAmt = payableAmt - tollAmt - taxAmt;

    return Scaffold(
      backgroundColor: TColor.lightGray,
      appBar: AppBar(
        backgroundColor: TColor.bg,
        elevation: 1,
        leading: IconButton(
          icon: Image.asset(
            "assets/images/back.png",
            width: 20,
            height: 20
          ),
          onPressed: () {
            context.pop();
          },
        ),
        centerTitle: true,
        title: Text("Trip Details",
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w800
          ),
        ),
        actions: [
          TextButton.icon(
              onPressed: () {

              },
              icon: Icon(Icons.help,size: 30,),
              label: Text(
                "Help",
                style: TextStyle(
                  color: TColor.primary,
                  fontSize: 14
                ),
              ),
          )
        ],
      ),
      body: !isApiData ?
      Center(child: Text(
          "Loading...",
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 25,
            fontWeight: FontWeight.w700
          ),
        ),
      ) :
      SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 2,
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
                children: [
                  SizedBox(height: 3),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 3),
                    child: Row(
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
                            bookinObj["pickup_address"] as String? ?? "",
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
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 3),
                    child: Row(
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
                            bookinObj["drop_address"] as String? ?? "",
                            style: TextStyle(
                                color: TColor.secondaryText,
                                fontSize: 15
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
        
            ),
            SizedBox(
              width: context.width,
              height: context.heigth * 0.35,
              child: OSMFlutter(
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
            ),
            Container(
              width: context.width,
              padding: const EdgeInsets.symmetric(vertical: 3),
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
                  SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                    child: Text(
                      "\$ ${payableAmt.toStringAsFixed(2)}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: TColor.primary,
                        fontSize: 25,
                        fontWeight: FontWeight.w800
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 2),
                    child: Text(
                      "Payment made succesfully by ${bookinObj["payment_type"] == 1 ? "Cash" : "Online"}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.w800
                      ),
                    ),
                  ),
                  const Divider(),
                  SizedBox(
                    height: 70,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                bookinObj["duration"] as String? ?? "00:00",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: TColor.primaryText,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800
                                ),
                              ),
                              Text(
                                "Time",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: TColor.secondaryText,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800
                                ),
                              ),
                            ],
                          )
                        ),
                        Container(
                          width: 1,
                          height: 70,
                          color: TColor.lightGray.withOpacity(0.5),
                        ),
                        Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${(double.tryParse(bookinObj["total_distance"]) ?? 0.0).toStringAsFixed(2)} Km",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: TColor.primaryText,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800
                                  ),
                                ),
                                Text(
                                  "Distance",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: TColor.secondaryText,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800
                                  ),
                                ),
                              ],
                            )
                        )
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 20),
                    child: Column(
                      children: [
                        TitleSubtitleRow(title: "Date Time", subTitle: "${bookinObj["stop_time"] as String? ?? ""}".dataFormat().stringFormat(format: "dd MM, yyyy hh:mm a")),
                        TitleSubtitleRow(title: "Service Type", subTitle: "${bookinObj["service_name"] as String? ?? ""}"),
                        //TitleSubtitleRow(title: "Trip Type", subTitle: "Normal")
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "You rated ${bookinObj["name"] as String? ?? ""}",
                          style: TextStyle(
                              color: TColor.secondaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w800
                          ),
                        ),
                        ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(
                              imageUrl: bookinObj["image"] as String? ?? "",
                              width: 30,
                              height: 30,
                              fit: BoxFit.cover,
                            )
                        ),
                        IgnorePointer(
                          ignoring: true,
                          child: RatingBar.builder(
                            initialRating: double.tryParse(bookinObj[ServiceCall.userType == 1 ? "driver_rating" : "user_rating"]) ?? 0.0,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 20,
                            itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              print(rating);
                            },
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),

            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
              child: Text(
                "RECEIPT",
                style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w800
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
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
                    padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 20),
                    child: Column(
                      children: [
                        TitleSubtitleRow(title: "Trip fares", subTitle: "\$ ${totalAmt.toStringAsFixed(2)}", color: TColor.secondaryText,),
                        // TitleSubtitleRow(title: "Fee", subTitle: "\$ 20.00", color: TColor.secondaryText,),
                        TitleSubtitleRow(title: "+ Tax", subTitle: "\$ ${taxAmt.toStringAsFixed(2)}", color: TColor.secondaryText,),
                        TitleSubtitleRow(title: "+ Tolls", subTitle: "\$ ${tollAmt.toStringAsFixed(2)}", color: TColor.secondaryText,),
                        // TitleSubtitleRow(title: "+ Discount", subTitle: "\$ 0.00", color: TColor.secondaryText,),
                        // TitleSubtitleRow(title: "+ Topup Added", subTitle: "\$ 0.00", color: TColor.secondaryText,),
                      ],
                    ),
                  ),
                  const Divider(),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 20),
                    child: TitleSubtitleRow(
                      title: "Your payment",
                      subTitle: "\$ ${payableAmt.toStringAsFixed(2)}",
                      color: TColor.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 1),
                    child: Text(
                      "This trip was towards your destination you received Guaranteed fare",
                      style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 13,
                          fontWeight: FontWeight.w800
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
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

    await controller.setStaticPosition([
      GeoPoint(
          latitude: double.tryParse(bookinObj["pickup_lat"].toString()) ?? 0.0,
          longitude: double.tryParse(bookinObj["pickup_long"].toString()) ?? 0.0
      )],
        "pickup");
    await controller.setStaticPosition([
      GeoPoint(
          latitude: double.tryParse(bookinObj["drop_lat"].toString()) ?? 0.0,
          longitude: double.tryParse(bookinObj["drop_long"].toString()) ?? 0.0
      )],
        "dropoff");

    //loadMapRoad();

  }

  void loadMapRoad()async{
    await controller.drawRoad(
        GeoPoint(
            latitude: double.tryParse(bookinObj["pickup_lat"].toString()) ?? 0.0,
            longitude: double.tryParse(bookinObj["pickup_long"].toString()) ?? 0.0
        ),
        GeoPoint(
            latitude: double.tryParse(bookinObj["drop_lat"].toString()) ?? 0.0,
            longitude: double.tryParse(bookinObj["drop_long"].toString()) ?? 0.0
        ),
        roadType: RoadType.car,
        roadOption: const RoadOption(roadColor: Colors.blueAccent,roadBorderWidth: 4)
    );
  }

  @override
  Future<void> mapIsReady(bool isReady) async{
    if(isReady){
      addMarker();
    }
  }

  void apiDetail(){
    Globs.showHUD();
    ServiceCall.post(
        {
          "booking_id" : widget.bObj["booking_id"].toString(),
        },
        isTokenApi: true,
        SVKey.svBookingDetail,
        withSuccess: (responseObj)async{
          Globs.hideHUD();
          if(responseObj[KKey.status]=="1"){
            bookinObj = responseObj[KKey.payload] as Map? ?? {};
          }else{
            bookinObj = responseObj[KKey.result][0] as Map? ?? {};
          }
          isApiData = true;
          if(mounted){
            setState(() {});
          }

          await Future.delayed(const Duration(seconds: 3));
          loadMapRoad();
        },
        failure: (error)async{
          Globs.hideHUD();
          mdShowAlert(Globs.appName, error.toString(),(){});
        }
    );
  }

}
