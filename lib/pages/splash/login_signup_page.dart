import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/pages/auth/login_page.dart';
import 'package:lost_and_find_app/pages/auth/sign_up_page.dart';
import 'package:lost_and_find_app/utils/app_assets.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/utils/colors.dart';
import 'package:lost_and_find_app/widgets/app_button.dart';

class LoginSignupPage extends StatefulWidget {
  const LoginSignupPage({super.key});

  @override
  State<LoginSignupPage> createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Gap(AppLayout.getHeight(100)),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 80),
            child: Image.asset(
              AppAssets.fptLogo,
              fit: BoxFit.fitWidth,
            ),
          ),
          Gap(AppLayout.getHeight(160)),
          AppButton(
            boxColor: AppColors.primaryColor,
            textButton: "Log in",
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ),
          Gap(AppLayout.getHeight(45)),
          AppButton(
            boxColor: AppColors.primaryColor,
            textButton: "Sign up",
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => SignUpPage()));
            },
          ),
        ],
      ),
    );
  }
}
