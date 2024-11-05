import "package:fl_country_code_picker/fl_country_code_picker.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:transport_app/common/color_extension.dart";
import "package:transport_app/common_widget/round_button.dart";
import "package:transport_app/view/login/otp_view.dart";

import "../../common/appLocalizations .dart";

class MobileNumberView extends StatefulWidget {
  const MobileNumberView({super.key});

  @override
  State<MobileNumberView> createState() => _MobileNumberViewState();
}

class _MobileNumberViewState extends State<MobileNumberView> {

  FlCountryCodePicker countryCodePicker = const FlCountryCodePicker();
  TextEditingController txtMobile = TextEditingController();
  late CountryCode countryCode;

  @override
  void initState() {
    super.initState();

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

            Text(AppLocalizations.of(context).translate('enter_phone_number'),
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

            const Divider(),

            const SizedBox(height: 8,),

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

            RoundButton(title: AppLocalizations.of(context).translate('login_as_driver'), onPressed: (){
              context.push(OTPView(number: txtMobile.text, dialCode: countryCode.dialCode));
            }),

            const SizedBox(height: 15,),

            RoundButton(title: AppLocalizations.of(context).translate('login_as_user'), onPressed: (){
              context.push(OTPView(number: txtMobile.text, dialCode: countryCode.dialCode, isDriver: false,));
            })

          ],
        ),
      ),
    );
  }
}