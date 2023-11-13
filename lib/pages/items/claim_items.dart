import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lost_and_find_app/data/api/user/user_controller.dart';
import 'package:lost_and_find_app/utils/app_assets.dart';

import '../../data/api/item/claim_controller.dart';
import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/big_text.dart';

class ClaimItems extends StatefulWidget {
  final int pageId;
  final String page;
  const ClaimItems({Key? key, required this.pageId, required this.page}) : super(key: key);

  @override
  _ClaimItemsState createState() => _ClaimItemsState();
}

class _ClaimItemsState extends State<ClaimItems> {
  bool _isMounted = false;
  List<Map<String, dynamic>> userClaimList = [];
  final ClaimController claimController = Get.put(ClaimController());
  final Map<String, dynamic> userMap = {};
  final UserController userController = Get.put(UserController());

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    Future.delayed(Duration(seconds: 1), () async {
      await claimController.getListClaimByItemId(widget.pageId).then((result) async {
        if (_isMounted) {
          final userClaims = result as List<dynamic>;
          for (var claim in userClaims) {
            final userId = claim['userId'];
            final userMap = await userController.getUserByUserId(userId);
            final Map<String, dynamic> claimInfo = {
              'claim': claim,
              'user': userMap != null ? userMap : null, // Check if user is null
            };
            print("claimInfo:" + claimInfo.toString());
            setState(() {
              userClaimList.add(claimInfo);
            });
          }
        }
      });
    });
  }

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
          userClaimList.isNotEmpty ? ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: userClaimList.length,
            itemBuilder: (BuildContext context, int index) {
              final userClaimInfo = userClaimList[index];
              final claim = userClaimInfo['claim'];
              final user = userClaimInfo['user'];
              // print("user:" + user);
              return claim['claimStatus'] ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).cardColor,
                ),
                margin: EdgeInsets.only(
                    bottom: AppLayout.getHeight(20)),
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Container(
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(user['avatar']),
                        // backgroundImage: AssetImage(AppAssets.avatarDefault!),
                      ),
                    ),
                    Gap(AppLayout.getWidth(15)),
                    Column(
                      children: [
                        Text(user['fullName'] ?? "No Name"),
                        // const Text("Name"),
                        Gap(AppLayout.getHeight(10)),
                        Text(user['email'] ?? "No Email"),
                        // const Text("Email"),

                      ],
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Handle the tap event
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.secondPrimaryColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(FontAwesomeIcons.comment, color: Colors.white),
                            ),
                          ),
                        ),
                        Gap(AppLayout.getWidth(5)),
                        GestureDetector(
                          onTap: () async {
                            await claimController.accpectClaimByItemIdAndUserId(widget.pageId, claim['userId']);
                            final updatedClaims = await claimController.getListClaimByItemId(widget.pageId);
                            final updatedUserClaimList = <Map<String, dynamic>>[];
                            for (var claim in updatedClaims) {
                              final userId = claim['userId'];
                              final userMap = await userController.getUserByUserId(userId);
                              updatedUserClaimList.add({
                                'claim': claim,
                                'user': userMap != null ? userMap : null,
                              });
                            }

                            setState(() {
                              userClaimList = updatedUserClaimList;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryColor, // Set the desired color for the circular border
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0), // Adjust the padding as needed
                              child: Icon(FontAwesomeIcons.check, color: Colors.white), // You can set the color of the main icon
                            ),
                          ),

                        ),

                        Gap(AppLayout.getWidth(5)),
                        GestureDetector(
                          onTap: () async {
                            await claimController.denyClaimByItemIdAndUserId(widget.pageId, claim['userId']);
                            final updatedClaims = await claimController.getListClaimByItemId(widget.pageId);
                            final updatedUserClaimList = <Map<String, dynamic>>[];
                            for (var claim in updatedClaims) {
                              final userId = claim['userId'];
                              final userMap = await userController.getUserByUserId(userId);
                              updatedUserClaimList.add({
                                'claim': claim,
                                'user': userMap != null ? userMap : null,
                              });
                            }

                            setState(() {
                              userClaimList = updatedUserClaimList;
                            });


                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.redAccent,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(FontAwesomeIcons.xmark, color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ) : Container();
            },
          ) :Center(child: CircularProgressIndicator(),),
        ],
      ),
    );
  }
}
