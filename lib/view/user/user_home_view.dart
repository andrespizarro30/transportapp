import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geocoding/geocoding.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:transport_app/common/color_extension.dart';
import 'package:transport_app/common/common_extension.dart';
import 'package:transport_app/common/dbhelpers.dart';
import 'package:transport_app/common/service_call.dart';
import 'package:transport_app/common/socket_manager.dart';
import 'package:transport_app/common_widget/location_select_button.dart';
import 'package:transport_app/common_widget/round_button.dart';
import 'package:transport_app/model/price_detail_model.dart';
import 'package:transport_app/model/zone_list_model.dart';
import 'package:transport_app/view/menu/menu_view.dart';
import 'package:transport_app/view/user/car_service_select_view.dart';
import 'package:transport_app/view/user/user_run_ride_view.dart';

import '../../common/globs.dart';

class UserHomeView extends StatefulWidget {
  const UserHomeView({super.key});

  @override
  State<UserHomeView> createState() => _UserHomeViewState();
}

class _UserHomeViewState extends State<UserHomeView> {

  bool isOpen = true;
  bool isSelectPickup = true;
  bool isLock = false;
  bool isLocationChange = true;

  GeoPoint? pickupLocation;
  Placemark? pickUpAddressObj;
  String pickUpAddressString = "";

  GeoPoint? dropLocation;
  Placemark? dropAddressObj;
  String dropAddressString = "";

  List<ZoneListModel> zoneListArr = [];
  ZoneListModel? selectZone;

  List servicePriceArr = [];

  double estTimeInMin = 0.0;
  double estDistInKm = 0.0;

  MapController controller = MapController(
    initPosition: GeoPoint(latitude: 4.8143276, longitude: -75.6951958),
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    changeLocation();
    // controller.listenerRegionIsChanging.addListener(() async{
    //   if(controller.listenerRegionIsChanging.value != null){
    //     if(isLock && !isLocationChange){
    //       return;
    //     }
    //     getSelectLocation(isSelectPickup);
    //   }
    // });

    SocketManager.shared.socket?.on("user_request_accept", (data){
      if(data[KKey.status] == "1"){
        apiHome();
      }
    });

  }

  @override
  void dispose() {
    super.dispose();
    controller.listenerRegionIsChanging.removeListener(() { });
    controller.dispose();
  }

  void changeLocation() async{
    await Future.delayed(const Duration(milliseconds: 4000));
    controller.goToLocation(GeoPoint(latitude: 4.8143276, longitude: -75.6951958));

    zoneListArr = await ZoneListModel.getActiveList();
  }

  void getCurrentPositionAddress(){
    getSelectLocation(isSelectPickup);
  }

  void getSelectLocation(bool isPickUp) async{
    GeoPoint centerMap = await controller.centerMap;
    print("lat: ${centerMap.latitude}, lon: ${centerMap.longitude}");
    List<Placemark> addressArr = await placemarkFromCoordinates(centerMap.latitude, centerMap.longitude);
    print("----------------------");
    if(addressArr.isNotEmpty){
      if(isPickUp){
        pickupLocation = centerMap;
        pickUpAddressObj = addressArr.first;
        //print(pickUpAddressObj.toString());

        pickUpAddressString = "${pickUpAddressObj?.name}, ${pickUpAddressObj?.street}, "
            "${pickUpAddressObj?.subLocality}, ${pickUpAddressObj?.subAdministrativeArea},"
            ", ${pickUpAddressObj?.administrativeArea}, ${pickUpAddressObj?.postalCode}";
      }else{
        dropLocation = centerMap;
        dropAddressObj = addressArr.first;
        //print(dropAddressObj.toString());

        dropAddressString = "${dropAddressObj?.name}, ${dropAddressObj?.street}, "
            "${dropAddressObj?.subLocality}, , ${dropAddressObj?.subAdministrativeArea},"
            ", ${dropAddressObj?.administrativeArea}, ${dropAddressObj?.postalCode}";
      }
      updateView();
    }

    if(isPickUp){
      selectZone = null;
      for(var zmObj in zoneListArr){
        if(PolygonUtil.containsLocation(LatLng(centerMap.latitude, centerMap.longitude), zmObj.zonePathArr!, true)){
          selectZone = zmObj;
          print(zmObj.toJson().toString());
        }

        if(selectZone==null){
          print("Not found inside zone");
        }



      }
    }

    drawRoadPickUpToDrop();

  }

