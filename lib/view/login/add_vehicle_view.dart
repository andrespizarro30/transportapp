import "dart:io";

import "package:flutter/material.dart";
import "package:transport_app/common/color_extension.dart";
import "package:transport_app/common/common_extension.dart";
import "package:transport_app/common/globs.dart";
import "package:transport_app/common/service_call.dart";
import "package:transport_app/common_widget/drop_down_button.dart";
import "package:transport_app/common_widget/line_text_field.dart";
import "package:transport_app/common_widget/round_button.dart";

import "../../common_widget/image_picker_view.dart";
import "../../common_widget/popup_layout.dart";

import "../../common_widget/image_picker_view.dart";

class AddVehicleView extends StatefulWidget {
  const AddVehicleView({super.key});

  @override
  State<AddVehicleView> createState() => _AddVehicleViewState();
}

class _AddVehicleViewState extends State<AddVehicleView> {
  
  TextEditingController txtSeat = TextEditingController();
  TextEditingController txtBrandName = TextEditingController();
  TextEditingController txtModelName = TextEditingController();
  TextEditingController txtManufacturer = TextEditingController();
  TextEditingController txtNumberPlate = TextEditingController();
  TextEditingController txtSeries = TextEditingController();
  File? selectImage;

  List brandArr = [];
  List modelArr = [];
  List seriesArr = [];

  Map? selectBrandObj;
  Map? selectModelObj;
  Map? selectSeriesObj;

  int otherFlag = 0;
  
  @override
  void initState() {
    super.initState();

    getBrandList();

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
          icon: Image.asset("assets/images/back.png",
            width: 20,
            height: 20, 
          ),
        ),
        centerTitle: true,

        title: Text("Vehiculo",
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 25,
            fontWeight: FontWeight.w800            
            ),
          ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
               
              const SizedBox(height: 30,),

              LineDropDownButton(
                  title: "Marca",
                  hintText: "Seleccione MARCA",
                  didChange: (bObj){

                    selectBrandObj = bObj;
                    selectModelObj = null;
                    selectSeriesObj = null;

                    if(bObj["brand_id"] == 0){
                      otherFlag = 1;
                    }else{
                      getModelList({"brand_id":bObj["brand_id"].toString()});
                    }
                    setState(() {});
                  },
                  displayKey: "brand_name",
                  itemArr: brandArr,
                  selectVal: selectBrandObj,
              ),

              const SizedBox(height: 8,),

              if((selectBrandObj?["brand_id"] as int? ?? -1)==0)
                LineTextField(
                  title: "Marca",
                  hintText: "Ej: Kia, Chevrolet, etc",
                  controller: txtBrandName,
                  keyboardType: TextInputType.name,
                ),
        
              const SizedBox(height: 10,),

              if((selectBrandObj?["brand_id"] as int? ?? -1)!=0)

                LineDropDownButton(
                    title: "Modelo",
                    hintText: "Seleccione modelo",
                    didChange: (mObj){

                      selectModelObj = mObj;
                      selectSeriesObj = null;

                      if(mObj["model_id"] == 0){
                        otherFlag = 2;
                      }else{
                        getSeriesList({"model_id":mObj["model_id"].toString()});
                      }
                      setState(() {});
                    },
                    displayKey: "model_name",
                    itemArr: modelArr,
                    selectVal: selectModelObj,
                ),

              const SizedBox(height: 8,),

              if((selectBrandObj?["brand_id"] as int? ?? -1)==0 || (selectModelObj?["model_id"] as int? ?? -1)==0)
                LineTextField(
                  title: "Modelo",
                  hintText: "Ej: Picanto, Spark",
                  controller: txtModelName,
                  keyboardType: TextInputType.name,
                ),

              const SizedBox(height: 10,),

              if(!((selectBrandObj?["brand_id"] as int? ?? -1)==0 || (selectModelObj?["model_id"] as int? ?? -1)==0))
                LineDropDownButton(
                    title: "Series",
                    hintText: "Seleccione serie",
                    didChange: (sObj){
                      selectSeriesObj = sObj;

                      if(sObj["series_id"]==0){
                        otherFlag = 3;
                      }
                      setState(() {});
                    },
                    displayKey: "series_name",
                    itemArr: seriesArr,
                    selectVal: selectSeriesObj,
                ),

              const SizedBox(height: 8,),

              if((selectBrandObj?["brand_id"] as int? ?? -1)==0 ||
                  (selectModelObj?["model_id"] as int? ?? -1)==0 ||
                  (selectSeriesObj?["series_id"] as int? ?? -1)==0
              )
                LineTextField(
                    title: "Series",
                    hintText: "Otra referencia del vehiculo",
                    controller: txtSeries,
                    keyboardType: TextInputType.name
                ),

              const SizedBox(height: 10,),

              LineTextField(
                  title: "Seat",
                  hintText: "Numero de asiento disponibles",
                  controller: txtSeat,
                  keyboardType: TextInputType.name
              ),

              const SizedBox(height: 10),

              LineTextField(
                title: "Placa", 
                hintText: "Ej: ABC123",
                controller: txtNumberPlate,
                keyboardType: TextInputType.name
              ),

