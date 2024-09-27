import '../common/dbhelpers.dart';

class ServiceDetailModel {
  String? serviceId;
  String? serviceName;
  String? seat;
  String? color;
  String? icon;
  String? topIcon;
  String? gender;
  String? status;
  String? createdDate;
  String? modifyDate;
  String? description;

  ServiceDetailModel(
      {this.serviceId,
        this.serviceName,
        this.seat,
        this.color,
        this.icon,
        this.topIcon,
        this.gender,
        this.status,
        this.createdDate,
        this.modifyDate,
        this.description});

  ServiceDetailModel.fromJson(Map<String, dynamic> json) {
    serviceId = json['service_id'].toString();
    serviceName = json['service_name'].toString();
    seat = json['seat'].toString();
    color = json['color'].toString();
    icon = json['icon'].toString();
    topIcon = json['top_icon'].toString();
    gender = json['gender'].toString();
    status = json['status'].toString();
    createdDate = json['created_date'].toString();
    modifyDate = json['modify_date'].toString();
    description = json['description'].toString();
  }

  Map<String, String> toJson() {
    final Map<String, String> data = new Map<String, String>();
    data['service_id'] = this.serviceId.toString();
    data['service_name'] = this.serviceName.toString();
    data['seat'] = this.seat.toString();
    data['color'] = this.color.toString();
    data['icon'] = this.icon.toString();
    data['top_icon'] = this.topIcon.toString();
    data['gender'] = this.gender.toString();
    data['status'] = this.status.toString();
    data['created_date'] = this.createdDate.toString();
    data['modify_date'] = this.modifyDate.toString();
    data['description'] = this.description.toString();
    return data;
  }

  static Future<List> getList() async{
    var db = await DBHelper.shared().db;
    if(db != null){
      List<Map> list = await db.rawQuery('SELECT * FROM ${DBHelper.tbServiceDetail} WHERE ${DBHelper.status} = 1');
      return list;
    }else{
      return [];
    }
  }
}