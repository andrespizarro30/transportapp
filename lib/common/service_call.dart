
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:transport_app/common/dbhelpers.dart';
import 'package:transport_app/model/document_model.dart';
import 'package:transport_app/model/price_detail_model.dart';
import 'package:transport_app/model/service_detail_model.dart';
import 'package:transport_app/model/zone_document_model.dart';
import 'package:transport_app/model/zone_list_model.dart';
import 'globs.dart';
import 'package:http/http.dart' as http;

import 'package:path/path.dart' as pth;


typedef ResSuccess = Future<void> Function(Map<String,dynamic>);
typedef ResFailure = Future<void> Function(dynamic);

class ServiceCall{

  static Map userObj = {};
  static int userType = 1;

  static Future<dynamic> getRequest(Uri url) async{

    http.Response response = await http.get(url);

    try{
      if(response.statusCode == 200){
        String jsonData = response.body;
        var decodeData = jsonDecode(jsonData);
        return decodeData;
      }
      else{
        return "failed";
      }
    }catch(exp){
      return "failed";
    }


  }

  static void post(Map<String, dynamic> parameter, String path, {
    bool isTokenApi = false,
    ResSuccess? withSuccess,
    ResFailure? failure
  }){
    Future((){
      try{

        var headers = {
          "Content_Type":'application/x-www-urlencoded'
        };

        if(isTokenApi){
          headers["access_token"] = userObj["auth_token"] as String? ?? "";
        }

        http.post(Uri.parse(path), body: parameter, headers: headers)
        .then((value){

          if(kDebugMode){
            print(value.body);
          }

          try{
            var jsonObj = json.decode(value.body) as Map<String,dynamic>? ?? {};
            if(withSuccess!=null) withSuccess(jsonObj);
          }catch(e){
            if(failure!=null) failure(e.toString());
          }

        }).catchError((e){
          if(failure!=null) failure(e.toString());
        });

      }catch(e){
        if(failure!=null) failure(e.toString());
      }
    });
  }

  static void multiPart(Map<String, String> parameter, String path,{
    bool isTokenApi = false,
    Map<String, File>? imgObj,
    ResSuccess? withSuccess,
    ResFailure? failure
  }){
    Future((){
      try{
        var uri = Uri.parse(path);
        var request = http.MultipartRequest('POST',uri);
        request.fields.addAll(parameter);

        if(isTokenApi){
          request.headers.addAll({"access_token" : userObj["auth_token"] as String? ?? ""});
        }

        if(kDebugMode){
          print('Service Call: $path');
          print('Service para: ${parameter.toString()}');
          print('Service header: ${request.headers.toString()}');
        }

        if(imgObj != null){
          imgObj.forEach((key, value) {
            var multipartFile = http.MultipartFile(
                key,
                value.readAsBytes().asStream(),
                value.lengthSync(),
                filename: pth.basename(value.path)
            );
            request.files.add(multipartFile);
          });
        }

        request.send().then((response) async{
          var value = await response.stream.transform(utf8.decoder).join();
          try{
            if(kDebugMode){
              print(value);
            }
            var jsonObj = json.decode(value) as Map<String,dynamic>? ?? {};
            if(withSuccess!=null){
              withSuccess(jsonObj);
            }
          }catch(err){
            if(failure != null) failure(err.toString());
          }
        }).catchError((err){
          if(failure != null) failure(err.toString());
        });
      }
      on SocketException catch (err){
        if(failure != null) failure(err.toString());
      }
      catch(err){
          if(failure != null) failure(err.toString());
      }
    });
  }

  static getStaticDateApi(){

    post(
        {
          "last_call_time":"2023-08-01 00:00:00"
        },
        SVKey.svStaticData,
        isTokenApi: true,
        withSuccess: (responseObj)async{
          try{
           if(responseObj[KKey.status]=="1"){

             var payload = responseObj[KKey.payload] as Map? ?? {};

             var db = await DBHelper.shared().db;

             var batch = db?.batch();

             for(var zObj in (payload[DBHelper.tbZoneList] as List? ?? [])){
               var data = zObj;
               db?.insert(
                   DBHelper.tbZoneList,
                   ZoneListModel.fromJson(zObj).toJson(),
                   conflictAlgorithm: ConflictAlgorithm.replace
               );
             }

             for(var zObj in (payload[DBHelper.tbServiceDetail] as List? ?? [])){
               batch?.insert(
                   DBHelper.tbServiceDetail,
                   ServiceDetailModel.fromJson(zObj).toJson(),
                   conflictAlgorithm: ConflictAlgorithm.replace
               );
             }

             for(var zObj in (payload[DBHelper.tbPriceDetail] as List? ?? [])){
               batch?.insert(
                   DBHelper.tbPriceDetail,
                   PriceDetailModel.fromJson(zObj).toJson(),
                   conflictAlgorithm: ConflictAlgorithm.replace
               );
             }

             for(var zObj in (payload[DBHelper.tbDocument] as List? ?? [])){
               batch?.insert(
                   DBHelper.tbDocument,
                   DocumentModel.fromJson(zObj).toJson(),
                   conflictAlgorithm: ConflictAlgorithm.replace
               );
             }

             for(var zObj in (payload[DBHelper.tbZoneDocument] as List? ?? [])){
               batch?.insert(
                   DBHelper.tbZoneDocument,
                   ZoneDocumentModel.fromJson(zObj).toJson(),
                   conflictAlgorithm: ConflictAlgorithm.replace
               );
             }

             var bResult = await batch?.commit();

             debugPrint(bResult.toString());

             debugPrint("Static data saved successfully");

           }else{
             debugPrint(responseObj.toString());
           }
          }catch(e){
            debugPrint(e.toString());
          }
        },
        failure: (e)async{
          debugPrint(e.toString());
        }
    );

  }

}