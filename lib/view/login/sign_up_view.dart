import "package:fl_country_code_picker/fl_country_code_picker.dart";
import "package:flutter/material.dart";
import "package:transport_app/common/color_extension.dart";
import "package:transport_app/common_widget/line_text_field.dart";
import "package:transport_app/common_widget/round_button.dart";
import "package:transport_app/view/login/bank_details_view.dart";

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {

  TextEditingController txtName = TextEditingController();
  TextEditingController txtLastName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtMobile = TextEditingController();
  TextEditingController txtPassword = TextEditingController();

  late bool obscurePassword;

  FlCountryCodePicker countryCodePicker = const FlCountryCodePicker();
  late CountryCode countryCode;

  
  @override
  void initState() {
    super.initState();

    obscurePassword = false;
    countryCode = countryCodePicker.countryCodes.firstWhere((element) => element.name == "Colombia");

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
        
              Text("Registrarse", 
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
        
              LineTextField(
                title: "Apellido", 
                hintText: "Ingrese su apellido", 
                controller: txtLastName, 
                keyboardType: TextInputType.name, 
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
        
              LineTextField(
                title: "Password", 
                hintText: "******", 
                controller: txtPassword, 
                keyboardType: TextInputType.phone, 
                obscureText: obscurePassword, 
                right: IconButton(onPressed: (){
                    setState(() {
                      obscurePassword = !obscurePassword;                    
                    });
                  },
                  icon: Image.asset(obscurePassword ? "assets/images/password_show.png" : "assets/images/password_hide.png",width: 25,height: 25,),)
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
        
              RoundButton(title: "Registrarse", onPressed: (){
                context.push(const BankDetailsView());
              })
              
              
            ],
          ),
        ),
      ),

    );
  }


}