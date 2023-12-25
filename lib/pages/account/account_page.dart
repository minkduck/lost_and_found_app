import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lost_and_find_app/pages/account/my_list_bookmark.dart';
import 'package:lost_and_find_app/pages/account/my_list_notifications.dart';
import 'package:lost_and_find_app/pages/account/my_post_bookmark.dart';
import 'package:lost_and_find_app/pages/account/my_receipt_page.dart';
import 'package:lost_and_find_app/pages/account/profile_page.dart';
import 'package:lost_and_find_app/pages/account/verify_account.dart';
import 'package:provider/provider.dart';

import '../../data/api/auth/google_sign_in.dart';
import '../../data/api/user/user_controller.dart';
import '../../utils/app_constraints.dart';
import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../widgets/app_button.dart';
import '../claims/item_claim_by_user.dart';
import 'my_qr_code.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _isMounted = false;
  Map<String, dynamic> userList = {};
  final UserController userController= Get.put(UserController());
  late String verifyStatus = "";
  bool loadingFinished = false;

  void initState() {
    super.initState();
    _isMounted = true;
    Future.delayed(Duration(seconds: 1), () async {
      verifyStatus = await AppConstrants.getVerifyStatus();

      await userController.getUserByUid().then((result) {
        if (_isMounted) {
          setState(() {
            userList = result;
          });
        }
      });
      setState(() {
        loadingFinished = true;
      });
    });

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    loadingFinished = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            loadingFinished ? Column(
              children: [
                // userList.isNotEmpty ? Column(
                //   children: [
                //     Gap(AppLayout.getHeight(50)),
                //     Gap(AppLayout.getHeight(30)),
                //     Center(
                //       child: CircleAvatar(
                //         radius: 80,
                //         backgroundImage:
                //         NetworkImage(userList['avatar']),
                //       ),
                //     ),
                //   ],
                // ) :const Center(child: CircularProgressIndicator(),),
                Gap(AppLayout.getHeight(50)),
                Gap(AppLayout.getHeight(20)),
                Gap(AppLayout.getHeight(50)),
                Center(
                  child: AppButton(boxColor: AppColors.primaryColor, textButton: "Profile", onTap: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => ProfilePage()));

                  }),
                ),
                Gap(AppLayout.getHeight(50)),
                AppButton(boxColor: AppColors.primaryColor, textButton: "My QR Code", onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => MyQrCode()));

                }),
                Gap(AppLayout.getHeight(50)),
                AppButton(boxColor: AppColors.primaryColor, textButton: "My List Claim Item", onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => ItemClaimByUser()));

                }),
                Gap(AppLayout.getHeight(50)),
                AppButton(boxColor: AppColors.primaryColor, textButton: "My List Bookmark", onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => MyListBookmark()));

                }),
                Gap(AppLayout.getHeight(50)),
                AppButton(boxColor: AppColors.primaryColor, textButton: "My Receipt", onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => MyReceipt()));

                }),
                Gap(AppLayout.getHeight(50)),
                AppButton(boxColor: AppColors.primaryColor, textButton: "My List Notifications", onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => MyListNotifications()));

                }),
                Gap(AppLayout.getHeight(50)),
                verifyStatus == 'VERIFIED'? Container() : AppButton(boxColor: AppColors.secondPrimaryColor, textButton: "Verify Account", onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => VerifyAccount()));

                }) ,
                verifyStatus == 'VERIFIED'? Container() : Gap(AppLayout.getHeight(80)),
              ],
            ) : Center(child: CircularProgressIndicator(),),

            loadingFinished ? Container() : Gap(AppLayout.getHeight(300)),
            Padding(
              padding: EdgeInsets.only(bottom: 40.0),
              child: InkWell(
                onTap: () async {
                  final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
                  await provider.logout();
                },
                child: Ink(
                  width: AppLayout.getWidth(325),
                  height: AppLayout.getHeight(50),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor, // Set the color here
                    // borderRadius: BorderRadius.circular(AppLayout.getHeight(15)),
                    borderRadius: BorderRadius.all(Radius.circular(15)),

                    boxShadow: [
                      BoxShadow(
                          blurRadius: 4,
                          spreadRadius: 4,
                          offset: Offset(0, 4),
                          color: Colors.grey.withOpacity(0.2))
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "Log out",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 25,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
