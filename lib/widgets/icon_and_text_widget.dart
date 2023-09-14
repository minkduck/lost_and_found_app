import 'package:flutter/material.dart';
import 'package:lost_and_find_app/widgets/small_text.dart';
import 'package:gap/gap.dart';

import '../utils/app_layout.dart';

class IconAndTextWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  Color textColor;
  double size;

  IconAndTextWidget(
      {Key? key,
      required this.icon,
      required this.text,
      required this.iconColor,
      this.textColor = const Color(0xFF2A2D64),
      this.size = 17})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).iconTheme.color,
          size: AppLayout.getHeight(24),
        ),
        const Gap(5),
        SmallText(
          text: text,
          color: textColor == const Color(0xFF2A2D64)
              ? const Color(0xFF2A2D64)
              : textColor,
          size: size == 17 ? 17 : size,
        ),
      ],
    );
  }
}
