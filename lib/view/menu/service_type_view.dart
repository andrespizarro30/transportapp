import 'package:flutter/material.dart';
import 'package:transport_app/common_widget/switch_row.dart';

import '../../common/color_extension.dart';

class ServiceTypeView extends StatefulWidget {
  const ServiceTypeView({super.key});

  @override
  State<ServiceTypeView> createState() => _ServiceTypeViewState();
}

class _ServiceTypeViewState extends State<ServiceTypeView> {

  List listArr = [
    {"name":"Executive","detail":"What is executive","value": false},
    {"name":"Limo","detail":"What is limo","value": true},
    {"name":"Economy","detail":"What is economy","value": false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: Text("Switch service type",
          style: TextStyle(
              color: TColor.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w800
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
          itemBuilder: (context,index){
            return SwitchRow(sObj: listArr[index] as Map? ?? {}, didChange: (isNew){
              setState(() {
                listArr.forEach((type) {
                  type["value"] = false;
                });
                listArr[index]["value"] = isNew;
              });
            });
          },
          separatorBuilder: (context,index)=>Divider(color: TColor.lightGray,),
          itemCount: listArr.length
      ),
    );
  }
}
