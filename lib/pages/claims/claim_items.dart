import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lost_and_find_app/data/api/user/user_controller.dart';
import 'package:lost_and_find_app/utils/app_assets.dart';

import '../../data/api/item/claim_controller.dart';
import '../../data/api/message/Chat.dart';
import '../../data/api/message/chat_controller.dart';
import '../../routes/route_helper.dart';
import '../../utils/app_constraints.dart';
import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/big_text.dart';
import '../message/chat_page.dart';
import 'scan_qrcode.dart';

class ClaimItems extends StatefulWidget {
  final int pageId;
  final String itemUserId;
  final String page;
  const ClaimItems({Key? key, required this.pageId, required this.page, required this.itemUserId}) : super(key: key);

  @override
  _ClaimItemsState createState() => _ClaimItemsState();
}

class _ClaimItemsState extends State<ClaimItems> {
  bool _isMounted = false;
  List<Map<String, dynamic>> userClaimList = [];
  final ClaimController claimController = Get.put(ClaimController());
  final Map<String, dynamic> userMap = {};
  final UserController userController = Get.put(UserController());
  late String uid = "";

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    Future.delayed(Duration(seconds: 1), () async {
      uid = await AppConstrants.getUid();
      await claimController.getListClaimByItemId(widget.pageId).then((result) async {
        if (_isMounted) {
          final userClaims = result as List<dynamic>;
          for (var claim in userClaims) {
            final userId = claim['userId'];
            final userMap = await userController.getUserByUserId(userId);
            final Map<String, dynamic> claimInfo = {
              'claim': claim,
              'user': userMap != null ? userMap : null,
            };
            print("claimInfo:" + claimInfo.toString());
            setState(() {
              userClaimList.add(claimInfo);
            });
          }
        }
      }).whenComplete(() {
        if (_isMounted) {
          setState(() {
            if (userClaimList.isEmpty) {
              _isMounted = false;
            }
          });
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
          if (userClaimList.isNotEmpty)
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: userClaimList.length,
            itemBuilder: (BuildContext context, int index) {
              final userClaimInfo = userClaimList[index];
              final claim = userClaimInfo['claim'];
              final user = userClaimInfo['user'];
              // print("user:" + user);
              return claim['isActive'] ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).cardColor,
                ),
                margin: EdgeInsets.only(
                    bottom: AppLayout.getHeight(20)),
                padding: const EdgeInsets.all(11.0),
                child: Column(
                  children: [
                    Row(
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
                      ],
                    ),
                    Gap(AppLayout.getHeight(10)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            String otherUserId = user['id'];

                            await ChatController().createUserChats(uid, otherUserId);
                            String chatId = uid.compareTo(otherUserId) > 0 ? uid + otherUserId : otherUserId + uid;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  chat: Chat(
                                    uid: otherUserId,
                                    name: user['fullName'] ?? 'No Name',
                                    image: user['avatar'] ?? '',
                                    lastMessage: '', // You may want to pass initial message if needed
                                    time: '',
                                    chatId:chatId, // You may want to pass the chatId if needed
                                    formattedDate: '',
                                    otherId: otherUserId,
                                    date: DateTime.now(),
                                  ),
                                ),
                              ),
                            );
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
                            // await claimController.accpectClaimByItemIdAndUserId(widget.pageId, claim['userId']);
                            // final updatedClaims = await claimController.getListClaimByItemId(widget.pageId);
                            // final updatedUserClaimList = <Map<String, dynamic>>[];
                            // for (var claim in updatedClaims) {
                            //   final userId = claim['userId'];
                            //   final userMap = await userController.getUserByUserId(userId);
                            //   updatedUserClaimList.add({
                            //     'claim': claim,
                            //     'user': userMap != null ? userMap : null,
                            //   });
                            // }
                            //
                            // setState(() {
                            //   userClaimList = updatedUserClaimList;
                            // });
                            Future.delayed(Duration(seconds: 2), () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ScanQrCode(
                                    userClaimId: claim['userId'],
                                    itemUserId: widget.itemUserId,
                                    itemId: widget.pageId,),
                                ),
                              );
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
          )
          else if (userClaimList.isEmpty && !_isMounted)
            SizedBox(
              width: AppLayout.getScreenWidth(),
              height: AppLayout.getScreenHeight()-200,
              child: Center(
                child: Text("This item don't have any claims"),
              ),
            )
          else
            SizedBox(
              width: AppLayout.getWidth(100),
              height: AppLayout.getHeight(300),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
        ],
      ),
    );
  }
}
