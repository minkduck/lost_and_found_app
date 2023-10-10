import 'package:flutter/material.dart';

class AppButtonUpLoadImage extends StatelessWidget {
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

  AppButtonUpLoadImage({
    Key? key,
    required this.boxColor,
    required this.textButton,
    required this.onTap,
    this.height = 0,
    this.width = 0,
    this.bottomRight = 0,
    this.topRight = 0,
    this.topLeft = 0,
    this.bottomLeft = 0,
    this.fontSize = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Material(
        color: Colors.transparent, // Set the Material's color to transparent
        child: Ink(
          width: width == 0 ? 150.0 : width,
          height: height == 0 ? 50.0 : height,
          decoration: BoxDecoration(
            color: boxColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(topLeft == 0 ? 15.0 : topLeft),
              topRight: Radius.circular(topRight == 0 ? 15.0 : topRight),
              bottomLeft: Radius.circular(bottomLeft == 0 ? 15.0 : bottomLeft),
              bottomRight:
              Radius.circular(bottomRight == 0 ? 15.0 : bottomRight),
            ),
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
              textButton,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize == 20 ? 20 : fontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