  void drawRoadPickUpToDrop() async{
    if(pickupLocation != null && dropLocation != null &&
        pickupLocation?.latitude != dropLocation?.latitude &&
        pickupLocation?.longitude != dropLocation?.longitude){
      await controller.clearAllRoads();
      RoadInfo roadObject = await controller.drawRoad(
          pickupLocation!,
          dropLocation!,
          roadType: RoadType.car,
          roadOption: RoadOption(roadColor: TColor.secondary, roadWidth: 10, zoomInto: false),
      );

      double dur = roadObject.duration!;

      estTimeInMin = (dur / 60.0);
      estDistInKm = roadObject.distance ?? 0;

      if(kDebugMode){
        print("EST Duration in sec: ${roadObject.duration ?? 0.0} sec");
        print("EST Distance in sec: ${roadObject.distance ?? 0} Km");
      }

      if(selectZone != null){
        servicePriceArr = (await PriceDetailModel.getSelectZoneGetServiceAndPriceList(selectZone!.zoneId ?? "0")).map((pObj){
          var price = getEstValue(pObj);
          return {
            "est_price_min" : price,
            "est_price_max" : price * 1.3,
            DBHelper.service_name: pObj[DBHelper.service_name],
            DBHelper.icon: pObj[DBHelper.icon],
            DBHelper.service_id: pObj[DBHelper.service_id],
            DBHelper.price_id: pObj[DBHelper.price_id],
          };
        }).toList();
      }

    }
  }

  double getEstValue(dynamic pObj){

    var amount = (double.tryParse(pObj[DBHelper.base_charge]) ?? 0.0) +
        ((double.tryParse(pObj[DBHelper.per_km_charge]) ?? 0.0) * estDistInKm) +
        ((double.tryParse(pObj[DBHelper.per_min_charge]) ?? 0.0) * estTimeInMin) +
        (double.tryParse(pObj[DBHelper.booking_charge]) ?? 0.0);

    if((double.tryParse(pObj[DBHelper.mini_km]) ?? 0.0) >= estDistInKm){
      amount = (double.tryParse(pObj[DBHelper.mini_fair]) ?? 0.0);
    }

    var minPrice = amount;

    if((double.tryParse(pObj[DBHelper.mini_fair]) ?? 0.0) >= minPrice){
      minPrice = (double.tryParse(pObj[DBHelper.mini_fair]) ?? 0.0);
    }

    return minPrice;
  }

  void updateView(){
    if(mounted){
      setState(() {});
    }
  }

  void addMarkerLocation(GeoPoint point, String icon) async{
    await controller.addMarker(
        point,
        markerIcon: MarkerIcon(
          iconWidget: Image.asset(
            icon,
            width: 50,
            height: 50,
            color: isSelectPickup ? TColor.secondary : TColor.primary,
          ),
        )
    );
  }

