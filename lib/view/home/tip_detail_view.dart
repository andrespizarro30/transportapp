import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_app/common/common_extension.dart';
import 'package:transport_app/common_widget/title_subtitle_row.dart';

import '../../common/appLocalizations .dart';
import '../../common/color_extension.dart';
import '../../common/globs.dart';
import '../../common/service_call.dart';
import '../../cubit/map_requests/map_requests_cubit.dart';
import '../../model/directions_model.dart';

class TipDetailView extends StatefulWidget {

  final Map bObj;

  const TipDetailView({super.key, required this.bObj});

  @override
  State<TipDetailView> createState() => _TipDetailViewState();
}

class _TipDetailViewState extends State<TipDetailView>{

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

  Map bookinObj = {

  };

  bool isApiData = false;

  @override
  void initState() {
    super.initState();
    apiDetail();
  }

  @override
  void dispose() {
    super.dispose();
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
        title: Text(AppLocalizations.of(context).translate('trip_details'),
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
                AppLocalizations.of(context).translate('help'),
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
        AppLocalizations.of(context).translate('loading')+"...",
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
              child: BlocConsumer<MapRequestsCubit, MapRequestsState>(
                listener: (context, state) {
                  if(state is MapRequestsDirectionsSuccess){
                    drawRoad(state.routes);
                  }
                },
                builder: (context, state) {
                  return GoogleMap(
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
                              },
                            );
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
                      AppLocalizations.of(context).translate('payment_made_successfully_by') + " ${bookinObj["payment_type"] == 1 ? "Cash" : "Online"}",
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
                                AppLocalizations.of(context).translate('time'),
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
                                  AppLocalizations.of(context).translate('distance'),
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
                        TitleSubtitleRow(title: AppLocalizations.of(context).translate('date_time'), subTitle: "${bookinObj["stop_time"] as String? ?? ""}".dataFormat().stringFormat(format: "dd MM, yyyy hh:mm a")),
                        TitleSubtitleRow(title: AppLocalizations.of(context).translate('service_type'), subTitle: "${bookinObj["service_name"] as String? ?? ""}"),
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
                          AppLocalizations.of(context).translate('you_rated') + " ${bookinObj["name"] as String? ?? ""}",
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
                AppLocalizations.of(context).translate('RECEIPT'),
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
                        TitleSubtitleRow(title: AppLocalizations.of(context).translate('trip_fares'), subTitle: "\$ ${totalAmt.toStringAsFixed(2)}", color: TColor.secondaryText,),
                        // TitleSubtitleRow(title: "Fee", subTitle: "\$ 20.00", color: TColor.secondaryText,),
                        TitleSubtitleRow(title: "+ " + AppLocalizations.of(context).translate('tax'), subTitle: "\$ ${taxAmt.toStringAsFixed(2)}", color: TColor.secondaryText,),
                        TitleSubtitleRow(title: "+ " + AppLocalizations.of(context).translate('tolls'), subTitle: "\$ ${tollAmt.toStringAsFixed(2)}", color: TColor.secondaryText,),
                        // TitleSubtitleRow(title: "+ Discount", subTitle: "\$ 0.00", color: TColor.secondaryText,),
                        // TitleSubtitleRow(title: "+ Topup Added", subTitle: "\$ 0.00", color: TColor.secondaryText,),
                      ],
                    ),
                  ),
                  const Divider(),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 20),
                    child: TitleSubtitleRow(
                      title: AppLocalizations.of(context).translate('your_payment'),
                      subTitle: "\$ ${payableAmt.toStringAsFixed(2)}",
                      color: TColor.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 1),
                    child: Text(
                      AppLocalizations.of(context).translate('guaranteed_fare'),
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

  void setMarkers(LatLng origPos, LatLng destPos) {
    Marker origLocationMarker = Marker(
        markerId: MarkerId("pickUpMarker"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        infoWindow: InfoWindow(
          //title: address!.placeName,
            snippet: AppLocalizations.of(context).translate('starting_point')),
        position: origPos);

    Marker destLocationMarker = Marker(
        markerId: MarkerId("destinyMarker"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          //title: result!.name!,
            snippet: AppLocalizations.of(context).translate('arriving_point')),
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

    origPos = LatLng(
        double.tryParse(bookinObj["pickup_lat"].toString()) ?? 0.0,
        double.tryParse(bookinObj["pickup_long"].toString()) ?? 0.0
    );
    
    destPos = LatLng(double.tryParse(bookinObj["drop_lat"].toString()) ?? 0.0,
        double.tryParse(bookinObj["drop_long"].toString()) ?? 0.0);

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
