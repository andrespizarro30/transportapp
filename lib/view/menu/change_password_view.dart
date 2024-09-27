import 'package:flutter/material.dart';
import 'package:transport_app/common/common_extension.dart';
import 'package:transport_app/common_widget/line_text_field.dart';
import 'package:transport_app/common_widget/round_button.dart';

import '../../common/color_extension.dart';
import '../../common/globs.dart';
import '../../common/service_call.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {

  TextEditingController txtCurrentPassword = TextEditingController();
  TextEditingController txtNewPassword = TextEditingController();
  TextEditingController txtConfirmPassword = TextEditingController();

  bool showCurrentPassword = true;
  bool showNewPassword = true;
  bool showConfirmPassword = true;

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
        title: Text("Change password",
          style: TextStyle(
              color: TColor.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w800
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25,horizontal: 25),
          child: Column(
            children: [
              LineTextField(
                  title: "Current password",
                  hintText: "******",
                  controller: txtCurrentPassword,
                  keyboardType: TextInputType.text,
                  obscureText: showCurrentPassword,
                  right: IconButton(onPressed: (){
                    setState(() {
                      showCurrentPassword = !showCurrentPassword;
                    });
                  },
                    icon: Image.asset(showCurrentPassword ? "assets/images/password_show.png" : "assets/images/password_hide.png",width: 25,height: 25,),)
              ),
              SizedBox(height: 15,),
              LineTextField(
                  title: "New password",
                  hintText: "******",
                  controller: txtNewPassword,
                  keyboardType: TextInputType.text,
                  obscureText: showNewPassword,
                  right: IconButton(onPressed: (){
                    setState(() {
                      showNewPassword = !showNewPassword;
                    });
                  },
                    icon: Image.asset(showNewPassword ? "assets/images/password_show.png" : "assets/images/password_hide.png",width: 25,height: 25,),)
              ),
              SizedBox(height: 15,),
              LineTextField(
                  title: "Confirm password",
                  hintText: "******",
                  controller: txtConfirmPassword,
                  keyboardType: TextInputType.text,
                  obscureText: showConfirmPassword,
                  right: IconButton(onPressed: (){
                    setState(() {
                      showConfirmPassword = !showConfirmPassword;
                    });
                  },
                    icon: Image.asset(showConfirmPassword ? "assets/images/password_show.png" : "assets/images/password_hide.png",width: 25,height: 25,),)
              ),

              const SizedBox(height: 25,),

              RoundButton(title: "Change", onPressed: (){
                actionSubmit();
              })

            ],
          ),
        ),
      ),
    );
  }

  void actionSubmit(){

    if(txtCurrentPassword.text.isEmpty){
      mdShowAlert("error", "Please enter current password", () { });
      return;
    }

    if(txtNewPassword.text.isEmpty){
      mdShowAlert("error", "Please enter new password", () { });
      return;
    }

    if(txtConfirmPassword.text != txtNewPassword.text){
      mdShowAlert("error", "Password not match", () { });
      return;
    }

    endEditing();

    appiChangePassword(
        {
          "old_password" : txtCurrentPassword.text,
          "new_password" : txtNewPassword.text
        }
    );

  }

  void appiChangePassword(Map<String,String> parameter){
    Globs.showHUD();

    ServiceCall.post(
        parameter,
        isTokenApi: true,
        SVKey.svChangePassword,
        withSuccess: (responseObj) async{
          Globs.hideHUD();
          if((responseObj[KKey.status] as String? ?? "") == "1"){
            mdShowAlert("Success", responseObj[KKey.message] as String? ?? "",(){
              context.pop();
            });
          }else{
            mdShowAlert("Error", responseObj[KKey.message] as String? ?? "",(){});
          }
          if(mounted){
            setState(() {

            });
          }
        },
        failure: (err) async{
          Globs.hideHUD();
          mdShowAlert("Error", err,(){});
        }
    );
  }

}
