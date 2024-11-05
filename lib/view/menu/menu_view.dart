import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transport_app/common/color_extension.dart';
import 'package:transport_app/common/common_extension.dart';
import 'package:transport_app/common/service_call.dart';
import 'package:transport_app/common_widget/icon_title.dart';
import 'package:transport_app/common_widget/menu_row.dart';
import 'package:transport_app/view/home/driver_my_rides_view.dart';
import 'package:transport_app/view/login/sign_in_view.dart';
import 'package:transport_app/view/menu/earning_view.dart';
import 'package:transport_app/view/menu/rating_view.dart';
import 'package:transport_app/view/menu/service_type_view.dart';
import 'package:transport_app/view/menu/settings_view.dart';
import 'package:transport_app/view/menu/summary_view.dart';
import 'package:transport_app/view/menu/wallet_view.dart';
import 'package:transport_app/view/user/users_my_rides_view.dart';

import '../../common/appLocalizations .dart';
import '../../common/globs.dart';

class MenuView extends StatefulWidget {

  final Map user_data;

  const MenuView({super.key, required this.user_data});

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {

  Map user_data = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    user_data = widget.user_data;

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Container(
              height: context.heigth * 0.27,
              decoration: BoxDecoration(
                color: TColor.primaryText
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            onPressed: (){
                              context.pop();
                            },
                            icon: Icon(Icons.cancel_outlined,size: 30,color: TColor.bg,)
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(Icons.question_mark, size: 30, color: TColor.bg,),
                            Text(
                              AppLocalizations.of(context).translate('help'),
                              style: TextStyle(
                                  color: TColor.primaryTextW,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconTitle(
                            title: AppLocalizations.of(context).translate('earnings'),
                            icon: "./assets/images/earnings.png",
                            onPress: (){
                              if(ServiceCall.userType == 1){
                                context.push(const UserMyRidesView());
                              }else{
                                context.push(const DriverMyRidesView());
                              }
                            }
                        ),
                        InkWell(
                          onTap: (){

                          },
                          child: InkWell(
                            onTap: (){
                              context.push(const RatingView());
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: CachedNetworkImage(
                                        imageUrl: user_data["image"] as String? ?? "",
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.contain,
                                        placeholder: (context, url) => Center(
                                          child: Image.asset(
                                            "assets/images/u1.png",
                                            width: 100,
                                            height: 100,
                                          ) // Loading indicator
                                        ),
                                      ),
                                    ),
                                    // Container(
                                    //   height: 30,
                                    //   padding: const EdgeInsets.symmetric(vertical: 4,horizontal: 8),
                                    //   color: TColor.bg,
                                    //   child: Row(
                                    //     mainAxisSize: MainAxisSize.min,
                                    //     children: [
                                    //       Image.asset("assets/images/rate.png",width: 15,height: 15,),
                                    //       SizedBox(width: 4,),
                                    //       Text(
                                    //         "4.89",
                                    //         style: TextStyle(
                                    //             color: TColor.primaryText,
                                    //             fontSize: 13
                                    //         ),
                                    //       )
                                    //     ],
                                    //   ),
                                    // ),
                                  ],
                                ),
                                SizedBox(height: 4,),
                                Text(
                                  user_data["name"] as String? ?? "",
                                  style: TextStyle(
                                      color: TColor.primaryTextW,
                                      fontSize: 16
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        IconTitle(
                            title: AppLocalizations.of(context).translate('wallet'),
                            icon: "./assets/images/wallet.png",
                            onPress: (){
                              //context.push(const WalletView());
                              mdShowAlert(Globs.appName, AppLocalizations.of(context).translate('soon'), () {

                              });
                            }
                        )
                      ],
                    ),
                  ],
                ),
              )
            ),
          ),
          // InkWell(
          //   onTap: (){
          //     context.push(const ServiceTypeView());
          //   },
          //   child: Container(
          //     color: TColor.lightGray.withOpacity(0.4),
          //     padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 20),
          //     child: Row(
          //       crossAxisAlignment: CrossAxisAlignment.center,
          //       mainAxisAlignment: MainAxisAlignment.spaceAround,
          //       children: [
          //         SizedBox(width: 25),
          //         Image.asset("./assets/images/car.png",width: 30,height: 30,),
          //         SizedBox(width: 25),
          //         Expanded(
          //             child: Column(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 Text(
          //                   "Swith Service type",
          //                   style: TextStyle(
          //                       color: TColor.primaryText,
          //                       fontSize: 18,
          //                       fontWeight: FontWeight.w700
          //                   ),
          //                 ),
          //                 Text(
          //                   "Change your service type",
          //                   style: TextStyle(
          //                       color: TColor.primaryText,
          //                       fontSize: 13
          //                   ),
          //                 )
          //               ],
          //             )
          //         ),
          //         SizedBox(width: 8,),
          //         Icon(Icons.navigate_next,size: 30,)
          //       ],
          //     ),
          //   ),
          // ),
          Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    MenuRow(title: "Home", icon: "./assets/images/home.png", onPress: (){
                
                    }),
                    MenuRow(title: AppLocalizations.of(context).translate('my_rides'), icon: "./assets/images/summary.png", onPress: (){
                      if(ServiceCall.userType == 1){
                        context.push(const UserMyRidesView());
                      }else{
                        context.push(const DriverMyRidesView());
                      }
                    }),
                    MenuRow(title: AppLocalizations.of(context).translate('summary'), icon: "./assets/images/summary.png", onPress: (){
                      context.push(const SummaryView());
                    }),
                    // MenuRow(title: "My Subscription", icon: "./assets/images/my_subscription.png", onPress: (){
                    //
                    // }),
                    // MenuRow(title: "Notifications", icon: "./assets/images/notification.png", onPress: (){
                    //
                    // }),
                    MenuRow(title: AppLocalizations.of(context).translate('settings'), icon: "./assets/images/settings.png", onPress: (){
                      context.push(const SettingsView());
                    }),
                    MenuRow(title: AppLocalizations.of(context).translate('logout'), icon: "./assets/images/logout.png", onPress: (){
                      Globs.udBoolSet(false, Globs.userLogin);
                      Globs.udSet({}, Globs.userPayload);
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const SignInView()),
                          (route) => false
                      );
                    }),
                    const SizedBox(height: 25,)
                  ],
                ),
              )
          ),
        ],
      ),
    );
  }

}
