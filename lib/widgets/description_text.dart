import 'package:flutter/material.dart';

class DescriptionText extends StatelessWidget {
  Color color;
  final String text;
  double size;
  double height;
  DescriptionText({Key? key,
    this.color = const Color(0xFFccc7c5),
    required this.text,
    this.size = 12,
    this.height = 1.2
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          color: color,
          fontSize: size,
          fontFamily: 'Roboto'
      ),
    );
  }
}
