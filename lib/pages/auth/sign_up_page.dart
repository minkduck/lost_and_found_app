import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/widgets/app_button.dart';

import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../widgets/app_text_filed_title.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Gap(AppLayout.getHeight(100)),
            Container(
              alignment: Alignment.center,
              child: Text(
                "Sign Up.",
                style: TextStyle(
                    fontSize: 50,
                    color: AppColors.titleColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Gap(AppLayout.getHeight(40)),
            AppTextFieldTitle(
                textController: nameController,
                hintText: "",
                titleText: "NAME",
              validator: 'Please input name',
            ),
            Gap(AppLayout.getHeight(40)),
            AppTextFieldTitle(
                textController: emailController,
                hintText: "",
                titleText: "EMAIL",
              validator: 'Please input email',
            ),
            Gap(AppLayout.getHeight(40)),
            AppTextFieldTitle(
                textController: passwordController,
                hintText: "",
                titleText: "PASSWORD",
              validator: 'Please input password',
            ),
            Gap(AppLayout.getHeight(40)),
            AppTextFieldTitle(
                textController: phoneController,
                hintText: "",
                titleText: "PHONE",
              validator: 'Please input phone',
            ),
            Gap(AppLayout.getHeight(60)),
            AppButton(
                boxColor: AppColors.primaryColor,
                textButton: "Sign Up",
                onTap: () {}),
            Gap(AppLayout.getHeight(30)),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: RichText(
                text: TextSpan(
                    text: "Already have an account?",
                    style: TextStyle(
                        fontSize: 20,
                        color: AppColors.titleLSColor),
                    children: [
                      TextSpan(
                        text: " Sign in",
                        style: TextStyle(
                          fontSize: 20,
                          color: AppColors.secondPrimaryColor,
                          fontWeight: FontWeight.bold
                        )
                      )
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
