import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_otp_text_field/flutter_otp_text_field.dart";
import "package:otp_timer_button/otp_timer_button.dart";
import "package:transport_app/common/color_extension.dart";
import "package:transport_app/common/common_extension.dart";
import "package:transport_app/common/globs.dart";
import "package:transport_app/common/service_call.dart";
import "package:transport_app/common_widget/round_button.dart";
import "package:transport_app/cubit/login/login_cubit.dart";
import "package:transport_app/view/home/home_view.dart";
import "package:transport_app/view/login/profile_image_view.dart";
import "package:transport_app/view/user/user_home_view.dart";

import "../../common/appLocalizations .dart";

class OTPView extends StatefulWidget {

  final bool isDriver;
  final String number;
  final String dialCode;

  const OTPView({super.key, required this.number, required this.dialCode, this.isDriver = true});

  @override
  State<OTPView> createState() => _OTPViewState();
}

class _OTPViewState extends State<OTPView> {
  FirebaseAuth auth = FirebaseAuth.instance;
  String verificationId = "";
  var otpCode = "";

  TextEditingController txtMobile = TextEditingController();

  @override
  void initState() {
    super.initState();

    onSendSms();
  }

  void onSendSms() async {
    try {
      await auth.verifyPhoneNumber(
          phoneNumber: "${widget.dialCode} ${widget.number}",
          timeout: const Duration(seconds: 5),
          verificationCompleted: (PhoneAuthCredential credential) async {
            await auth.signInWithCredential(credential);
          },
          verificationFailed: (error) {
            mdShowAlert(AppLocalizations.of(context).translate('fail'), error.toString(), () {});
          },
          codeSent: (verificationId, forceResendingToken) {
            this.verificationId = verificationId;
          },
          codeAutoRetrievalTimeout: (verificationId) {
            this.verificationId = verificationId;
          });
    } catch (error) {
      mdShowAlert(AppLocalizations.of(context).translate('error'), error.toString(), () {});
    }
  }

  void smsVerification() async {
    if (otpCode.length < 6) {
      mdShowAlert(AppLocalizations.of(context).translate('fail'), AppLocalizations.of(context).translate('please_enter_a_valid_code'), () {});
      return;
    }

    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: otpCode);
      final User? user = (await auth.signInWithCredential(credential)).user;
      if (user != null) {
        submitApiData(user.uid);
      } else {
        mdShowAlert(AppLocalizations.of(context).translate('fail'), AppLocalizations.of(context).translate('invalid_code'), () {});
      }
    } catch (error) {
      mdShowAlert(AppLocalizations.of(context).translate('fail'), error.toString(), () {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
        onPressed: () {
          context.pop();
        },
        icon: Image.asset(
          "assets/images/back.png",
          width: 20,
          height: 20,
        ),
      )),
      body: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if(state is LoginHUDState){
            Globs.showHUD();
          }else
          if(state is LoginApiResultState){
            Globs.hideHUD();
            mdShowAlert(AppLocalizations.of(context).translate('success'), AppLocalizations.of(context).translate('successfully_signed'), () {});

            if(ServiceCall.userType == 1){
              if(ServiceCall.userObj[KKey.status] == 1 && ServiceCall.userObj["name"] != ""){
                context.push(const UserHomeView());
              }else{
                context.push(const ProfileImageView());
              }
            }else{
              if(ServiceCall.userObj[KKey.status] == 1 && ServiceCall.userObj["name"] != ""){
                context.push(const HomeView());
              }else{
                context.push(const ProfileImageView());
              }
            }
          }else
          if(state is LoginErrortState){
            Globs.hideHUD();
            mdShowAlert(AppLocalizations.of(context).translate('fail'), state.errorMSG, () {});
          }else
          if(state is TokenState){
            Globs.hideHUD();
            mdShowAlert(AppLocalizations.of(context).translate('token'), state.token, () {});
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context).translate('verification_code'),
                  style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 25,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  AppLocalizations.of(context).translate('insert_six_digits_of_received_code'),
                  style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "${widget.dialCode} ${widget.number}",
                      style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    TextButton(
                        onPressed: () {
                          context.pop();
                        },
                        child: Text(
                          AppLocalizations.of(context).translate('editing'),
                          style:
                              TextStyle(color: TColor.secondary, fontSize: 16),
                        ))
                  ],
                ),
                const SizedBox(height: 5),
                OtpTextField(
                  numberOfFields: 6,
                  borderColor: TColor.placeholder,
                  focusedBorderColor: TColor.primary,
                  showFieldAsBox: false,
                  borderWidth: 1.0,
                  onCodeChanged: (String code) {},
                  onSubmit: (String verificationCode) {
                    this.otpCode = verificationCode;
                    smsVerification();
                  },
                ),
                const SizedBox(height: 15),
                RoundButton(
                    title: AppLocalizations.of(context).translate('sending'),
                    onPressed: () {
                      smsVerification();
                    }),
                const SizedBox(width: 30),
                OtpTimerButton(
                    height: 60,
                    onPressed: () {
                      onSendSms();
                    },
                    text: Text(
                      AppLocalizations.of(context).translate('resend_code'),
                      style: TextStyle(fontSize: 16),
                    ),
                    buttonType: ButtonType.text_button,
                    backgroundColor: TColor.primaryText,
                    duration: 60)
              ],
            ),
          );
        },
      ),
    );
  }

  void submitApiData(String uid) {
    context.read<LoginCubit>().submitLogin(widget.dialCode, widget.number, widget.isDriver ? "2" : "1");
  }

}
