import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/widgets/big_text.dart';

import '../../utils/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Gap(AppLayout.getHeight(20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: BigText(
                    text: "Home",
                    size: 20,
                    color: AppColors.secondPrimaryColor,
                    fontW: FontWeight.w500,
                  ),
                ),
                Container(
                  child: Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 40,
                  ),
                )
              ],
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: BigText(
                text: "Items",
                size: 30,
                fontW: FontWeight.w600,
              ),
            ),
            Gap(AppLayout.getHeight(25)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                BigText(
                  text: "All",
                  size: 17,
                  color: AppColors.primaryColor,
                  fontW: FontWeight.w500,
                ),
                BigText(
                  text: "Moblie",
                  size: 17,
                  color: AppColors.secondPrimaryColor,
                  fontW: FontWeight.w500,
                ),
                BigText(
                  text: "Documents",
                  size: 17,
                  color: AppColors.secondPrimaryColor,
                  fontW: FontWeight.w500,
                ),
                BigText(
                  text: "Laptop",
                  size: 17,
                  color: AppColors.secondPrimaryColor,
                  fontW: FontWeight.w500,
                ),

              ],
            ),
            Gap(AppLayout.getHeight(25)),

          ],
        ),
      ),
    );
  }
}
