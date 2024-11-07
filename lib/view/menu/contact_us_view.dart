import 'package:flutter/material.dart';
import 'package:transport_app/common/common_extension.dart';
import 'package:transport_app/common_widget/line_text_field.dart';

import '../../common/appLocalizations .dart';
import '../../common/color_extension.dart';
import '../../common/globs.dart';
import '../../common/service_call.dart';
import '../../common_widget/round_button.dart';

class ContactUsView extends StatefulWidget {
  const ContactUsView({super.key});

  @override
  State<ContactUsView> createState() => _ContactUsViewState();
}

class _ContactUsViewState extends State<ContactUsView> {

  TextEditingController txtName = TextEditingController();
  TextEditingController txtMail = TextEditingController();
  TextEditingController txtSubject = TextEditingController();
  TextEditingController txtMessage = TextEditingController();

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
        title: Text(AppLocalizations.of(context).translate('contact_us'),
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
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 25),
          child: Column(
            children: [
              LineTextField(
                  title: AppLocalizations.of(context).translate('name'),
                  hintText: AppLocalizations.of(context).translate('enter_name'),
                  controller: txtName,
                  keyboardType: TextInputType.text,
                  right: Icon(Icons.abc,size: 25,)
              ),
              const SizedBox(height: 15,),
              LineTextField(
                  title: AppLocalizations.of(context).translate('e_mail'),
                  hintText: AppLocalizations.of(context).translate('enter_your_e_mail'),
                  controller: txtMail,
                  keyboardType: TextInputType.emailAddress,
                  right: Icon(Icons.email,size: 25,)
              ),
              const SizedBox(height: 15,),
              LineTextField(
                  title: AppLocalizations.of(context).translate('subject'),
                  hintText: AppLocalizations.of(context).translate('enter_subject'),
                  controller: txtSubject,
                  keyboardType: TextInputType.text,
                  right: Icon(Icons.subject,size: 25,)
              ),
              const SizedBox(height: 15,),
              LineTextField(
                  title: AppLocalizations.of(context).translate('message'),
                  hintText: AppLocalizations.of(context).translate('enter_message'),
                  controller: txtMessage,
                  keyboardType: TextInputType.text,
                  right: Icon(Icons.message,size: 25,),
                  minLines: 5,
                  maxLines: 10,
              ),
              const SizedBox(height: 25,),
              RoundButton(title: AppLocalizations.of(context).translate('submit'), onPressed: (){
                actionSubmit();
              })
            ],
          ),
        ),
      ),
    );
  }

  void actionSubmit(){

    if(txtName.text.isEmpty){
      mdShowAlert("error", "Please enter name", () { });
      return;
    }

    if(txtMail.text.isEmpty){
      mdShowAlert("error", "Please enter email", () { });
      return;
    }

    if(txtSubject.text.isEmpty){
      mdShowAlert("error", "Please enter subject", () { });
      return;
    }

    if(txtMessage.text.isEmpty){
      mdShowAlert("error", "Please enter message", () { });
      return;
    }

    endEditing();

    apiContactUs(
        {
          "name" : txtName.text,
          "email" : txtMail.text,
          "subject" : txtSubject.text,
          "message" : txtMessage.text
        }
    );

  }

  void apiContactUs(Map<String,String> parameter){
    Globs.showHUD();

    ServiceCall.post(
        parameter,
        isTokenApi: true,
        SVKey.svContactUs,
        withSuccess: (responseObj) async{
          Globs.hideHUD();
          if((responseObj[KKey.status] as String? ?? "") == "1"){
            mdShowAlert("Success", responseObj[KKey.message] as String? ?? MSG.success,(){
              context.pop();
            });
          }else{
            mdShowAlert("Error", responseObj[KKey.message] as String? ?? MSG.fail,(){});
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
