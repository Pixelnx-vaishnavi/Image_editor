import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomWidgetScreen extends StatelessWidget {
  const CustomWidgetScreen({super.key});

  Widget buildToolButton(String label, String image) {
    return Column(
      // mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
            height: 22,child: Image.asset(image)),
        // Icon(icon, color: Colors.white, size: 28),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
              color: Colors.white, fontSize: 12, fontFamily: 'Outfit'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
