import "package:flutter/material.dart";
import "package:transport_app/common/color_extension.dart";
import "package:transport_app/common/common_extension.dart";
import "package:transport_app/common/globs.dart";
import "package:transport_app/common/service_call.dart";
import "package:transport_app/common_widget/line_text_field.dart";
import "package:transport_app/common_widget/round_button.dart";
import "package:transport_app/view/login/document_upload_view.dart";

import "../../common/appLocalizations .dart";

class BankDetailsView extends StatefulWidget {
  const BankDetailsView({super.key});

  @override
  State<BankDetailsView> createState() => _BankDetailsViewState();
}

class _BankDetailsViewState extends State<BankDetailsView> {
  
  TextEditingController txtBankName = TextEditingController();
  TextEditingController txtAccountHolderName = TextEditingController();
  TextEditingController txtAccountNumber = TextEditingController();
  TextEditingController txtSwiftCode = TextEditingController();
  
  @override
  void initState() {
    super.initState();

    getBankDetail();

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

        title: Text(AppLocalizations.of(context).translate('data_payment'),
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
        
              LineTextField(
                title: AppLocalizations.of(context).translate('payment_method'),
                hintText: "Ej: Nequi", 
                controller: txtBankName, 
                keyboardType: TextInputType.name
              ),
        
              const SizedBox(height: 10,),
        
              LineTextField(
                title: AppLocalizations.of(context).translate('holder_name'),
                hintText: AppLocalizations.of(context).translate('enter_name_and_last_name'),
                controller: txtAccountHolderName, 
                keyboardType: TextInputType.name, 
              ),
        
              const SizedBox(height: 10,),
        
              LineTextField(
                title: AppLocalizations.of(context).translate('account_number'),
                hintText: AppLocalizations.of(context).translate('num_account'),
                controller: txtAccountNumber, 
                keyboardType: TextInputType.number, 
              ),
        
              const SizedBox(height: 10,),
        
              LineTextField(
                title: AppLocalizations.of(context).translate('bank_code'),
                hintText: AppLocalizations.of(context).translate('code_if_applies'),
                controller: txtSwiftCode,
                keyboardType: TextInputType.number
              ),
        
              const SizedBox(height: 8),

              Text(AppLocalizations.of(context).translate('when_continuing_confirm_i_agree'),
              style: TextStyle(
                color: TColor.secondaryText,
                fontSize: 11,
                fontWeight: FontWeight.w800            
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context).translate('terms_and_conditions'),
                  style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w800            
                    ),
                  ),
                  Text(" & ", 
                  style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w800            
                    ),
                  ),
                  Text(AppLocalizations.of(context).translate('privacy_policies'),
                  style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w800            
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15,),
        
              RoundButton(title: AppLocalizations.of(context).translate('next'), onPressed: (){
                //context.push(const DocumentUploadView(title: "Documentos"));
                updateAction();
              })
              
              
            ],
          ),
        ),
      ),

    );
  }

  void updateAction(){

    if(txtBankName.text.isEmpty){
      mdShowAlert(AppLocalizations.of(context).translate('error'), AppLocalizations.of(context).translate('please_enter_bank_name'), () {});
      return;
    }

    if(txtAccountNumber.text.isEmpty){
      mdShowAlert(AppLocalizations.of(context).translate('error'), AppLocalizations.of(context).translate('please_enter_account_number'), () {});
      return;
    }

    if(txtAccountHolderName.text.isEmpty){
      mdShowAlert(AppLocalizations.of(context).translate('error'), AppLocalizations.of(context).translate('please_enter_account_holder_name'), () {});
      return;
    }

    endEditing();

    updateBankDetail({
      "account_name":txtAccountHolderName.text,
      "account_no":txtAccountNumber.text,
      "bank_name":txtBankName.text,
      "ifsc":txtSwiftCode.text
    });
  }

  void getBankDetail(){
    Globs.showHUD();
    ServiceCall.post(
    {},
    SVKey.svBankDetail,
    isTokenApi: true,
    withSuccess: (responseObj)async{
      Globs.hideHUD();
      if(responseObj[KKey.status]=="1"){
        var payload = responseObj[KKey.payload] as Map? ?? {};
        setState(() {
          txtAccountHolderName.text = payload["account_name"] as String? ?? "";
          txtAccountNumber.text = payload["account_no"] as String? ?? "";
          txtBankName.text = payload["bank_name"] as String? ?? "";
          txtSwiftCode.text = payload["bsb"] as String? ?? "";
        });
      }else{
        mdShowAlert(AppLocalizations.of(context).translate('error'), responseObj[KKey.message] as String? ?? MSG.fail, () {});
      }
    },
    failure: (err)async {
      Globs.hideHUD();
      mdShowAlert(AppLocalizations.of(context).translate('error'), err,(){});
    }
    );
  }

  void updateBankDetail(Map<String,dynamic> parameter){

    Globs.showHUD();
    ServiceCall.post(
        parameter,
        SVKey.svDriverBankDetailUpdate,
        isTokenApi: true,
        withSuccess: (responseObj)async{
          Globs.hideHUD();
          if(responseObj[KKey.status]=="1"){
            var payload = responseObj[KKey.payload] as Map? ?? {};
            setState(() {
              txtAccountHolderName.text = payload["account_name"] as String? ?? "";
              txtAccountNumber.text = payload["account_no"] as String? ?? "";
              txtBankName.text = payload["bank_name"] as String? ?? "";
              txtSwiftCode.text = payload["bsb"] as String? ?? "";
            });
            mdShowAlert(AppLocalizations.of(context).translate('success'), responseObj[KKey.message] as String? ?? MSG.success, () {});
          }else{
            mdShowAlert(AppLocalizations.of(context).translate('error'), responseObj[KKey.message] as String? ?? MSG.fail, () {});
          }
        },
        failure: (err)async {
          Globs.hideHUD();
          mdShowAlert(AppLocalizations.of(context).translate('error'), err,(){});
        }
    );

  }
  

}