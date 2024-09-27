import "dart:ui";

import "package:flutter/material.dart";
import "package:transport_app/common/color_extension.dart";

enum RoundButtonType{
  primary,
  secondary,
  red,
  boarded
}

class RoundButton extends StatelessWidget {

  final String title;
  final RoundButtonType buttonType;
  final VoidCallback onPressed;

  const RoundButton({super.key, required this.title, required this.onPressed,this.buttonType = RoundButtonType.primary});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      minWidth: double.maxFinite,
      elevation: 0,
      color: buttonType == RoundButtonType.primary ?
              TColor.primary :
              buttonType == RoundButtonType.secondary ?
              TColor.secondary :
              buttonType == RoundButtonType.red ?
              Colors.redAccent :
              Colors.transparent,
      height: 45,
      shape: RoundedRectangleBorder(
        side: buttonType == RoundButtonType.boarded ? BorderSide(color: TColor.secondary) : BorderSide.none,
        borderRadius: BorderRadius.circular(25)
      ),
      child: Text(
        title,
        style: TextStyle(
          color: buttonType == RoundButtonType.boarded ? TColor.secondary : TColor.primaryTextW,
          fontSize: 19
        ),
      ),
    );
  }
}