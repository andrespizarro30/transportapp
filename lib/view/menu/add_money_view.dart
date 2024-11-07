import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transport_app/common_widget/bank_row.dart';
import 'package:transport_app/common_widget/round_button.dart';
import 'package:transport_app/common_widget/tag_button.dart';

import '../../common/appLocalizations .dart';
import '../../common/color_extension.dart';

class AddMoneyView extends StatefulWidget {
  const AddMoneyView({super.key});

  @override
  State<AddMoneyView> createState() => _AddMoneyViewState();
}

class _AddMoneyViewState extends State<AddMoneyView> {

  TextEditingController txtAdd = TextEditingController();

  @override
  void initState() {
    super.initState();
    txtAdd.text="48";
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
          icon: Image.asset("./assets/images/back.png",width: 25,height: 25,),
        ),
        centerTitle: true,
        title: Text(AppLocalizations.of(context).translate('add_money_to_wallet'),
          style: TextStyle(
              color: TColor.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w800
          ),
        ),
      ),
      body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    width: double.maxFinite,
                    height: 15,
                    color: TColor.lightWhite
                ),
                const SizedBox(height: 15,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context).translate('available_balance'),
                        style: TextStyle(
                            color: TColor.secondaryText,
                            fontSize: 16
                        ),
                      ),
                      Text("54.57",
                        style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 16
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset("./assets/images/dollar.png",width: 25,height: 25,),
                      const SizedBox(width: 9,),
                      Expanded(
                        child: TextField(
                          controller: txtAdd,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 25,
                              fontWeight: FontWeight.w800
                          ),
                          decoration: InputDecoration(
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              hintText: AppLocalizations.of(context).translate('enter_add_wallet_amount'),
                              hintStyle: TextStyle(color: TColor.placeholder, fontSize:  18,fontWeight: FontWeight.w800)
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TagButton(title: "+\$10", onPressed: (){}),
                        TagButton(title: "+\$20", onPressed: (){}),
                        TagButton(title: "+\$50", onPressed: (){}),
                        TagButton(title: "+\$100", onPressed: (){}),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15,),
                Container(
                    width: double.maxFinite,
                    height: 12,
                    color: TColor.lightWhite
                ),
                const SizedBox(height: 15,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context).translate('from_bank_account'),
                        style: TextStyle(
                            color: TColor.secondaryText,
                            fontSize: 16
                        ),
                      ),
                      Icon(Icons.navigate_next,size: 30,)
                    ],
                  ),
                ),
                const SizedBox(height: 15,),

                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                  itemBuilder: (context, index){
                    return const BankRow(wObj: {
                      "icon":"./assets/images/bank_logo.png",
                      "name":"Standard Chartered Bank",
                      "number":"**** 3315"
                    });
                  },
                  separatorBuilder: (context, index)=> const Divider(),
                  itemCount: 1
                ),

                const SizedBox(height: 15,),
                Container(
                    width: double.maxFinite,
                    height: 12,
                    color: TColor.lightWhite
                ),
                const SizedBox(height: 15,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: RoundButton(title: AppLocalizations.of(context).translate('submit_request'), onPressed: (){}),
                ),
                const SizedBox(height: 15,),
              ]
          )
      ),
    );
  }
}
