
import 'package:flutter/material.dart';

class ServiceValueAdded extends StatelessWidget {

  final String value;

  const ServiceValueAdded({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 3,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "+\$$value",
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700),
      ),
    );
  }
}
