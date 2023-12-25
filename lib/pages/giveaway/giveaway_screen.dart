import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/utils/app_assets.dart';

import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../widgets/big_text.dart';

class GiveawayScreen extends StatefulWidget {
  const GiveawayScreen({super.key});

  @override
  State<GiveawayScreen> createState() => _GiveawayScreenState();
}

class _GiveawayScreenState extends State<GiveawayScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Gap(AppLayout.getHeight(50)),
              Row(
                children: [
                  BigText(
                    text: "Giveaway",
                    size: 20,
                    color: AppColors.secondPrimaryColor,
                    fontW: FontWeight.w500,
                  ),
                ],
              ),
              ListView.builder(
                  shrinkWrap: true,
                  reverse: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  itemBuilder: (BuildContext context, int index) {

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).cardColor,
                      ),
                      margin: EdgeInsets.only(
                          bottom: AppLayout.getHeight(20)),
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "Title: Giveaway + ItemName",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium,
                            ),
                          ),
                          Gap(AppLayout.getHeight(20)),
                          Container(
                            height:
                            MediaQuery.of(context).size.height *
                                0.3,
                            child: ListView.builder(
                              padding: EdgeInsets.zero, // Add this line to set zero padding
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: 5,
                              itemBuilder: (context, indexs) {
                                return Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(
                                      left: AppLayout.getWidth(20)),
                                  height: AppLayout.getHeight(151),
                                  width: AppLayout.getWidth(180),
                                  child: Image.asset(AppAssets.airpods),
                                );
                              },
                            ),
                          ),
                          Gap(AppLayout.getHeight(20)),
                          
                          Container(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "Description",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),
                          ),
                          Gap(AppLayout.getHeight(20)),
                          Container(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "Start Date: 20/12/2023",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),
                          ),
                          Gap(AppLayout.getHeight(20)),
                          Container(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "End Date: 22/12/2023",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),
                          ),
                        ],
                      ),
                    );
                  })

            ],
          ),
        ),
      ),
    );
  }
}
