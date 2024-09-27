import "package:flutter/material.dart";
import "package:transport_app/common/color_extension.dart";
import "package:transport_app/common/common_extension.dart";
import "package:transport_app/common/globs.dart";
import "package:transport_app/common/service_call.dart";
import "package:transport_app/common_widget/line_text_field.dart";
import "package:transport_app/common_widget/round_button.dart";
import "package:transport_app/view/login/document_upload_view.dart";

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

        title: Text("Datos de pago", 
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
                title: "Medio de pago", 
                hintText: "Ej: Nequi", 
                controller: txtBankName, 
                keyboardType: TextInputType.name
              ),
        
              const SizedBox(height: 10,),
        
              LineTextField(
                title: "Nombre del titular", 
                hintText: "Ingrese su nombre y apellido", 
                controller: txtAccountHolderName, 
                keyboardType: TextInputType.name, 
              ),
        
              const SizedBox(height: 10,),
        
              LineTextField(
                title: "Numero de cuenta", 
                hintText: "# cuenta de pago", 
                controller: txtAccountNumber, 
                keyboardType: TextInputType.number, 
              ),
        
              const SizedBox(height: 10,),
        
              LineTextField(
                title: "Codigo del Banco",
                hintText: "Codigo (Si aplica)",
                controller: txtSwiftCode,
                keyboardType: TextInputType.number
              ),
        
              const SizedBox(height: 8),

              Text("Al continuar, confirmo que he leido y estoy de acuerdo,", 
              style: TextStyle(
                color: TColor.secondaryText,
                fontSize: 11,
                fontWeight: FontWeight.w800            
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Terminos y condiciones", 
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
                  Text("Poliza de privacidad", 
                  style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w800            
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15,),
        
              RoundButton(title: "Siguiente", onPressed: (){
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
      mdShowAlert("Error", "Please enter bank name", () {});
      return;
    }

    if(txtAccountNumber.text.isEmpty){
      mdShowAlert("Error", "Please enter account number", () {});
      return;
    }

    if(txtAccountHolderName.text.isEmpty){
      mdShowAlert("Error", "Please enter account holder name", () {});
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
        mdShowAlert("Error", responseObj[KKey.message] as String? ?? MSG.fail, () {});
      }
    },
    failure: (err)async {
      Globs.hideHUD();
      mdShowAlert("Error", err,(){});
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
            mdShowAlert("Success", responseObj[KKey.message] as String? ?? MSG.success, () {});
          }else{
            mdShowAlert("Error", responseObj[KKey.message] as String? ?? MSG.fail, () {});
          }
        },
        failure: (err)async {
          Globs.hideHUD();
          mdShowAlert("Error", err,(){});
        }
    );

  }
  

}