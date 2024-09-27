import "dart:ffi";

import "package:fl_country_code_picker/fl_country_code_picker.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:transport_app/common/color_extension.dart";
import "package:transport_app/common/common_extension.dart";
import "package:transport_app/common/service_call.dart";
import "package:transport_app/common_widget/line_text_field.dart";
import "package:transport_app/common_widget/round_button.dart";

import "../../common/globs.dart";
import "../../common_widget/drop_down_button.dart";

class DriverEditProfileView extends StatefulWidget {
  const DriverEditProfileView({super.key});

  @override
  State<DriverEditProfileView> createState() => _DriverEditProfileViewState();
}

class _DriverEditProfileViewState extends State<DriverEditProfileView> {

  TextEditingController txtName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtMobile = TextEditingController();

  FlCountryCodePicker countryCodePicker = const FlCountryCodePicker();
  late CountryCode countryCode;

  bool isMale = true;

  List zoneList = [];
  List serviceList = [];

  Map<String,dynamic>? selectZone = null;

  List<int> serviceOnIndex = [];

  @override
  void initState() {
    super.initState();

    txtName.text = "${ServiceCall.userObj["name"]}";
    txtEmail.text = "${ServiceCall.userObj["email"]}";
    txtMobile.text = "${ServiceCall.userObj["mobile"]}";

    isMale = ServiceCall.userObj["gender"] == 'm' ? true : false;

    countryCode = countryCodePicker.countryCodes.firstWhere((element) => element.dialCode == "${ServiceCall.userObj["mobile_code"]}");

    serviceOnIndex = ServiceCall.userObj["select_service_id"].toString().split(",").map((id) => int.tryParse(id) ?? 0).toList();

    getServiceZoneList();

  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
          leading: IconButton(
            onPressed: (){
              context.pop();
            },
            icon: Image.asset("assets/images/back.png",
              width: 20,
              height: 20,
            ),
          )
      ),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Text("Edit profile",
                style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 25,
                    fontWeight: FontWeight.w800
                ),
              ),

              const SizedBox(height: 30,),

              LineTextField(
                  title: "Nombre",
                  hintText: "Ingrese su nombre",
                  controller: txtName,
                  keyboardType: TextInputType.name
              ),

              const SizedBox(height: 10,),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      IconButton(
                          onPressed:() {
                            setState(() {
                              isMale = true;
                            });
                          },
                          icon: Icon(
                            isMale ?
                            Icons.radio_button_checked :
                            Icons.radio_button_off,
                            color: TColor.primary,
                          )
                      ),
                      Text(
                        "Male",
                        style: TextStyle(color: TColor.placeholder,fontSize: 14),
                      )
                    ],
                  ),

                  const SizedBox(width: 10,),

                  Row(
                    children: [
                      IconButton(
                          onPressed:() {
                            setState(() {
                              isMale = false;
                            });
                          },
                          icon: Icon(
                            !isMale ?
                            Icons.radio_button_checked :
                            Icons.radio_button_off,
                            color: TColor.primary,
                          )
                      ),
                      Text(
                        "Female",
                        style: TextStyle(color: TColor.placeholder,fontSize: 14),
                      )
                    ],
                  ),
                ],
              ),

              const Divider(),

              const SizedBox(height: 10,),

              LineTextField(
                title: "E-mail",
                hintText: "Ingrese su e-mail",
                controller: txtEmail,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 10,),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () async{

                      final code = await countryCodePicker.showPicker(context: context);

                      if(code != null){
                        setState(() {
                          countryCode = code;
                        });
                      }

                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 30,
                          height: 20,
                          child: countryCode.flagImage(),
                        ),

                        SizedBox(width: 10,),

                        Text(
                          countryCode.dialCode,
                          style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 16
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: TextField(
                      controller: txtMobile,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          hintText: "3001234567"
                      ),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 15,),

              LineDropDownButton(
                title: "Zone",
                hintText: "Select zone",
                itemArr: zoneList,
                didChange: (newObj){
                  setState(() {
                    selectZone = newObj;
                  });
                },
                displayKey: "zone_name",
                selectVal: selectZone != null ? selectZone : null,
              ),

              const SizedBox(height: 8,),

              Text(
                "Service List",
                style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 25,
                  fontWeight: FontWeight.w800
                ),
              ),

              ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context,index){

                    var sObj = serviceList[index] as Map? ?? {};

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          sObj["service_name"] as String? ?? "",
                          style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 17
                          ),
                        ),
                        CupertinoSwitch(
                          value: serviceOnIndex.contains(sObj["service_id"]),
                          onChanged: (isTrue){
                            if(isTrue){
                              //serviceOnIndex.clear();
                              serviceOnIndex.add(sObj["service_id"]);
                            }else{
                              serviceOnIndex.remove(sObj["service_id"]);
                            }

                            setState(() {

                            });

                          }
                        )
                      ],
                    );
                  },
                  separatorBuilder: (context, index)=>const Divider(),
                  itemCount: serviceList.length
              ),
              RoundButton(title: "UPDATE", onPressed: (){
                btnUpdateAction();
              })


            ],
          ),
        ),
      ),

    );
  }

  void btnUpdateAction(){
    if(txtName.text.isEmpty){
      mdShowAlert("Error", "Please enter name", () {});
      return;
    }

    if(txtEmail.text.isEmpty || !txtEmail.text.isEmail){
      mdShowAlert("Error", "Please enter email address", () {});
      return;
    }

    if(txtMobile.text.isEmpty){
      mdShowAlert("Error", "Please enter mobile number", () {});
      return;
    }

    if(selectZone == null){
      mdShowAlert("Error", "Select a job zone", () {});
      return;
    }

    endEditing();

    serviceUpdateProfile(
      {
        "name": txtName.text,
        "email": txtEmail.text,
        "mobile": txtMobile.text,
        "gender": isMale ? 'm' : 'f',
        "mobile_code": countryCode.dialCode,
        "zone_id": selectZone?["zone_id"].toString(),
        "select_service_id": serviceOnIndex.join(",")
      }
    );

  }

  //ServiceCall
  void getServiceZoneList(){

    try{
      ServiceCall.post(
          {

          },
          SVKey.svServiceAndZoneList,
          isTokenApi: true,
          withSuccess:(responseObj)async{
            if((responseObj[KKey.status] as String? ?? "")=="1"){

              var payLoad = responseObj[KKey.payload] as Map? ?? {};

              zoneList = payLoad["zone_list"] as List? ?? [];
              serviceList = payLoad["service_list"] as List? ?? [];

              zoneList.forEach((zObj) {
                if(zObj["zone_id"] == ServiceCall.userObj["zone_id"]){
                  selectZone = zObj;
                }
              });

              if(mounted){
                setState(() {

                });
              }

            }else{
              mdShowAlert("Error",responseObj[KKey.message] ?? MSG.fail,(){});
            }
          },
          failure: (err) async{
            mdShowAlert("Error",err.toString(),(){});
          });
    }catch(e){
      mdShowAlert("Error",e.toString(),(){});
    }

  }

  void serviceUpdateProfile(Map<String, dynamic> parameter){

    Globs.showHUD();

    try{
      ServiceCall.post(
          parameter,
          SVKey.svProfileUpdate,
          isTokenApi: true,
          withSuccess:(responseObj)async{
            Globs.hideHUD();
            if((responseObj[KKey.status] as String? ?? "")=="1"){

              ServiceCall.userObj = responseObj[KKey.payload] as Map? ?? {};
              ServiceCall.userType = ServiceCall.userObj["user_type"] as int? ?? 1;

              Globs.udSet(ServiceCall.userObj, Globs.userPayload);
              Globs.udBoolSet(true, Globs.userLogin);

              mdShowAlert("Updated", responseObj[KKey.message] ?? MSG.success, () { });

              if(mounted){
                setState(() {

                });
              }

            }else{
              mdShowAlert("Error",responseObj[KKey.message] ?? MSG.fail,(){});
            }
          },
          failure: (err) async{
            Globs.hideHUD();
            mdShowAlert("Error...",err.toString(),(){});
          });
    }catch(e){
      Globs.hideHUD();
      mdShowAlert("Error",e.toString(),(){});
    }

  }

}