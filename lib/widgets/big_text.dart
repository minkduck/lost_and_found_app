import 'package:flutter/material.dart';
import 'package:lost_and_find_app/utils/app_styles.dart';

import '../utils/app_layout.dart';

class BigText extends StatelessWidget {
  Color color;
  final String text;
  double size;
  TextOverflow overflow;
  FontWeight fontW;
  BigText({Key? key,
    this.color = const Color(0xFF332d2b),
    required this.text,
    this.size = 0,
    this.overflow = TextOverflow.ellipsis,
    this.fontW = FontWeight.w400
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: overflow,
      style: TextStyle(
        color: color,
        fontSize: size == 0?AppLayout.getHeight(20):size,
        fontFamily: FontFamily.proxima,
        fontWeight: fontW == FontWeight.w400? FontWeight.w400:fontW
      ),
    );
  }
}
