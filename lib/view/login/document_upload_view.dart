import "dart:io";

import "package:flutter/material.dart";
import "package:transport_app/common/color_extension.dart";
import "package:transport_app/common/common_extension.dart";
import "package:transport_app/common_widget/document_row.dart";
import "package:transport_app/common_widget/image_picker_view.dart";
import "package:transport_app/common_widget/line_text_field.dart";
import "package:transport_app/common_widget/popup_layout.dart";
import "package:transport_app/common_widget/round_button.dart";
import "package:transport_app/view/login/add_vehicle_view.dart";

import "../../common/appLocalizations .dart";
import "../../common/globs.dart";
import "../../common/service_call.dart";


class DocumentUploadView extends StatefulWidget {

  final String title;

  const DocumentUploadView({super.key, required this.title});

  @override
  State<DocumentUploadView> createState() => _DocumentUploadViewState();
}

class _DocumentUploadViewState extends State<DocumentUploadView> {

  List documentList = [];

  bool isApiData = false;
   
  @override
  void initState() {
    super.initState();

    apiDocumentList();

  }

  
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
          icon: Image.asset("assets/images/back.png",
            width: 20,
            height: 20, 
          ),
        ),
        centerTitle: true,

        title: Text(widget.title, 
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 25,
            fontWeight: FontWeight.w800            
            ),
          ),
      ),
      body: !isApiData ?
      Center(child: Text(
        AppLocalizations.of(context).translate('loading') + "...",
          style: TextStyle(
              color: TColor.primaryText,
              fontSize: 25,
              fontWeight: FontWeight.w700
          ),
        ),
        ) : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
               
              const SizedBox(height: 30,),

              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index){

                  var dObj = documentList[index] as Map? ?? {};

                  return DocumentRow(
                    dObj: dObj, 
                    onPressed: (){

                    }, 
                    onInfo: (){
                      showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        context: context, 
                        builder: (context){
                          return Container(
                            width: context.width,
                            height: context.heigth - 100,
                            margin: const EdgeInsets.symmetric(vertical: 46, horizontal: 20),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 3
                                )
                              ]
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(dObj["name"] as String? ?? "",
                                style: TextStyle(
                                  color: TColor.primaryText,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800            
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.", 
                                    style: TextStyle(
                                      color: TColor.primaryText,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800            
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: (){
                                        context.pop();
                                      }, 
                                      child: Text(
                                        AppLocalizations.of(context).translate('upload'),
                                        style: TextStyle(
                                          color: TColor.primary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700
                                        ),
                                      )
                                    )
                                  ],
                                )
                              ],
                              ),
                          );
                        }
                      );                      
                    }, 
                    onUpload: () async{
                      await Navigator.push(
                          context,
                          PopupLayout(
                            child: ImagePickerView(
                              didSelect: (imagePath){
                                var image = File(imagePath);

                                apiUploadDoc(
                                    {
                                      "doc_id" : dObj["doc_id"].toString(),
                                      "zone_doc_id" : dObj["zone_doc_id"].toString(),
                                      "user_car_id" : "",
                                      "expriry_date" : DateTime.now().add(const Duration(days: 365)).stringFormat()
                                    },
                                    {
                                      "image" : image
                                    }
                                );
                              },
                            )
                          )
                      );
                    }, 
                    onAction: (){
                      
                    },
                  );
                }, 
                itemCount: documentList.length
              ),

              const SizedBox(height: 15,),
        
              RoundButton(title: AppLocalizations.of(context).translate('next'), onPressed: (){
                context.push(const AddVehicleView());        
              })
              
              
            ],
          ),
        ),
      ),

    );
  }

  void apiDocumentList(){
    Globs.showHUD();
    ServiceCall.post(
        {},
        isTokenApi: true,
        SVKey.svPersonalDocumentList,
        withSuccess: (responseObj)async{
          Globs.hideHUD();
          if(responseObj[KKey.status] == "1"){
            documentList = responseObj[KKey.payload] as List? ?? [];
            isApiData = true;
            if(mounted){
              setState(() {});
            }
          }else{
            mdShowAlert(AppLocalizations.of(context).translate('error'), responseObj[KKey.message] as String? ?? MSG.fail,(){});
          }
        },
        failure: (err)async{
          Globs.hideHUD();
          debugPrint(err.toString());
        }
    );
  }

  void apiUploadDoc(Map<String,String> parameter, Map<String, File> imgObj){
    Globs.showHUD();
    ServiceCall.multiPart(
        parameter,
        imgObj: imgObj,
        isTokenApi: true,
        SVKey.svDriverUpdateDocument,
        withSuccess: (responseObj)async{
          Globs.hideHUD();
          if(responseObj[KKey.status] == "1"){
            mdShowAlert(AppLocalizations.of(context).translate('success'), responseObj[KKey.message] as String? ?? MSG.success, () { });
            apiDocumentList();
          }else{
            mdShowAlert(AppLocalizations.of(context).translate('error'), responseObj[KKey.message] as String? ?? MSG.fail,(){});
          }
        },
        failure: (err)async{
          Globs.hideHUD();
          debugPrint(err.toString());
        }
    );
  }

}