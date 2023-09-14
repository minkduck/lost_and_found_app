import 'package:flutter/material.dart';
import 'package:lost_and_find_app/utils/app_styles.dart';

class SmallText extends StatelessWidget {
  Color color;
  final String text;
  double size;
  double height;
  SmallText({Key? key,
    this.color = const Color(0xFF2A2D64),
    required this.text,
    this.size = 17,
    this.height = 1.2
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall,
    );
  }
}
