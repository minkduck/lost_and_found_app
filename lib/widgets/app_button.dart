import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/app_layout.dart';
import '../utils/colors.dart';

class AppButton extends StatelessWidget {
  final Color boxColor;
  final String textButton;
  final VoidCallback onTap;
  double height;
  double width;
  double topLeft;
  double topRight;
  double bottomLeft;
  double bottomRight;
  double fontSize;

  AppButton(
      {Key? key,
      required this.boxColor,
      required this.textButton,
      required this.onTap,
      this.height = 0,
      this.width = 0,
      this.bottomRight = 0,
      this.topRight = 0,
      this.topLeft = 0,
      this.bottomLeft = 0,
      this.fontSize = 20})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Ink(
        width: width == 0 ? AppLayout.getWidth(325) : AppLayout.getWidth(width),
        height:
            height == 0 ? AppLayout.getHeight(50) : AppLayout.getHeight(height),
        decoration: BoxDecoration(
          color: boxColor, // Set the color here
          // borderRadius: BorderRadius.circular(AppLayout.getHeight(15)),
          borderRadius: BorderRadius.only(
              topLeft: topLeft == 0
                  ? Radius.circular(AppLayout.getHeight(15))
                  : Radius.circular(AppLayout.getHeight(topLeft)),
              topRight: topRight == 0
                  ? Radius.circular(AppLayout.getHeight(15))
                  : Radius.circular(AppLayout.getHeight(topRight)),
              bottomLeft: bottomLeft == 0
                  ? Radius.circular(AppLayout.getHeight(15))
                  : Radius.circular(AppLayout.getHeight(bottomLeft)),
              bottomRight: bottomRight == 0
                  ? Radius.circular(AppLayout.getHeight(15))
                  : Radius.circular(AppLayout.getHeight(bottomRight))),

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
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize == 20 ? 20 : fontSize,
            ),
          ),
        ),
      ),
    );
  }
}
