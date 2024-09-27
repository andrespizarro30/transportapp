import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:transport_app/common/color_extension.dart';
import 'package:transport_app/common/globs.dart';
import 'package:transport_app/view/home/home_view.dart';
import 'package:transport_app/view/login/change_language.dart';
import 'package:transport_app/view/login/profile_image_view.dart';
import 'package:transport_app/view/login/welcome_view.dart';
import 'package:transport_app/view/user/user_home_view.dart';

import '../../common/service_call.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    super.initState();
    load();

  }

  void load() async{
    await Future.delayed(const Duration(seconds: 3));
    loadNextScreen();
  }

  void loadNextScreen(){
    if(Globs.udValueBool(Globs.userLogin)){
      if(ServiceCall.userType == 2){
        if(ServiceCall.userObj[KKey.status] == 1){
          context.push(const HomeView());
        }else{
          context.push(const ProfileImageView());
        }
      }else
      {
        context.push(const UserHomeView());
      }

    }else{
      context.push(const ChangeLanguageView());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.bg,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: context.width,
            height: context.heigth,
            color:  TColor.primary,
          ),
          Image.asset("assets/images/app_logo.png",width: context.width * 0.25,)
        ],
      ),
    );
  }
}