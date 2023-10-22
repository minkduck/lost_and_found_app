import 'package:firebase_auth/firebase_auth.dart';
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
}
