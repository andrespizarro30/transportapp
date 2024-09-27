import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transport_app/common_widget/wallet_row.dart';
import 'package:transport_app/view/menu/add_money_view.dart';

import '../../common/color_extension.dart';

class WalletView extends StatefulWidget {
  const WalletView({super.key});

  @override
  State<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {

  List walletArr = [
    {
      "icon": "./assets/images/trips_cut.png",
      "name": "Trip deducted",
      "time": "1 Feb 19 • #1234567",
      "price": "\$30"
    },
    {
      "icon": "./assets/images/withdraw.png",
      "name": "Withdraw wallet",
      "time": "1 Feb 19 • #1234567",
      "price": "\$20"
    },
    {
      "icon": "./assets/images/wallet_add.png",
      "name": "Added to wallet",
      "time": "1 Feb 19 • #1234567",
      "price": "\$50"
    },
    {
      "icon": "./assets/images/trips_cut.png",
      "name": "Trip deducted",
      "time": "1 Feb 19 • #1234567",
      "price": "\$30"
    },
    {
      "icon": "./assets/images/withdraw.png",
      "name": "Withdraw wallet",
      "time": "1 Feb 19 • #1234567",
      "price": "\$20"
    },
    {
      "icon": "./assets/images/wallet_add.png",
      "name": "Added to wallet",
      "time": "1 Feb 19 • #1234567",
      "price": "\$50"
    },
    {
      "icon": "./assets/images/trips_cut.png",
      "name": "Trip deducted",
      "time": "1 Feb 19 • #1234567",
      "price": "\$30"
    },
    {
      "icon": "./assets/images/withdraw.png",
      "name": "Withdraw wallet",
      "time": "1 Feb 19 • #1234567",
      "price": "\$20"
    },
    {
      "icon": "./assets/images/wallet_add.png",
      "name": "Added to wallet",
      "time": "1 Feb 19 • #1234567",
      "price": "\$50"
    },
    {
      "icon": "./assets/images/trips_cut.png",
      "name": "Trip deducted",
      "time": "1 Feb 19 • #1234567",
      "price": "\$30"
    },
    {
      "icon": "./assets/images/withdraw.png",
      "name": "Withdraw wallet",
      "time": "1 Feb 19 • #1234567",
      "price": "\$20"
    },
    {
      "icon": "./assets/images/wallet_add.png",
      "name": "Added to wallet",
      "time": "1 Feb 19 • #1234567",
      "price": "\$50"
    },
  ];

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
        title: Text("Wallet",
          style: TextStyle(
              color: TColor.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w800
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                width: double.maxFinite,
                height: 12,
                color: TColor.lightWhite
            ),
            const SizedBox(height: 10,),
            Text("Total balance",
              style: TextStyle(
                  color: TColor.secondaryText,
                  fontSize: 16
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("\$",
                  style: TextStyle(
                      color: TColor.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800
                  ),
                ),
                Text("54.57",
                  style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 25,
                      fontWeight: FontWeight.w800
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              height: 0.5,
              color: TColor.lightGray,
              width: double.maxFinite,
            ),
            Row(
              children: [
                Expanded(
                    child: TextButton(
                      onPressed: () {

                      },
                      child: Text(
                        "WITHDRAW",
                        style: TextStyle(
                          color: TColor.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800
                        ),
                      ),
                    )
                ),
                Container(
                  width: 0.5,
                  height: 55,
                  color: TColor.lightGray,
                ),
                Expanded(
                    child: TextButton(
                      onPressed: () {
                        context.push(const AddMoneyView());
                      },
                      child: Text(
                        "ADD MONEY",
                        style: TextStyle(
                            color: TColor.primary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800
                        ),
                      ),
                    )
                )
              ],
            ),
            Container(
                width: double.maxFinite,
                height: 12,
                color: TColor.lightWhite
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              width: double.maxFinite,
              color: TColor.lightWhite,
              child: Text("APRIL 2023",
                style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w800
                ),
              ),
            ),
            ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                itemBuilder: (context, index){
                  var iObj = walletArr[index] as Map ?? {};
                  return WalletRow(wObj: iObj);
                },
                separatorBuilder: (context, index)=>const Divider(indent: 50,),
                itemCount: walletArr.length
            )
          ],
        ),
      ),
    );
  }
}
