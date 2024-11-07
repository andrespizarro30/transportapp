import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:transport_app/common/common_extension.dart';
import 'package:transport_app/common_widget/my_car_row.dart';
import 'package:transport_app/common_widget/round_button.dart';
import 'package:transport_app/view/login/add_vehicle_view.dart';
import 'package:transport_app/view/login/vehicle_documents_view.dart';
import 'package:transport_app/view/menu/my_car_details_view.dart';

import '../../common/appLocalizations .dart';
import '../../common/color_extension.dart';
import '../../common/globs.dart';
import '../../common/service_call.dart';

class MyVehicleView extends StatefulWidget {
  const MyVehicleView({super.key});

  @override
  State<MyVehicleView> createState() => _MyVehicleViewState();
}

class _MyVehicleViewState extends State<MyVehicleView> {

  List carList = [];

  @override
  void initState() {
    super.initState();
    getCarList();
  }

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
        title: Text(AppLocalizations.of(context).translate('my_vehicle'),
          style: TextStyle(
              color: TColor.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w800
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.separated(
                  physics: AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  itemBuilder: (context,index){

                    var cObj = carList[index] as Map? ?? {};

                    return Slidable(
                      child: MyCarRow(
                          cObj: cObj as Map? ?? {},
                          onPressed: (){
                            context.push(VehicleDocumentsView(obj: cObj,));
                          }
                      ),
                      key: ValueKey(cObj["user_car_id"]),
                      endActionPane: ActionPane(
                        motion: DrawerMotion(),
                        children: [
                          SlidableAction(
                            flex: 1,
                            onPressed: (context){
                              setCarRunningApi({"user_car_id":cObj["user_car_id"].toString() ?? "0"});
                            },
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            icon: Icons.directions_car,
                            label: AppLocalizations.of(context).translate('set'),
                          ),
                          SlidableAction(
                            flex: 1,
                            onPressed: (context){
                              carDeleteApi({"user_car_id":cObj["user_car_id"].toString() ?? "0"},index);
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: AppLocalizations.of(context).translate('delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index)=>const Divider(height: 0.5,),
                  itemCount: carList.length
              )
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: RoundButton(title: AppLocalizations.of(context).translate('add_vehicle'), onPressed: (){
              context.push(const AddVehicleView());
            }),
          ),
          SizedBox(height: 25,)
        ],
      ),
    );
  }

  void getCarList(){
    Globs.showHUD();

    ServiceCall.post(
        {},
        isTokenApi: true,
        SVKey.svCarList,
        withSuccess: (responseObj) async{
          Globs.hideHUD();
          if((responseObj[KKey.status] as String? ?? "") == "1"){
            carList = responseObj[KKey.payload] as List? ?? [];
          }else{
            carList = [];
          }
          if(mounted){
            setState(() {

            });
          }
        },
        failure: (err) async{
          Globs.hideHUD();
          mdShowAlert(AppLocalizations.of(context).translate('error'), err,(){});
        }
    );
  }

  void carDeleteApi(Map<String,String> parameter, int deleteIndex){
    Globs.showHUD();

    ServiceCall.post(
        parameter,
        isTokenApi: true,
        SVKey.svDeleteCar,
        withSuccess: (responseObj) async{
          Globs.hideHUD();
          carList.removeAt(deleteIndex);
          if((responseObj[KKey.status] as String? ?? "") == "1"){
            mdShowAlert(AppLocalizations.of(context).translate('success'), responseObj[KKey.message] as String? ?? "",(){});
          }else{
            mdShowAlert(AppLocalizations.of(context).translate('error'), responseObj[KKey.message] as String? ?? "",(){});
          }
          if(mounted){
            setState(() {

            });
          }
        },
        failure: (err) async{
          Globs.hideHUD();
          mdShowAlert(AppLocalizations.of(context).translate('error'), err,(){});
        }
    );
  }

  void setCarRunningApi(Map<String,String> parameter){
    Globs.showHUD();

    ServiceCall.post(
        parameter,
        isTokenApi: true,
        SVKey.svSetCar,
        withSuccess: (responseObj) async{
          Globs.hideHUD();
          if((responseObj[KKey.status] as String? ?? "") == "1"){
            getCarList();
            mdShowAlert(AppLocalizations.of(context).translate('success'), responseObj[KKey.message] as String? ?? "",(){});
          }else{
            mdShowAlert(AppLocalizations.of(context).translate('error'), responseObj[KKey.message] as String? ?? "",(){});
          }
          if(mounted){
            setState(() {

            });
          }
        },
        failure: (err) async{
          Globs.hideHUD();
          mdShowAlert(AppLocalizations.of(context).translate('error'), err,(){});
        }
    );
  }

}
