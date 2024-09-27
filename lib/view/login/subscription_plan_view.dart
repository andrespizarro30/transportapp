import "package:flutter/material.dart";
import "package:transport_app/common/color_extension.dart";
import "package:transport_app/common_widget/line_text_field.dart";
import "package:transport_app/common_widget/plan_row.dart";
import "package:transport_app/common_widget/round_button.dart";
import "package:transport_app/view/login/document_upload_view.dart";

class SubscriptionPlanView extends StatefulWidget {
  const SubscriptionPlanView({super.key});

  @override
  State<SubscriptionPlanView> createState() => _SubscriptionPlanViewState();
}

class _SubscriptionPlanViewState extends State<SubscriptionPlanView> {

  List planArr = [
    {
      "name":"Basic Plan",
      "time":"1 Month",
      "rides":"• 10 viajes por dia",
      "cash_rides":"• 2 viajes en efectivo",
      "km": "• 50 km en viajes",
      "price": "TRY FREE"
    },
    {
      "name":"Classic Plan",
      "time":"3 Month",
      "rides":"• 10 viajes por dia",
      "cash_rides":"• 2 viajes en efectivo",
      "km": "• 50 km en viajes",
      "price": "COMPRA POR \$119.000"
    },
  ];
  
  
  @override
  void initState() {
    super.initState();

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

        title: Text("Plan de Suscripcion", 
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 25,
            fontWeight: FontWeight.w800            
            ),
          ),
      ),
      backgroundColor: TColor.bg,
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
        itemCount: planArr.length,
        itemBuilder: (context,index){
          var pObj = planArr[index] as Map? ?? {};
          return PlanRow(pObj: pObj, onPressed: (){

          });

        }
      )

    );
  }
  

}