  void removeMarkerLocation(GeoPoint point) async{
    await controller.removeMarker(point);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          OSMFlutter(
              controller:controller,
              osmOption: OSMOption(
                userTrackingOption: const UserTrackingOption(
                  enableTracking: false,
                  unFollowUser: false,
                ),
                enableRotationByGesture: false,
                zoomOption: const ZoomOption(
                  initZoom: 13,
                  minZoomLevel: 3,
                  maxZoomLevel: 19,
                  stepZoom: 1.0,
                ),
                userLocationMarker: UserLocationMaker(
                  personMarker: const MarkerIcon(
                    icon: Icon(
                      Icons.location_history_rounded,
                      color: Colors.red,
                      size: 100,
                    ),
                  ),
                  directionArrowMarker: const MarkerIcon(
                    icon: Icon(
                      Icons.double_arrow,
                      size: 48,
                    ),
                  ),
                ),
                roadConfiguration: const RoadOption(
                  roadColor: Colors.red,
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
              )
          ),
          Image.asset(isSelectPickup ? "assets/images/pickup_pin.png" : "assets/images/drop_pin.png", width: 50, height: 50),
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
                      onTap: (){
                        getCurrentPositionAddress();
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
                                  offset: Offset(0, 5)
                              )
                            ]
                        ),
                        child: Icon(Icons.my_location,size: 40),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15,),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 20),
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
                    LocationSelectButton(
                        title: "Pickup",
                        placeHolder: "Select pick up location",
                        color: TColor.secondary,
                        value: pickUpAddressString,
                        isSelect: isSelectPickup,
                        onPressed: () async{
                          setState(() {
                            isSelectPickup = true;
                          });
                          if(dropAddressString.isNotEmpty && dropLocation != null){
                            addMarkerLocation(dropLocation!,"assets/images/drop_pin.png");
                          }
                          if(pickupLocation != null){
                            isLocationChange = false;
                            controller.goToLocation(pickupLocation!);
                            await Future.delayed(const Duration(milliseconds: 500));
                            isLocationChange = true;
                            removeMarkerLocation(pickupLocation!);
                          }
                        }
                    ),
                    SizedBox(height: 8,),
                    LocationSelectButton(
                        title: "Dropoff",
                        placeHolder: "Select dropoff location",
                        color: TColor.primary,
                        value: dropAddressString,
                        isSelect: !isSelectPickup,
                        onPressed: () async{
                          setState(() {
                            isSelectPickup = false;
                          });
                          if(pickUpAddressString.isNotEmpty && pickupLocation != null){
                            addMarkerLocation(pickupLocation!,"assets/images/pickup_pin.png");
                          }
                          if(dropAddressString.isEmpty){
                            getSelectLocation(isSelectPickup);
                          }else{
                            isLocationChange = false;
                            controller.goToLocation(dropLocation!);
                            isLocationChange = true;
                            removeMarkerLocation(dropLocation!);
                          }
                        }
                    ),
                    SizedBox(height: 20,),

                    RoundButton(
                        title: "Continue",
                        buttonType: RoundButtonType.primary,
                        onPressed: (){
                          openCarService();
                        }
                    ),

                    SizedBox(height: 25,),
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
                      mainAxisAlignment: MainAxisAlignment.end,
                      children:[
                        SizedBox(
                          width: 60,
                          child: Stack(
                            alignment: Alignment.bottomLeft,
                            children: [
                              InkWell(
                                onTap:(){
                                  context.push(const MenuView());
                                },
                                child: Container(
                                  margin: EdgeInsets.only(left: 10),
                                  padding: const EdgeInsets.all(2),
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
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: Image.asset(
                                        "assets/images/u1.png",
                                        width: 40,
                                        height: 40,
                                      )
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                constraints: const BoxConstraints(minWidth: 15),
                                child: Text(
                                  "3",
                                  style: TextStyle(
                                      color: TColor.bg,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
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

  void openCarService(){

    if(pickupLocation == null){
      mdShowAlert("Select", "Please select your pickup location",(){});
      return;
    }

    if(dropLocation == null){
      mdShowAlert("Select", "Please select your drop off location",(){});
      return;
    }

    if(selectZone == null){
      mdShowAlert("...", "Not Provided any service in this area 1", () { });
      return;
    }

    if(servicePriceArr.isEmpty){
      mdShowAlert("...", "Not Provided any service in this area 2", () { });
      return;
    }


    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context){
          return CarServiceSelectView(
            serviceArr: servicePriceArr,
            didSelect: (selectObj){
              print(selectObj);

              var estMaxVal = ((selectObj["est_price_max"] as double? ?? 0.0) % 100)>0 ? ((selectObj["est_price_max"] as double? ?? 0.0) ~/ 100) * 100 + 100 : (selectObj["est_price_max"] as double? ?? 0.0);

              apiBookingRequest({
                "pickup_latitude" : "${pickupLocation?.latitude ?? 0.0}",
                "pickup_longitude" : "${pickupLocation?.longitude ?? 0.0}",
                "pickup_address" : pickUpAddressString,
                "drop_latitude" : "${dropLocation?.latitude ?? 0.0}",
                "drop_longitude" : "${dropLocation?.longitude ?? 0.0}",
                "drop_address" : dropAddressString,
                "pickup_date" : DateTime.now().stringFormat(format: "yyyy-MM-dd HH:mm:ss"),
                "payment_type" : "1",
                "card_id" : "",
                "price_id" : selectObj["price_id"].toString(),
                "est_total_distance" : estDistInKm.toStringAsFixed(2),
                "est_duration" : estTimeInMin.toString(),
                "amount" : estMaxVal.toString(),
                "service_id" : selectObj["service_id"].toString()
              });
            },
          );
        }
    );

  }

  void bookingAction(){

  }

  void apiBookingRequest(Map<String,String> parameter){
    Globs.showHUD();
    ServiceCall.post(
      parameter,
      SVKey.svBookingRequest,
      isTokenApi: true,
      withSuccess: (responseObj)async{
        Globs.hideHUD();
        if(responseObj[KKey.status]=="1"){
          var payload = responseObj[KKey.payload] as Map? ?? {};
          setState(() {

          });
          mdShowAlert(Globs.appName, responseObj[KKey.message] as String? ?? MSG.success, () {});
        }else{
          mdShowAlert("Error", responseObj[KKey.message] as String? ?? MSG.fail, () {});
        }
      },
      failure: (error)async{
        Globs.hideHUD();
        mdShowAlert("Error", error.toString() as String? ?? MSG.fail, () {});
      }
    );
  }

  void apiHome(){
    Globs.showHUD();
    ServiceCall.post(
        {},
        isTokenApi: true,
        SVKey.svHome,
        withSuccess: (responseObj)async{
          Globs.hideHUD();
          if(responseObj[KKey.status]=="1"){
            var rObj = (responseObj[KKey.payload] as Map? ?? {})["running"] as Map? ?? {};
            if(rObj.keys.isNotEmpty){
              context.push(UserRunRideView(rObj: rObj));
            }
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

}