import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/utils/colors.dart';
import 'package:lost_and_find_app/widgets/app_button.dart';
import 'package:provider/provider.dart';

import '../../data/api/auth/google_sign_in.dart';
import '../../utils/app_assets.dart';
import '../../utils/app_layout.dart';

class LoginGooglePage extends StatefulWidget {
  const LoginGooglePage({super.key});

  @override
  State<LoginGooglePage> createState() => _LoginGooglePageState();
}

class _LoginGooglePageState extends State<LoginGooglePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Gap(AppLayout.getHeight(200)),
            Container(
              alignment: Alignment.center,
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 80),
                child: Image.asset(
                  AppAssets.lostAndFound,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            Gap(AppLayout.getHeight(160)),

            InkWell(
              onTap: () {
                final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
                provider.googleLogin();
              },
              child: Ink(
                width: AppLayout.getWidth(325) ,
                height: AppLayout.getHeight(50),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor, // Set the color here
                  // borderRadius: BorderRadius.circular(AppLayout.getHeight(15)),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppLayout.getHeight(15)),
                      topRight: Radius.circular(AppLayout.getHeight(15)),
                      bottomLeft: Radius.circular(AppLayout.getHeight(15)),
                      bottomRight: Radius.circular(AppLayout.getHeight(15))),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AppAssets.googleLogo,
                        height: 24,
                        width: 24,
                      ),
                      SizedBox(width: 16),
                      Text(
                        'Sign in with Google',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
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
