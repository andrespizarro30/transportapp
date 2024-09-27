import '../common/dbhelpers.dart';

class ZoneDocumentModel {
  String? zoneDocId;
  String? zoneId;
  String? serviceId;
  String? personalDoc;
  String? carDoc;
  String? requiredPersonalDoc;
  String? requiredCarDoc;
  String? status;
  String? createdDate;
  String? modifyDate;

  ZoneDocumentModel(
      {this.zoneDocId,
        this.zoneId,
        this.serviceId,
        this.personalDoc,
        this.carDoc,
        this.requiredPersonalDoc,
        this.requiredCarDoc,
        this.status,
        this.createdDate,
        this.modifyDate});

  ZoneDocumentModel.fromJson(Map<String, dynamic> json) {
    zoneDocId = json['zone_doc_id'].toString();
    zoneId = json['zone_id'].toString();
    serviceId = json['service_id'].toString();
    personalDoc = json['personal_doc'].toString();
    carDoc = json['car_doc'].toString();
    requiredPersonalDoc = json['required_personal_doc'].toString();
    requiredCarDoc = json['required_car_doc'].toString();
    status = json['status'].toString();
    createdDate = json['created_date'].toString();
    modifyDate = json['modify_date'].toString();
  }

  Map<String, String> toJson() {
    final Map<String, String> data = new Map<String, String>();
    data['zone_doc_id'] = this.zoneDocId.toString();
    data['zone_id'] = this.zoneId.toString();
    data['service_id'] = this.serviceId.toString();
    data['personal_doc'] = this.personalDoc.toString();
    data['car_doc'] = this.carDoc.toString();
    data['required_personal_doc'] = this.requiredPersonalDoc.toString();
    data['required_car_doc'] = this.requiredCarDoc.toString();
    data['status'] = this.status.toString();
    data['created_date'] = this.createdDate.toString();
    data['modify_date'] = this.modifyDate.toString();
    return data;
  }

  static Future<List> getList() async{
    var db = await DBHelper.shared().db;
    if(db != null){
      List<Map> list = await db.rawQuery('SELECT * FROM ${DBHelper.tbZoneDocument} WHERE ${DBHelper.status} = 1');
      return list;
    }else{
      return [];
    }
  }

}