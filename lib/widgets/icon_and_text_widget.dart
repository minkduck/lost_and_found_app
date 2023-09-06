import 'package:flutter/material.dart';
import 'package:lost_and_find_app/widgets/small_text.dart';
import 'package:gap/gap.dart';

import '../utils/app_layout.dart';

class IconAndTextWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  const IconAndTextWidget(
      {Key? key,
      required this.icon,
      required this.text,
      required this.iconColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: AppLayout.getHeight(24),),
        const Gap(5),
        SmallText(text: text,)
      ],
    );
  }
}
