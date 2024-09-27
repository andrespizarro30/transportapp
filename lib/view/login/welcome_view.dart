import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:transport_app/common/color_extension.dart";
import "package:transport_app/common_widget/round_button.dart";
import "package:transport_app/view/login/mobile_number_view.dart";

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.bg,
      body: Stack(
        alignment: Alignment.center,
        children: [

          Image.asset(
            "assets/images/welcome.png",
            width: context.width,
            height: context.heigth,
            fit: BoxFit.cover,
          ),

          Container(
            width: context.width,
            height: context.heigth,
            color:  Colors.black.withOpacity(0.7),
          ),

          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 30,),

                Image.asset(
                  "assets/images/app_logo.png",
                  width: context.width * 0.25,
                ),

                Spacer(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                  child: RoundButton(title: "GET STARTED", onPressed: (){
                    context.push(const MobileNumberView());
                  }),
                ),

                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                //   child: RoundButton(title: "Registrarse", buttonType: RoundButtonType.boarded, onPressed: (){
                //     context.push(const SignUpView());
                //   }),
                // ),

              ],
            )
          )

        ],
      ),
    );
  }

}