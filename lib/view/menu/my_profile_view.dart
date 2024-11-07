import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:transport_app/common_widget/icon_title_row.dart';
import 'package:transport_app/common_widget/title_subtiltle_cell.dart';
import 'package:transport_app/view/menu/edit_profile_view.dart';
import 'package:transport_app/view/menu/rating_view.dart';

import '../../common/appLocalizations .dart';
import '../../common/color_extension.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.lightWhite,
      appBar: AppBar(
        backgroundColor: TColor.darkAppBar,
        elevation: 1,
        leading: IconButton(
          onPressed: (){
            context.pop();
          },
          icon: Image.asset("./assets/images/back.png",width: 25,height: 25,color: TColor.bg,),
        ),
        centerTitle: true,
        title: Text(AppLocalizations.of(context).translate('my_profile'),
          style: TextStyle(
              color: TColor.bg,
              fontSize: 18,
              fontWeight: FontWeight.w800
          ),
        ),
        actions: [
          IconButton(
              onPressed: (){
                context.push(const EditProfileView());
              },
              icon: const Icon(
                Icons.edit,
                size: 25,
                color: Colors.white,
              )
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  width: double.maxFinite,
                  height: context.heigth * 0.2,
                  alignment: Alignment.topCenter,
                  color: TColor.darkAppBar,
                ),
                Column(
                  children: [
                    Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.asset(
                                  "assets/images/u1.png",
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                              InkWell(
                                onTap: (){
                                  context.push(const RatingView());
                                },
                                child: Container(
                                  height: 30,
                                  padding: const EdgeInsets.symmetric(vertical: 4,horizontal: 8),
                                  color: TColor.bg,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset("assets/images/rate.png",width: 15,height: 15,),
                                      SizedBox(width: 4,),
                                      Text(
                                        "4.89",
                                        style: TextStyle(
                                            color: TColor.primaryText,
                                            fontSize: 13
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: TColor.bg,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const[
                          BoxShadow(color: Colors.black12,blurRadius: 2)
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 20,),
                          Text(
                            "Andres Pizarro",
                            style: TextStyle(
                                color: TColor.primaryText,
                                fontSize: 25,
                                fontWeight: FontWeight.w800
                            ),
                          ),
                          SizedBox(height: 25,),
                          Container(
                            height: 0.5,
                            width: double.maxFinite,
                            color: TColor.lightGray,
                          ),
                          Row(
                            children: [
                              const Expanded(
                                  child: TitleSubtitleCell(title: "3250", subTitle: "Total trips")
                              ),
                              Container(
                                height: 60,
                                width: 0.5,
                                color: TColor.lightGray,
                              ),
                              const Expanded(
                                  child: TitleSubtitleCell(title: "2.5", subTitle: "Years")
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8,),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 20),
              child: Text(
                AppLocalizations.of(context).translate('personal_info'),
                style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w800
                ),
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 20),
              child: Column(
                children: [
                  IconTitleRow(title: "+57 313 577 9273", icon: "./assets/images/phone.png", onPressed: (){

                  }),
                  IconTitleRow(title: "felipe50@hotmail.com", icon: "./assets/images/email.png", onPressed: (){

                  }),
                  IconTitleRow(title: "English and Spanish", icon: "./assets/images/language.png", onPressed: (){

                  }),
                  IconTitleRow(title: "Cll 98 B 15 a 47 Belmonte", icon: "./assets/images/home.png", onPressed: (){

                  })
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
