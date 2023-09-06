import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/utils/app_assets.dart';
import 'package:lost_and_find_app/widgets/status_widget.dart';

import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../widgets/big_text.dart';

class ItemsDetails extends StatefulWidget {
  const ItemsDetails({super.key});

  @override
  State<ItemsDetails> createState() => _ItemsDetailsState();
}

class _ItemsDetailsState extends State<ItemsDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
          children: [
            Gap(AppLayout.getHeight(20)),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    // Handle the back button tap
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.grey,
                    size: 30,
                  ),
                ),
                BigText(
                  text: "Items",
                  size: 20,
                  color: AppColors.secondPrimaryColor,
                  fontW: FontWeight.w500,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 10),
              child: BigText(
                text: "Items Details",
                size: 30,
                fontW: FontWeight.w600,
              ),
            ),
            Gap(AppLayout.getHeight(20)),
            Container(
              margin: EdgeInsets.only(left: AppLayout.getWidth(20)),
              height: AppLayout.getHeight(350),
              width: AppLayout.getWidth(350),
              child: Image.asset(AppAssets.airpods, fit: BoxFit.fill),
            ),
            Gap(AppLayout.getHeight(20)),
            Container(
              padding: EdgeInsets.only(left: AppLayout.getWidth(20)),
                child: StatusWidget(text: "Found", color: Colors.grey))
          ],
        ),
      ),
    );
  }
}

