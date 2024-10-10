import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transport_app/common_widget/user_foreground_notification.dart';

import 'local_notification_service.dart';

class PushNotificationSystem {

  BuildContext context;

  PushNotificationSystem({required this.context});

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future initializeCloudMessaging() async{

    //1.Terminated
    //cuando la app esta completamente cerrada y abre directamente desde la notificación
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMessage)
    {
      if(remoteMessage != null){

      }
    });

    //2.Foreground
    //cuando la app esta abierta y recive una notificación
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      if(remoteMessage != null){
        userForeGroundNotification(remoteMessage.notification!.body!, context);
        //LocalNotificationService.showNotification(remoteMessage);
      }
    });

    //3.Background
    //cuando la app esta en segundo plano y abre directamente desde la notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      if(remoteMessage != null){
        if(Platform.isAndroid){
          LocalNotificationService.showNotification(remoteMessage);
        }else
        if(Platform.isIOS){

        }
      }
    });

  }

  Future<String> generateMessagingToken() async{

    if(Platform.isAndroid){
      await messaging.requestPermission();
    }else
    if(Platform.isIOS){
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    String? registrationToken = await messaging.getToken();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("FIRESTORE_TOKEN", registrationToken!);

    return registrationToken;

  }

}