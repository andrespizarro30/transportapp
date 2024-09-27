
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:transport_app/common/color_extension.dart';
import 'package:transport_app/common/common_extension.dart';
import 'package:transport_app/common/location_helper.dart';
import 'package:transport_app/common/service_call.dart';
import 'package:transport_app/common_widget/icon_title_subtitle.dart';
import 'package:transport_app/view/home/run_ride_view.dart';
import 'package:transport_app/view/home/tip_request_view.dart';
import 'package:transport_app/view/menu/menu_view.dart';

import '../../common/globs.dart';
import '../../common/socket_manager.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  bool isOpen = true;

  bool isDriverOnLine = false;

  MapController controller = MapController(
      initPosition: GeoPoint(latitude: 47.4358055, longitude: 8.4737324),
  );

  @override
  void initState() {
    super.initState();

    apiHome();
    isDriverOnLine = Globs.udValueBool("is_online");

    if(ServiceCall.userType==2){
      LocationHelper.shared().startInit();

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
                  userTrackingOption: const UserTrackingOption(
                  enableTracking: false,
                  unFollowUser: false,
                ),
                zoomOption: const ZoomOption(
                      initZoom: 8,
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
                              color: !isDriverOnLine ? Colors.red : TColor.primary,
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
                              !isDriverOnLine ? "OFF" : "GO",
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
                          !isDriverOnLine ? "You are offline" : "You are online",
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
                              title: "95.0",
                              subTitle: "Aceptacion",
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
                              title: "4.75",
                              subTitle: "Califcacion",
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
                              title: "2.0%",
                              subTitle: "Cancelacion",
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
                              "155.000",
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
          }else{
            isDriverOnLine = !isDriverOnLine;
            mdShowAlert("Error", responseObj[KKey.message] as String? ?? MSG.fail, () { });
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