import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/utils/app_assets.dart';

import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/big_text.dart';

class ClaimItems extends StatefulWidget {
  const ClaimItems({Key? key}) : super(key: key);

  @override
  _ClaimItemsState createState() => _ClaimItemsState();
}

class _ClaimItemsState extends State<ClaimItems> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Gap(AppLayout.getHeight(50)),
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
                text: "List Claim",
                size: 20,
                color: AppColors.secondPrimaryColor,
                fontW: FontWeight.w500,
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, builder) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).cardColor,
                  ),
                  margin: EdgeInsets.only(
                      bottom: AppLayout.getHeight(20)),
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage(AppAssets.avatarDefault!),
                      ),
                      Gap(AppLayout.getWidth(15)),
                      Column(
                        children: [
                          Text('Name'),
                          Gap(AppLayout.getHeight(10)),
                          Text('email')
                        ],
                      ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: (){

                            },
                            child: Container(
                              width: 70 ,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.secondPrimaryColor,
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  )
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  "Claim",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Gap(AppLayout.getWidth(5)),
                          InkWell(
                            onTap: (){

                            },
                            child: Container(
                              width: 70 ,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.redAccent, // Set the color here
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  )
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  "Decline",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          )

                        ],
                      )

                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
