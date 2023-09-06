import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/app_layout.dart';
import '../utils/colors.dart';

class AppButton extends StatelessWidget {
  final Color boxColor;
  final String textButton;
  final VoidCallback onTap;
  AppButton({Key? key, required this.boxColor, required this.textButton, required this.onTap}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        width: AppLayout.getWidth(325),
        height: AppLayout.getHeight(50),
        decoration: BoxDecoration(
          color: boxColor, // Set the color here
          borderRadius: BorderRadius.circular(AppLayout.getHeight(15)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: Offset(0, 1),
            )
          ],
        ),
        child: Center(
          child: Text(
            textButton,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 20, ),
          ),
        ),
      ),
    );
  }

}