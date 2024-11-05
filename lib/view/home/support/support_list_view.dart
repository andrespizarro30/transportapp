import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:transport_app/common/common_extension.dart';
import 'package:transport_app/common/globs.dart';
import 'package:transport_app/common/service_call.dart';
import 'package:transport_app/common/socket_manager.dart';
import 'package:transport_app/common_widget/support_user_row.dart';
import 'package:transport_app/view/home/support/support_message_view.dart';

import '../../../common/appLocalizations .dart';
import '../../../common/color_extension.dart';

class SupportListView extends StatefulWidget {
  const SupportListView({super.key});

  @override
  State<SupportListView> createState() => _SupportListViewState();
}

class _SupportListViewState extends State<SupportListView> {

  List listArr = [];

  @override
  void initState() {
    super.initState();
    getList();
    SocketManager.shared.socket?.on("support_message",(data){
      print("support_message socket get :${data.toString()}");
      if(data[KKey.status] == "1"){
        var mObj = data[KKey.payload] as List? ?? [];
        var senderUserObj = data["user_info"] as Map? ?? {};

        Map? userObj;

        var senderId = mObj[0]["sender_id"];
        var userExists = false;
        for(var uObj in listArr){
          if(senderId == uObj["user_id"]){
            uObj["message"] = mObj[0]["message"];
            uObj["message_type"] = mObj[0]["message_type"];
            uObj["created_date"] = mObj[0]["created_date"];
            uObj["base_count"] = int.parse("${uObj["base_count"]}") + 1;
            userExists = true;
            userObj = uObj;
            break;
          }
        }

        if(!userExists){
          senderUserObj["message"] = mObj[0]["message"];
          senderUserObj["message_type"] = mObj[0]["message_type"];
          senderUserObj["created_date"] = mObj[0]["created_date"];
          senderUserObj["base_count"] = 1;
          listArr.insert(0, senderUserObj);
        }else{
          listArr.remove(userObj);
          listArr.insert(0, userObj);
        }

        if(mounted){
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.lightWhite,
        appBar: AppBar(
          backgroundColor: TColor.bg,
          elevation: 1,
          leading: IconButton(
            onPressed: (){
              context.pop();
            },
            icon: Image.asset("./assets/images/back.png",width: 25,height: 25,),
          ),
          centerTitle: true,
          title: Text(AppLocalizations.of(context).translate('support'),
            style: TextStyle(
                color: TColor.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w800
            ),
          ),
        ),
      body: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
          itemBuilder: (context,index){
            var uObj = listArr[index] as Map? ?? {};
            return SupportUserRow(uObj: uObj,
              onPressed: () async{
                await context.push(SupportMessageView(uObj: uObj,));
                getList();
              },
            );
          },
          separatorBuilder: (context,index)=> Divider(),
          itemCount: listArr.length
      ),
    );
  }

  void getList(){
    Globs.showHUD();
    ServiceCall.post(
        {
          "socket_id": SocketManager.shared.socket?.id ?? ""
        },
        SVKey.svSupportList,
        isTokenApi: true,
        withSuccess: (responseObj) async{
          Globs.hideHUD();
          if(responseObj[KKey.status] == "1"){
            listArr = responseObj[KKey.payload] as List? ?? [];
            if(mounted){
              setState(() {});
            }
          }else{
            mdShowAlert(Globs.appName, responseObj[KKey.message] as String? ?? MSG.fail,(){

            });
          }
        },
        failure: (error) async{
          Globs.hideHUD();
          mdShowAlert(Globs.appName, error.toString(),(){

          });
        }
    );
  }

}
