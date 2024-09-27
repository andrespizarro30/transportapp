import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:transport_app/common_widget/round_button.dart';

import '../../common/color_extension.dart';

class ReasonsView extends StatefulWidget {
  const ReasonsView({super.key});

  @override
  State<ReasonsView> createState() => _ReasonsViewState();
}

class _ReasonsViewState extends State<ReasonsView> {

  List reasonArr=[
    "Usuario no esta aqui",
    "Direccion erronea",
    "Usuario no carga"
  ];

  int selectIndex = 0;

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
          icon: Icon(Icons.cancel,size: 20,color: Colors.black,),
        ),
        centerTitle: true,
        title: Text("Cancelacion Viaje",
          style: TextStyle(
              color: TColor.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w800
          ),
        ),
      ),
      body: Column(
        children:[
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
              separatorBuilder: (itemBuilder,index)=>Divider(color: TColor.placeholder,),
              itemCount: reasonArr.length,
              itemBuilder: (itemBuilder,index){
                return GestureDetector(
                  onTap: (){
                    setState(() {
                      selectIndex = index;
                    });
                  },
                  child: ListTile(
                    leading: selectIndex == index ? Icon(Icons.check_circle,size: 20,color: TColor.primary,) : Icon(Icons.circle_outlined, size: 20,),
                    title: Text(
                        reasonArr[index] as String? ?? "",
                        style: TextStyle(
                          color: selectIndex == index ? TColor.primaryText : TColor.secondaryText,
                          fontSize: 16
                        ),
                    ),
                  ),
                );
              }
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: RoundButton(title: "OK", onPressed: (){
              context.pop();
            }),
          ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
