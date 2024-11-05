import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:maps_toolkit/maps_toolkit.dart' as mapToolKit;
import 'package:transport_app/common/color_extension.dart';
import 'package:transport_app/common/common_extension.dart';
import 'package:transport_app/common/dbhelpers.dart';
import 'package:transport_app/common/helpers.dart';
import 'package:transport_app/common/service_call.dart';
import 'package:transport_app/common/socket_manager.dart';
import 'package:transport_app/common_widget/location_select_button.dart';
import 'package:transport_app/common_widget/round_button.dart';
import 'package:transport_app/model/price_detail_model.dart';
import 'package:transport_app/model/zone_list_model.dart';
import 'package:transport_app/view/menu/menu_view.dart';
import 'package:transport_app/view/user/car_service_select_view.dart';
import 'package:transport_app/view/user/search_screen.dart';
import 'package:transport_app/view/user/user_run_ride_view.dart';
import '../../common/globs.dart';
import '../../cubit/geolocation/geolocation_bloc.dart';
import '../../cubit/geolocation/geolocation_event.dart';
import '../../cubit/geolocation/geolocation_state.dart';
import '../../cubit/map_requests/map_requests_cubit.dart';
import '../../firebase/push_notification.dart';
import '../../model/current_drivers_model.dart';
import '../../model/directions_model.dart';

class UserHomeView extends StatefulWidget {
  const UserHomeView({super.key});

  @override
  State<UserHomeView> createState() => _UserHomeViewState();
}

class _UserHomeViewState extends State<UserHomeView> {
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

  Routes? tripDirectionDetails;

  bool isOpen = true;
  bool isSelectPickup = true;
  bool isLock = false;
  bool isLocationChange = true;

  LatLng? pickupLocation;
  Placemark? pickUpAddressObj;
  String pickUpAddressString = "";

  LatLng? dropLocation;
  Placemark? dropAddressObj;
  String dropAddressString = "";

  List<ZoneListModel> zoneListArr = [];
  ZoneListModel? selectZone;

  List servicePriceArr = [];

  double estTimeInMin = 0.0;
  double estDistInKm = 0.0;

  List<CurrentDriversModel> currentDrivers = [];
  BitmapDescriptor? activeNearbyIcon;

  double suggestedPrice = 0;
  List availableDriversList = [];
  bool isAvailableDriverList = false;
  bool isRequestingService = false;
  Map<String,dynamic> requestData = {};

  Map user_data = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    changeLocation();

    initNotificationService();

    getUserData();

    SocketManager.shared.socket?.on("user_request_accept", (data) {
      if (data[KKey.status] == "1") {
        apiHome();
      }
      isRequestingService = false;
      setState(() {});
    });

    SocketManager.shared.socket?.on("driver_not_available", (data) {
      if (data[KKey.status] == "1") {
        var pObj = data[KKey.payload];
        if(pObj["booking_status"] == 7){
          mdShowAlert(Globs.appName, data[KKey.message] as String? ?? MSG.fail, () {});
        }
      }
      isRequestingService = false;
      setState(() {});
    });

