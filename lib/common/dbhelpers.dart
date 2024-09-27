import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

class DBHelper{

  static final DBHelper singleton = new DBHelper.internal();
  factory DBHelper() => singleton;
  static Database? _db;
  DBHelper.internal();
  static DBHelper shared() => singleton;

  static final String tbZoneList = "zone_list";
  static final String tbServiceDetail = "service_detail";
  static final String tbPriceDetail = "price_detail";
  static final String tbDocument = "document";
  static final String tbZoneDocument = "zone_document";

  static const String zone_id = "zone_id";
  static const String zone_name = "zone_name";
  static const String zone_json = "zone_json";
  static const String city = "city";
  static const String tax = "tax";
  static const String status = "status";
  static const String created_date = "created_date";
  static const String modify_date = "modify_date";

  static const String service_id = "service_id";
  static const String service_name = "service_name";
  static const String seat = "seat";
  static const String color = "color";
  static const String icon = "icon";
  static const String top_icon = "top_icon";
  static const String gender = "gender";
  static const String description = "description";

  static const String price_id = "price_id";
  static const String base_charge = "base_charge";
  static const String per_km_charge = "per_km_charge";
  static const String per_min_charge = "per_min_charge";
  static const String booking_charge = "booking_charge";
  static const String mini_fair = "mini_fair";
  static const String mini_km = "mini_km";
  static const String cancel_charge = "cancel_charge";

  static const String doc_id = "doc_id";
  static const String name = "name";
  static const String type = "type";

  static const String zone_doc_id = "zone_doc_id";
  static const String personal_doc = "personal_doc";
  static const String car_doc = "car_doc";
  static const String required_personal_doc = "required_personal_doc";
  static const String required_car_doc = "required_car_doc";

  static final Map tables = {
    tbZoneList: [zone_id,zone_name,zone_json,city,tax,status,created_date,modify_date],
    tbServiceDetail: [service_id,service_name,seat,color,icon,top_icon,gender,status,created_date,modify_date,description],
    tbPriceDetail: [price_id,zone_id,service_id,base_charge,per_km_charge,per_min_charge,booking_charge,mini_fair,mini_km,cancel_charge,tax,status,created_date,modify_date],
    tbDocument: [doc_id,name,type,status,created_date,modify_date],
    tbZoneDocument: [zone_doc_id,zone_id,service_id,personal_doc,car_doc,required_personal_doc,required_car_doc,status,created_date,modify_date]
  };


  Future<Database?> get db async{
    if(_db != null){
      return _db;
    }
    _db = await initDB();
    return _db;
  }

  initDB() async{

    String databasePath = await getDatabasesPath();

    /*var appDirectory = await getDownloadsDirectory();
    String appImagesPath = appDirectory!.path;
    Directory folderDir = Directory("${appImagesPath}/databases");*/

    String path = join(databasePath,'data.db');

    var isDBExists = await databaseExists(path);

    if(kDebugMode){
      print(isDBExists);
      print(path);
    }

    return await openDatabase(path,version: 1, onCreate: onCreate);

  }

  void onCreate(Database db,int newVersion) async{
    debugPrint("DB Created");

    for(var tableName in tables.keys){

      List<String> tableFields = tables[tableName];

      String tableFieldsStruc = "";

      for (var i = 0; i < tableFields.length; i++) {
        if(i==0){
          tableFieldsStruc = "[${tableFields[i]}] TEXT PRIMARY KEY,";
        }else{
          tableFieldsStruc = "$tableFieldsStruc[${tableFields[i]}] TEXT,";
        }
      }

      tableFieldsStruc = tableFieldsStruc.substring(0, tableFieldsStruc.length - 1);

      await db.execute('CREATE TABLE $tableName($tableFieldsStruc)');

    }

  }

  static Future dbClearAll() async{
    if(_db==null){
      return;
    }

    for(var tableName in tables.keys){
      await _db?.execute("DELETE FROM $tableName");
    }

  }

  static Future bdClearTable(String tableName) async{
    if(_db==null){
      return;
    }
    await _db?.execute("DELETE FROM $tableName");
  }

  Future close() async{
    if(_db==null){
      return;
    }
    var dbClient = await db;

    return dbClient?.close();
  }



}