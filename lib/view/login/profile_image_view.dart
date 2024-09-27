import "dart:io";

import "package:flutter/material.dart";
import "package:path_provider/path_provider.dart";
import "package:transport_app/common/color_extension.dart";
import "package:transport_app/common/common_extension.dart";
import "package:transport_app/common/globs.dart";
import "package:transport_app/common/service_call.dart";
import "package:transport_app/common_widget/image_picker_view.dart";
import "package:transport_app/common_widget/popup_layout.dart";
import "package:transport_app/common_widget/round_button.dart";

import 'package:http/http.dart' as http;
import "package:transport_app/view/login/driver_edit_profile_view.dart";
import "package:transport_app/view/menu/edit_profile_view.dart";

class ProfileImageView extends StatefulWidget {

  final bool showBack;

  const ProfileImageView({super.key, this.showBack = true});

  @override
  State<ProfileImageView> createState() => _ProfileImageViewState();
}

class _ProfileImageViewState extends State<ProfileImageView> {

  File? image;

  @override
  void initState() {
    super.initState();
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      loadImage();
    });*/
  }

/*  void loadImage() async{
    Map userPayload = Globs.udValue(Globs.userPayload);
    if(userPayload != null){
      if(userPayload["image"] != null && userPayload["image"] != ""){
        image = await downloadFile(userPayload["image"] as String,"ImageProfile");
        setState(() {

        });
      }
    }
  }*/


  @override
  Widget build(BuildContext context) {



    return Scaffold(

      appBar: AppBar(
        backgroundColor: TColor.bg,
        elevation: 1,
        leading: widget.showBack ? IconButton(
          onPressed: (){
            context.pop();
          },
          icon: Image.asset("assets/images/back.png",
            width: 20,
            height: 20,
          ),
        ): null,
        centerTitle: true,

        title: Text("Profile Image",
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

              const SizedBox(height: 50,),

              InkWell(
                onTap: () async{
                  await Navigator.push(context, PopupLayout(child: ImagePickerView(didSelect: (imagePath) async{
                    image = File(imagePath);
                    await serviceCall({"image":image!});
                    setState(() {

                    });

                  },),),);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: const[
                      BoxShadow(color: Colors.black26,blurRadius: 10)
                    ]
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: image != null ?
                    Image.file(image!, width: 200, height: 200,fit: BoxFit.cover,) :
                    Icon(Icons.person,size: 200,color: TColor.secondaryText),
                  ),
                ),
              ),

              const SizedBox(height: 50,),

              RoundButton(
                title: "NEXT",
                onPressed: (){
                  if(ServiceCall.userType == 2){
                    context.push(const DriverEditProfileView());
                  }else{
                    context.push(const EditProfileView());
                  }
                }
              )

            ],
          ),
        ),
      ),

    );
  }

  Future<void> serviceCall(Map<String,File> imagePara) async{
    Globs.showHUD();
    ServiceCall.multiPart(
        {},
        SVKey.svProfileImageUpload,
        isTokenApi: true,
        imgObj: imagePara,
        withSuccess: (responseObj) async{
          if((responseObj[KKey.status] ?? "")=="1"){
            Globs.hideHUD();
            ServiceCall.userObj = responseObj[KKey.payload] as Map? ?? {};
            Globs.udSet(ServiceCall.userObj, Globs.userPayload);
            mdShowAlert("",responseObj[KKey.message] ?? MSG.success,(){});
          }else{
            Globs.hideHUD();
            mdShowAlert("Error",responseObj[KKey.message] ?? MSG.fail,(){});
          }
        },
        failure: (err) async{
          Globs.hideHUD();
          mdShowAlert("Error", err,(){});
        }
    );
  }

/*  Future<File> downloadFile(String url, String fileName) async {
    final response = await http.get(Uri.parse(url));
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    return file.writeAsBytes(response.bodyBytes);
  }*/

}