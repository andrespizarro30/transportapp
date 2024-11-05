
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport_app/common/color_extension.dart';
import 'package:transport_app/common/common_extension.dart';
import 'package:transport_app/common/service_call.dart';
import 'package:transport_app/common_widget/icon_title_subtitle.dart';
import 'package:transport_app/view/home/run_ride_view.dart';
import 'package:transport_app/view/home/service_value_add.dart';
import 'package:transport_app/view/home/tip_request_view.dart';
import 'package:transport_app/view/menu/menu_view.dart';

import '../../common/appLocalizations .dart';
import '../../common/globs.dart';
import '../../common/socket_manager.dart';
import '../../cubit/change_language/language_cubit.dart';
import '../../cubit/geolocation/geolocation_bloc.dart';
import '../../cubit/geolocation/geolocation_event.dart';
import '../../cubit/geolocation/geolocation_state.dart';
import '../../firebase/push_notification.dart';
import '../../main.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with RouteAware, SingleTickerProviderStateMixin{

  Position? position = null;
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;
  final initialCameraPosition = const CameraPosition(target: LatLng(4.8,-75.7),zoom: 15.0);
  double bottomPaddingOfMap = 0;
  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};
  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  Map driverRating = {
    "driver_rating": 5,
    "acceptante_rating": 100,
    "cancel_rating": 0
  };

  bool isOpen = true;

  bool isDriverOnLine = false;

  int totalDaily = 0;

  late Timer timer;

  late AnimationController lineAnimationController;
  late Animation<double> lineAnimation;

  // late AnimationController textAnimationController;
  // late Animation<double> textAnimation;

  void setCurrentLocationInCamera(){
    LatLng latLng = LatLng(position!.latitude, position!.longitude);
    CameraPosition cameraPosition = new CameraPosition(target: latLng, zoom: 16);
    if (newGoogleMapController != null) {
      newGoogleMapController?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    }
  }

  Map user_data = {};

  @override
  void initState() {
    super.initState();

    initNotificationService();

    lineAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    lineAnimation = Tween<double>(begin: 0, end: 1).animate(lineAnimationController);

    // textAnimationController = AnimationController(
    //   duration: const Duration(seconds: 2),
    //   vsync: this,
    // )..addStatusListener((status) {
    //   if (status == AnimationStatus.completed) {
    //     textAnimationController.reverse();
    //   } else if (status == AnimationStatus.dismissed) {
    //     Future.delayed(Duration(seconds: 2), () {
    //       textAnimationController.forward();
    //     });
    //   }
    // });
    // textAnimation = Tween<double>(begin: 0, end: 1).animate(textAnimationController);
    // textAnimationController.forward();

    apiHome();
    apiSummaryDaily();
    apiDriverRatings();

    getUserData();

    isDriverOnLine = Globs.udValueBool("is_online");

    if(ServiceCall.userType==2){
      //LocationHelper.shared().startInit();
      SocketManager.shared.socket?.on("new_ride_request",(data) async{
        print("New ride request socket :${data.toString()}");
        if(data[KKey.status] == "1"){
          var bArr = data[KKey.payload] as List? ?? [];
          if(mounted && bArr.isNotEmpty){
            await context.push(TipRequestView(bObj: bArr[0]));
            apiHome();
          }
        }
      });

    }

  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    newGoogleMapController?.dispose();
    timer.cancel();
    lineAnimationController.dispose();
    //textAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute? modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void didPopNext() {
    onResume();
  }

  void onResume() {
    apiSummaryDaily();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: BlocBuilder<GeolocationBloc, GeolocationState>(
        builder: (context, state) {
          if (state is GeolocationLoading) {
            return Center(child: CircularProgressIndicator());
          }else
          if (state is GeolocationSuccess){
            position = state.position;
            LatLng latLng = LatLng(position!.latitude, position!.longitude);
            CameraPosition cameraPosition = new CameraPosition(target: latLng,zoom: 16);
            if(newGoogleMapController != null){
              newGoogleMapController?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
            }
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
                  onMapCreated: (GoogleMapController controller){
                    _controllerGoogleMap.complete(controller);
                    newGoogleMapController = controller;

                    setState(() {
                      bottomPaddingOfMap=265.0;
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
                          const SizedBox(width: 50,height: 50,),
                          InkWell(
                            borderRadius: BorderRadius.circular(35),
                            onTap: (){
                              isDriverOnLine = !isDriverOnLine;
                              apiGoOnLine();
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                      color: isDriverOnLine ? Colors.red : TColor.primary,
                                      borderRadius: BorderRadius.circular(35),
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 10,
                                            offset: Offset(0, 5)
                                        )
                                      ]
                                  ),
                                ),

                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white, width: 1.5),
                                    borderRadius: BorderRadius.circular(35),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    isDriverOnLine ? "OFF" : "GO",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(35),
                            onTap: (){
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
                          Row(
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
                                !isDriverOnLine ?
                                AppLocalizations.of(context).translate('you_are_offline') :
                                AppLocalizations.of(context).translate('you_are_online'),
                                style: TextStyle(
                                    color: TColor.primaryText,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800
                                ),
                              ),
                              const SizedBox(
                                width:50,
                                height: 50,
                              )
                            ],
                          ),
                          if(isDriverOnLine)
                            AnimatedBuilder(
                              animation: lineAnimation,
                              builder: (context, child) {
                                return Container(
                                  width: MediaQuery.of(context).size.width * lineAnimation.value,
                                  height: 5,
                                  color: Colors.blue,
                                );
                              },
                            ),
                          // if(isDriverOnLine)
                          //   FadeTransition(
                          //     opacity: textAnimation, // Use the animation for opacity
                          //     child: Text(
                          //       "Looking for service",
                          //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          //     ),
                          //   ),
                          if(isOpen)
                            Container(
                              width: context.width,
                              height: 0.5,
                              decoration: BoxDecoration(
                                  color: TColor.placeholder.withOpacity(0.5)
                              ),
                            ),
                          if(isOpen)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                IconTitleSubtitleButton(
                                    title: "${(double.tryParse(driverRating["acceptante_rating"].toString()) ?? 0.0).toStringAsFixed(0)}%",
                                    subTitle: AppLocalizations.of(context).translate('acceptance'),
                                    icon: Icon(Icons.check_circle,size: 30,color: TColor.primary,),
                                    onPress: (){

                                    }
                                ),
                                Container(
                                  width: 0.5,
                                  height: 100,
                                  decoration: BoxDecoration(
                                      color: TColor.placeholder.withOpacity(0.5)
                                  ),
                                ),
                                IconTitleSubtitleButton(
                                    title: (double.tryParse(driverRating["driver_rating"].toString()) ?? 0.0).toStringAsFixed(2),
                                    subTitle: AppLocalizations.of(context).translate('rating'),
                                    icon: Icon(Icons.star_rate,size: 30,color: TColor.primary,),
                                    onPress: (){

                                    }
                                ),
                                Container(
                                  width: 0.5,
                                  height: 100,
                                  decoration: BoxDecoration(
                                      color: TColor.placeholder.withOpacity(0.5)
                                  ),
                                ),
                                IconTitleSubtitleButton(
                                    title: "${(double.tryParse(driverRating["cancel_rating"].toString()) ?? 0.0).toStringAsFixed(0)}%",
                                    subTitle: AppLocalizations.of(context).translate('cancellation'),
                                    icon: Icon(Icons.cancel_presentation_outlined,size: 30,color: TColor.primary,),
                                    onPress: (){

                                    }
                                )
                              ],
                            )
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children:[

                              SizedBox(width: 60),

                              Container(
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "\$",
                                        style: TextStyle(
                                            color: TColor.secondary,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800
                                        ),
                                      ),

                                      SizedBox(width: 8),

                                      Text(
                                        totalDaily.toString(),
                                        style: TextStyle(
                                            color: TColor.primaryText,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800
                                        ),
                                      ),
                                    ],
                                  )
                              ),
                              SizedBox(
                                width: 60,
                                child: Stack(
                                  alignment: Alignment.bottomLeft,
                                  children: [
                                    InkWell(
                                      onTap:(){
                                        context.push(MenuView(user_data: user_data,));
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
                                    //   padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 1),
                                    //   decoration: BoxDecoration(
                                    //     color: Colors.red,
                                    //     borderRadius: BorderRadius.circular(30),
                                    //   ),
                                    //   constraints: const BoxConstraints(minWidth: 15),
                                    //   child: Text(
                                    //     "3",
                                    //     style: TextStyle(
                                    //         color: TColor.bg,
                                    //         fontSize: 10,
                                    //         fontWeight: FontWeight.w800
                                    //     ),
                                    //   ),
                                    // )
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
            );

          }else
          if (state is GeolocationFailure) {
            return Center(child: Text(AppLocalizations.of(context).translate('error') + ': ${state.error}'));
          }else{
            getPosition();
            if(!isDriverOnLine){
              stopGetPosition();
            }
            return Center(child: Text(AppLocalizations.of(context).translate('awaiting_location') + '...'));
          }
        }
      ),
    );
  }

  void apiGoOnLine(){
    Globs.showHUD();
    ServiceCall.post(
        {
          "is_online": isDriverOnLine ? "1" : "0"
        },
        isTokenApi: true,
        SVKey.svDriverGoOnline,
        withSuccess: (responseObj)async{
          Globs.hideHUD();
          if(responseObj[KKey.status]=="1"){
            Globs.udBoolSet(isDriverOnLine, "is_online");
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(responseObj[KKey.message] as String? ?? MSG.success))
            );
            if(mounted){
              setState(() {});
            }

            if(isDriverOnLine){
              resumeGetPosition();
            }else
            if(!isDriverOnLine){
              stopGetPosition();
            }
          }else{
            isDriverOnLine = !isDriverOnLine;
            mdShowAlert(AppLocalizations.of(context).translate('error'), responseObj[KKey.message] as String? ?? MSG.fail, () { });
          }
        },
        failure: (error)async{
          Globs.hideHUD();
          mdShowAlert(Globs.appName, error.toString(),(){});
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
              context.push(RunRideView(rObj: rObj));
            }
          }else{
            mdShowAlert(AppLocalizations.of(context).translate('error'), responseObj[KKey.message] as String? ?? MSG.fail, () { });
          }
        },
        failure: (error)async{
          Globs.hideHUD();
          mdShowAlert(Globs.appName, error.toString(),(){});
        }
    );
  }

  void apiSummaryDaily() {
    Globs.showHUD();
    ServiceCall.post(
        {},
        isTokenApi: true,
        SVKey.svDriverSummaryDaily,
        withSuccess: (responseObj)async{
          Globs.hideHUD();
          if(responseObj[KKey.status]=="1"){
            var rObj = (responseObj[KKey.payload] as List? ?? [])[0] as Map;
            if(rObj.isNotEmpty){

              int targetValue = rObj["total_amt"];

              int difIncrement = targetValue - totalDaily;

              if(difIncrement>0){
                showValueAdded(targetValue,difIncrement);
              }

            }
          }else{
            //mdShowAlert("Error", responseObj[KKey.message] as String? ?? MSG.fail, () { });
          }
        },
        failure: (error)async{
          Globs.hideHUD();
          //mdShowAlert(Globs.appName, error.toString(),(){});
        }
    );
  }

  void apiDriverRatings() {
    Globs.showHUD();
    ServiceCall.post(
        {},
        isTokenApi: true,
        SVKey.svDriverRatings,
        withSuccess: (responseObj)async{
          Globs.hideHUD();
          if(responseObj[KKey.status]=="1"){
            var rObj = responseObj[KKey.payload] as Map? ?? {};
            if(rObj.isNotEmpty){
              driverRating = rObj;
              if(mounted){
                setState(() {});
              }
            }
          }else{
            //mdShowAlert("Error", responseObj[KKey.message] as String? ?? MSG.fail, () { });
          }
        },
        failure: (error)async{
          Globs.hideHUD();
          //mdShowAlert(Globs.appName, error.toString(),(){});
        }
    );
  }

  void getPosition() async{
    BlocProvider.of<GeolocationBloc>(context).add(StartLocationTracking());
  }

  void stopGetPosition() async{
    BlocProvider.of<GeolocationBloc>(context).add(StopLocationTracking());
  }

  void resumeGetPosition() async{
    BlocProvider.of<GeolocationBloc>(context).add(ResumeLocationTracking());
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
          }else{
            mdShowAlert(AppLocalizations.of(context).translate('error'), responseObj[KKey.message] as String? ?? MSG.fail, () { });
          }
        },
        failure: (error)async{
          Globs.hideHUD();
          mdShowAlert(Globs.appName, error.toString(),(){});
        }
    );
  }

  void showValueAdded(int targetValue,int difIncrement) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: (MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width / 3)) / 2,
        child: ServiceValueAdded(value: difIncrement.toString()),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
      int increment = (difIncrement / 15).round();

      const Duration interval = Duration(milliseconds: 200);

      timer = Timer.periodic(interval, (Timer timer) {
        setState(() {
          if (totalDaily < targetValue) {
            totalDaily = (totalDaily + increment > targetValue)
                ? targetValue
                : totalDaily + increment;
          } else {
            timer.cancel();
          }
        });
      });

    });

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