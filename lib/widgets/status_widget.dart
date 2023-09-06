import 'package:flutter/material.dart';

import '../utils/app_layout.dart';

class StatusWidget extends StatelessWidget {
  final Color color;
  final String text;
  double height;
  double width;

  StatusWidget(
      {super.key,
      required this.text,
      required this.color,
      this.height = 0,
      this.width = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width == 0 ? AppLayout.getWidth(100) : AppLayout.getWidth(width),
      height: height == 0 ? AppLayout.getHeight(45) : AppLayout.getHeight(height),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppLayout.getHeight(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
