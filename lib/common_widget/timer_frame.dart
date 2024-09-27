import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const Color purple = Color.fromARGB(255, 63, 45, 149);

class TimerFrame extends StatelessWidget {
  final String description;
  final Widget timer;
  final bool inverted;

  const TimerFrame({
    required this.description,
    required this.timer,
    this.inverted = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(
        vertical: 1,
      ),
      child: Column(
        children: [
          timer,
        ],
      ),
    );
  }
}