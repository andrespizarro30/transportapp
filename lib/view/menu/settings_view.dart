import 'package:flutter/material.dart';
import 'package:transport_app/common_widget/setting_row.dart';
import 'package:transport_app/view/home/support/support_list_view.dart';
import 'package:transport_app/view/login/bank_details_view.dart';
import 'package:transport_app/view/login/document_upload_view.dart';
import 'package:transport_app/view/menu/change_password_view.dart';
import 'package:transport_app/view/menu/contact_us_view.dart';
import 'package:transport_app/view/menu/edit_profile_view.dart';
import 'package:transport_app/view/menu/my_profile_view.dart';
import 'package:transport_app/view/menu/my_vehicle_view.dart';

import '../../common/color_extension.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
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
          icon: Image.asset("./assets/images/back.png",width: 25,height: 25,),
        ),
        centerTitle: true,
        title: Text("Settings",
          style: TextStyle(
              color: TColor.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w800
          ),
        ),
      ),
      backgroundColor: TColor.lightWhite,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8,),
              SettingRow(title: "My profile", icon: "./assets/images/sm_profile.png", onPressed: (){
                context.push(const MyProfile());
              }),
              SettingRow(title: "My Vehicle", icon: "./assets/images/sm_vehicle.png", onPressed: (){
                context.push(const MyVehicleView());
              }),
              SettingRow(title: "Personal Documents", icon: "./assets/images/sm_documents.png", onPressed: (){
                context.push(const DocumentUploadView(title: "Personal Document"));
              }),
              SettingRow(title: "Bank Detail", icon: "./assets/images/sm_bank.png", onPressed: (){
                context.push(const BankDetailsView());
              }),
              SettingRow(title: "Change Password", icon: "./assets/images/sm_password.png", onPressed: (){
                context.push(const ChangePasswordView());
              }),
              const SizedBox(height: 15,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text("Help",
                  style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.w800
                  ),
                ),
              ),
              SettingRow(title: "Terms & Conditions", icon: "./assets/images/documents.png", onPressed: (){

              }),
              SettingRow(title: "Privacy Policies", icon: "./assets/images/documents.png", onPressed: (){

              }),
              SettingRow(title: "About", icon: "./assets/images/documents.png", onPressed: (){

              }),
              SettingRow(title: "Contact Us", icon: "./assets/images/sm_profile.png", onPressed: (){
                context.push(const ContactUsView());
              }),
              SettingRow(title: "Support", icon: "./assets/images/sm_profile.png", onPressed: (){
                context.push(const SupportListView());
              }),
            ],
          ),
        ),
      ),
    );
  }
}
