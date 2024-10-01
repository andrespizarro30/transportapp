import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
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
  }

  void _onStartLocationTracking(StartLocationTracking event, Emitter<GeolocationState> emit) async {
    emit(GeolocationLoading());
    try {
      await Geolocator.requestPermission();
      Stream<Position> positionStream = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 10,
            timeLimit: Duration(milliseconds: 60000000)
        ),
      );

      await emit.forEach(positionStream, onData: (Position position) {
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
        return GeolocationSuccess(position);
      });
    } catch (e) {
      //emit(GeolocationFailure(e.toString()));
    }
  }

  void _onStopLocationTracking(StopLocationTracking event, Emitter<GeolocationState> emit) {
    emit(GeolocationInitial());
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

  String getRideSaveLocationJsonString(int bookingId){
    try{
      return "[${File("$saveFilePath/$bookingId.txt").readAsStringSync()}]";
    }catch(e){
      debugPrint(e.toString());
      return "[]";
    }
  }

}