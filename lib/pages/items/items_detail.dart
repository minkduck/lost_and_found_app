import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/utils/app_assets.dart';
import 'package:lost_and_find_app/widgets/app_button.dart';
import 'package:lost_and_find_app/widgets/icon_and_text_widget.dart';
import 'package:lost_and_find_app/widgets/small_text.dart';
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // Align children to the left
            children: [
              Gap(AppLayout.getHeight(20)),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
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
                padding: EdgeInsets.only(
                    left: AppLayout.getWidth(30), top: AppLayout.getHeight(10)),
                child: Text('Items', style: Theme.of(context).textTheme.displayMedium,),
              ),
              Gap(AppLayout.getHeight(20)),
              Container(
                margin: EdgeInsets.only(left: 20),
                height: AppLayout.getHeight(350),
                width: AppLayout.getWidth(350),
                child: Image.asset(AppAssets.airpods, fit: BoxFit.fill),
              ),
              Gap(AppLayout.getHeight(20)),
              Container(
                  padding: EdgeInsets.only(left: AppLayout.getWidth(20)),
                  child: StatusWidget(text: "Found", color: Colors.grey)),
              Padding(
                padding: EdgeInsets.only(
                    left: AppLayout.getWidth(16), top: AppLayout.getHeight(16)),
                child: Text(
                  "Airpods lost at the libraries.",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              // time
              Container(
                  padding: EdgeInsets.only(
                      left: AppLayout.getWidth(16),
                      top: AppLayout.getHeight(8)),
                  child: IconAndTextWidget(
                      icon: Icons.timer_sharp,
                      text: "2 days ago",
                      iconColor: Colors.grey)),
              //location
              Container(
                  padding: EdgeInsets.only(
                      left: AppLayout.getWidth(16),
                      top: AppLayout.getHeight(8)),
                  child: IconAndTextWidget(
                      icon: Icons.location_on,
                      text: "Libraries",
                      iconColor: Colors.black)),
              //description
              Gap(AppLayout.getHeight(10)),
              Container(
                  padding: EdgeInsets.only(
                      left: AppLayout.getWidth(18),
                      top: AppLayout.getHeight(8)),
                  child: SmallText(
                    text: "Airpods lost at the libraries.",
                    size: 15,
                  )),
              //profile user
              Gap(AppLayout.getHeight(10)),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                        left: AppLayout.getWidth(16),
                        top: AppLayout.getHeight(8)),
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[500],
                      radius: 50,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(AppAssets.avatarDefault!),
                      ),
                    ),
                  ),
                  Gap(AppLayout.getHeight(50)),
                  Text("Nguyen Van A", style: TextStyle(fontSize: 20),)
                ],
              ),
              Gap(AppLayout.getHeight(40)),
              Center(
                  child: AppButton(boxColor: AppColors.secondPrimaryColor, textButton: "Send Message", onTap: () {})),
            ],
          ),
        ),
      ),
    );
  }
}
