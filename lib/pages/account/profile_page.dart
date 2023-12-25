import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:lost_and_find_app/data/api/user/user_controller.dart';
import 'package:lost_and_find_app/pages/claims/item_claim_by_user.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/utils/colors.dart';
import 'package:lost_and_find_app/widgets/app_button.dart';
import 'package:lost_and_find_app/widgets/big_text.dart';
import 'package:lost_and_find_app/widgets/icon_and_text_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/api/auth/google_sign_in.dart';
import '../../utils/app_assets.dart';
import '../../utils/app_constraints.dart';
import 'edit_user_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}


class _ProfilePageState extends State<ProfilePage> {
  bool _isMounted = false;
  Map<String, dynamic> userList = {};
  final UserController userController= Get.put(UserController());
  late String verifyStatus = "";
  bool loadingFinished = false;
  Future<void> _refreshData() async {
    _isMounted = true;
    await userController.getUserByUid().then((result) {
      if (_isMounted) {
        setState(() {
          userList = result;
        });
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('verifyStatus', userList['verifyStatus'].toString());
  }

  Color _getVerifyStatusColor(String? verifyStatus) {
    switch (verifyStatus) {
      case 'NOT_VERIFIED':
        return Colors.grey; // Set the color for NOT_VERIFIED
      case 'WAITING_VERIFIED':
        return AppColors.secondPrimaryColor; // Set the color for WAITING_VERIFIED
      case 'VERIFIED':
        return AppColors.primaryColor; // Set the color for VERIFIED
      default:
        return Colors.grey; // Default color if the status is not recognized
    }
  }


  @override
  void initState() {
    super.initState();
    _isMounted = true;
    Future.delayed(Duration(seconds: 1), () async {
      await userController.getUserByUid().then((result) {
        if (_isMounted) {
          setState(() {
            userList = result;
          });
        }
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('verifyStatus', userList['verifyStatus'].toString());
      verifyStatus = await AppConstrants.getVerifyStatus();
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
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          child: Column(
            children: [
              userList.isNotEmpty ? Column(
                children: [
                  Gap(AppLayout.getHeight(70)),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context, MaterialPageRoute(builder: (context) => EditUserPage()));
                          },
                          child: Text("Edit", style: TextStyle(color: AppColors.primaryColor, fontSize: 20),),
                        )
                      ],
                    ),
                  ),
                  Gap(AppLayout.getHeight(30)),
                  CircleAvatar(
                    radius: 80,
                    backgroundImage:
                    NetworkImage(userList['avatar']),
                  ),
                  Gap(AppLayout.getHeight(30)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(userList['fullName']?? '-', style: Theme.of(context).textTheme.headlineMedium,),
                      verifyStatus == 'VERIFIED'? Icon(Icons.verified, color: AppColors.primaryColor,): Container()
                    ],
                  ),
                  Gap(AppLayout.getHeight(30)),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 30),
                    padding: EdgeInsets.only(top: AppLayout.getHeight(20), bottom: AppLayout.getHeight(20)),
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 4,
                              spreadRadius: 4,
                              offset: Offset(0, 4),
                              color: Colors.grey.withOpacity(0.2))
                        ]),
                    // color: Colors.red,
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding:  EdgeInsets.only(bottom: AppLayout.getHeight(8), left: AppLayout.getWidth(40)),
                          child: IconAndTextWidget(icon: Icons.email, text: userList['email']?? '-', iconColor: AppColors.secondPrimaryColor),
                        ),

                        Divider(color: Colors.grey,thickness: 1, indent: 30,endIndent: 30,),
                        Gap(AppLayout.getHeight(10)),

                        Padding(
                          padding: EdgeInsets.only(bottom: AppLayout.getHeight(8), left: AppLayout.getWidth(40)),
                          child: IconAndTextWidget(icon: FontAwesomeIcons.genderless, text: userList['gender'] ?? '-', iconColor: AppColors.secondPrimaryColor),

                        ),
                        Divider(color: Colors.grey,thickness: 1, indent: 30,endIndent: 30,),
                        Gap(AppLayout.getHeight(10)),

                        Padding(
                          padding: EdgeInsets.only(bottom: AppLayout.getHeight(8), left: AppLayout.getWidth(40)),
                          child: IconAndTextWidget(icon: Icons.phone, text: userList['phone']?? '-', iconColor: AppColors.secondPrimaryColor),
                        ),
                        Divider(color: Colors.grey,thickness: 1, indent: 30,endIndent: 30,),
                        Gap(AppLayout.getHeight(10)),

                        Padding(
                          padding: EdgeInsets.only(bottom: AppLayout.getHeight(8), left: AppLayout.getWidth(40)),
                          child: IconAndTextWidget(icon: Icons.house, text: userList['campus']['name']?? '-', iconColor: AppColors.secondPrimaryColor),
                        ),
                        Gap(AppLayout.getHeight(10)),

                        Divider(color: Colors.grey,thickness: 1, indent: 30,endIndent: 30,),
                        Padding(
                          padding: EdgeInsets.only(bottom: AppLayout.getHeight(8), left: AppLayout.getWidth(40)),
                          child: IconAndTextWidget(
                            icon: Icons.verified_user_outlined,
                            text: userList['verifyStatus']?? '-',
                            iconColor: AppColors.secondPrimaryColor,
                            textColor: _getVerifyStatusColor(userList['verifyStatus']),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ) :const Center(child: CircularProgressIndicator(),),

            ],
          ),
        ),
      ),
    );
  }
}
