import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:lost_and_find_app/data/api/auth/user_controller.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/utils/colors.dart';
import 'package:lost_and_find_app/widgets/big_text.dart';
import 'package:lost_and_find_app/widgets/icon_and_text_widget.dart';
import 'package:provider/provider.dart';

import '../../data/api/auth/google_sign_in.dart';
import '../../utils/app_assets.dart';
import 'edit_user_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}


class _AccountPageState extends State<AccountPage> {
  bool _isMounted = false;
  Map<String, dynamic> userList = {};
  final UserController userController= Get.put(UserController());

  Future<void> _refreshData() async {
    _isMounted = true;
    await userController.getUserByUid().then((result) {
      if (_isMounted) {
        setState(() {
          userList = result;
        });
      }
    });
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
    });

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
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
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
                  Text(userList['fullName']?? '-', style: Theme.of(context).textTheme.headlineMedium,),
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

                      ],
                    ),
                  ),
                  Gap(AppLayout.getHeight(150)),
                ],
              ) :const Center(child: CircularProgressIndicator(),),
              InkWell(
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
              )

            ],
          ),
        ),
      ),
    );
  }
}
/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/utils/colors.dart';
import 'package:lost_and_find_app/widgets/big_text.dart';
import 'package:lost_and_find_app/widgets/icon_and_text_widget.dart';
import 'package:provider/provider.dart';

import '../../data/api/auth/google_sign_in.dart';
import '../../utils/app_assets.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      body: Column(
        children: [
          Gap(AppLayout.getHeight(70)),
          CircleAvatar(
            radius: 80,
            backgroundImage:
            NetworkImage(user.photoURL!),
          ),
          Gap(AppLayout.getHeight(30)),
          Text(user.displayName!, style: Theme.of(context).textTheme.headlineMedium,),
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
                  padding: EdgeInsets.only(bottom: AppLayout.getHeight(8), left: AppLayout.getWidth(40)),
                  child: IconAndTextWidget(icon: Icons.account_box, text: user.displayName!, iconColor: AppColors.secondPrimaryColor),

                ),
                Divider(color: Colors.grey,thickness: 1, indent: 30,endIndent: 30,),
                Gap(AppLayout.getHeight(10)),

                Padding(
                  padding:  EdgeInsets.only(bottom: AppLayout.getHeight(8), left: AppLayout.getWidth(40)),
                  child: IconAndTextWidget(icon: Icons.email, text: user.email!, iconColor: AppColors.secondPrimaryColor),
                ),
                Divider(color: Colors.grey,thickness: 1, indent: 30,endIndent: 30,),
                Gap(AppLayout.getHeight(10)),

                Padding(
                  padding: EdgeInsets.only(bottom: AppLayout.getHeight(8), left: AppLayout.getWidth(40)),
                  child: IconAndTextWidget(icon: Icons.phone, text: "-", iconColor: AppColors.secondPrimaryColor),
                ),

              ],
            ),
          ),
          Gap(AppLayout.getHeight(150)),
          InkWell(
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
          )

        ],
      ),
    );
  }
}*/
