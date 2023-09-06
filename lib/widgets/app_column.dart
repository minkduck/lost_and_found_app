import 'package:flutter/material.dart';

import 'package:gap/gap.dart';
import 'package:lost_and_find_app/widgets/small_text.dart';

import '../utils/app_layout.dart';
import '../utils/colors.dart';
import 'big_text.dart';
import 'icon_and_text_widget.dart';

class AppColumn extends StatelessWidget {
  final String text;
  const AppColumn({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BigText(text: text,size: AppLayout.getHeight(26),),
        Gap(AppLayout.getHeight(10)),
        Row(
          children: [
            Wrap(
              children: List.generate(
                5,
                    (index) => Icon(
                  Icons.star,
                  color: AppColors.mainColor,
                  size: 16,
                ),
              ),
            ),
            const Gap(10),
            SmallText(text: "4.5"),
            const Gap(10),
            SmallText(text: "1287"),
            const Gap(10),
            SmallText(text: "comments")
          ],
        ),
        Gap(AppLayout.getHeight(20)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconAndTextWidget(
              icon: Icons.circle_sharp,
              text: 'Normal',
              iconColor: AppColors.iconColor1,
            ),
            IconAndTextWidget(
              icon: Icons.location_on,
              text: '1.7km',
              iconColor: AppColors.mainColor,
            ),
            IconAndTextWidget(
              icon: Icons.access_time_rounded,
              text: '32min',
              iconColor: AppColors.iconColor2,
            ),
          ],
        )
      ],
    );
  }
}
