import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../common/color_extension.dart';

class RatingRow extends StatelessWidget {

  final Map rObj;

  const RatingRow({super.key, required this.rObj});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rObj["rate"].toString() as String? ?? "0.0",
            style: TextStyle(
                color: TColor.primaryText,
                fontSize: 25,
                fontWeight: FontWeight.w800
            ),
          ),
          RatingBar.builder(
            initialRating: rObj["rate"] as double? ?? 5.0,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 20,
            itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.green,
            ),
            onRatingUpdate: (rating) {
              print(rating);
            },
          ),
          if((rObj["message"] as String? ?? "") != "")
            Text(
              rObj["message"],
              style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 15,
                  fontWeight: FontWeight.w800
              ),
            ),
        ],
      ),
    );
  }
}
