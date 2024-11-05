import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:transport_app/common/common_extension.dart';

import '../../common/globs.dart';
import '../../common/service_call.dart';
import '../../common/socket_manager.dart';
import 'geolocation_event.dart';
import 'geolocation_state.dart';

class GeolocationBloc extends Bloc<GeolocationEvent, GeolocationState>{

  GeolocationBloc() : super(GeolocationInitial()) {
    on<StartLocationTracking>(_onStartLocationTracking);
    on<StopLocationTracking>(_onStopLocationTracking);
    on<ResumeLocationTracking>(_onResumeLocationTracking);
  }

  bool is_online = false;
  bool has_just_stopped = false;

  void _onStartLocationTracking(StartLocationTracking event, Emitter<GeolocationState> emit) async {

    is_online = true;

    emit(GeolocationLoading());
    try {
      await Geolocator.requestPermission();

      Stream<Position> positionStream = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 10,
            timeLimit: Duration(milliseconds: 60000000)
        ),
      );

      await emit.forEach<Position>(positionStream, onData: (Position position) {
        if(isSaveFileLocation && bookingId !=0) {
          try {
            File("$saveFilePath/$bookingId.txt")
                .writeAsStringSync(
                '{"latitude":${position.latitude},'
                    '"longitude":${position.longitude},'
                    '"time":"${DateTime.now().stringFormat(format: "yyyy-MM-dd HH:mm:ss")}"},', mode: FileMode.append);

            // pos2 = gmap.LatLng(position.latitude,position.longitude);
            //
            // double distanceInMeters = Geolocator.distanceBetween(
            //   pos1.latitude,
            //   pos1.longitude,
            //   pos2.latitude,
            //   pos2.longitude,
            // );
            //
            // km = km + distanceInMeters;
            //
            // pos1 = pos2;
            //
            // debugPrint('Saved location $km kms acum---');

          } catch (e) {
            debugPrint(e.toString());
          }
        }
        if(is_online){
          apiCallingLocationUpdate(position);
          return GeolocationSuccess(position);
        }else{
          Position position = Position(longitude: 0.0, latitude: 0.0, timestamp: DateTime.now(), accuracy: 0.0, altitude: 0.0, altitudeAccuracy: 0.0, heading: 0.0, headingAccuracy: 0.0, speed: 0.0, speedAccuracy: 0.0);
          if(has_just_stopped){
            has_just_stopped = false;
            apiCallingLocationUpdate(position);
          }
          return GeolocationSuccess(position);
        }

      });
    } catch (e) {
      //emit(GeolocationFailure(e.toString()));
    }
  }

  void _onStopLocationTracking(StopLocationTracking event, Emitter<GeolocationState> emit) {
    is_online = false;
    has_just_stopped = true;
    //emit(GeolocationInitial());
  }

  void _onResumeLocationTracking(ResumeLocationTracking event, Emitter<GeolocationState> emit){
    is_online = true;
  }

  void apiCallingLocationUpdate(Position pos){

    if(ServiceCall.userType != 2){
      return;
    }

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

  bool isSaveFileLocation = false;
  int bookingId = 0;
  String saveFilePath = "";

  // gmap.LatLng pos1 = gmap.LatLng(0.0, 0.0);
  // gmap.LatLng pos2 = gmap.LatLng(0.0, 0.0);
  // double km = 0;

  void startRideLocationSave(int bId, Position position) async{
    // km = 0;
    // pos1 = gmap.LatLng(position.latitude, position.longitude);
    bookingId = bId;
    try {
      saveFilePath = (await getSavedPath()).path;
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

  String getRideSaveLocationJsonString(int bookingId){
    try{
      return "[${File("$saveFilePath/$bookingId.txt").readAsStringSync()}]";
    }catch(e){
      debugPrint(e.toString());
      return "[]";
    }
  }

  Future<Directory> getSavedPath(){
    if(Platform.isAndroid){
      return getTemporaryDirectory();
    }else{
      return getApplicationCacheDirectory();
    }
  }

}