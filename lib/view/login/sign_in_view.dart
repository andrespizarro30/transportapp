import "package:fl_country_code_picker/fl_country_code_picker.dart";
import "package:flutter/material.dart";
import "package:transport_app/common/color_extension.dart";
import "package:transport_app/common_widget/line_text_field.dart";
import "package:transport_app/common_widget/round_button.dart";

class SignInView extends StatefulWidget {

  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Text("Ingresar", 
            style: TextStyle(
              color: TColor.primaryText,
              fontSize: 25,
              fontWeight: FontWeight.w800            
              ),
            ),

            const SizedBox(height: 30,),

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

            const SizedBox(height: 15),

            RoundButton(title: "Ingresar", onPressed: (){

            }),

            RoundButton(title: "Olvide la contrasena", onPressed: (){

            }),
            
            
          ],
        ),
      ),

    );
  }
}