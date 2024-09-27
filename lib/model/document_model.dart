import '../common/dbhelpers.dart';

class DocumentModel {
  String? docId;
  String? name;
  String? type;
  String? status;
  String? createdDate;
  String? modifyDate;

  DocumentModel(
      {this.docId,
        this.name,
        this.type,
        this.status,
        this.createdDate,
        this.modifyDate});

  DocumentModel.fromJson(Map<String, dynamic> json) {
    docId = json['doc_id'].toString();
    name = json['name'].toString();
    type = json['type'].toString();
    status = json['status'].toString();
    createdDate = json['created_date'].toString();
    modifyDate = json['modify_date'].toString();
  }

  Map<String, String> toJson() {
    final Map<String, String> data = new Map<String, String>();
    data['doc_id'] = this.docId.toString();
    data['name'] = this.name.toString();
    data['type'] = this.type.toString();
    data['status'] = this.status.toString();
    data['created_date'] = this.createdDate.toString();
    data['modify_date'] = this.modifyDate.toString();
    return data;
  }

  static Future<List> getList() async{
    var db = await DBHelper.shared().db;
    if(db != null){
      List<Map> list = await db.rawQuery('SELECT * FROM ${DBHelper.tbDocument} WHERE ${DBHelper.status} = 1');
      return list;
    }else{
      return [];
    }
  }
}