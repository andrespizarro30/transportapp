import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:transport_app/common_widget/car_documents_row.dart';

import '../../common/color_extension.dart';

class MyCarDetails extends StatefulWidget {

  final Map cObj;

  const MyCarDetails({super.key, required this.cObj});

  @override
  State<MyCarDetails> createState() => _MyCarDetailsState();
}

class _MyCarDetailsState extends State<MyCarDetails> {
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
          icon: CachedNetworkImage(imageUrl: widget.cObj["car_image"] as String? ?? "",width: 50,height: 50,fit: BoxFit.cover,)
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(widget.cObj["brand_name"],
              style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w800
              ),
            ),
            Text(widget.cObj["car_number"],
              style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w800
              ),
            ),
          ],
        )
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CarDocumentRow(title: "Vehicle Registration", date: "Expires in 2024-11-10", status: "APPROVED", statusColor: Colors.green,onPressed:(){

            }),
            CarDocumentRow(title: "Vehicle Insurance", date: "Expires in 2025-06-05", status: "APPROVED", statusColor: Colors.green,onPressed:(){

            }),
            CarDocumentRow(title: "Vehicle Permit", date: "Incorrect document typed", status: "NOT APPROVED", statusColor: Colors.red,onPressed:(){

            })
          ],
        ),
      ),
    );
  }
}
