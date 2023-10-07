import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/pages/items/items_detail.dart';
import 'package:lost_and_find_app/utils/colors.dart';
import 'package:lost_and_find_app/widgets/app_button.dart';
import 'package:lost_and_find_app/widgets/status_widget.dart';

import '../../utils/app_assets.dart';
import '../../utils/app_layout.dart';
import '../../widgets/icon_and_text_widget.dart';

class ItemsGird extends StatelessWidget {
  final String id;
  final String title;

  ItemsGird(this.id, this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: AppLayout.getHeight(151),
            width: AppLayout.getWidth(180),
            child: Image.asset(AppAssets.airpods, fit: BoxFit.fill),
          ),
          Container(
            color: Theme.of(context).cardColor,
            padding: EdgeInsets.only(
                bottom: AppLayout.getHeight(28.5),
                left: AppLayout.getWidth(8),
                right: AppLayout.getWidth(8)),
            child: Column(
              children: [
                Gap(AppLayout.getHeight(5)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Airpods lost at ..."),
                  ],
                ),
                Gap(AppLayout.getHeight(5)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconAndTextWidget(
                        icon: Icons.location_on,
                        text: "P001",
                        size: 15,
                        iconColor: Colors.black),
                    StatusWidget(
                      text: "Found",
                      color: Colors.grey,
                      height: AppLayout.getHeight(35),
                      width: AppLayout.getWidth(70),
                      fontSize: 15,
                    )
                  ],
                ),
                Gap(AppLayout.getHeight(15)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "2 day ago",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                )
              ],
            ),
          ),
          Spacer(),
          Container(
            child: AppButton(
                boxColor: AppColors.secondPrimaryColor,
                textButton: "Details",
                fontSize: 18,
                height: AppLayout.getHeight(30),
                width: AppLayout.getWidth(180),
                topLeft: 1,
                topRight: 1,
                onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => ItemsDetails()));
                }),
          )
        ],
      ),
    );
  }
}