              const SizedBox(height: 10),

              InkWell(
                onTap: () async{
                  await Navigator.push(context, PopupLayout(child: ImagePickerView(didSelect: (imagePath) async{
                    selectImage = File(imagePath);
                    setState(() {

                    });

                  },),),);
                },
                child: Container(
                  width: context.width-120,
                  height: context.width-120,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const[
                        BoxShadow(color: Colors.black26,blurRadius: 10)
                      ]
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: selectImage != null ?
                    Image.file(selectImage!, width: context.width-40, height: context.width-40,fit: BoxFit.cover,) :
                    Icon(Icons.directions_car,size: 150,color: TColor.secondaryText),
                  ),
                ),
              ),

              const SizedBox(height: 15,),
        
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: RoundButton(title: "Registrar", onPressed: submitCarAction),
              )
            ],
          ),
        ),
      ),

    );
  }

  void submitCarAction(){
    if(selectBrandObj == null){
      mdShowAlert("Error", "Please select a car brand", () { });
      return;
    }

    if(otherFlag==1 && txtBrandName.text.isEmpty){
      mdShowAlert("Error", "Please enter a brand name", () { });
      return;
    }

    if(otherFlag > 1 && selectModelObj == null){
      mdShowAlert("Error", "Please select a car model", () { });
      return;
    }

    if(otherFlag > 0 && otherFlag<=2 && txtModelName.text.isEmpty){
      mdShowAlert("Error", "Please enter a model name", () { });
      return;
    }

    if(otherFlag > 2 && selectSeriesObj == null){
      mdShowAlert("Error", "Please select a car series", () { });
      return;
    }

    if(otherFlag > 0 && otherFlag<=3 && txtSeries.text.isEmpty){
      mdShowAlert("Error", "Please enter a series name", () { });
      return;
    }

    if(txtSeat.text.isEmpty){
      mdShowAlert("Error", "Please enter number of seats", () { });
      return;
    }

    if(txtNumberPlate.text.isEmpty){
      mdShowAlert("Error", "Please enter car plate", () { });
      return;
    }

    if(selectImage == null){
      mdShowAlert("Error", "Please take or select car image", () { });
      return;
    }

    endEditing();

    submitCarApi({
      "brand": otherFlag > 0 && otherFlag<=1 ? txtBrandName.text : selectBrandObj!["brand_id"].toString(),
      "model": otherFlag > 0 && otherFlag<=2 ? txtModelName.text : selectModelObj!["model_id"].toString(),
      "series": otherFlag > 0 && otherFlag<=3 ? txtSeries.text : selectSeriesObj!["series_id"].toString(),
      "seat":txtSeat.text,
      "other_status":otherFlag.toString(),
      "car_number": txtNumberPlate.text
    });

  }

  void getBrandList(){
    Globs.showHUD();

    ServiceCall.post(
      {

      },
      isTokenApi: true,
      SVKey.svBrandList,
      withSuccess: (responseObj) async{
        Globs.hideHUD();
        if((responseObj[KKey.status] as String? ?? "") == "1"){
          brandArr = responseObj[KKey.payload] as List? ?? [];
        }else{
          brandArr = [];
        }
        setState(() {

        });
      },
      failure: (err) async{
        Globs.hideHUD();
      }
    );

  }

  void getModelList(Map<String,dynamic> parameter){
    Globs.showHUD();

    ServiceCall.post(
        parameter,
        isTokenApi: true,
        SVKey.svModelList,
        withSuccess: (responseObj) async{
          Globs.hideHUD();
          if((responseObj[KKey.status] as String? ?? "") == "1"){
            modelArr = responseObj[KKey.payload] as List? ?? [];
          }else{
            modelArr = [];
          }
          setState(() {});
        },
        failure: (err) async{
          Globs.hideHUD();
          mdShowAlert("Error", err,(){});
        }
    );

  }

  void getSeriesList(Map<String,dynamic> parameter){
    Globs.showHUD();

    ServiceCall.post(
        parameter,
        isTokenApi: true,
        SVKey.svSeriesList,
        withSuccess: (responseObj) async{
          Globs.hideHUD();
          if((responseObj[KKey.status] as String? ?? "") == "1"){
            seriesArr = responseObj[KKey.payload] as List? ?? [];
          }else{
            seriesArr = [];
          }
          setState(() {});
        },
        failure: (err) async{
          Globs.hideHUD();
          mdShowAlert("Error", err,(){});
        }
    );

  }

  void submitCarApi(Map<String,String> parameter){
    Globs.showHUD();
    ServiceCall.multiPart(
        parameter,
        SVKey.svAddCar,
        isTokenApi: true,
        imgObj: {"image":selectImage!},
        withSuccess: (responseObj) async{
          Globs.hideHUD();
          if((responseObj[KKey.status] ?? "")=="1"){
            mdShowAlert("Success",responseObj[KKey.message] ?? MSG.success,(){
              context.pop();
            });
          }else{
            mdShowAlert("Error",responseObj[KKey.message] ?? MSG.fail,(){});
          }
        },
        failure: (err) async{
          Globs.hideHUD();
          mdShowAlert("Error", err,(){});
        }
    );
  }

}