    SocketManager.shared.socket?.on("drivers_location", (data) {
      if (data[KKey.status] == "1") {
        var pObj = data[KKey.payload];
        int userId = pObj["user_id"] ?? 0;
        double latitude = pObj["latitude"]==0 ? 0.0 : pObj["latitude"] ?? 0.0;
        double longitude = pObj["longitude"]==0 ? 0.0 : pObj["longitude"] ?? 0.0;

        CurrentDriversModel driverLocation = CurrentDriversModel(user_id: userId,latitude: latitude, longitude: longitude,bearing: 0.0);

        int index = currentDrivers.indexWhere((element) => element.user_id == userId);

        num distMts = mapToolKit.SphericalUtil.computeDistanceBetween(
            mapToolKit.LatLng(pickupLocation!.latitude,pickupLocation!.longitude),
            mapToolKit.LatLng(latitude,longitude)
        );

        if(index>=0){

          if(distMts<=3000){

            LatLng lastDriverPosition = LatLng(currentDrivers[index].latitude!, currentDrivers[index].longitude!);

            currentDrivers[index].latitude = latitude;
            currentDrivers[index].longitude = longitude;

            LatLng currentDriverPosition = LatLng(latitude, longitude);

            double bearing = 0.0;
            if(lastDriverPosition != currentDriverPosition){
              bearing = getBearing(lastDriverPosition, currentDriverPosition);
            }

            currentDrivers[index].bearing = bearing;

          }else{

            currentDrivers.removeWhere((driver) => driver.user_id == userId);

          }

        }else{
          if(distMts<=3000){
            currentDrivers.add(driverLocation);
          }
        }

        displayActiveDriverOnUserMap();

      }
    });

  }

  @override
  void dispose() {
    super.dispose();
    newGoogleMapController?.dispose();
  }

  void changeLocation() async {
    zoneListArr = await ZoneListModel.getActiveList();
  }

  void getCurrentPositionAddress() {
    getSelectLocation();
  }

  void setCurrentLocationInCamera(){
    LatLng latLng = LatLng(position!.latitude, position!.longitude);
    CameraPosition cameraPosition = new CameraPosition(target: latLng, zoom: 16);
    if (newGoogleMapController != null) {
      newGoogleMapController?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    }
  }

  void getSelectLocation() async {

    List<Placemark> addressArr = await placemarkFromCoordinates(position!.latitude, position!.longitude);
    pickUpAddressObj = addressArr.first;
    pickUpAddressString = "${pickUpAddressObj?.name}, ${pickUpAddressObj?.street}, "
        "${pickUpAddressObj?.subLocality}, ${pickUpAddressObj?.subAdministrativeArea},"
        ", ${pickUpAddressObj?.administrativeArea}, ${pickUpAddressObj?.postalCode}";

    selectZone = null;

    for (var zmObj in zoneListArr) {
      if (mapToolKit.PolygonUtil.containsLocation(
          mapToolKit.LatLng(position!.latitude, position!.longitude),
          zmObj.zonePathArr!,
          true)) {
        selectZone = zmObj;
        print(zmObj.toJson().toString());
      }

      if (selectZone == null) {
        print("Not found inside zone");
      }else{
        double dur = double.tryParse(tripDirectionDetails!.legs![0].duration!.value.toString()) ?? 0.0;
        estTimeInMin = (dur / 60.0);
        double dist = double.tryParse(tripDirectionDetails!.legs![0].distance!.value.toString()) ?? 0.0;
        estDistInKm = dist/1000;

        if (selectZone != null) {
          servicePriceArr =
              (await PriceDetailModel.getSelectZoneGetServiceAndPriceList(
                  selectZone!.zoneId ?? "0"))
                  .map((pObj) {
                var price = getEstValue(pObj);
                return {
                  "est_price_min": price,
                  "est_price_max": price * 1.3,
                  DBHelper.service_name: pObj[DBHelper.service_name],
                  DBHelper.icon: pObj[DBHelper.icon],
                  DBHelper.service_id: pObj[DBHelper.service_id],
                  DBHelper.price_id: pObj[DBHelper.price_id],
                };
              }).toList();
        }
      }

      boundMap();

    }

  }

  void drawRoadPickUpToDrop() async {
    if (pickupLocation != null &&
        dropLocation != null &&
        pickupLocation?.latitude != dropLocation?.latitude &&
        pickupLocation?.longitude != dropLocation?.longitude) {

      resetMap();

    }
  }

  double getEstValue(dynamic pObj) {
    var amount = (double.tryParse(pObj[DBHelper.base_charge]) ?? 0.0) +
        ((double.tryParse(pObj[DBHelper.per_km_charge]) ?? 0.0) * estDistInKm) +
        ((double.tryParse(pObj[DBHelper.per_min_charge]) ?? 0.0) *
            estTimeInMin) +
        (double.tryParse(pObj[DBHelper.booking_charge]) ?? 0.0);

    if ((double.tryParse(pObj[DBHelper.mini_km]) ?? 0.0) >= estDistInKm) {
      amount = (double.tryParse(pObj[DBHelper.mini_fair]) ?? 0.0);
    }

    var minPrice = amount;

    if ((double.tryParse(pObj[DBHelper.mini_fair]) ?? 0.0) >= minPrice) {
      minPrice = (double.tryParse(pObj[DBHelper.mini_fair]) ?? 0.0);
    }

    return minPrice;
  }

  void updateView() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {

    createActiveNearByDriverIconMarker();

    return Scaffold(
      body: BlocBuilder<GeolocationBloc, GeolocationState>(
          builder: (context, state) {
        if (state is GeolocationLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is GeolocationSuccess) {
          position = state.position;
          pickupLocation = LatLng(position!.latitude!, position!.longitude!);
          LatLng latLng = LatLng(position!.latitude, position!.longitude);
          CameraPosition cameraPosition = new CameraPosition(target: latLng, zoom: 16);
          if (newGoogleMapController != null) {
            newGoogleMapController?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
          }
          return BlocConsumer<MapRequestsCubit, MapRequestsState>(
            listener: (context, state) {
              if(state is MapRequestsDirectionsSuccess){
                drawRoad(state.routes);
              }else
              if(state is MapRequestsDirectionsFailed){
                mdShowAlert("Error", "Route calcule failed, try again", () { });
              }else
              if(state is MapRequestsInfoModelSuccess){
                context.pop();
                context.pop();
                dropAddressString = state.placesInfoModel.result!.formattedAddress!;
                dropLocation = LatLng(state.placesInfoModel.result!.geometry!.location!.lat!, state.placesInfoModel.result!.geometry!.location!.lng!);
                getDirection();
              }else
              if(state is MapRequestsAddressSuccess){
                if(state.address != null){
                  pickUpAddressString  = state.address.placeFormattedAddress!;
                }
              }else
              if(state is MapRequestsInfoModelFailed){

              }
            },
            builder: (context, state) {
              return Stack(
                alignment: Alignment.center,
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

                      setState(() {
                        bottomPaddingOfMap = 265.0;
                      });
                    },
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(35),
                              onTap: () {
                                setCurrentLocationInCamera();
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                    color: TColor.bg,
                                    borderRadius: BorderRadius.circular(35),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 10,
                                          offset: Offset(0, 5))
                                    ]),
                                child: Icon(Icons.my_location, size: 40),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      if(!isRequestingService && !isAvailableDriverList)
                        Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
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
                          children: [
                            LocationSelectButton(
                                title: "Pickup",
                                placeHolder: "Select pick up location",
                                color: TColor.secondary,
                                value: pickUpAddressString,
                                isSelect: isSelectPickup,
                                onPressed: () async {
                                  if(position != null){
                                    context.push(SearchScreen(position: position!));
                                  }
                                }),
                            SizedBox(
                              height: 8,
                            ),
                            LocationSelectButton(
                                title: "Dropoff",
                                placeHolder: "Select dropoff location",
                                color: TColor.primary,
                                value: dropAddressString,
                                isSelect: !isSelectPickup,
                                onPressed: () async {
                                  if(position != null){
                                    context.push(SearchScreen(position: position!));
                                  }
                                }),
                            SizedBox(
                              height: 20,
                            ),
                            RoundButton(
                                title: "Continue",
                                buttonType: RoundButtonType.primary,
                                onPressed: () {
                                  openCarService();
                                }),
                            SizedBox(
                              height: 25,
                            ),
                          ],
                        ),
                      ),
                      if(!isRequestingService && isAvailableDriverList)
                        getDriversList(),
                      if(isRequestingService && !isAvailableDriverList)
                        requestSentToDriver(),
                    ],
                  ),
                  SafeArea(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 60,
                              child: Stack(
                                alignment: Alignment.bottomLeft,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      context.push(MenuView(user_data: user_data,));
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(left: 10),
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 10)
                                          ]),
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          child: CachedNetworkImage(
                                            imageUrl: user_data["image"] as String? ?? "",
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.contain,
                                            placeholder: (context, url) => Center(
                                                child: Image.asset(
                                                  "assets/images/u1.png",
                                                  width: 40,
                                                  height: 40,
                                                ) // Loading indicator
                                            ),
                                          )
                                      ),
                                    ),
                                  ),
                                  // Container(
                                  //   padding: const EdgeInsets.symmetric(
                                  //       horizontal: 8, vertical: 1),
                                  //   decoration: BoxDecoration(
                                  //     color: Colors.red,
                                  //     borderRadius: BorderRadius.circular(30),
                                  //   ),
                                  //   constraints:
                                  //       const BoxConstraints(minWidth: 15),
                                  //   child: Text(
                                  //     "3",
                                  //     style: TextStyle(
                                  //         color: TColor.bg,
                                  //         fontSize: 10,
                                  //         fontWeight: FontWeight.w800),
                                  //   ),
                                  // )
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ))
                ],
              );
            },
          );
        } else if (state is GeolocationFailure) {
          return Center(child: Text('Error: ${state.error}'));
        } else {
          //getPosition();
          return Center(child: Text('Awaiting Location...'));
        }
      }),
    );
  }

  void openCarService() {
    if (pickupLocation == null) {
      mdShowAlert("Select", "Please select your pickup location", () {});
      return;
    }

    if (dropLocation == null) {
      mdShowAlert("Select", "Please select your drop off location", () {});
      return;
    }

    if (selectZone == null) {
      mdShowAlert("...", "Not Provided any service in this area 1", () {});
      return;
    }

    if (servicePriceArr.isEmpty) {
      mdShowAlert("...", "Not Provided any service in this area 2", () {});
      return;
    }

    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return CarServiceSelectView(
            serviceArr: servicePriceArr,
            didSelect: (selectObj) {
              print(selectObj);

              var estMaxVal =
                  ((selectObj["est_price_max"] as double? ?? 0.0) % 100) > 0
                      ? ((selectObj["est_price_max"] as double? ?? 0.0) ~/
                                  100) *
                              100 +
                          100
                      : (selectObj["est_price_max"] as double? ?? 0.0);

              suggestedPrice =  double.tryParse(estMaxVal!.toString())!;

              apiBookingRequest({
                "pickup_latitude": "${pickupLocation?.latitude ?? 0.0}",
                "pickup_longitude": "${pickupLocation?.longitude ?? 0.0}",
                "pickup_address": pickUpAddressString,
                "drop_latitude": "${dropLocation?.latitude ?? 0.0}",
                "drop_longitude": "${dropLocation?.longitude ?? 0.0}",
                "drop_address": dropAddressString,
                "pickup_date":
                    DateTime.now().stringFormat(format: "yyyy-MM-dd HH:mm:ss"),
                "payment_type": "1",
                "card_id": "",
                "price_id": selectObj["price_id"].toString(),
                "est_total_distance": estDistInKm.toStringAsFixed(2),
                "est_duration": estTimeInMin.toString(),
                "amount": estMaxVal.toString(),
                "service_id": selectObj["service_id"].toString()
              });
            },
          );
        });
  }

  void bookingAction() {

  }

  void apiBookingRequest(Map<String, String> parameter) {
    Globs.showHUD();
    ServiceCall.post(parameter, SVKey.svBookingRequestIndividual, isTokenApi: true,
        withSuccess: (responseObj) async {
      Globs.hideHUD();
      if (responseObj[KKey.status] == "1") {
        var payload = responseObj[KKey.payload] as Map<String,dynamic>? ?? {};
        availableDriversList = responseObj["driverslist"] as List ?? [];
        requestData = payload;
        //availableDriversList = Helpers.convertListValuesToString(availableDriversList);
        //requestData = Helpers.convertMapValuesToString(requestData);
        isAvailableDriverList = true;
        //isRequestingService = true;
        //mdShowAlert_auto_closing(Globs.appName, responseObj[KKey.message] as String? ?? MSG.success, () {});
        getDriversDistance();
      } else {
        mdShowAlert(
            "Error", responseObj[KKey.message] as String? ?? MSG.fail, () {});
      }
    }, failure: (error) async {
      Globs.hideHUD();
      mdShowAlert("Error", error.toString() as String? ?? MSG.fail, () {});
    });
  }

  void getDriversDistance() {

    final routeRequest = BlocProvider.of<MapRequestsCubit>(context);

    routeRequest.stream.listen((state) {
      if (state is MapRequestsDriversDirectionsSuccess) {
        availableDriversList.forEach((driver) {
          if(driver["user_id"]==state.dataRoutes["driver_id"]){
            List<Routes> routes = state.dataRoutes["routes"];
            driver["distance_from_me"] = routes[0].legs![0].distance!.value.toString();
            setState(() {});
          }
        });
      }else
      if (state is MapRequestsDriversDirectionsFailed) {

      }
    });

    availableDriversList.forEach((driver) {
      LatLng driverPos = LatLng(double.tryParse(driver["lati"]) ?? 0.0, double.tryParse(driver["longi"]) ?? 0.0);
      LatLng currentPos = LatLng(position!.latitude, position!.longitude);
      BlocProvider.of<MapRequestsCubit>(context).getDriversDirections(driverPos, currentPos, driver["user_id"], context);
    });



  }

  void apiHome() {
    Globs.showHUD();
    ServiceCall.post({}, isTokenApi: true, SVKey.svHome,
        withSuccess: (responseObj) async {
      Globs.hideHUD();
      if (responseObj[KKey.status] == "1") {
        var rObj =
            (responseObj[KKey.payload] as Map? ?? {})["running"] as Map? ?? {};
        if (rObj.keys.isNotEmpty) {
          context.push(UserRunRideView(rObj: rObj));
        }
      } else {
        mdShowAlert(
            "Error", responseObj[KKey.message] as String? ?? MSG.fail, () {});
      }
    }, failure: (error) async {
      Globs.hideHUD();
      mdShowAlert(Globs.appName, error.toString(), () {});
    });
  }

  void apiCancelRide() {
    Globs.showHUD();
    ServiceCall.post({
      "booking_id": requestData["booking_id"].toString(),
      "booking_status": requestData["booking_status"].toString()
    }, isTokenApi: true, SVKey.svUserRideCancelForce,
        withSuccess: (responseObj) async {
          Globs.hideHUD();
          if (responseObj[KKey.status] == "1") {
            mdShowAlert(
                Globs.appName, responseObj[KKey.message] as String? ?? MSG.success,
                    () {
                      isRequestingService = false;
                      setState(() {});
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

  void apiCallDriverIndividual(Map<String, dynamic> parameter) {
    Globs.showHUD();
    ServiceCall.post(parameter, SVKey.svCallDriverIndividual, isTokenApi: true,
        withSuccess: (responseObj) async {
          Globs.hideHUD();
          if (responseObj[KKey.status] == "1") {
            isRequestingService = true;
            setState(() {});
          } else {
            mdShowAlert(
                "Error", responseObj[KKey.message] as String? ?? MSG.fail, () {});
          }
        }, failure: (error) async {
          Globs.hideHUD();
          mdShowAlert("Error", error.toString() as String? ?? MSG.fail, () {});
        });
  }

  void getPosition() async {
    BlocProvider.of<GeolocationBloc>(context).add(StartLocationTracking());
  }

  void getDirection() async {
    LatLng origPos = LatLng(position!.latitude, position!.longitude);
    LatLng destPos = LatLng(dropLocation!.latitude, dropLocation!.longitude);
    context.read<MapRequestsCubit>().getDirections(origPos, destPos, context);
  }

  void drawRoad(List<Routes> res) {
    LatLng origPos = LatLng(position!.latitude, position!.longitude);
    LatLng destPos = LatLng(dropLocation!.latitude, dropLocation!.longitude);

    tripDirectionDetails = res![0];

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

    //setState(() {
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
    //});

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

    setState(() {
      markersSet.add(origLocationMarker);
      markersSet.add(destLocationMarker);
    });

    getSelectLocation();
  }

  void boundMap() async {

    LatLng origPos = LatLng(position!.latitude, position!.longitude);
    LatLng destPos = LatLng(dropLocation!.latitude, dropLocation!.longitude);

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

    newGoogleMapController?.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 40));
  }

  void displayActiveDriverOnUserMap(){

    //setState(() {
      markersSet.clear();

      Set<Marker> driversMarkerSet = Set<Marker>();

      for(CurrentDriversModel cdm in currentDrivers){

        LatLng driverPos = LatLng(cdm.latitude!,cdm.longitude!);

        Marker driverMark = Marker(
            markerId: MarkerId(cdm.user_id!.toString()),
            icon: activeNearbyIcon!,
            position: driverPos,
            rotation: cdm.bearing!
        );

        driversMarkerSet.add(driverMark);

      }

      markersSet= driversMarkerSet;

      setState(() {});


    //});
  }

  void resetMap() {
    setState(() {
      bottomPaddingOfMap = 230.0;
      polylineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      pLineCoordinates.clear();
    });
  }

  createActiveNearByDriverIconMarker() async{
    if(activeNearbyIcon == null){

      ImageConfiguration imageConfiguration = ImageConfiguration(
          bundle: DefaultAssetBundle.of(context),
          locale: Localizations.maybeLocaleOf(context),
          textDirection: Directionality.maybeOf(context),
          size: const Size(2,2)
      );

      bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

      if(isIOS){
        BitmapDescriptor.fromAssetImage(imageConfiguration, "assets/images/carmap_ios.png").then((value){
          activeNearbyIcon = value;
        });
      }else{
        BitmapDescriptor.fromAssetImage(imageConfiguration, "assets/images/carmap_android.png").then((value){
          activeNearbyIcon = value;
        });
      }


    }
  }

  void initNotificationService() async{

    PushNotificationSystem pushNotificationSystem = PushNotificationSystem(context: context);
    pushNotificationSystem.initializeCloudMessaging();
    String pushToken = await pushNotificationSystem.generateMessagingToken();

    apiUpdatePushToken(pushToken);

  }

  void apiUpdatePushToken(String pushToken){
    Globs.showHUD();
    ServiceCall.post(
        {
          "push_token": pushToken
        },
        isTokenApi: true,
        SVKey.svUpdatePushToken,
        withSuccess: (responseObj)async{
          Globs.hideHUD();
          if(responseObj[KKey.status]=="1"){
            if(kDebugMode){
              print(responseObj[KKey.message] as String? ?? MSG.success);
            }
            getPosition();
          }else{
            mdShowAlert("Error", responseObj[KKey.message] as String? ?? MSG.fail, () { });
          }
        },
        failure: (error)async{
          Globs.hideHUD();
          mdShowAlert(Globs.appName, error.toString(),(){});
        }
    );
  }

  Widget getDriversList(){

    NumberFormat formatter = NumberFormat.decimalPatternDigits(
      locale: 'en_us',
      decimalDigits: 0,
    );

    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.symmetric(
              vertical: 25, horizontal: 5),
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
          child: ListView.builder(
              itemCount: availableDriversList.length,
              itemBuilder: (BuildContext context, int index) {
        
                return GestureDetector(
                  onTap: (){
                    requestData = requestData;
                    setState(() {
                      isAvailableDriverList = false;
                      apiCallDriverIndividual({
                        "push_token": availableDriversList[index]["push_token"],
                        "driver_id": availableDriversList[index]["user_id"].toString(),
                        "pickup_address": requestData["pickup_address"],
                        "booking_id": requestData["booking_id"].toString(),
                        "service_name": requestData["service_name"],
                        "color": requestData["color"],
                        "name": requestData["name"],
                        "pickup_date": requestData["pickup_date"],
                        "pickup_lat": requestData["pickup_lat"],
                        "pickup_long": requestData["pickup_long"],
                        "drop_lat": requestData["drop_lat"],
                        "drop_long": requestData["drop_long"],
                        "pickup_address": requestData["pickup_address"],
                        "drop_address": requestData["drop_address"],
                        "amt": requestData["amt"],
                        "payment_type": requestData["payment_type"].toString(),
                        "est_total_distance": requestData["est_total_distance"],
                        "est_duration": requestData["est_duration"],
                        "pickup_accpet_time": requestData["accpet_time"].toString(),
                        "request_time_out": requestData["accpet_time"].toString(),
                        "request_driver_id": requestData["request_driver_id"].toString()
                      });
                      setState(() {});
                    });
                  },
                  child: Card(
                    color: Colors.white,
                    elevation: 3,
                    shadowColor: Colors.green,
                    margin: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        FadeInImage(
                          placeholder: AssetImage('assets/images/car.png'),
                          //image: NetworkImage("https://firebasestorage.googleapis.com/v0/b/plataformatransporte-b20ba.appspot.com/o/${dList[index]["carMake"]}_${dList[index]["carModel"]}.jpeg?alt=media&token=dc8ab158-472d-4150-b19b-2fa87971b4d6"),
                          image: NetworkImage(availableDriversList[index]["car_image"]),
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              availableDriversList[index]["brand_name"],
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54
                              ),
                            ),
                            Text(
                                "${availableDriversList[index]["model_name"]}-${availableDriversList[index]["series_name"]}",
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54
                                )
                            ),
                            const SizedBox(height: 2,),
                            Text(
                              "${estDistInKm.toStringAsFixed(2)} km",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            const SizedBox(height: 2,),
                            Text(
                              "${estTimeInMin.toStringAsFixed(0)}" + " min",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black
                              ),
                            ),
                            const SizedBox(height: 2,),
                            Text(
                              "Distancia real de mí:",
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            const SizedBox(height: 2,),
                            Text(
                                "${availableDriversList[index]["distance_from_me"]}" + "mts",
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold
                                )
                            ),
                            const SizedBox(height: 2,),
                            Text(
                              "COP ${formatter.format(suggestedPrice)}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ),
                );
              }
          ),
        ),
        Container(
          height: 20,
          width: 20,
          child: InkWell(
              onTap: (){
                isAvailableDriverList=false;
                setState(() {});
              },
              child: Icon(Icons.close,size: 30,color: Colors.black,)
          ),
        ),
      ],
    );

  }

  Widget requestSentToDriver(){
    return Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.symmetric(
            vertical: 0, horizontal: 5),
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
          mainAxisAlignment: MainAxisAlignment.start,
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
                  lottie.Lottie.asset(
                    "assets/animations/radar_animation.json",
                    height: MediaQuery.of(context).size.height * 0.3,
                    width: MediaQuery.of(context).size.width * 0.8,
                  ),
                  Text(
                    "${double.parse(requestData["est_duration"]).ceil() ?? "0"} min",
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
                          "${requestData["est_total_distance"] ?? ""} KM",
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
                          "\$${requestData["amt"] ?? ""}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: TColor.secondaryText,
                              fontSize: 18,
                              fontWeight: FontWeight.w800
                          ),
                        ),
                      ),
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
                            "${requestData["pickup_address"] ?? ""}",
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
                            "${requestData["drop_address"] ?? ""}",
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
                      apiCancelRide();
                    },
                    child: Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.all(6),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Cancel request",
                                style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25,)
                ],
              ),

            )
          ],
        )
    );
  }

  void getUserData(){
    Globs.showHUD();

    ServiceCall.post(
        {},
        isTokenApi: true,
        SVKey.svGetProfileData,
        withSuccess: (responseObj) async{
          Globs.hideHUD();
          if((responseObj[KKey.status] as String? ?? "") == "1"){
            user_data = responseObj[KKey.payload] as Map? ?? {};
          }else{
            user_data = {};
          }
          setState(() {

          });
        },
        failure: (err) async{
          Globs.hideHUD();
        }
    );
  }

}
