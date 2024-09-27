import 'package:transport_app/common/service_call.dart';

import '../common/dbhelpers.dart';

class PriceDetailModel {
  String? priceId;
  String? zoneId;
  String? serviceId;
  String? baseCharge;
  String? perKmCharge;
  String? perMinCharge;
  String? bookingCharge;
  String? miniFair;
  String? miniKm;
  String? cancelCharge;
  String? tax;
  String? status;
  String? createdDate;
  String? modifyDate;

  PriceDetailModel(
      {this.priceId,
        this.zoneId,
        this.serviceId,
        this.baseCharge,
        this.perKmCharge,
        this.perMinCharge,
        this.bookingCharge,
        this.miniFair,
        this.miniKm,
        this.cancelCharge,
        this.tax,
        this.status,
        this.createdDate,
        this.modifyDate});

  PriceDetailModel.fromJson(Map<String, dynamic> json) {
    priceId = json['price_id'].toString();
    zoneId = json['zone_id'].toString();
    serviceId = json['service_id'].toString();
    baseCharge = json['base_charge'].toString();
    perKmCharge = json['per_km_charge'].toString();
    perMinCharge = json['per_min_charge'].toString();
    bookingCharge = json['booking_charge'].toString();
    miniFair = json['mini_fair'].toString();
    miniKm = json['mini_km'].toString();
    cancelCharge = json['cancel_charge'].toString();
    tax = json['tax'].toString();
    status = json['status'].toString();
    createdDate = json['created_date'].toString();
    modifyDate = json['modify_date'].toString();
  }

  Map<String, String> toJson() {
    final Map<String, String> data = new Map<String, String>();
    data['price_id'] = this.priceId.toString();
    data['zone_id'] = this.zoneId.toString();
    data['service_id'] = this.serviceId.toString();
    data['base_charge'] = this.baseCharge.toString();
    data['per_km_charge'] = this.perKmCharge.toString();
    data['per_min_charge'] = this.perMinCharge.toString();
    data['booking_charge'] = this.bookingCharge.toString();
    data['mini_fair'] = this.miniFair.toString();
    data['mini_km'] = this.miniKm.toString();
    data['cancel_charge'] = this.cancelCharge.toString();
    data['tax'] = this.tax.toString();
    data['status'] = this.status.toString();
    data['created_date'] = this.createdDate.toString();
    data['modify_date'] = this.modifyDate.toString();
    return data;
  }

  static Future<List> getList() async{
    var db = await DBHelper.shared().db;
    if(db != null){
      List<Map> list = await db.rawQuery('SELECT * FROM ${DBHelper.tbPriceDetail} WHERE ${DBHelper.status} = 1');
      return list;
    }else{
      return [];
    }
  }

  static Future<List> getSelectZoneGetServiceAndPriceList(String zoneId) async{
    var db = await DBHelper.shared().db;
    if(db != null){
      String sqlQuery = "SELECT sd.${DBHelper.service_id},pd.${DBHelper.price_id},"
          "pd.${DBHelper.base_charge},pd.${DBHelper.per_km_charge},pd.${DBHelper.per_min_charge},pd.${DBHelper.booking_charge},"
          "pd.${DBHelper.mini_fair},pd.${DBHelper.mini_km},sd.${DBHelper.service_name},sd.${DBHelper.color},sd.${DBHelper.icon} "
          "FROM ${DBHelper.tbServiceDetail} AS sd INNER JOIN ${DBHelper.tbPriceDetail} AS pd "
          "ON pd.${DBHelper.service_id} = sd.${DBHelper.service_id} AND "
          "sd.${DBHelper.status} = 1 AND pd.${DBHelper.status} = 1 AND "
          "(sd.${DBHelper.gender} LIKE '%${ServiceCall.userObj[DBHelper.gender]}%' ) WHERE pd.${DBHelper.zone_id} = ?";
      List<Map> list = await db.rawQuery(sqlQuery,[zoneId]);
      return list;
    }else{
      return [];
    }
  }

}