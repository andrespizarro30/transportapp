import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:transport_app/common_widget/timer_frame.dart';

import '../common/color_extension.dart';

class TimerBasic extends StatelessWidget {
  final CountDownTimerFormat format;
  final bool inverted;

  final int minutes;
  final int seconds;

  TimerBasic({
    required this.format,
    this.inverted = false,
    Key? key,
    required this.minutes,
    required this.seconds,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TimerCountdown(
      format: format,
      endTime: DateTime.now().add(
        Duration(
          minutes: minutes,
          seconds: seconds,
        ),
      ),
      onEnd: () {

      },
      timeTextStyle: TextStyle(
        color: TColor.secondary,
        fontWeight: FontWeight.w300,
        fontSize: 40,
        fontFeatures: <FontFeature>[
          FontFeature.tabularFigures(),
        ],
      ),
      colonsTextStyle: TextStyle(
        color: TColor.secondary,
        fontWeight: FontWeight.w300,
        fontSize: 40,
        fontFeatures: <FontFeature>[
          FontFeature.tabularFigures(),
        ],
      ),
      descriptionTextStyle: TextStyle(
        color: TColor.secondary,
        fontSize: 10,
        fontFeatures: <FontFeature>[
          FontFeature.tabularFigures(),
        ],
      ),
      spacerWidth: 0,
      minutesDescription: "",
      secondsDescription: "",
    );
  }
}