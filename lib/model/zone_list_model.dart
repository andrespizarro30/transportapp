import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:transport_app/common/dbhelpers.dart';

class ZoneListModel {
  String? zoneId;
  String? zoneName;
  String? zoneJson;
  String? city;
  String? tax;
  String? status;
  String? createdDate;
  String? modifyDate;
  List<LatLng>? zonePathArr = [];

  ZoneListModel(
      {this.zoneId,
        this.zoneName,
        this.zoneJson,
        this.city,
        this.tax,
        this.status,
        this.createdDate,
        this.modifyDate});

  ZoneListModel.fromJson(Map<dynamic, dynamic> json) {
    zoneId = json['zone_id'].toString();
    zoneName = json['zone_name'].toString();
    zoneJson = json['zone_json'].toString();
    city = json['city'].toString();
    tax = json['tax'].toString();
    status = json['status'].toString();
    createdDate = json['created_date'].toString();
    modifyDate = json['modify_date'].toString();

    try{
      zonePathArr = (jsonDecode(zoneJson!) as List? ?? []).map((pObj) => LatLng(pObj["lat"] as double? ?? 0.0,pObj["lng"] as double? ?? 0.0)).toList();
    }catch(e){
      if(kDebugMode){
        print(e.toString());
      }
    }

  }

  Map<String, String> toJson() {
    final Map<String, String> data = new Map<String, String>();
    data['zone_id'] = this.zoneId.toString();
    data['zone_name'] = this.zoneName.toString();
    data['zone_json'] = this.zoneJson.toString();
    data['city'] = this.city.toString();
    data['tax'] = this.tax.toString();
    data['status'] = this.status.toString();
    data['created_date'] = this.createdDate.toString();
    data['modify_date'] = this.modifyDate.toString();
    return data;
  }

  static Future<List> getList() async{
    var db = await DBHelper.shared().db;
    if(db != null){
      List<Map> list = await db.rawQuery('SELECT * FROM ${DBHelper.tbZoneList} WHERE ${DBHelper.status} = 1');
      return list;
    }else{
      return [];
    }
  }

  static Future<List<ZoneListModel>> getActiveList() async{
    var db = await DBHelper.shared().db;
    if(db != null){

      String sqlQry = "SELECT zl.* FROM ${DBHelper.tbZoneList} AS zl "
          "INNER JOIN ${DBHelper.tbPriceDetail} AS pd ON pd.${DBHelper.zone_id} = zl.${DBHelper.zone_id} AND pd.${DBHelper.status}='1' "
          "WHERE zl.${DBHelper.status}='1' GROUP BY zl.${DBHelper.zone_id}";

      List<Map> list = await db.rawQuery(sqlQry);
      return list.map((zObj) => ZoneListModel.fromJson(zObj)).toList();
    }else{
      return [];
    }
  }

}