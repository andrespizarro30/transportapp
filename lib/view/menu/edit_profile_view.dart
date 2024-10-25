import "package:fl_country_code_picker/fl_country_code_picker.dart";
import "package:flutter/material.dart";
import "package:transport_app/common/color_extension.dart";
import "package:transport_app/common/common_extension.dart";
import "package:transport_app/common_widget/line_text_field.dart";
import "package:transport_app/common_widget/round_button.dart";
import "package:transport_app/view/login/bank_details_view.dart";

import "../../common/globs.dart";
import "../../common/service_call.dart";
import "../user/user_home_view.dart";

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {

  TextEditingController txtName = TextEditingController();
  TextEditingController txtLastName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtMobile = TextEditingController();

  FlCountryCodePicker countryCodePicker = const FlCountryCodePicker();
  late CountryCode countryCode;

  bool isMale = true;

  @override
  void initState() {
    super.initState();

    countryCode = countryCodePicker.countryCodes.firstWhere((element) => element.name == "Colombia");

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
        title: Text("Edit profile",
          style: TextStyle(
              color: TColor.primaryText,
              fontSize: 18,
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

              const SizedBox(height: 10,),

              LineTextField(
                  title: "Nombre",
                  hintText: "Ingrese su nombre",
                  controller: txtName,
                  keyboardType: TextInputType.name
              ),

              const SizedBox(height: 10,),

              LineTextField(
                title: "Apellido",
                hintText: "Ingrese su apellido",
                controller: txtLastName,
                keyboardType: TextInputType.name,
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

              const SizedBox(height: 8),

              RoundButton(title: "Save", onPressed: (){
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

    if(txtLastName.text.isEmpty){
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

    endEditing();

    serviceUpdateProfile(
        {
          "name": txtName.text + " " + txtLastName.text,
          "email": txtEmail.text,
          "mobile": txtMobile.text,
          "gender": isMale ? 'm' : 'f',
          "mobile_code": countryCode.dialCode,
          "zone_id": '3',
          "select_service_id": '0,1,2,3'
        }
    );

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

              mdShowAlert("Updated", responseObj[KKey.message] ?? MSG.success, () {
                context.push(const UserHomeView());
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
            Globs.hideHUD();
            mdShowAlert("Error...",err.toString(),(){});
          });
    }catch(e){
      Globs.hideHUD();
      mdShowAlert("Error",e.toString(),(){});
    }

  }


}