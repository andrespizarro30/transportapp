import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:transport_app/common/common_extension.dart';
import 'package:transport_app/common/globs.dart';
import 'package:transport_app/common/service_call.dart';
import 'package:transport_app/common/socket_manager.dart';

class LocationHelper {

  static final LocationHelper singleton = LocationHelper.internal();
  factory LocationHelper() => singleton;
  LocationHelper.internal();
  static LocationHelper shared() => singleton;

  final GeolocatorPlatform geolocatorPlatform = GeolocatorPlatform.instance;

  StreamSubscription<Position>? positionStreamSub;
  StreamSubscription<ServiceStatus>? serviceStatusStreamSub;
  bool positionStreamStarted = true;

  Position? lastLocation;
  bool isSaveFileLocation = false;
  int bookingId = 0;

  String saveFilePath = "";

  void startInit() async{

    var isAccess = await handlerPermissions();

    if(!isAccess){
      return;
    }

    saveFilePath = (await getSavedPath()).path;

    locationChangelistening();

    if(serviceStatusStreamSub == null){
      final serviceStatusStream = geolocatorPlatform.getServiceStatusStream();
      serviceStatusStreamSub = serviceStatusStream.handleError((onError){
        serviceStatusStreamSub?.cancel();
        serviceStatusStreamSub = null;
      }).listen((serviceStatus) {
        String serviceStatusValue;
        if(serviceStatus == ServiceStatus.enabled){
          if(positionStreamStarted){
            locationChangelistening();
          }
          serviceStatusValue = "enabled";
        }else{
          if(positionStreamSub != null){
            positionStreamSub?.cancel();
            positionStreamSub = null;
            print("Position Stream has been cancelled");
          }
          serviceStatusValue = "disabled";
        }
        print("Location service has been $serviceStatusValue");
      });
    }

  }

  void locationSendPause(){
    if(positionStreamSub!=null){
      positionStreamSub?.cancel();
      positionStreamSub = null;
      positionStreamStarted = false;
    }
  }

  void locationSendStart(){
    if(positionStreamSub!=null){
      return;
    }
    locationChangelistening();
  }

  Future<bool> handlerPermissions() async{

    bool serviceEnable;

    LocationPermission permission;

    serviceEnable = await geolocatorPlatform.isLocationServiceEnabled();

    if(!serviceEnable){
      return false;
    }

    permission = await geolocatorPlatform.checkPermission();

    if(permission == LocationPermission.denied){
      permission = await geolocatorPlatform.requestPermission();
      if(permission==LocationPermission.denied){
        return false;
      }
    }

    if(permission == LocationPermission.deniedForever){
      return false;
    }

    return true;
  }

  void locationChangelistening(){
    if(positionStreamSub == null){
      final positionStream = geolocatorPlatform.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 15
        )
      );
      positionStreamSub = positionStream.handleError((onError){
        positionStreamSub?.cancel();
        positionStreamSub = null;
      }).listen((position){

        lastLocation = position;

        if(isSaveFileLocation && bookingId !=0) {
          try {
            File("$saveFilePath/$bookingId.txt")
                .writeAsStringSync(
                '{"latitude":${position.latitude},'
                    '"longitude":${position.longitude},'
                    '"time":"${DateTime.now().stringFormat(format: "yyyy-MM-dd HH:mm:ss")}"},', mode: FileMode.append);

            debugPrint('Saved location ---');

          } catch (e) {
            debugPrint(e.toString());
          }
        }
        apiCallingLocationUpdate(position);
      });
    }
  }

  void apiCallingLocationUpdate(Position pos){

    if(ServiceCall.userType != 2){
      return;
    }

    debugPrint("Driver Location sending api calling");

    ServiceCall.post(
        {
          "latitude" : pos.latitude.toString(),
          "longitude" : pos.longitude.toString(),
          "socket_id" : SocketManager.shared.socket?.id ?? ""
        },
        isTokenApi: true,
        SVKey.svUpdateLocationDriver,
        withSuccess: (responseObj)async{
          if(responseObj[KKey.status]=="1"){
            debugPrint("Location send success");
          }else{
            debugPrint("Location send fill: ${responseObj[KKey.message].toString()}");
          }
        },
        failure: (error)async{
          debugPrint("Location send fill: $error");
        }
    );
  }

  void startRideLocationSave(int bId, Position position) async{
    bookingId = bId;
    try {
      final file = File('$saveFilePath/$bookingId.txt');
      if (await file.exists()) {
        await file.delete(); // Deletes the file
      }
      File("$saveFilePath/$bookingId.txt")
          .writeAsStringSync(
          '{"latitude":${position.latitude},'
              '"longitude":${position.longitude},'
              '"time":"${DateTime.now().stringFormat(format: "yyyy-MM-dd HH:mm:ss")}"},', mode: FileMode.append);

      debugPrint('Saved location ---');

      isSaveFileLocation = true;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void stopRideLocationSave(){
    isSaveFileLocation = false;
    bookingId = 0;
  }

  Future<Directory> getSavedPath(){
    if(Platform.isAndroid){
      return getTemporaryDirectory();
    }else{
      return getApplicationCacheDirectory();
    }
  }

  String getRideSaveLocationJsonString(int bookingId){
    try{
      return "[${File("$saveFilePath/$bookingId.txt").readAsStringSync()}]";
    }catch(e){
      debugPrint(e.toString());
      return "[]";
    }
  }

}