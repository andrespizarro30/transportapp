import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:transport_app/common/color_extension.dart";

class LineDropDownButton extends StatelessWidget {

  final String title;
  final String hintText;
  final Map? selectVal;
  final String displayKey;
  final List itemArr;
  final Function(dynamic) didChange;

  const LineDropDownButton({super.key, required this.title, required this.hintText, required this.didChange, this.selectVal, required this.displayKey, required this.itemArr});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
            title,
            style: TextStyle(
                color: TColor.placeholder,
                fontSize: 12
            )
        ),
        SizedBox(height: 4,),

        DropdownButton(
          isExpanded: true,
          hint: Text(
            hintText,
            style: TextStyle(
              color: TColor.secondaryText,
              fontSize: 16
            ),
          ),
          value: selectVal != null ? selectVal : null,
          items: itemArr.map((itemObj){
            return DropdownMenuItem(
              value: itemObj,
              child: Text(itemObj[displayKey] as String? ?? ""),
            );
          }).toList(),
          onChanged: didChange,
        ),

      ],
    );
  }
}