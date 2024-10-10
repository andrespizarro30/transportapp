import 'package:flutter/material.dart';

void userForeGroundNotification(String message, BuildContext context,{bool isError=true,String title="Transport App", Color backgroundColor = Colors.blueAccent}){

  ScaffoldMessenger.of(context).showMaterialBanner(
    MaterialBanner(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            message,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor, // Set the background color
      leading: Icon(Icons.info, color: Colors.white),
      actions: [
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
          },
          child: Text(
            'OK',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );

  Future.delayed(Duration(seconds: 5), () {
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
  });

  // ScaffoldMessenger.of(context).showSnackBar(
  //   SnackBar(
  //     content: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Text(
  //           title,
  //           style: TextStyle(
  //             fontWeight: FontWeight.bold,
  //             color: Colors.white,
  //             fontSize: 16.0,
  //           ),
  //         ),
  //         SizedBox(height: 4),
  //         Text(
  //           message,
  //           style: TextStyle(
  //             color: Colors.white,
  //             fontSize: 14.0,
  //           ),
  //         ),
  //       ],
  //     ),
  //     backgroundColor: backgroundColor,
  //     behavior: SnackBarBehavior.floating, // Positions the SnackBar
  //     margin: EdgeInsets.all(10.0), // Adds margin around SnackBar
  //     duration: Duration(seconds: 3), // Time before it disappears
  //   ),
  // );

}

