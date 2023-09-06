import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/utils/app_assets.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/utils/colors.dart';
import 'package:lost_and_find_app/widgets/app_text_field.dart';
import 'package:lost_and_find_app/widgets/app_text_filed_title.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Gap(AppLayout.getHeight(100)),
          Container(
            alignment: Alignment.center,
            child: Text(
              "Log In.",
              style: TextStyle(
                  fontSize: AppLayout.getHeight(50),
                  color: AppColors.titleColor,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Gap(AppLayout.getHeight(40)),
/*          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 20),
            child: Text("NAME",
                style: TextStyle(
                    fontSize: AppLayout.getHeight(20),
                    color: AppColors.titleColor,
                    fontWeight: FontWeight.bold)),
          ),
          Gap(AppLayout.getHeight(20)),
          AppTextField(textController: emailController, hintText: "")*/
          AppTextFieldTitle(textController: emailController, hintText: "", titleText: "NAME"),
          Gap(AppLayout.getHeight(80)),
          AppTextFieldTitle(textController: passwordController, hintText: "", titleText: "PASSWORD"),
        ],
      ),
    );
  }
}
